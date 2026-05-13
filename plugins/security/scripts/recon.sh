#!/bin/bash
set -euo pipefail

# recon.sh — Deterministic project reconnaissance. No LLM involved.
# Usage: recon.sh [directory]
# Output: JSON to stdout with project analysis.

TARGET="${1:-.}"
TARGET=$(cd "$TARGET" && pwd)

# --- Language detection by file extension ---
lang_counts=$(
    find "$TARGET" -type f \
        -not -path '*/node_modules/*' \
        -not -path '*/vendor/*' \
        -not -path '*/.git/*' \
        -not -path '*/__pycache__/*' \
        -not -path '*/dist/*' \
        -not -path '*/build/*' \
        -not -path '*/.venv/*' \
        -not -path '*/venv/*' \
        2>/dev/null |
    awk '
        function lang_for(ext) {
            ext=tolower(ext)
            if (ext=="py") return "python"
            if (ext=="js" || ext=="jsx") return "javascript"
            if (ext=="ts" || ext=="tsx") return "typescript"
            if (ext=="go") return "go"
            if (ext=="rs") return "rust"
            if (ext=="java") return "java"
            if (ext=="rb") return "ruby"
            if (ext=="php") return "php"
            if (ext=="cs") return "csharp"
            if (ext=="swift") return "swift"
            if (ext=="kt") return "kotlin"
            if (ext=="scala") return "scala"
            if (ext=="c" || ext=="h") return "c"
            if (ext=="cpp" || ext=="hpp") return "cpp"
            if (ext=="sh" || ext=="bash" || ext=="zsh") return "shell"
            if (ext=="sql") return "sql"
            if (ext=="r") return "r"
            if (ext=="dart") return "dart"
            if (ext=="lua") return "lua"
            if (ext=="pl") return "perl"
            if (ext=="ex" || ext=="exs") return "elixir"
            return ""
        }
        {
            n=split($0, parts, ".")
            if (n > 1) {
                lang=lang_for(parts[n])
                if (lang != "") counts[lang]++
            }
        }
        END {
            for (lang in counts) print lang "=" counts[lang]
        }
    ' | sort -t= -k2 -nr
)

total_files=$(printf '%s\n' "$lang_counts" | awk -F= 'NF == 2 {sum += $2} END {print sum + 0}')

languages_json="["
first=true
if [ "$total_files" -gt 0 ]; then
    while IFS='=' read -r lang count; do
        [ -z "$lang" ] && continue
        pct=$((count * 100 / total_files))
        if [ "$first" = true ]; then first=false; else languages_json+=","; fi
        languages_json+="{\"name\":\"$lang\",\"files\":$count,\"percentage\":$pct}"
    done <<EOF_LANGS
$lang_counts
EOF_LANGS
fi
languages_json+="]"

primary_language=$(printf '%s\n' "$lang_counts" | awk -F= 'NF == 2 {print $1; exit}')
if [ -z "$primary_language" ]; then
    primary_language="unknown"
fi

# --- Framework detection ---
framework="unknown"

# Python frameworks
if [ -f "$TARGET/requirements.txt" ] || [ -f "$TARGET/setup.py" ] || [ -f "$TARGET/pyproject.toml" ]; then
    for depfile in "$TARGET/requirements.txt" "$TARGET/setup.py" "$TARGET/pyproject.toml" "$TARGET/Pipfile"; do
        if [ -f "$depfile" ]; then
            if grep -qi 'django' "$depfile" 2>/dev/null; then framework="django"; break; fi
            if grep -qi 'fastapi' "$depfile" 2>/dev/null; then framework="fastapi"; break; fi
            if grep -qi 'flask' "$depfile" 2>/dev/null; then framework="flask"; break; fi
        fi
    done
fi

# JavaScript/TypeScript frameworks
if [ -f "$TARGET/package.json" ]; then
    pkg="$TARGET/package.json"
    if grep -q '"next"' "$pkg" 2>/dev/null; then framework="nextjs"
    elif grep -q '"react"' "$pkg" 2>/dev/null; then framework="react"
    elif grep -q '"express"' "$pkg" 2>/dev/null; then framework="express"
    elif grep -q '"fastify"' "$pkg" 2>/dev/null; then framework="fastify"
    elif grep -q '"vue"' "$pkg" 2>/dev/null; then framework="vue"
    elif grep -q '"@angular/core"' "$pkg" 2>/dev/null; then framework="angular"
    fi
fi

# Go frameworks
if [ -f "$TARGET/go.mod" ]; then
    if grep -q 'gin-gonic/gin' "$TARGET/go.mod" 2>/dev/null; then framework="gin"
    elif grep -q 'labstack/echo' "$TARGET/go.mod" 2>/dev/null; then framework="echo"
    elif grep -q 'go-chi/chi' "$TARGET/go.mod" 2>/dev/null; then framework="chi"
    elif grep -q 'gorilla/mux' "$TARGET/go.mod" 2>/dev/null; then framework="gorilla-mux"
    fi
