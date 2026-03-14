#!/bin/bash
set -euo pipefail

# recon.sh — Deterministic project reconnaissance. No LLM involved.
# Usage: recon.sh [directory]
# Output: JSON to stdout with project analysis.

TARGET="${1:-.}"
TARGET=$(cd "$TARGET" && pwd)

# --- Language detection by file extension ---
declare -A lang_counts
declare -A ext_to_lang=(
    [py]=python [js]=javascript [ts]=typescript [tsx]=typescript [jsx]=javascript
    [go]=go [rs]=rust [java]=java [rb]=ruby [php]=php [cs]=csharp
    [swift]=swift [kt]=kotlin [scala]=scala [c]=c [cpp]=cpp [h]=c [hpp]=cpp
    [sh]=shell [bash]=shell [zsh]=shell
    [sql]=sql [r]=r [dart]=dart [lua]=lua [pl]=perl [ex]=elixir [exs]=elixir
)

while IFS= read -r ext; do
    lang="${ext_to_lang[$ext]:-}"
    if [ -n "$lang" ]; then
        lang_counts[$lang]=$(( ${lang_counts[$lang]:-0} + 1 ))
    fi
done < <(
    find "$TARGET" -type f \
        -not -path '*/node_modules/*' \
        -not -path '*/vendor/*' \
        -not -path '*/.git/*' \
        -not -path '*/__pycache__/*' \
        -not -path '*/dist/*' \
        -not -path '*/build/*' \
        -not -path '*/.venv/*' \
        -not -path '*/venv/*' \
        2>/dev/null | sed -n 's/.*\.\([a-zA-Z0-9]*\)$/\1/p'
)

total_files=0
for count in "${lang_counts[@]}"; do
    total_files=$((total_files + count))
done

# Build sorted languages array
languages_json="["
first=true
if [ "$total_files" -gt 0 ]; then
    # Sort by count descending
    while IFS='=' read -r lang count; do
        pct=$((count * 100 / total_files))
        if [ "$first" = true ]; then first=false; else languages_json+=","; fi
        languages_json+="{\"name\":\"$lang\",\"files\":$count,\"percentage\":$pct}"
    done < <(
        for lang in "${!lang_counts[@]}"; do
            echo "$lang=${lang_counts[$lang]}"
        done | sort -t= -k2 -nr
    )
fi
languages_json+="]"

# Primary language
primary_language="unknown"
max_count=0
for lang in "${!lang_counts[@]}"; do
    if [ "${lang_counts[$lang]}" -gt "$max_count" ]; then
        max_count=${lang_counts[$lang]}
        primary_language="$lang"
    fi
done

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

# --- Sensitive directories ---
sensitive_dirs_json="["
first=true
for dir_name in auth api middleware crypto admin config security secrets keys certs; do
    while IFS= read -r found_dir; do
        # Make relative to target
        rel_dir="${found_dir#$TARGET/}"
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
