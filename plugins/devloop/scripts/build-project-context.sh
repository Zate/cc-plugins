#!/bin/bash
# build-project-context.sh
# Detects project tech stack and generates .claude/project-context.json
#
# Usage: ${CLAUDE_PLUGIN_ROOT}/scripts/build-project-context.sh [project_dir]
#
# If no project_dir is provided, uses the current directory.

PROJECT_DIR="${1:-.}"

# Prefer .devloop/ for output, fallback to .claude/ if it exists and .devloop/ doesn't
if [ -d "${PROJECT_DIR}/.devloop" ] || [ ! -d "${PROJECT_DIR}/.claude" ]; then
    OUTPUT_FILE="${PROJECT_DIR}/.devloop/context.json"
    mkdir -p "${PROJECT_DIR}/.devloop"
else
    # Legacy location for existing projects
    OUTPUT_FILE="${PROJECT_DIR}/.claude/project-context.json"
    mkdir -p "${PROJECT_DIR}/.claude"
fi

# Initialize variables
LANGUAGES=""
FRAMEWORKS=""
PROJECT_NAME=$(basename "$(cd "$PROJECT_DIR" && pwd)")
PROJECT_TYPE="other"

# Feature detection flags
HAS_AUTH=false
HAS_OAUTH=false
HAS_FILE_UPLOAD=false
HAS_WEBSOCKETS=false
HAS_DATABASE=false
HAS_API=false
HAS_GRAPHQL=false
HAS_PAYMENTS=false
HAS_EMAIL=false
HAS_LOGGING=false

# Directory detection
SOURCE_DIR=""
TESTS_DIR=""
CONFIG_DIR=""

# Security notes
SECURITY_NOTES=""

# ============================================================================
# Helper Functions
# ============================================================================

add_language() {
    if [[ -z "$LANGUAGES" ]]; then
        LANGUAGES="$1"
    elif [[ "$LANGUAGES" != *"$1"* ]]; then
        LANGUAGES="$LANGUAGES,$1"
    fi
}

add_framework() {
    if [[ -z "$FRAMEWORKS" ]]; then
        FRAMEWORKS="$1"
    elif [[ "$FRAMEWORKS" != *"$1"* ]]; then
        FRAMEWORKS="$FRAMEWORKS,$1"
    fi
}

add_security_note() {
    if [[ -z "$SECURITY_NOTES" ]]; then
        SECURITY_NOTES="$1"
    else
        SECURITY_NOTES="$SECURITY_NOTES|$1"
    fi
}

file_exists() {
    [[ -f "${PROJECT_DIR}/$1" ]]
}

dir_exists() {
    [[ -d "${PROJECT_DIR}/$1" ]]
}

# Simplified has_files - checks top 3 levels for speed
has_files() {
    local pattern="$1"
    local dir="$PROJECT_DIR"
    # Use compgen for reliable glob expansion
    compgen -G "$dir"/$pattern > /dev/null 2>&1 && return 0
    compgen -G "$dir"/*/$pattern > /dev/null 2>&1 && return 0
    compgen -G "$dir"/*/*/$pattern > /dev/null 2>&1 && return 0
    return 1
}

grep_file() {
    local pattern="$1"
    local file="$2"
    grep -q "$pattern" "${PROJECT_DIR}/$file" 2>/dev/null
}

# ============================================================================
# Language Detection
# ============================================================================

detect_languages() {
    # TypeScript
    if file_exists "tsconfig.json" || has_files "*.ts"; then
        add_language "typescript"
    fi

    # JavaScript
    if file_exists "package.json" || has_files "*.js"; then
        add_language "javascript"
    fi

    # Python
    if file_exists "requirements.txt" || file_exists "pyproject.toml" || file_exists "setup.py"; then
        add_language "python"
    fi

    # Go
    if file_exists "go.mod"; then
        add_language "go"
    fi

    # Rust
    if file_exists "Cargo.toml"; then
        add_language "rust"
    fi

    # Java
    if file_exists "pom.xml" || file_exists "build.gradle" || file_exists "build.gradle.kts"; then
        add_language "java"
    fi

    # Ruby
    if file_exists "Gemfile"; then
        add_language "ruby"
    fi

    # PHP
    if file_exists "composer.json"; then
        add_language "php"
    fi

    # Shell (for plugin repositories)
    if has_files "*.sh"; then
        add_language "shell"
    fi
}

