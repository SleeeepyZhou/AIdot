---
name: SkillCreator
description: Teaches how to create AIdot skills using the SKILL.md format
tool_names: create_tool_module
---

# Creating AIdot Skills

A Skill bundles system-context instructions with tool references. Skills tell the LLM *how* and *when* to use tools, and inject guidance into every conversation where the skill is active.

## Format

Create a subfolder under `addons/AIdot/SkillModules/` containing a single `SKILL.md` file:

```markdown
---
name: my-skill
description: Short one-line description shown to the LLM as a capability header.
tool_names: tool_a, tool_b
---

# Skill Title

Detailed instructions injected into the agent's system context.
Explain when and how to use the tools, expected inputs/outputs, and constraints.
```

### Frontmatter fields

- `name` (required) — unique identifier; rendered as `[Skill: my-skill]` in system context
- `description` (optional) — appended to the header line
- `tool_names` (optional) — comma-separated list of tool names already registered in ToolBox

The markdown body after `---` becomes the instructions injected each request.

## Writing good instructions

- Be specific about *when* to call each tool (conditions and triggers)
- Show the expected input format with a concrete example
- Describe what the tool returns and how to interpret it
- State constraints: ordering requirements, rate limits, side effects
- Use imperative tone: "Call X when Y. Always Z after W."

## Example

```markdown
---
name: WebSearch
description: Search the web for current information
tool_names: web_search
---

Use `web_search` when you need information that may be more recent than your training data.
Formulate a concise, specific query. Summarize the most relevant results in your answer.
Do not call web_search more than 3 times per conversation turn.
```

## Hot-reload

ToolBox scans `SkillModules/` on startup and every 10 seconds.
Drop a new folder with a `SKILL.md` and it will be available without restarting.
