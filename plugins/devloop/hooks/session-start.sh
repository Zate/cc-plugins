#!/bin/bash
# Feature-dev SessionStart hook
# Detects project language, framework, and test framework
# Sets environment variables for use by agents

set -euo pipefail

# Detect primary project language
detect_language() {
    # Check for Go
    if [ -f "go.mod" ] || [ -f "go.sum" ]; then
        echo "go"
        return
    fi

    # Check for TypeScript/JavaScript
    if [ -f "package.json" ]; then
        if [ -f "tsconfig.json" ] || grep -q '"typescript"' package.json 2>/dev/null; then
            echo "typescript"
        else
            echo "javascript"
        fi
        return
    fi

    # Check for Java
    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "java"
        return
    fi

    # Check for Python
    if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
        echo "python"
        return
    fi

    # Check for Rust
    if [ -f "Cargo.toml" ]; then
        echo "rust"
        return
    fi

    # Check for Ruby
    if [ -f "Gemfile" ]; then
        echo "ruby"
        return
    fi

    # Check by file extension prevalence
    local go_count=$(find . -maxdepth 3 -name "*.go" 2>/dev/null | wc -l | tr -d ' ')
    local ts_count=$(find . -maxdepth 3 -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l | tr -d ' ')
    local js_count=$(find . -maxdepth 3 -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l | tr -d ' ')
    local java_count=$(find . -maxdepth 3 -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
    local py_count=$(find . -maxdepth 3 -name "*.py" 2>/dev/null | wc -l | tr -d ' ')

    # Find the max
    local max=$go_count
    local lang="go"

    if [ "$ts_count" -gt "$max" ]; then max=$ts_count; lang="typescript"; fi
    if [ "$js_count" -gt "$max" ]; then max=$js_count; lang="javascript"; fi
    if [ "$java_count" -gt "$max" ]; then max=$java_count; lang="java"; fi
    if [ "$py_count" -gt "$max" ]; then max=$py_count; lang="python"; fi

    if [ "$max" -gt 0 ]; then
        echo "$lang"
    else
        echo "unknown"
    fi
}

# Detect framework based on language
detect_framework() {
    local lang=$1

    case "$lang" in
        typescript|javascript)
            if [ -f "package.json" ]; then
                # Check for React
                if grep -q '"react"' package.json 2>/dev/null; then
                    # Check for Next.js
                    if grep -q '"next"' package.json 2>/dev/null; then
                        echo "nextjs"
                    else
                        echo "react"
                    fi
                    return
                fi
                # Check for Vue
                if grep -q '"vue"' package.json 2>/dev/null; then
                    echo "vue"
                    return
                fi
                # Check for Angular
                if grep -q '"@angular/core"' package.json 2>/dev/null; then
                    echo "angular"
                    return
                fi
                # Check for Express
                if grep -q '"express"' package.json 2>/dev/null; then
                    echo "express"
                    return
                fi
                # Check for NestJS
                if grep -q '"@nestjs/core"' package.json 2>/dev/null; then
                    echo "nestjs"
                    return
                fi
            fi
            ;;
        java)
            if [ -f "pom.xml" ]; then
                if grep -q "spring-boot" pom.xml 2>/dev/null; then
                    echo "spring-boot"
                    return
                fi
                if grep -q "spring" pom.xml 2>/dev/null; then
                    echo "spring"
                    return
                fi
            fi
            if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
                if grep -q "spring" build.gradle* 2>/dev/null; then
                    echo "spring-boot"
                    return
                fi
            fi
            ;;
        python)
            if [ -f "requirements.txt" ]; then
                if grep -q "django" requirements.txt 2>/dev/null; then
                    echo "django"
                    return
                fi
                if grep -q "flask" requirements.txt 2>/dev/null; then
                    echo "flask"
                    return
                fi
                if grep -q "fastapi" requirements.txt 2>/dev/null; then
                    echo "fastapi"
                    return
                fi
            fi
            if [ -f "pyproject.toml" ]; then
                if grep -q "django" pyproject.toml 2>/dev/null; then
                    echo "django"
                    return
                fi
                if grep -q "fastapi" pyproject.toml 2>/dev/null; then
                    echo "fastapi"
                    return
                fi
            fi
            ;;
        go)
            # Check for common Go frameworks
            if [ -f "go.mod" ]; then
                if grep -q "gin-gonic" go.mod 2>/dev/null; then
                    echo "gin"
                    return
                fi
                if grep -q "labstack/echo" go.mod 2>/dev/null; then
                    echo "echo"
                    return
                fi
                if grep -q "gofiber/fiber" go.mod 2>/dev/null; then
                    echo "fiber"
                    return
                fi
                if grep -q "go-chi/chi" go.mod 2>/dev/null; then
                    echo "chi"
                    return
                fi
                if grep -q "gorilla/mux" go.mod 2>/dev/null; then
                    echo "gorilla"
                    return
                fi
                if grep -q "beego" go.mod 2>/dev/null; then
                    echo "beego"
                    return
                fi
                if grep -q "gobuffalo/buffalo" go.mod 2>/dev/null; then
                    echo "buffalo"
                    return
                fi
            fi
            ;;
    esac

    echo "none"
}