# ============================================================================
# Framework Detection
# ============================================================================

detect_node_frameworks() {
    if ! file_exists "package.json"; then
        return
    fi

    local pkg="${PROJECT_DIR}/package.json"

    # Backend frameworks
    grep -q '"express"' "$pkg" 2>/dev/null && add_framework "express"
    grep -q '"fastify"' "$pkg" 2>/dev/null && add_framework "fastify"
    grep -q '"koa"' "$pkg" 2>/dev/null && add_framework "koa"
    grep -q '"nest' "$pkg" 2>/dev/null && add_framework "nestjs"

    # Frontend frameworks
    grep -q '"next"' "$pkg" 2>/dev/null && add_framework "nextjs"
    grep -q '"react"' "$pkg" 2>/dev/null && add_framework "react"
    grep -q '"vue"' "$pkg" 2>/dev/null && add_framework "vue"
    grep -q '"@angular/core"' "$pkg" 2>/dev/null && add_framework "angular"
    grep -q '"svelte"' "$pkg" 2>/dev/null && add_framework "svelte"

    # ORMs and database
    grep -q '"prisma"' "$pkg" 2>/dev/null && add_framework "prisma"
    grep -q '"typeorm"' "$pkg" 2>/dev/null && add_framework "typeorm"
    grep -q '"sequelize"' "$pkg" 2>/dev/null && add_framework "sequelize"
    grep -q '"mongoose"' "$pkg" 2>/dev/null && add_framework "mongoose"

    # Testing
    grep -q '"jest"' "$pkg" 2>/dev/null && add_framework "jest"
    grep -q '"mocha"' "$pkg" 2>/dev/null && add_framework "mocha"
    grep -q '"vitest"' "$pkg" 2>/dev/null && add_framework "vitest"
}

detect_python_frameworks() {
    local req=""
    if file_exists "requirements.txt"; then
        req="${PROJECT_DIR}/requirements.txt"
    elif file_exists "pyproject.toml"; then
        req="${PROJECT_DIR}/pyproject.toml"
    else
        return
    fi

    grep -qi "django" "$req" 2>/dev/null && add_framework "django"
    grep -qi "flask" "$req" 2>/dev/null && add_framework "flask"
    grep -qi "fastapi" "$req" 2>/dev/null && add_framework "fastapi"
    grep -qi "sqlalchemy" "$req" 2>/dev/null && add_framework "sqlalchemy"
    grep -qi "pytest" "$req" 2>/dev/null && add_framework "pytest"
}

detect_go_frameworks() {
    if ! file_exists "go.mod"; then
        return
    fi

    local gomod="${PROJECT_DIR}/go.mod"

    grep -q "gin-gonic/gin" "$gomod" 2>/dev/null && add_framework "gin"
    grep -q "gofiber/fiber" "$gomod" 2>/dev/null && add_framework "fiber"
    grep -q "labstack/echo" "$gomod" 2>/dev/null && add_framework "echo"
    grep -q "gorm.io/gorm" "$gomod" 2>/dev/null && add_framework "gorm"
}

detect_java_frameworks() {
    if file_exists "pom.xml"; then
        local pom="${PROJECT_DIR}/pom.xml"
        grep -q "spring-boot" "$pom" 2>/dev/null && add_framework "spring-boot"
    fi

    if file_exists "build.gradle" || file_exists "build.gradle.kts"; then
        local gradle="${PROJECT_DIR}/build.gradle"
        [[ -f "${PROJECT_DIR}/build.gradle.kts" ]] && gradle="${PROJECT_DIR}/build.gradle.kts"
        grep -q "spring" "$gradle" 2>/dev/null && add_framework "spring-boot"
    fi
}

detect_ruby_frameworks() {
    if ! file_exists "Gemfile"; then
        return
    fi

    local gemfile="${PROJECT_DIR}/Gemfile"

    grep -q "rails" "$gemfile" 2>/dev/null && add_framework "rails"
    grep -q "sinatra" "$gemfile" 2>/dev/null && add_framework "sinatra"
}

detect_php_frameworks() {
    if ! file_exists "composer.json"; then
        return
    fi

    local composer="${PROJECT_DIR}/composer.json"

    grep -q "laravel/framework" "$composer" 2>/dev/null && add_framework "laravel"
    grep -q "symfony/" "$composer" 2>/dev/null && add_framework "symfony"
}

