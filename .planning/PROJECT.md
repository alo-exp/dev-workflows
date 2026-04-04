# Silver Bullet

## Vision
Agentic Process Orchestrator for AI-native Software Engineering & DevOps. Combines GSD, Superpowers, Engineering, and Design plugins into enforced workflows with 7 layers of compliance.

## Stack
Node.js (shell hooks, markdown skills, HTML site)

## Repository
https://github.com/alo-exp/silver-bullet.git

## Key Principles
- Never modify third-party plugin files (§8)
- 7 enforcement layers — no single point of bypass
- Non-destructive file operations
- User instructions always take precedence

## Core Value
Single enforced workflow that eliminates the gap between "what AI should do" and "what AI actually does" — 7 compliance layers, zero single-point-of-bypass.

## Constraints
- Must not modify third-party plugin files (GSD, Superpowers, Engineering, Design, etc.)
- All enforcement must survive context window resets
- User CLAUDE.md instructions always override SB defaults

## Decisions
1. `silver-bullet.md.base` is the single source of truth for enforcement sections 0-9.
2. `CLAUDE.md.base` reduced to minimal scaffold referencing silver-bullet.md.
3. Conflict detection runs interactively during setup.
4. Update mode overwrites silver-bullet.md without confirmation.