# Detect test framework
detect_test_framework() {
    local lang=$1

    case "$lang" in
        typescript|javascript)
            if [ -f "package.json" ]; then
                if grep -q '"jest"' package.json 2>/dev/null; then
                    echo "jest"
                    return
                fi
                if grep -q '"vitest"' package.json 2>/dev/null; then
                    echo "vitest"
                    return
                fi
                if grep -q '"mocha"' package.json 2>/dev/null; then
                    echo "mocha"
                    return
                fi
                if grep -q '"playwright"' package.json 2>/dev/null; then
                    echo "playwright"
                    return
                fi
                if grep -q '"cypress"' package.json 2>/dev/null; then
                    echo "cypress"
                    return
                fi
            fi
            ;;
        go)
            echo "go-test"
            return
            ;;
        java)
            if [ -f "pom.xml" ]; then
                if grep -q "junit" pom.xml 2>/dev/null; then
                    echo "junit"
                    return
                fi
            fi
            if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
                if grep -q "junit" build.gradle* 2>/dev/null; then
                    echo "junit"
                    return
                fi
            fi
            echo "junit"
            return
            ;;
        python)
            if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
                if [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null; then
                    echo "pytest"
                    return
                fi
                if [ -f "pytest.ini" ]; then
                    echo "pytest"
                    return
                fi
            fi
            if [ -f "requirements.txt" ] && grep -q "pytest" requirements.txt 2>/dev/null; then
                echo "pytest"
                return
            fi
            echo "unittest"
            return
            ;;
        rust)
            echo "cargo-test"
            return
            ;;
        ruby)
            if [ -f "Gemfile" ] && grep -q "rspec" Gemfile 2>/dev/null; then
                echo "rspec"
                return
            fi
            echo "minitest"
            return
            ;;
    esac

    echo "unknown"
}

# Detect project type (frontend, backend, fullstack, cli, library)
detect_project_type() {
    local lang=$1
    local framework=$2

    # Check for CLI indicators
    if [ -d "cmd" ] || [ -f "main.go" ] && grep -q "cobra\|urfave/cli" go.mod 2>/dev/null; then
        echo "cli"
        return
    fi

    # Frontend frameworks
    if [ "$framework" = "react" ] || [ "$framework" = "vue" ] || [ "$framework" = "angular" ]; then
        # Check if it's a full-stack app
        if [ -d "server" ] || [ -d "api" ] || [ -d "backend" ]; then
            echo "fullstack"
        else
            echo "frontend"
        fi
        return
    fi

    # Next.js is typically fullstack
    if [ "$framework" = "nextjs" ]; then
        echo "fullstack"
        return
    fi

    # Backend frameworks
    if [ "$framework" = "express" ] || [ "$framework" = "nestjs" ] || [ "$framework" = "spring-boot" ] || \
       [ "$framework" = "spring" ] || [ "$framework" = "django" ] || [ "$framework" = "flask" ] || \
       [ "$framework" = "fastapi" ] || [ "$framework" = "gin" ] || [ "$framework" = "echo" ] || \
       [ "$framework" = "fiber" ] || [ "$framework" = "chi" ] || [ "$framework" = "gorilla" ] || \
       [ "$framework" = "beego" ] || [ "$framework" = "buffalo" ]; then
        # Check for frontend
        if [ -d "frontend" ] || [ -d "client" ] || [ -d "web" ]; then
            echo "fullstack"
        else
            echo "backend"
        fi
        return
    fi

    # Check for library indicators
    if [ -f "setup.py" ] || [ -f "Cargo.toml" ] && grep -q '\[lib\]' Cargo.toml 2>/dev/null; then
        echo "library"
        return
    fi

    echo "unknown"
}

# Main execution
LANGUAGE=$(detect_language)
FRAMEWORK=$(detect_framework "$LANGUAGE")
TEST_FRAMEWORK=$(detect_test_framework "$LANGUAGE")
PROJECT_TYPE=$(detect_project_type "$LANGUAGE" "$FRAMEWORK")

# Write to environment file if available
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    echo "export FEATURE_DEV_PROJECT_LANGUAGE=$LANGUAGE" >> "$CLAUDE_ENV_FILE"
    echo "export FEATURE_DEV_FRAMEWORK=$FRAMEWORK" >> "$CLAUDE_ENV_FILE"
    echo "export FEATURE_DEV_TEST_FRAMEWORK=$TEST_FRAMEWORK" >> "$CLAUDE_ENV_FILE"
    echo "export FEATURE_DEV_PROJECT_TYPE=$PROJECT_TYPE" >> "$CLAUDE_ENV_FILE"
fi

# Output for Claude (JSON format for system message)
cat <<EOF
{
  "systemMessage": "Feature-dev context loaded: Language=$LANGUAGE, Framework=$FRAMEWORK, Tests=$TEST_FRAMEWORK, Type=$PROJECT_TYPE"
}
EOF

exit 0
