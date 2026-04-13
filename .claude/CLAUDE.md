### 💰 Token Optimization Rules
1. **Don't re-read files already accessed in the same session**
2. **Avoid unnecessary tool calls** - verify necessity before execution
3. **Execute parallel tool calls when possible** - batch independent operations
4. **Delegate large outputs (20+ lines) to subagents** - keep main context clean
5. **Don't repeat what the user already explained** - reference previous context
6. **Auto-compress context at ~60% usage** - trigger compression before hitting limits
7. **Preserve critical state when compressing** - retain ongoing features, current tasks, and error history
8. **Limit shell command output** - use `head`/`tail` to cap output unless full content is required
9. **Use CLAUDE.md as skill index only** - keep skill descriptions brief, store full content separately
10. **Save state before clearing** - write progress.md with completed/in-progress/next steps before context reset
11. **Always display status line** - show context usage and session state regularly
12. **Maintain .claudeignore actively** - add unnecessary files (logs, builds, deps, binaries) to prevent context waste

## Rules
- Never use `cd && git ...` pattern
- Always use `git -C <path>` instead