detect_frameworks() {
    detect_node_frameworks
    detect_python_frameworks
    detect_go_frameworks
    detect_java_frameworks
    detect_ruby_frameworks
    detect_php_frameworks
}

# ============================================================================
# Feature Detection
# ============================================================================

detect_features() {
    # Authentication
    if file_exists "package.json"; then
        local pkg="${PROJECT_DIR}/package.json"
        grep -qE '"(passport|jsonwebtoken|bcrypt|argon2|express-session)"' "$pkg" 2>/dev/null && HAS_AUTH=true
        grep -qE '"(passport-oauth|passport-google|passport-github|openid-client)"' "$pkg" 2>/dev/null && HAS_OAUTH=true
        grep -qE '"(multer|formidable|busboy)"' "$pkg" 2>/dev/null && HAS_FILE_UPLOAD=true
        grep -qE '"(socket\.io|ws|websocket)"' "$pkg" 2>/dev/null && HAS_WEBSOCKETS=true
        grep -qE '"(pg|mysql|mysql2|mongodb|mongoose|prisma|typeorm|sequelize|sqlite)"' "$pkg" 2>/dev/null && HAS_DATABASE=true
        grep -qE '"(apollo-server|graphql|@graphql)"' "$pkg" 2>/dev/null && HAS_GRAPHQL=true
        grep -qE '"(stripe|paypal|braintree)"' "$pkg" 2>/dev/null && HAS_PAYMENTS=true
        grep -qE '"(nodemailer|sendgrid|mailgun)"' "$pkg" 2>/dev/null && HAS_EMAIL=true
        grep -qE '"(winston|bunyan|pino|morgan)"' "$pkg" 2>/dev/null && HAS_LOGGING=true
    fi

    # API detection (routes, controllers)
    if dir_exists "routes" || dir_exists "api" || dir_exists "controllers"; then
        HAS_API=true
    fi

    # Add security notes for high-risk features
    [[ "$HAS_PAYMENTS" == "true" ]] && add_security_note "Payment processing detected - PCI DSS considerations apply"
    [[ "$HAS_FILE_UPLOAD" == "true" ]] && add_security_note "File uploads detected - validate types and scan for malware"
    [[ "$HAS_AUTH" == "true" ]] && add_security_note "Authentication detected - review credential storage and session management"
    [[ "$HAS_DATABASE" == "true" ]] && add_security_note "Database access detected - review for SQL injection and data protection"
}

# ============================================================================
# Directory Detection
# ============================================================================

detect_directories() {
    # Source directories
    for dir in "src" "lib" "app" "source" "pkg"; do
        if dir_exists "$dir"; then
            SOURCE_DIR="$dir/"
            break
        fi
    done

    # Test directories
    for dir in "tests" "test" "__tests__" "spec" "specs"; do
        if dir_exists "$dir"; then
            TESTS_DIR="$dir/"
            break
        fi
    done

    # Config directories
    for dir in "config" "configs" "conf" ".config"; do
        if dir_exists "$dir"; then
            CONFIG_DIR="$dir/"
            break
        fi
    done
}

# ============================================================================
# Project Type Classification
# ============================================================================

detect_project_type() {
    # CLI detection
    if file_exists "package.json"; then
        grep -q '"bin"' "${PROJECT_DIR}/package.json" 2>/dev/null && PROJECT_TYPE="cli" && return
    fi

    # Library detection
    if file_exists "package.json"; then
        if grep -q '"main"' "${PROJECT_DIR}/package.json" 2>/dev/null && \
           ! grep -q '"start"' "${PROJECT_DIR}/package.json" 2>/dev/null; then
            PROJECT_TYPE="library"
            return
        fi
    fi

    # Mobile detection
    if file_exists "app.json" || file_exists "expo.json" || dir_exists "ios" || dir_exists "android"; then
        PROJECT_TYPE="mobile"
        return
    fi

    # Web app vs API based on frameworks
    if [[ "$FRAMEWORKS" == *"react"* || "$FRAMEWORKS" == *"vue"* || "$FRAMEWORKS" == *"angular"* || "$FRAMEWORKS" == *"svelte"* ]]; then
        if [[ "$FRAMEWORKS" == *"express"* || "$FRAMEWORKS" == *"fastify"* ]]; then
            PROJECT_TYPE="web-app"
        else
            PROJECT_TYPE="web-app"
        fi
    elif [[ "$FRAMEWORKS" == *"express"* || "$FRAMEWORKS" == *"fastify"* || "$FRAMEWORKS" == *"django"* || "$FRAMEWORKS" == *"flask"* || "$FRAMEWORKS" == *"fastapi"* || "$FRAMEWORKS" == *"gin"* || "$FRAMEWORKS" == *"spring"* || "$FRAMEWORKS" == *"rails"* || "$FRAMEWORKS" == *"laravel"* ]]; then
        PROJECT_TYPE="web-api"
    fi

    # Plugin detection (for Claude Code plugins)
    if dir_exists ".claude-plugin" || dir_exists "plugins"; then
        PROJECT_TYPE="plugin"
    fi
}

