# Claude Efficiency Guide Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create comprehensive Claude efficiency guide with token optimization strategies, caching best practices, and automation tools

**Architecture:** Documentation-focused with 7 markdown files organized into main guide, examples, and checklists. Designed for human use now, skill automation later.

**Tech Stack:** Markdown, Git

---

## File Structure

**Create:**
- `docs/claude-efficiency-guide.md` - Main guide (sections 1-8, ~3000-5000 lines)
- `docs/examples/hooks-examples.md` - Hook configuration examples  
- `docs/examples/prompt-templates.md` - Reusable prompt templates
- `docs/examples/workflow-scenarios.md` - Real-world scenarios
- `docs/checklists/token-optimization.md` - Token optimization checklist
- `docs/checklists/code-review.md` - Code review checklist
- `docs/checklists/documentation.md` - Documentation checklist

---

## Task 1: Create Directory Structure

**Files:**
- Create: `docs/examples/` (directory)
- Create: `docs/checklists/` (directory)

- [ ] **Step 1: Create directories**

```bash
mkdir -p docs/examples docs/checklists
```

- [ ] **Step 2: Verify**

Run: `ls -la docs/`
Expected: See `examples/` and `checklists/` directories

---

## Task 2: Main Guide Part 1 - Sections 1-2

**Files:**
- Create: `docs/claude-efficiency-guide.md`

- [ ] **Step 1: Write header, TOC, and section 1**

Write complete section 1 including:
- Guide reading instructions (beginner/advanced/team leader paths)
- Terminology (token, context, caching, session, cache hit rate)
- Quick start guide (5-minute essentials)

- [ ] **Step 2: Write section 2.1 (11 token rules)**

Expand each of the 11 CLAUDE.md rules with:
- Why (importance)
- When (application scenarios)
- How (concrete methods)
- Examples (before/after)

Rules to cover:
1. Don't re-read files in same session
2. Avoid unnecessary tool calls
3. Execute parallel tool calls
4. Delegate large outputs to subagents
5. Don't repeat user explanations
6. Auto-compress at ~60% context
7. Preserve critical state when compressing
8. Limit shell output
9. Use CLAUDE.md as skill index only
10. Save state before clearing
11. Maintain .claudeignore actively

- [ ] **Step 3: Commit**

```bash
git add docs/claude-efficiency-guide.md
git commit -m "docs: add sections 1-2.1 (intro and 11 token rules)"
```

---

## Task 3: Main Guide Part 2 - Caching Optimization

**Files:**
- Modify: `docs/claude-efficiency-guide.md`

- [ ] **Step 1: Append section 2.2 (caching fundamentals)**

Include:
- How caching works
- What gets cached (system prompts, CLAUDE.md, tool results)
- Cache lifetime (5 minutes)
- Cache key matching (exact match required)
- Cacheable elements list
- Cache invalidation conditions

- [ ] **Step 2: Append section 2.3 (cache hit rate optimization)**

Include:
- Cache-friendly project structure
- Session management strategies
- CLAUDE.md optimization
- Measuring and monitoring (target: 70%+)

- [ ] **Step 3: Commit**

```bash
git add docs/claude-efficiency-guide.md
git commit -m "docs: add sections 2.2-2.3 (caching optimization)"
```

---

## Task 4: Main Guide Part 3 - Project Setup

**Files:**
- Modify: `docs/claude-efficiency-guide.md`

- [ ] **Step 1: Append section 3 (project setup)**

Include subsections:
- 3.1 CLAUDE.md writing guide (required sections, optional sections, template, anti-patterns)
- 3.2 .claudeignore setup (must-exclude items, language-specific patterns, dynamic updates)
- 3.3 Hooks setup (types, purposes, setup method, caveats - reference hooks-examples.md)

- [ ] **Step 2: Commit**

```bash
git add docs/claude-efficiency-guide.md
git commit -m "docs: add section 3 (project setup)"
```

---

## Task 5: Main Guide Part 4 - Prompting Best Practices

**Files:**
- Modify: `docs/claude-efficiency-guide.md`

- [ ] **Step 1: Append section 4 (prompting)**

Include subsections:
- 4.1 Common principles
- 4.2 Coding prompts (refactoring, bug fixes, new features, code review)
- 4.3 Documentation prompts  
- 4.4 Refactoring/review prompts
- Reference to prompt-templates.md for actual templates

