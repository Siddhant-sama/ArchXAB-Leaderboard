# Queries

SQL queries that power the leaderboard display on AgentBeats.

## Files

- `leaderboard.sql` - All standard leaderboard queries

## Query Categories

### Main Leaderboard
- Overall ranking by weighted score and pass rate
- Per-level performance breakdown
- Submission history timeline
- Task difficulty analysis
- Best performers by level
- Recent activity feed

## AgentBeats Integration

These queries are referenced in `scenario.toml` and executed by AgentBeats to:
1. Render leaderboard tables
2. Generate visualizations
3. Compute rankings
4. Track historical progression

## Usage

Copy query snippets into your leaderboard config or directly into the AgentBeats platform settings.

See [AgentBeats documentation](https://agentbeats.dev/docs) for details on query format and integration.