# ============================================================================
# JSON Output
# ============================================================================

generate_json() {
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Convert comma-separated strings to JSON arrays
    local langs_json="[]"
    if [[ -n "$LANGUAGES" ]]; then
        langs_json=$(echo "$LANGUAGES" | tr ',' '\n' | jq -R . | jq -s .)
    fi

    local fw_json="[]"
    if [[ -n "$FRAMEWORKS" ]]; then
        fw_json=$(echo "$FRAMEWORKS" | tr ',' '\n' | jq -R . | jq -s .)
    fi

    local notes_json="[]"
    if [[ -n "$SECURITY_NOTES" ]]; then
        notes_json=$(echo "$SECURITY_NOTES" | tr '|' '\n' | jq -R . | jq -s .)
    fi

    # Build directories object
    local dirs_json="{}"
    if [[ -n "$SOURCE_DIR" || -n "$TESTS_DIR" || -n "$CONFIG_DIR" ]]; then
        dirs_json=$(jq -n \
            --arg src "$SOURCE_DIR" \
            --arg tests "$TESTS_DIR" \
            --arg config "$CONFIG_DIR" \
            '{source: (if $src != "" then $src else null end), tests: (if $tests != "" then $tests else null end), config: (if $config != "" then $config else null end)} | with_entries(select(.value != null))')
    fi

    # Build the full JSON
    jq -n \
        --arg name "$PROJECT_NAME" \
        --arg type "$PROJECT_TYPE" \
        --argjson languages "$langs_json" \
        --argjson frameworks "$fw_json" \
        --argjson auth "$HAS_AUTH" \
        --argjson oauth "$HAS_OAUTH" \
        --argjson file_upload "$HAS_FILE_UPLOAD" \
        --argjson websockets "$HAS_WEBSOCKETS" \
        --argjson database "$HAS_DATABASE" \
        --argjson api "$HAS_API" \
        --argjson graphql "$HAS_GRAPHQL" \
        --argjson payments "$HAS_PAYMENTS" \
        --argjson email "$HAS_EMAIL" \
        --argjson logging "$HAS_LOGGING" \
        --argjson directories "$dirs_json" \
        --arg detected_at "$timestamp" \
        --argjson security_notes "$notes_json" \
        '{
            name: $name,
            type: $type,
            languages: $languages,
            frameworks: $frameworks,
            features: {
                authentication: $auth,
                oauth: $oauth,
                "file-upload": $file_upload,
                websockets: $websockets,
                database: $database,
                api: $api,
                graphql: $graphql,
                payments: $payments,
                email: $email,
                logging: $logging
            },
            directories: $directories,
            detected_at: $detected_at,
            security_notes: $security_notes
        }'
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo "Detecting project context for: $PROJECT_DIR" >&2

    # Check for jq
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed" >&2
        exit 1
    fi

    detect_languages
    detect_frameworks
    detect_features
    detect_directories
    detect_project_type

    # Generate and save JSON
    local json
    json=$(generate_json)

    echo "$json" > "$OUTPUT_FILE"

    echo "Project context saved to: $OUTPUT_FILE" >&2
    echo "" >&2
    echo "Summary:" >&2
    echo "  Type: $PROJECT_TYPE" >&2
    echo "  Languages: ${LANGUAGES:-none detected}" >&2
    echo "  Frameworks: ${FRAMEWORKS:-none detected}" >&2
    echo "" >&2

    # Output the JSON to stdout as well
    echo "$json"
}

main