- [ ] **Step 2: Commit**

```bash
git add docs/claude-efficiency-guide.md
git commit -m "docs: add section 4 (prompting best practices)"
```

---

## Task 6: Main Guide Part 5 - Workflows and Quality

**Files:**
- Modify: `docs/claude-efficiency-guide.md`

- [ ] **Step 1: Append section 5 (workflows)**

Include:
- 5.1 Personal workflows (daily startup, large task management, context compression timing)
- 5.2 Team workflows (CLAUDE.md as team standard, PR reviews, shared templates, monitoring)
- Reference to workflow-scenarios.md

- [ ] **Step 2: Append section 6 (quality management)**

Include:
- 6.1 Output verification methods (code quality, documentation quality)
- 6.2 Common mistakes and solutions (10+ mistake patterns with symptoms and fixes)

- [ ] **Step 3: Commit**

```bash
git add docs/claude-efficiency-guide.md
git commit -m "docs: add sections 5-6 (workflows and quality)"
```

---

## Task 7: Main Guide Part 6 - Metrics and Advanced

**Files:**
- Modify: `docs/claude-efficiency-guide.md`

- [ ] **Step 1: Append section 7 (measurement and improvement)**

Include:
- 7.1 Metrics to track (token usage, cache hit rate, session efficiency)
- 7.2 Cache hit rate analysis and improvement
- 7.3 Optimization checklist (auto-checkable items, manual items)
- Reference to checklists/

- [ ] **Step 2: Append section 8 (advanced techniques)**

Include:
- 8.1 Subagent utilization
- 8.2 Context management strategies
- 8.3 Memory system utilization
- 8.4 Cache-friendly project structure

- [ ] **Step 3: Commit**

```bash
git add docs/claude-efficiency-guide.md
git commit -m "docs: add sections 7-8 (metrics and advanced techniques)"
```

---

## Task 8: Token Optimization Checklist

**Files:**
- Create: `docs/checklists/token-optimization.md`

- [ ] **Step 1: Write checklist**

Structure with categories:
- Project setup (6 items)
- Session management (4 items)
- Caching optimization (4 items)
- File management (3 items)
- Prompting (4 items)

Include scoring system (100 points total, target: 80+)

- [ ] **Step 2: Commit**

```bash
git add docs/checklists/token-optimization.md
git commit -m "docs: add token optimization checklist (21 items)"
```

---

## Task 9: Code Review Checklist

**Files:**
- Create: `docs/checklists/code-review.md`

- [ ] **Step 1: Write checklist**

Include:
- Review preparation items
- Efficient review request items
- Post-review items
- Prompt template example

- [ ] **Step 2: Commit**

```bash
git add docs/checklists/code-review.md
git commit -m "docs: add code review checklist"
```

---

## Task 10: Documentation Checklist

**Files:**
- Create: `docs/checklists/documentation.md`

- [ ] **Step 1: Write checklist**

Include:
- Documentation preparation items
- Efficient writing items
- Verification items
- Prompt template example

- [ ] **Step 2: Commit**

```bash
git add docs/checklists/documentation.md
git commit -m "docs: add documentation checklist"
```

---

## Task 11: Hooks Examples

**Files:**
- Create: `docs/examples/hooks-examples.md`

- [ ] **Step 1: Write hook examples**

Include 4 hooks with complete details for each:
- Pre-commit hook (large file check, .env check)
- Session-start hook (optimization status summary)
- Post-edit hook (file size warning, .claudeignore suggestions)
- Pre-push hook (test and lint execution)

Each hook includes:
- Purpose
- Trigger condition
- Script code (bash)
- Setup method
- Example output
- Caveats
- Token impact

- [ ] **Step 2: Commit**

```bash
git add docs/examples/hooks-examples.md
git commit -m "docs: add hook examples (4 complete hooks)"
```

---

## Task 12: Prompt Templates

**Files:**
- Create: `docs/examples/prompt-templates.md`

- [ ] **Step 1: Write templates**

Include 10+ templates across categories:

**Coding:**
- Refactoring request
- Bug fix request
- New feature implementation
- Code review
- Performance optimization
- Test writing

**Documentation:**
- README writing
- API documentation
- Technical blog post
- User guide
- Release notes

