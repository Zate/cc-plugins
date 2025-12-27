#!/usr/bin/env bats
#
# Tests for sync-plan-state.sh
#
# Run with: bats plugins/devloop/tests/sync-plan-state.bats
# Install bats: https://github.com/bats-core/bats-core
#
# These tests verify:
# - Task marker parsing (all 5 types)
# - Phase detection and parsing
# - Dependency extraction
# - Parallel group tracking
# - Stats calculation
# - Edge cases

# Setup - runs before each test
setup() {
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SYNC_SCRIPT="$SCRIPT_DIR/scripts/sync-plan-state.sh"

    # Create temp directory for test files
    TEST_TEMP="$(mktemp -d)"
    TEST_PLAN="$TEST_TEMP/plan.md"
    TEST_STATE="$TEST_TEMP/plan-state.json"

    # Verify script exists
    [ -f "$SYNC_SCRIPT" ] || skip "sync-plan-state.sh not found"
}

# Teardown - runs after each test
teardown() {
    # Clean up temp files
    [ -d "$TEST_TEMP" ] && rm -rf "$TEST_TEMP"
}

# Helper: create a minimal plan file
create_plan() {
    cat > "$TEST_PLAN" << 'EOF'
# Test Plan

**Created**: 2025-01-15
**Updated**: 2025-01-15 09:00
**Status**: In Progress
**Current Phase**: Phase 1

## Tasks

### Phase 1: Test Phase
**Goal**: Test the sync script

EOF
    # Append provided content
    echo "$1" >> "$TEST_PLAN"
}

# Helper: run sync and extract JSON field
sync_and_get() {
    "$SYNC_SCRIPT" "$TEST_PLAN" --output "$TEST_STATE" >/dev/null 2>&1
    jq -r "$1" "$TEST_STATE"
}

# ============================================
# Basic Functionality Tests
# ============================================

@test "sync-plan-state.sh exists and is executable" {
    [ -x "$SYNC_SCRIPT" ]
}

@test "shows help with --help flag" {
    run "$SYNC_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "exits with error for missing plan file" {
    run "$SYNC_SCRIPT" "/nonexistent/plan.md"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not found"* ]]
}

@test "creates valid JSON output" {
    create_plan "- [ ] Task 1.1: Test task"
    "$SYNC_SCRIPT" "$TEST_PLAN" --output "$TEST_STATE"

    # Verify valid JSON
    run jq . "$TEST_STATE"
    [ "$status" -eq 0 ]
}

# ============================================
# Task Marker Tests
# ============================================

@test "parses pending task marker [ ]" {
    create_plan "- [ ] Task 1.1: Pending task"

    result=$(sync_and_get '.tasks["1.1"].status')
    [ "$result" = "pending" ]
}

@test "parses completed task marker [x]" {
    create_plan "- [x] Task 1.1: Completed task"

    result=$(sync_and_get '.tasks["1.1"].status')
    [ "$result" = "complete" ]
}

@test "parses completed task marker [X] (uppercase)" {
    create_plan "- [X] Task 1.1: Completed task uppercase"

    result=$(sync_and_get '.tasks["1.1"].status')
    [ "$result" = "complete" ]
}

@test "parses in_progress task marker [~]" {
    create_plan "- [~] Task 1.1: In progress task"

    result=$(sync_and_get '.tasks["1.1"].status')
    [ "$result" = "in_progress" ]
}

@test "parses blocked task marker [!]" {
    create_plan "- [!] Task 1.1: Blocked task"

    result=$(sync_and_get '.tasks["1.1"].status')
    [ "$result" = "blocked" ]
}

@test "parses skipped task marker [-]" {
    create_plan "- [-] Task 1.1: Skipped task"

    result=$(sync_and_get '.tasks["1.1"].status')
    [ "$result" = "skipped" ]
}

# ============================================
# Stats Calculation Tests
# ============================================

