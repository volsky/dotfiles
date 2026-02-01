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

## Step 2: Dotfiles (Claude Code config)

```bash
cd ~/workspace/dotfiles && ./setup.sh
```

This copies/symlinks to `~/.claude/`:
- `CLAUDE.md` — global Claude Code instructions (concise style, git workflow, PR rules)
- `settings.json` — editor preferences
- `mcp.json` — MCP server config (Discord bot, Playwright)

## Step 3: Helicopter AI

```bash
cd ~/workspace/helicopter-ai
chmod +x dev-setup.sh && ./dev-setup.sh
```

Then edit `.env` with credentials. Get secrets from GCP:
```bash
gcloud auth login && gcloud auth application-default login
gcloud secrets versions access latest --secret=discord-bot-token --project=helicopter-ai
# Copy GEMINI_API_KEY, GOOGLE_CLIENT_ID from GCP console or existing .env backup
```

## Step 4: Verify

```bash
cd ~/workspace/helicopter-ai
source .venv/bin/activate
pytest                          # unit tests
cd fe && npm run build          # frontend
```

## Repo Guide

### helicopter-ai (main project)
Audio/video analysis pipeline. Upload recordings → chunked transcription → HTML report.

Key paths:
- `fe/` — Next.js 16 frontend
- `services/` — FastAPI microservices (upload_ui, worker_v2, prepass, shard_worker_v2, reduce, report)
- `shared/` — Core pipeline logic
- `prompts/` — Gemini prompt templates (en, he)
- `scripts/` — Quality tests, migration tools
- `deploy_*.sh` — Service deployment scripts
- `.claude/agents/` — 10 specialized AI agents
- `.claude/skills/` — 9 slash commands (/plan, /status, /ship, etc.)
- `.mcp.json` — Project-level MCP config (Discord bot)
- `CLAUDE.md` — Project context, architecture, investigation log, session handoff

### pm (project management)
Markdown-based PM system tracked in git. All state in YAML frontmatter.

Structure:
```
projects/helicopter-ai/
  backlog/epics/E###.md    — feature epics (E001=V2 Pipeline, E002=UI Redesign)
  backlog/items/W###.md    — work items (W001-W029+)
  decisions/ADR-###.md     — architecture decisions (ADR-001=Pub/Sub over Cloud Tasks)
  retros/YYYY-MM-DD-*.md   — session retrospectives
  definitions/             — agent/skill/config definitions (source of truth)
templates/                 — file templates for items, epics, ADRs, retros
```

Status flow: `pending → waiting → started → merged → deployed → tested → done`

Claude Code skills: `/plan`, `/status`, `/next`, `/done`, `/decide`, `/retro`

### dotfiles (Claude Code config sync)
Syncs `~/.claude/` config between machines.

- `claude/CLAUDE.md` — global instructions
- `claude/settings.json` — preferences
- `claude/mcp.json` — MCP servers
- `setup.sh` — install symlinks
- `sync.sh` — commit + push changes

## MCP Servers

### Discord Bot
Full Discord integration via bot token. Tools: send, read, react, reply, list_channels.
- Config: `.mcp.json` (project root) + `~/.claude/mcp.json` (user level)
- Server code: `.claude/mcp-servers/discord-webhook/`
- Token: GCP Secret Manager `discord-bot-token`
- Channels: #alerts, #bugs, #general

### Playwright
Browser automation for E2E testing. Headless mode.

## GCP Resources

- Project: `helicopter-ai`
- Region: `us-central1`
- Cloud Run: 7 services (fe, upload-ui, worker-v2, prepass, shard-worker-v2, reduce, report)
- Firestore: `upload_jobs`, `v2_jobs`, `v2_jobs/{id}/shards/`
- GCS: `helicopter-ai-uploads` (jobs/{job_id}/ prefix)
- Pub/Sub: `dev-v2-shard-gpu` topic
- Secrets: `discord-bot-token`
