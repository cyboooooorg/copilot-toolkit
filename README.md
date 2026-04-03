# 🤖 Copilot Toolkit

Personal toolkit for GitHub Copilot CLI — use it on any machine, any project.

## What's inside

| Path | Purpose |
| --- | --- |
| `skills/` | Custom skills — one folder per skill (`SKILL.md`) |
| `.agents/skills/` | `npx skills` packages, symlinked to `~/.agents/skills/` |
| `instructions/copilot-instructions.md` | Global Copilot instructions |
| `lsp/lsp-config.json` | LSP server configuration |
| `mcp/mcp-config.json` | MCP server configuration |
| `templates/` | Per-project starter files (drop these into your repos) |

## Quick start (new machine)

```bash
git clone https://github.com/cyboooooorg/copilot-toolkit.git ~/Developer/copilot-toolkit
cd ~/Developer/copilot-toolkit
./install.sh
```

`install.sh` will:

1. Install GitHub Copilot CLI if not already present
2. Symlink `instructions/copilot-instructions.md` →
   `~/.copilot/copilot-instructions.md`
3. Symlink `lsp/lsp-config.json` → `~/.copilot/lsp-config.json`
4. Register `skills/` as a custom skill directory in your Copilot config
5. Check for `npx` / Node.js — prompt to install via nvm if missing
6. Symlink each skill in `.agents/skills/` → `~/.agents/skills/`
7. Install any LSP servers listed in `lsp/lsp-config.json`

## Adding a skill

There are two ways to add skills:

### Option A — Discover & install from the ecosystem (recommended)

Use the built-in **find-skills** skill: just ask Copilot something like:

> *"Find a skill for writing changelogs"* or *"Is there a skill for PR reviews?"*

Copilot will search [skills.sh](https://skills.sh/) and suggest matching skills.
You can also search and install directly from the terminal:

```bash
npx skills find [query]               # interactive search
npx skills add <owner/repo@skill>     # install a specific skill
```

Installed skills land in `.agents/skills/` and are automatically symlinked to
`~/.agents/skills/` the next time you run `./install.sh`.

### Option B — Write a custom skill

```bash
mkdir skills/my-skill
# create the SKILL.md following the format below
```

**Skill format** (`skills/my-skill/SKILL.md`):

```markdown
---
name: my-skill
description: >-
  What this skill does and when to use it.
user-invocable: true
---

# My Skill

Skill content here...
```

After adding a skill, reload with `/skills reload` inside Copilot CLI.

## Adding an MCP server

Edit `mcp/mcp-config.json` and re-run `./install.sh`
(or use `/mcp` inside Copilot CLI).

## Per-project setup

Copy a template into your project:

```bash
cp ~/Developer/copilot-toolkit/templates/copilot-instructions.md .github/copilot-instructions.md
```

## Updating

```bash
cd ~/Developer/copilot-toolkit && git pull
```

Symlinks are permanent — once installed, changes to this repo are picked up automatically.