@test "calculates total tasks correctly" {
    create_plan "- [ ] Task 1.1: First
- [x] Task 1.2: Second
- [~] Task 1.3: Third"

    result=$(sync_and_get '.stats.total')
    [ "$result" = "3" ]
}

@test "calculates completed count correctly" {
    create_plan "- [x] Task 1.1: Done one
- [x] Task 1.2: Done two
- [ ] Task 1.3: Not done"

    result=$(sync_and_get '.stats.completed')
    [ "$result" = "2" ]
}

@test "calculates pending count correctly" {
    create_plan "- [ ] Task 1.1: Pending one
- [ ] Task 1.2: Pending two
- [x] Task 1.3: Done"

    result=$(sync_and_get '.stats.pending')
    [ "$result" = "2" ]
}

@test "calculates done count (completed + skipped)" {
    create_plan "- [x] Task 1.1: Completed
- [-] Task 1.2: Skipped
- [ ] Task 1.3: Pending"

    result=$(sync_and_get '.stats.done')
    [ "$result" = "2" ]
}

@test "calculates percentage correctly" {
    create_plan "- [x] Task 1.1: Done
- [x] Task 1.2: Done
- [ ] Task 1.3: Pending
- [ ] Task 1.4: Pending"

    result=$(sync_and_get '.stats.percentage')
    [ "$result" = "50" ]
}

@test "handles zero tasks gracefully" {
    create_plan ""

    result=$(sync_and_get '.stats.total')
    [ "$result" = "0" ]

    result=$(sync_and_get '.stats.percentage')
    [ "$result" = "0" ]
}

# ============================================
# Phase Parsing Tests
# ============================================

@test "parses phase number" {
    create_plan "- [ ] Task 1.1: In phase 1"

    result=$(sync_and_get '.phases[0].number')
    [ "$result" = "1" ]
}

@test "parses phase name" {
    result=$(sync_and_get '.phases[0].name')
    [ "$result" = "Test Phase" ]
}

@test "parses phase goal" {
    result=$(sync_and_get '.phases[0].goal')
    [ "$result" = "Test the sync script" ]
}

@test "calculates phase status as complete when all tasks done" {
    create_plan "- [x] Task 1.1: Done
- [x] Task 1.2: Also done"

    result=$(sync_and_get '.phases[0].status')
    [ "$result" = "complete" ]
}

@test "calculates phase status as in_progress when partially done" {
    create_plan "- [x] Task 1.1: Done
- [ ] Task 1.2: Not done"

    result=$(sync_and_get '.phases[0].status')
    [ "$result" = "in_progress" ]
}

@test "calculates phase status as pending when nothing done" {
    create_plan "- [ ] Task 1.1: Pending
- [ ] Task 1.2: Also pending"

    result=$(sync_and_get '.phases[0].status')
    [ "$result" = "pending" ]
}

@test "parses multiple phases" {
    cat > "$TEST_PLAN" << 'EOF'
# Multi-Phase Plan

**Created**: 2025-01-15
**Status**: In Progress
**Current Phase**: Phase 1

## Tasks

### Phase 1: First Phase
**Goal**: Do first things

- [x] Task 1.1: First task

### Phase 2: Second Phase
**Goal**: Do second things

- [ ] Task 2.1: Second task
EOF

    "$SYNC_SCRIPT" "$TEST_PLAN" --output "$TEST_STATE" >/dev/null 2>&1

    phase_count=$(jq '.phases | length' "$TEST_STATE")
    [ "$phase_count" = "2" ]

    phase1_status=$(jq -r '.phases[0].status' "$TEST_STATE")
    [ "$phase1_status" = "complete" ]

    phase2_status=$(jq -r '.phases[1].status' "$TEST_STATE")
    [ "$phase2_status" = "pending" ]
}

# ============================================
# Dependency Tests
# ============================================