**Analysis:**
- Codebase analysis
- Architecture review
- Security audit
- Dependency analysis

Each template includes: name, purpose, structure (with placeholders), options, example (filled), token-saving tips, estimated token cost

- [ ] **Step 2: Commit**

```bash
git add docs/examples/prompt-templates.md
git commit -m "docs: add prompt templates (10+ reusable templates)"
```

---

## Task 13: Workflow Scenarios

**Files:**
- Create: `docs/examples/workflow-scenarios.md`

- [ ] **Step 1: Write scenarios**

Include 6 complete scenarios:

1. Large codebase refactoring (100 files, 10K lines)
2. Batch documentation (50 API endpoints)
3. Legacy code analysis and modernization (5-year-old codebase)
4. Team collaboration - code review automation (PR workflow)
5. Emergency bug fix (production issue)
6. New project bootstrapping (optimized from start)

Each scenario includes:
- Initial situation (problem description)
- Goal
- Step-by-step solution
- Example prompts used
- Techniques/principles applied
- Measurement results (before/after token usage, time, savings %)
- Lessons learned
- Caveats

- [ ] **Step 2: Commit**

```bash
git add docs/examples/workflow-scenarios.md
git commit -m "docs: add workflow scenarios (6 real-world examples)"
```

---

## Task 14: Self-Review

**Files:**
- All documentation files

- [ ] **Step 1: Spec coverage check**

Review design spec at `docs/superpowers/specs/2026-04-12-claude-efficiency-guide-design.md` and verify every section/requirement has corresponding content in implementation

- [ ] **Step 2: Placeholder scan**

```bash
grep -r "TBD\|TODO\|FIXME\|fill in\|implement later\|add appropriate" docs/claude-efficiency-guide.md docs/examples/ docs/checklists/
```

Expected: No output (no placeholders)

- [ ] **Step 3: Consistency check**

Verify cross-references are correct:
- Main guide references to examples/ and checklists/ files exist
- Hook names consistent across documents
- Template names consistent across documents

- [ ] **Step 4: Completeness check**

```bash
# Verify 8 main sections
grep -c "^## [0-9]\\." docs/claude-efficiency-guide.md
# Expected: 8

# Verify minimum checklist items
grep -c "^- \[ \]" docs/checklists/*.md
# Expected: 50+

# Verify all 7 files exist
ls docs/claude-efficiency-guide.md docs/examples/*.md docs/checklists/*.md | wc -l
# Expected: 7
```

---

## Task 15: Final Commit

**Files:**
- All documentation files

- [ ] **Step 1: Final comprehensive commit**

```bash
git add docs/
git commit -m "docs: complete Claude efficiency guide v1.0

Comprehensive guide for efficient Claude usage with focus on:
- Token optimization (30-50% reduction target)
- Caching strategies (70%+ hit rate target)
- Team standardization and automation

Contents:
- Main guide: 8 sections covering fundamentals to advanced
- Examples: 4 hooks, 10+ prompt templates, 6 workflows
- Checklists: 50+ optimization items across 3 categories

Files created:
- docs/claude-efficiency-guide.md (3000-5000 lines)
- docs/examples/hooks-examples.md
- docs/examples/prompt-templates.md
- docs/examples/workflow-scenarios.md
- docs/checklists/token-optimization.md
- docs/checklists/code-review.md
- docs/checklists/documentation.md

Designed for immediate use and future skill automation.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

- [ ] **Step 2: Generate statistics**

```bash
echo "📊 Claude Efficiency Guide - Implementation Complete"
echo "===================================================="
echo ""
echo "Files created: 7"
echo "Main guide lines: $(wc -l < docs/claude-efficiency-guide.md)"
echo "Total lines: $(find docs -name '*.md' -exec cat {} \; | wc -l)"
echo "Checklist items: $(grep -h '^\- \[ \]' docs/checklists/*.md | wc -l)"
echo "Hook examples: 4"
echo "Prompt templates: 10+"
echo "Workflow scenarios: 6"
echo ""
echo "✅ Ready for team adoption"
echo "✅ Structured for skill automation"
echo "✅ Comprehensive examples and checklists"
```

- [ ] **Step 3: Verify commit**

```bash
git log -1 --stat
```

Expected: All 7 files in commit

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-04-12-claude-efficiency-guide.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach would you like?
