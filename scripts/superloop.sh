#!/bin/bash
# Superpowers Loop - Long-running AI agent loop
# Usage: ./superloop.sh <plan-name> [max_iterations]
#
# Example: ./superloop.sh knowledge-base-module-upgrade 20

set -e

# Default values
MAX_ITERATIONS=10
PLAN_NAME=""

# Show usage information
show_usage() {
  echo "Usage: superloop.sh <plan-name> [max_iterations]"
  echo ""
  echo "Arguments:"
  echo "  <plan-name>       Required. Name of the plan to execute"
  echo "  [max_iterations]  Optional. Maximum number of iterations (default: 10)"
  echo ""
  echo "Examples:"
  echo "  superloop.sh knowledge-base-module-upgrade"
  echo "  superloop.sh knowledge-base-module-upgrade 20"
  exit 1
}

# Validate and parse arguments
if [[ $# -lt 1 ]]; then
  echo "Error: Missing required argument <plan-name>"
  echo ""
  show_usage
fi

PLAN_NAME="$1"

# Parse optional max_iterations
if [[ -n "$2" ]]; then
  # Validate that max_iterations is a positive integer
  if [[ ! "$2" =~ ^[0-9]+$ ]]; then
    echo "Error: max_iterations must be a positive integer, got '$2'"
    exit 1
  fi
  MAX_ITERATIONS="$2"
  # Prevent unreasonably high iteration counts
  if [[ "$MAX_ITERATIONS" -gt 500 ]]; then
    echo "Error: max_iterations cannot exceed 500"
    exit 1
  fi
fi

echo "Starting Superloop - Plan: $PLAN_NAME - Max iterations: $MAX_ITERATIONS"
echo ""

PROMPT="Load the executing-plans skill and execute the $PLAN_NAME plans until all tasks are completed. If ALL tasks are complete and passing, reply with: <promise>COMPLETE</promise>"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Iteration $i of $MAX_ITERATIONS - Plan: $PLAN_NAME"
  echo "==============================================================="

  # Run Claude Code with the plan's CLAUDE.md
  # Use --dangerously-skip-permissions for autonomous operation
  # Use --print for output capture
  OUTPUT=$(claude --dangerously-skip-permissions -p "$PROMPT" 2>&1 | tee /dev/stderr) || true

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "Superloop completed all tasks!"
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi
  
  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "⚠️  Superloop reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "   Plan: $PLAN_NAME"
exit 1