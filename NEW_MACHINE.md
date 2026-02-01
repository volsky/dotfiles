# New Machine Setup

Complete setup guide for Helicopter AI development environment.

## Prerequisites

```bash
brew install python@3.11 node@20 google-cloud-sdk gh git
```

## Step 1: Clone All Repos

```bash
mkdir -p ~/workspace && cd ~/workspace
gh auth login
gh repo clone volsky/helicopter-ai
gh repo clone volsky/pm
gh repo clone volsky/dotfiles
```

## Step 2: GCP Auth

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project helicopter-ai
```

## Step 3: Dotfiles (Claude Code global config)

```bash
cd ~/workspace/dotfiles && ./setup.sh
```

Syncs to `~/.claude/`:
- `CLAUDE.md` — global Claude Code instructions (concise style, git workflow, PR rules)
- `settings.json` — editor preferences
- `mcp.json` — MCP server config (Discord bot, Playwright) — **copied, not symlinked**

Then set the Discord bot token in `~/.claude/mcp.json`:
```bash
# Get token from GCP
gcloud secrets versions access latest --secret=discord-bot-token --project=helicopter-ai
# Paste it into ~/.claude/mcp.json replacing the REPLACE_WITH_TOKEN placeholder
```

## Step 4: Helicopter AI

```bash
cd ~/workspace/helicopter-ai
chmod +x dev-setup.sh && ./dev-setup.sh
```

This script:
1. Checks prereqs (python3, node, npm, gcloud)
2. Creates Python venv + installs deps
3. Installs frontend deps (`fe/npm install`)
4. Creates `.env` from template (if missing)
5. Verifies GCP auth
6. **Syncs Claude Code definitions from PM repo** (agents, skills, settings, MCP server code)
7. Installs Discord MCP server npm deps

Then edit `.env` with credentials:
```bash
# Get secrets from GCP
gcloud secrets versions access latest --secret=discord-bot-token --project=helicopter-ai
# Also need: GEMINI_API_KEY, GOOGLE_CLIENT_ID (from GCP console or .env backup)
```

## Step 5: Discord Bot Token in .mcp.json

The project-level `.mcp.json` also needs the token:
```bash
# Edit .mcp.json at project root, replace DISCORD_BOT_TOKEN value
```

## Step 6: Verify

```bash
cd ~/workspace/helicopter-ai
source .venv/bin/activate
pytest                          # unit tests
cd fe && npm run build          # frontend
claude                          # start Claude Code, check /mcp shows discord server
```

## Repo Guide

### helicopter-ai (main project)
Audio/video analysis pipeline. Upload recordings → chunked transcription → HTML report.

Key paths:
| Path | Purpose |
|------|---------|
| `fe/` | Next.js 16 frontend (React 19, Tailwind, shadcn/ui) |
| `services/` | FastAPI microservices (upload_ui, worker_v2, prepass, shard_worker_v2, reduce, report, on_call) |
| `shared/` | Core pipeline logic (chunker, gemini, html_report, llm_cache) |
| `prompts/` | Gemini prompt templates (en, he) |
| `scripts/` | Quality tests, migration tools, comparison scripts |
| `deploy_*.sh` | Per-service deployment scripts |
| `.mcp.json` | Project-level MCP config (Discord bot) |
| `.claude/agents/` | 10 specialized AI agents (synced from PM) |
| `.claude/skills/` | 9 slash commands (/plan, /status, /ship, etc.) |
| `.claude/mcp-servers/` | MCP server code (Discord bot) |
| `CLAUDE.md` | Project context, architecture, investigation log, session handoff |
| `dev-setup.sh` | Local dev environment setup |
| `setup.sh` | GCP project setup (APIs, Firestore) |
| `env.template` | Required env vars template |

### pm (project management)
Markdown-based PM system tracked in git. All state in YAML frontmatter.

```
projects/helicopter-ai/
  backlog/epics/E###.md      — feature epics
  backlog/items/W###.md      — work items (W001-W029+)
  decisions/ADR-###.md       — architecture decision records
  retros/YYYY-MM-DD-*.md     — session retrospectives
  definitions/               — source of truth for Claude Code config
    agents/*.md              — 10 agent definitions
    skills/*.md              — 9 skill definitions
    config/                  — settings, CLAUDE.md copies
    mcp-servers/             — MCP server source code
templates/                   — file templates (item, epic, ADR, retro)
```

Status flow: `pending → waiting → started → merged → deployed → tested → done`

Claude Code skills: `/plan`, `/status`, `/next`, `/done`, `/decide`, `/retro`, `/ship`, `/update-status`, `/save-session`

### dotfiles (Claude Code global config sync)
Syncs `~/.claude/` config between machines.

| File | Purpose | Sync method |
|------|---------|-------------|
| `claude/CLAUDE.md` | Global instructions | symlink |
| `claude/settings.json` | Preferences | symlink |
| `claude/mcp.json` | MCP servers | copy (symlinks unsupported) |
| `setup.sh` | Install config | run once |
| `sync.sh` | Commit + push changes | run after edits |
| `NEW_MACHINE.md` | This file | reference |

## MCP Servers

### Discord Bot
Full Discord integration via REST API (discord.js). No persistent gateway connection.

Tools: `discord_send`, `discord_send_embed`, `discord_read`, `discord_react`, `discord_reply`, `discord_list_channels`

- Config locations: `.mcp.json` (project root) + `~/.claude/mcp.json` (user level)
- Server code: `.claude/mcp-servers/discord-webhook/index.js`
- Source of truth: `pm/projects/helicopter-ai/definitions/mcp-servers/discord-webhook/`
- Token: GCP Secret Manager `discord-bot-token`
- Channels: #alerts (1460737935421739038), #bugs (1460737778089459834), #general (1460736650224074925)
- Bot invite URL: `https://discord.com/oauth2/authorize?client_id=1467620362035531788&scope=bot&permissions=68672`

### Playwright
Browser automation for E2E testing. Headless mode. No setup needed.

## GCP Resources

| Resource | Details |
|----------|---------|
| Project | `helicopter-ai` |
| Region | `us-central1` |
| Cloud Run | 8 services: fe, upload-ui, worker, worker-v2, prepass, shard-worker-v2, reduce, report, on-call |
| Firestore | Collections: upload_jobs, v2_jobs, v2_jobs/{id}/shards/, allowlist, share_tokens |
| GCS | Bucket: `helicopter-ai-uploads`, prefix: jobs/{job_id}/ |
| Pub/Sub | Topic: `dev-v2-shard-gpu`, push sub → shard-worker-v2 |
| Secrets | `discord-bot-token` |
| Service accounts | `tasks-invoker@helicopter-ai.iam.gserviceaccount.com` |

## Troubleshooting

**Discord MCP not showing in `/mcp`:**
- MCP config must be at `.mcp.json` (project root), NOT `.claude/mcp.json`
- Claude Code doesn't follow symlinks for MCP config
- Restart Claude Code after config changes

**Tests failing:**
- Activate venv: `source .venv/bin/activate`
- Check `.env` has all required vars
- Run `pytest -x` for first failure only

**GCP permission errors:**
- Re-auth: `gcloud auth application-default login`
- Check project: `gcloud config get-value project` (should be `helicopter-ai`)