@test "parses single dependency [depends:N.M]" {
    create_plan "- [x] Task 1.1: First task
- [ ] Task 1.2: Second task [depends:1.1]"

    result=$(sync_and_get '.dependencies["1.2"][0]')
    [ "$result" = "1.1" ]
}

@test "parses multiple dependencies [depends:N.M,N.N]" {
    create_plan "- [x] Task 1.1: First
- [x] Task 1.2: Second
- [ ] Task 1.3: Third [depends:1.1,1.2]"

    dep_count=$(sync_and_get '.dependencies["1.3"] | length')
    [ "$dep_count" = "2" ]
}

@test "handles task with no dependencies" {
    create_plan "- [ ] Task 1.1: Independent task"

    result=$(sync_and_get '.dependencies["1.1"] // "null"')
    [ "$result" = "null" ]
}

# ============================================
# Parallel Group Tests
# ============================================

@test "parses parallel group marker [parallel:A]" {
    create_plan "- [ ] Task 1.1: Parallel task [parallel:A]"

    result=$(sync_and_get '.tasks["1.1"].parallel_group')
    [ "$result" = "A" ]
}

@test "groups tasks by parallel marker" {
    create_plan "- [ ] Task 1.1: First parallel [parallel:A]
- [ ] Task 1.2: Second parallel [parallel:A]
- [ ] Task 1.3: Not parallel"

    group_count=$(sync_and_get '.parallel_groups["A"] | length')
    [ "$group_count" = "2" ]
}

@test "handles multiple parallel groups" {
    create_plan "- [ ] Task 1.1: Group A [parallel:A]
- [ ] Task 1.2: Group B [parallel:B]
- [ ] Task 1.3: Also group A [parallel:A]"

    group_a=$(sync_and_get '.parallel_groups["A"] | length')
    group_b=$(sync_and_get '.parallel_groups["B"] | length')

    [ "$group_a" = "2" ]
    [ "$group_b" = "1" ]
}

# ============================================
# Task Description Tests
# ============================================

@test "extracts task description" {
    create_plan "- [ ] Task 1.1: This is the description"

    result=$(sync_and_get '.tasks["1.1"].description')
    [ "$result" = "This is the description" ]
}

@test "strips markers from description" {
    create_plan "- [ ] Task 1.1: Description [parallel:A] [depends:0.1]"

    result=$(sync_and_get '.tasks["1.1"].description')
    # Should not contain the markers
    [[ "$result" != *"[parallel:"* ]]
    [[ "$result" != *"[depends:"* ]]
}

@test "parses acceptance criteria" {
    create_plan "- [ ] Task 1.1: Main task
  - Acceptance: This is the acceptance criteria"

    result=$(sync_and_get '.tasks["1.1"].acceptance')
    [ "$result" = "This is the acceptance criteria" ]
}