fi

# --- LOC estimate ---
loc_estimate=0
loc_estimate=$(find "$TARGET" -type f \
    \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' \
       -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.rb' -o -name '*.php' \
       -o -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.cs' -o -name '*.swift' \
       -o -name '*.kt' -o -name '*.sh' \) \
    -not -path '*/node_modules/*' \
    -not -path '*/vendor/*' \
    -not -path '*/.git/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.venv/*' \
    -not -path '*/venv/*' \
    -print0 2>/dev/null | xargs -0 wc -l 2>/dev/null | tail -1 | awk '{print $1}') || loc_estimate=0
if [ -z "$loc_estimate" ]; then
    loc_estimate=0
fi

# --- Sensitive directories ---
sensitive_dirs_json="["
first=true
for dir_name in auth api middleware crypto admin config security secrets keys certs; do
    while IFS= read -r found_dir; do
        # Make relative to target
        if [ "$found_dir" = "$TARGET" ]; then
            rel_dir="."
        else
            rel_dir="${found_dir#$TARGET/}"
        fi
        if [ "$first" = true ]; then first=false; else sensitive_dirs_json+=","; fi
        sensitive_dirs_json+="\"$rel_dir\""
    done < <(find "$TARGET" -type d -name "$dir_name" \
        -not -path '*/node_modules/*' \
        -not -path '*/vendor/*' \
        -not -path '*/.git/*' \
        2>/dev/null || true)
done
sensitive_dirs_json+="]"

# --- Docker ---
has_docker=false
if [ -f "$TARGET/Dockerfile" ] || [ -f "$TARGET/docker-compose.yml" ] || [ -f "$TARGET/docker-compose.yaml" ]; then
    has_docker=true
fi
# Check subdirectories one level deep
if [ "$has_docker" = false ]; then
    if find "$TARGET" -maxdepth 2 -name 'Dockerfile' -print -quit 2>/dev/null | grep -q .; then
        has_docker=true
    fi
fi

# --- CI ---
has_ci=false
if [ -d "$TARGET/.github/workflows" ] || [ -f "$TARGET/.gitlab-ci.yml" ] || [ -d "$TARGET/.circleci" ] || [ -f "$TARGET/Jenkinsfile" ] || [ -f "$TARGET/.travis.yml" ]; then
    has_ci=true
fi

# --- Dependency files ---
dep_files_json="["
first=true
for dep in package.json go.mod go.sum requirements.txt Pipfile pyproject.toml setup.py Cargo.toml Gemfile pom.xml build.gradle composer.json; do
    if [ -f "$TARGET/$dep" ]; then
        if [ "$first" = true ]; then first=false; else dep_files_json+=","; fi
        dep_files_json+="\"$dep\""
    fi
done
dep_files_json+="]"

# --- App type signals ---
signals_json="["
first=true
add_signal() {
    if [ "$first" = true ]; then first=false; else signals_json+=","; fi
    signals_json+="\"$1\""
}

# Check for HTTP handlers
if find "$TARGET" -type f \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.go' \) \
    -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' \
    -print0 2>/dev/null | xargs -0 grep -lE '(@app\.(get|post|put|delete|route)|router\.(get|post|put)|app\.(get|post|use)|http\.Handle|func.*Handler)' 2>/dev/null | head -1 | grep -q .; then
    add_signal "http_handlers"
fi

# Check for HTML templates
if find "$TARGET" -type f \( -name '*.html' -o -name '*.ejs' -o -name '*.hbs' -o -name '*.jinja2' -o -name '*.tmpl' \) \
    -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' \
    2>/dev/null | head -1 | grep -q .; then
    add_signal "html_templates"
else
    add_signal "no_html_templates"
fi

# Check for database usage
if find "$TARGET" -type f \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.go' \) \
    -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' \
    -print0 2>/dev/null | xargs -0 grep -lE '(SELECT|INSERT|UPDATE|DELETE|CREATE TABLE|mongoose|sequelize|sqlalchemy|gorm|prisma)' 2>/dev/null | head -1 | grep -q .; then
    add_signal "database_usage"
fi

# Check for auth patterns
if find "$TARGET" -type f \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.go' \) \
    -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' \
    -print0 2>/dev/null | xargs -0 grep -lE '(jwt|oauth|passport|bcrypt|argon2|authenticate|authorization)' 2>/dev/null | head -1 | grep -q .; then
    add_signal "auth_patterns"
fi

signals_json+="]"

# --- Output ---
cat <<EOF
{
  "languages": $languages_json,
  "primary_language": "$primary_language",
  "framework": "$framework",
  "loc_estimate": $loc_estimate,
  "sensitive_dirs": $sensitive_dirs_json,
  "has_docker": $has_docker,
  "has_ci": $has_ci,
  "dependency_files": $dep_files_json,
  "app_type_signals": $signals_json
}
EOF
