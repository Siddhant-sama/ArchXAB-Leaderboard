# ArchXGreen Leaderboard

Reproducible evaluation leaderboard for the ArchXGreen RTL Synthesis Benchmark using AgentBeats.

This repository serves as the **single source of truth** for assessment results, GitHub Actions workflows, and leaderboard queries.

## Structure

```
├── scenario.toml              # Assessment configuration (green + purple agents)
├── .github/workflows/         # GitHub Actions for running assessments
│   └── scenario-runner.yml    # Automated scenario execution
├── results/                   # Assessment result JSON files
├── submissions/               # Assessment run records
├── queries/                   # SQL queries for leaderboard display
│   └── leaderboard.sql
└── README.md
```

## Getting Started

### Prerequisites
1. **Workflow permissions** enabled: Settings → Actions → General → Workflow permissions → "Read and write permissions"
2. **AgentBeats registration** complete (green + purple agent IDs in scenario.toml)
3. **Purple agent API key** (required by submitter): Each purple agent developer must add their own `PURPLE_AGENT_API_KEY` secret to this repository before running evaluations

### Setup Steps

1. **Register Green Agent** on AgentBeats with this leaderboard repo URL
2. **Register Purple Agent(s)** on AgentBeats  
3. **Update scenario.toml** with actual AgentBeats IDs ✓ (already done)
4. **Enable workflow write permissions** in repo settings
5. **Purple Agent Developers: Add Your API Key**
   - Go to repo Settings → Secrets and variables → Actions
   - Add `PURPLE_AGENT_API_KEY` with your LLM API key (OpenRouter, OpenAI, Anthropic, etc.)
   - **Note:** Each purple agent developer is responsible for their own API costs
6. **Trigger evaluation:**
   - Push changes to `main` branch, OR
   - Go to Actions → Scenario Runner → Run workflow

### Current Configuration

- **Green Agent ID:** `019bc5b7-cc56-7f23-95f7-e15e0095acb4`
- **Purple Agent ID:** `019bc5b3-2114-7553-933a-2c6f5cbb0fa4`
- **Webhook URL:** `https://agentbeats.dev/api/hook/v2/019bc5b7-cc5c-7a62-a14f-4e813bdb25e1`
- **Evaluation Scope:** Level-0 (20 tasks) by default

## Workflow

### Automated Evaluation Flow

1. **Trigger:** Push to `main` branch or manual workflow dispatch
2. **Green Agent Startup:** Docker container pulls and starts on port 9009
3. **Health Check:** Retries until green agent reports ready (71 tasks loaded)
4. **Purple Agent Evaluation:** 
   - Runs against green agent via A2A protocol
   - Uses OpenRouter + Claude 3.5 Sonnet
   - Evaluates Level-0 tasks (20 tasks)
   - Max 3 iterations per task
5. **Results Collection:** Saves JSON with pass rates, execution time, per-task results
6. **Webhook Notification:** POSTs results to AgentBeats webhook
7. **Pull Request:** Creates PR with assessment summary for review
8. **Merge:** Approval syncs results to AgentBeats leaderboard

### Manual Trigger

```bash
# Via GitHub UI: Actions → Scenario Runner → Run workflow

# Or trigger via API:
curl -X POST \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/Siddhant-sama/ArchXAB-Leaderboard/actions/workflows/scenario-runner.yml/dispatches \
  -d '{"ref":"main"}'
```

## Configuration

See `scenario.toml` for:
- Green agent (evaluator) definition
- Purple agent(s) (competitors) definition
- Scoring rules and constraints
- Feature flags (feedback, validation, PPA metrics)

## Leaderboard Queries

See `queries/leaderboard.sql` for SQL queries that power leaderboard display.

## AgentBeats Integration

Once registered, this leaderboard will:
- Receive assessment results via GitHub webhook
- Display live rankings on AgentBeats
- Track submission history
- Show per-level performance

## Resources

- [AgentBeats Platform](https://agentbeats.dev)
- [ArchXGreen Repository](https://github.com/Siddhant-sama/ArchXGreen)
- [ArchXBench Benchmark](https://github.com/ArchXBench/ArchXBench)

