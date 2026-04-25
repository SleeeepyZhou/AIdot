# SkillModules

Drop skill plugin folders here. Each folder needs a `SKILL.md`.

Compatible with [anthropics/skills](https://github.com/anthropics/skills) format.

## SKILL.md format

```markdown
---
name: my-skill
description: Short description shown to the LLM.
tool_names: tool_a, tool_b
---

# Instructions

Detailed usage guidance injected into system context each request.
```

### Frontmatter fields

- `name` (required) — unique skill identifier
- `description` (optional) — appended to the `[Skill: name]` header
- `tool_names` (optional) — comma-separated tool names registered in ToolBox

The markdown body is injected verbatim into the agent's system context.

ToolBox scans this folder on startup and every 10 seconds (hot-reload).
