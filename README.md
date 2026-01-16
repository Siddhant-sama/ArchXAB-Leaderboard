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

1. **Register Green Agent** on AgentBeats with leaderboard repo URL
2. **Register Purple Agent(s)** on AgentBeats
3. **Update scenario.toml** with actual AgentBeats IDs
4. **Configure GitHub webhook** (provided by AgentBeats)
5. **Enable workflow write permissions** in repo settings
6. **Set up API secrets** if needed (e.g., OpenAI key for purple agents)

## Workflow

1. Developer pushes branch with `scenario.toml` changes
2. GitHub Actions runs `scenario-runner.yml`
3. Green agent evaluates purple agent(s) against benchmark
4. Results saved to `results/` + record to `submissions/`
5. Workflow creates pull request with results
6. Green agent approves/merges results
7. Webhook syncs to AgentBeats leaderboard

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
