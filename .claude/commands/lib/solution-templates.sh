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
  local severity=$1
  local impact=$2
  local effort=$3

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
    echo "scale=0; $severity_score + ($roi * 10)" | bc
  else
    # Fallback to awk if bc not available
    awk "BEGIN {roi = $impact / ($effort + 1); print int($severity_score + (roi * 10))}"
  fi
}
