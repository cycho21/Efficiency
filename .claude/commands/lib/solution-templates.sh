#!/bin/bash
# Solution generation templates and helper functions for efficiency audit

# This library provides:
# - Priority score calculation
# - Solution template generation for common issues
# - Report generation and formatting

set -euo pipefail

# Calculate priority score for an issue
# Args: severity impact effort
# Returns: priority score (higher = more urgent)
calculate_priority_score() {
  # Validate arguments
  if [[ $# -ne 3 ]]; then
    echo "Error: calculate_priority_score requires 3 args (severity impact effort)" >&2
    return 1
  fi

  local severity=$1
  local impact=$2
  local effort=$3

  # Validate numeric inputs
  if ! [[ "$impact" =~ ^[0-9]+$ ]] || ! [[ "$effort" =~ ^[0-9]+$ ]]; then
    echo "Error: impact and effort must be numeric" >&2
    return 1
  fi

  # Severity weight
  local severity_score
  case $severity in
    CRITICAL) severity_score=100 ;;
    IMPORTANT) severity_score=50 ;;
    MINOR) severity_score=20 ;;
    *) severity_score=0 ;;
  esac

  # ROI (tokens per minute)
  local roi
  if command -v bc &>/dev/null; then
    roi=$(echo "scale=2; $impact / ($effort + 1)" | bc)
    # Final priority = severity + (ROI * 10)
    # Add 0.5 before truncation to achieve round-half-up
    echo "scale=0; ($severity_score + ($roi * 10) + 0.5) / 1" | bc
  else
    # Fallback to awk if bc not available
    awk "BEGIN {roi = $impact / ($effort + 1); print int($severity_score + (roi * 10) + 0.5)}"
  fi
}
