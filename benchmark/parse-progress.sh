#!/bin/bash
# Parse streaming JSON from Claude and show progress
# Usage: claude -p "..." --output-format stream-json | ./parse-progress.sh [output_file]

OUTPUT_FILE="${1:-/dev/null}"
TURN=0
TOOL_NAME=""

# Tee to output file while parsing
while IFS= read -r line; do
    # Save raw line to output file
    echo "$line" >> "$OUTPUT_FILE"
    
    # Parse JSON for progress display
    if echo "$line" | grep -q '"type"'; then
        type=$(echo "$line" | grep -o '"type":"[^"]*"' | head -1 | cut -d'"' -f4)
        
        case "$type" in
            assistant)
                TURN=$((TURN + 1))
                echo -e "\n📍 Turn $TURN"
                ;;
            tool_use)
                TOOL_NAME=$(echo "$line" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
                if [ -n "$TOOL_NAME" ]; then
                    echo "  🔧 Tool: $TOOL_NAME"
                fi
                ;;
            tool_result)
                if [ -n "$TOOL_NAME" ]; then
                    # Check for error
                    if echo "$line" | grep -q '"is_error":true'; then
                        echo "  ❌ $TOOL_NAME failed"
                    else
                        echo "  ✅ $TOOL_NAME done"
                    fi
                    TOOL_NAME=""
                fi
                ;;
            result)
                echo -e "\n🏁 Complete!"
                # Extract final stats
                cost=$(echo "$line" | grep -o '"total_cost_usd":[0-9.]*' | cut -d':' -f2)
                duration=$(echo "$line" | grep -o '"duration_ms":[0-9]*' | cut -d':' -f2)
                turns=$(echo "$line" | grep -o '"num_turns":[0-9]*' | cut -d':' -f2)
                if [ -n "$cost" ]; then
                    echo "  💰 Cost: \$$cost"
                fi
                if [ -n "$duration" ]; then
                    secs=$((duration / 1000))
                    echo "  ⏱️  Duration: ${secs}s"
                fi
                if [ -n "$turns" ]; then
                    echo "  🔄 Turns: $turns"
                fi
                ;;
        esac
    fi
done
