#!/usr/bin/env bash
#
# suggest-skills.sh - Centralized skill routing based on context
#
# Usage: suggest-skills.sh [--file-type TYPE] [--task-type TYPE] [--keywords KEYWORDS]
#
# Arguments:
#   --file-type   File extension/type (e.g., go, py, ts, tsx)
#   --task-type   Task type (e.g., testing, api, database, security)
#   --keywords    Keywords from task description
#
# Output: JSON with recommended skills and rationale

set -euo pipefail

# Defaults
FILE_TYPE=""
TASK_TYPE=""
KEYWORDS=""
JSON_OUTPUT=false
MAX_SUGGESTIONS=5

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --file-type) FILE_TYPE="$2"; shift 2 ;;
        --task-type) TASK_TYPE="$2"; shift 2 ;;
        --keywords) KEYWORDS="$2"; shift 2 ;;
        --json) JSON_OUTPUT=true; shift ;;
        --max) MAX_SUGGESTIONS="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: suggest-skills.sh [options]"
            echo ""
            echo "Suggest relevant devloop skills based on context."
            echo ""
            echo "Options:"
            echo "  --file-type TYPE   File extension (go, py, ts, java, etc.)"
            echo "  --task-type TYPE   Task type (testing, api, database, etc.)"
            echo "  --keywords WORDS   Keywords from task description"
            echo "  --json             Output as JSON"
            echo "  --max N            Max suggestions (default: 5)"
            exit 0
            ;;
        *) shift ;;
    esac
done

# ============================================================================
# Skill database with triggers
# ============================================================================
# Format: skill_name|triggers|description

SKILLS=(
    # Language-specific
    "go-patterns|go,golang|Go best practices, error handling, concurrency"
    "python-patterns|py,python|Python idioms, type hints, async patterns"
    "java-patterns|java|Java/Spring patterns, DI, testing"
    "react-patterns|tsx,jsx,react|React hooks, state management, performance"

    # Technical domains
    "api-design|api,endpoint,rest,graphql|API design, versioning, error handling"
    "database-patterns|database,db,sql,query,schema|Database design, indexing, migrations"
    "testing-strategies|test,testing,coverage,tdd|Test strategies, unit/integration/e2e"
    "security-checklist|security,auth,vulnerability,owasp|Security patterns, OWASP, auth"
    "architecture-patterns|architecture,design,pattern,structure|Architecture patterns by language"

    # Workflow
    "plan-management|plan,task,phase|Plan format, task markers, updates"
    "atomic-commits|commit,git,pr|Commit conventions, atomic changes"
    "git-workflows|git,branch,merge,rebase|Git workflow patterns, branching"
    "worklog-management|worklog,history,log|Worklog format, updates"
    "version-management|version,release,changelog|Semantic versioning, CHANGELOG"
    "deployment-readiness|deploy,ship,production,release|Deployment validation, readiness"

    # Process
    "complexity-estimation|estimate,size,complexity|T-shirt sizing, risk assessment"
    "requirements-patterns|requirement,spec,scope|Requirements gathering, user stories"
    "task-checkpoint|checkpoint,verify,done|Task completion verification"
    "workflow-loop|workflow,loop,context|Multi-task workflow patterns"
    "workflow-selection|workflow,choose,which|Workflow selection guidance"

    # Development
    "file-locations|file,location,path,where|Devloop file locations"
    "project-context|project,detect,stack|Tech stack detection"
    "issue-tracking|issue,bug,feature,track|Issue format, tracking"
    "phase-templates|phase,template|Reusable phase patterns"
)