@test "parses files metadata" {
    create_plan "- [ ] Task 1.1: Main task
  - Files: \`path/to/file.ts\`"

    result=$(sync_and_get '.tasks["1.1"].files[0]')
    [ "$result" = "path/to/file.ts" ]
}

# ============================================
# Header Metadata Tests
# ============================================

@test "extracts plan name from title" {
    result=$(sync_and_get '.plan_name')
    [ "$result" = "Test Plan" ]
}

@test "extracts plan status" {
    result=$(sync_and_get '.status')
    [ "$result" = "in_progress" ]
}

@test "extracts current phase number" {
    result=$(sync_and_get '.current_phase')
    [ "$result" = "1" ]
}

@test "extracts created date" {
    result=$(sync_and_get '.created')
    [ "$result" = "2025-01-15" ]
}

@test "includes schema version" {
    result=$(sync_and_get '.schema_version')
    [ "$result" = "1.0.0" ]
}

@test "includes last_sync timestamp" {
    create_plan "- [ ] Task 1.1: Test"
    result=$(sync_and_get '.last_sync')

    # Should be ISO 8601 format
    [[ "$result" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T ]]
}

# ============================================
# Next Task Detection
# ============================================

@test "identifies next pending task" {
    create_plan "- [x] Task 1.1: Done
- [ ] Task 1.2: Next one
- [ ] Task 1.3: After that"

    result=$(sync_and_get '.next_task')
    [ "$result" = "1.2" ]
}

@test "next_task is null when all complete" {
    create_plan "- [x] Task 1.1: Done
- [x] Task 1.2: Also done"

    result=$(sync_and_get '.next_task')
    [ "$result" = "null" ]
}

# ============================================
# Edge Cases
# ============================================

@test "handles special characters in descriptions" {
    create_plan "- [ ] Task 1.1: Task with \"quotes\" and 'apostrophes'"

    # Should not fail
    "$SYNC_SCRIPT" "$TEST_PLAN" --output "$TEST_STATE" >/dev/null 2>&1
    [ -f "$TEST_STATE" ]

    # Should produce valid JSON
    run jq . "$TEST_STATE"
    [ "$status" -eq 0 ]
}

@test "handles tasks without phase header" {
    cat > "$TEST_PLAN" << 'EOF'
# Minimal Plan

**Status**: In Progress

## Tasks

- [ ] Task 1.1: Orphan task
EOF

    # Should not fail
    "$SYNC_SCRIPT" "$TEST_PLAN" --output "$TEST_STATE" >/dev/null 2>&1
    [ -f "$TEST_STATE" ]
}

@test "handles empty phases" {
    cat > "$TEST_PLAN" << 'EOF'
# Empty Phase Plan

**Status**: In Progress
**Current Phase**: Phase 1

## Tasks

### Phase 1: Empty Phase
**Goal**: Has no tasks

### Phase 2: Has Tasks
**Goal**: Has one task

- [ ] Task 2.1: Only task
EOF

    "$SYNC_SCRIPT" "$TEST_PLAN" --output "$TEST_STATE" >/dev/null 2>&1

    # Phase 1 should exist with 0 tasks
    phase1_total=$(jq '.phases[0].stats.total' "$TEST_STATE")
    [ "$phase1_total" = "0" ]
}

@test "handles very long task descriptions" {
    long_desc="This is a very long task description that goes on and on and contains many words to test that the parser can handle lengthy text without truncating or failing in unexpected ways"
    create_plan "- [ ] Task 1.1: $long_desc"

    result=$(sync_and_get '.tasks["1.1"].description')
    [[ "$result" == *"very long task description"* ]]
}

@test "output file location respects --output flag" {
    create_plan "- [ ] Task 1.1: Test"
    custom_output="$TEST_TEMP/custom-state.json"

    "$SYNC_SCRIPT" "$TEST_PLAN" --output "$custom_output" >/dev/null 2>&1
    [ -f "$custom_output" ]
}

# ============================================
# Plan Status Parsing
# ============================================

@test "parses 'Planning' status" {
    cat > "$TEST_PLAN" << 'EOF'
# Status Test

**Status**: Planning

## Tasks
EOF

    result=$(sync_and_get '.status')
    [ "$result" = "planning" ]
}

@test "parses 'Complete' status" {
    cat > "$TEST_PLAN" << 'EOF'
# Status Test

**Status**: Complete

## Tasks
EOF

    result=$(sync_and_get '.status')
    [ "$result" = "complete" ]
}

@test "parses 'Review' status" {
    cat > "$TEST_PLAN" << 'EOF'
# Status Test

**Status**: Review

## Tasks
EOF

    result=$(sync_and_get '.status')
    [ "$result" = "review" ]
}

@test "defaults to 'planning' for unknown status" {
    cat > "$TEST_PLAN" << 'EOF'
# Status Test

**Status**: Unknown Status Value

## Tasks
EOF

    result=$(sync_and_get '.status')
    [ "$result" = "planning" ]
}