# ============================================================================
# Suggest skills based on context
# ============================================================================
suggest_skills() {
    local suggestions=()
    local reasons=()

    # Match by file type
    if [ -n "$FILE_TYPE" ]; then
        local file_lower=$(echo "$FILE_TYPE" | tr '[:upper:]' '[:lower:]')
        file_lower="${file_lower#.}"  # Remove leading dot

        for skill_entry in "${SKILLS[@]}"; do
            local skill=$(echo "$skill_entry" | cut -d'|' -f1)
            local triggers=$(echo "$skill_entry" | cut -d'|' -f2)
            local desc=$(echo "$skill_entry" | cut -d'|' -f3)

            if echo ",$triggers," | grep -q ",$file_lower,"; then
                suggestions+=("$skill")
                reasons+=("Matches file type: $FILE_TYPE")
            fi
        done
    fi

    # Match by task type
    if [ -n "$TASK_TYPE" ]; then
        local task_lower=$(echo "$TASK_TYPE" | tr '[:upper:]' '[:lower:]')

        for skill_entry in "${SKILLS[@]}"; do
            local skill=$(echo "$skill_entry" | cut -d'|' -f1)
            local triggers=$(echo "$skill_entry" | cut -d'|' -f2)
            local desc=$(echo "$skill_entry" | cut -d'|' -f3)

            if echo ",$triggers," | grep -q ",$task_lower,"; then
                # Avoid duplicates
                local already_added=false
                for s in "${suggestions[@]:-}"; do
                    [ "$s" = "$skill" ] && already_added=true
                done
                if [ "$already_added" = false ]; then
                    suggestions+=("$skill")
                    reasons+=("Matches task type: $TASK_TYPE")
                fi
            fi
        done
    fi

    # Match by keywords
    if [ -n "$KEYWORDS" ]; then
        local keywords_lower=$(echo "$KEYWORDS" | tr '[:upper:]' '[:lower:]')

        for skill_entry in "${SKILLS[@]}"; do
            local skill=$(echo "$skill_entry" | cut -d'|' -f1)
            local triggers=$(echo "$skill_entry" | cut -d'|' -f2)
            local desc=$(echo "$skill_entry" | cut -d'|' -f3)

            for trigger in $(echo "$triggers" | tr ',' ' '); do
                if echo "$keywords_lower" | grep -qw "$trigger"; then
                    # Avoid duplicates
                    local already_added=false
                    for s in "${suggestions[@]:-}"; do
                        [ "$s" = "$skill" ] && already_added=true
                    done
                    if [ "$already_added" = false ]; then
                        suggestions+=("$skill")
                        reasons+=("Keyword match: $trigger")
                    fi
                    break
                fi
            done
        done
    fi

    # Limit suggestions
    local count=${#suggestions[@]}
    if [ "$count" -gt "$MAX_SUGGESTIONS" ]; then
        count=$MAX_SUGGESTIONS
    fi

    # Output
    if [ "$JSON_OUTPUT" = true ]; then
        echo "{"
        echo "  \"suggestions\": ["
        for ((i=0; i<count; i++)); do
            local comma=""
            [ $i -lt $((count-1)) ] && comma=","
            echo "    {\"skill\": \"${suggestions[$i]}\", \"reason\": \"${reasons[$i]}\"}$comma"
        done
        echo "  ],"
        echo "  \"count\": $count"
        echo "}"
    else
        if [ "$count" -eq 0 ]; then
            echo "No skill suggestions for given context."
            echo "Try: --file-type, --task-type, or --keywords"
        else
            echo "Suggested Skills:"
            for ((i=0; i<count; i++)); do
                echo "  - ${suggestions[$i]} (${reasons[$i]})"
            done
            echo ""
            echo "Usage: Skill: <skill-name>"
        fi
    fi
}

# ============================================================================
# Main
# ============================================================================
main() {
    if [ -z "$FILE_TYPE" ] && [ -z "$TASK_TYPE" ] && [ -z "$KEYWORDS" ]; then
        # No context provided - show help
        echo "No context provided. Specify at least one of:"
        echo "  --file-type TYPE    (e.g., go, py, ts)"
        echo "  --task-type TYPE    (e.g., testing, api, security)"
        echo "  --keywords WORDS    (e.g., 'database query optimization')"
        echo ""
        echo "Available skills:"
        for skill_entry in "${SKILLS[@]}"; do
            local skill=$(echo "$skill_entry" | cut -d'|' -f1)
            local desc=$(echo "$skill_entry" | cut -d'|' -f3)
            printf "  %-24s %s\n" "$skill" "$desc"
        done
        exit 0
    fi

    suggest_skills
}

main "$@"
