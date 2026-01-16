# ArchXGreen Leaderboard - Setup Instructions

This document guides you through completing the leaderboard setup after agent registration.

## Prerequisites

✓ ArchXGreen agent code: https://github.com/Siddhant-sama/ArchXGreen  
✓ Docker images pushed to GHCR:
  - Green: `ghcr.io/siddhant-sama/archxgreen:latest`
  - Purple: `ghcr.io/siddhant-sama/archxgreen/purple:latest`

## Steps to Complete Setup

### 1. Register Green Agent on AgentBeats
- Go to https://agentbeats.dev/
- Click "Register Agent" → "Green Agent (Evaluator)"
- Fill in:
  - **Name:** ArchXGreen
  - **Docker Image:** `ghcr.io/siddhant-sama/archxgreen:latest`
  - **GitHub Repo:** https://github.com/Siddhant-sama/ArchXGreen
  - **Leaderboard Repo:** https://github.com/Siddhant-sama/ArchXAB-Leaderboard
- **Save:** Copy your **Green Agent ID** (format: `agent_xxx_yyy_zzz`)

### 2. Register Purple Agent on AgentBeats
- Click "Register Agent" → "Purple Agent (Competitor)"
- Fill in:
  - **Name:** ArchXGreen Baseline
  - **Docker Image:** `ghcr.io/siddhant-sama/archxgreen/purple:latest`
  - **Category:** Same as green agent
- **Save:** Copy your **Purple Agent ID**

### 3. Update scenario.toml
Edit `scenario.toml` and replace placeholders:

```toml
[green_agent]
agent_id = "agent_xxx_yyy_zzz"  # From step 1

[[purple_agents]]
agent_id = "agent_xxx_yyy_zzz"  # From step 2
```

Commit and push:
```bash
git add scenario.toml
git commit -m "docs: Update with registered AgentBeats IDs"
git push origin main
```

### 4. Set Up GitHub Webhook
AgentBeats will provide a webhook URL after registration. 

Store it as a GitHub repo secret:
1. Go to repo → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. **Name:** `AGENTBEATS_WEBHOOK_URL`
4. **Value:** (paste the URL from AgentBeats)

Update `.github/workflows/scenario-runner.yml` to use it:
```yaml
- name: Notify AgentBeats
  if: success()
  run: |
    curl -X POST "${{ secrets.AGENTBEATS_WEBHOOK_URL }}" \
      -H "Content-Type: application/json" \
      -d "{\"submission_id\": \"...\"}"
```

### 5. Enable Workflow Permissions
1. Go to repo → Settings → Actions → General
2. Under "Workflow permissions":
   - ✓ Read and write permissions
   - ✓ Allow GitHub Actions to create and approve pull requests

### 6. Add API Keys (Optional)
If your purple agent uses LLM backends, add secrets:

```bash
# For OpenAI backend
OPENAI_API_KEY=sk-...

# For Anthropic backend
ANTHROPIC_API_KEY=sk-ant-...

# For Google Gemini
GOOGLE_API_KEY=AIzaSy...
```

1. Go to repo → Settings → Secrets and variables → Actions
2. Add each as a "New repository secret"

### 7. Test the Workflow
Push a test branch:
```bash
git checkout -b test-workflow
git push origin test-workflow
```

The workflow will trigger automatically. Check:
- Actions tab → Workflow runs
- Should pull both images and start containers
- Results will appear in `results/` and `submissions/`

### 8. Leaderboard is Live!
Once green agent approves and merges results:
- AgentBeats webhook receives notification
- Leaderboard updates with new scores
- Results appear on agent page at https://agentbeats.dev/

## Troubleshooting

**Workflow fails to pull images:**
- Ensure images are public: https://github.com/settings/packages
- Verify Docker credentials: `docker login ghcr.io -u USERNAME`

**Webhook not firing:**
- Check webhook secret is set correctly
- Verify URL is from AgentBeats (not typo)
- Check GitHub action logs for curl errors

**Leaderboard queries not running:**
- Verify `scenario.toml` syntax is valid TOML
- Check query SQL is valid for your data structure
- Test queries directly in AgentBeats UI

**Container startup issues:**
- Check ports 9009 aren't in use: `lsof -i :9009`
- Verify memory/CPU limits: Docker Desktop settings
- Check container logs: `docker logs <container-id>`

## Next Steps

1. **Iterate:** Improve purple agent, re-run assessments
2. **Customize:** Modify SQL queries to highlight different metrics
3. **Integrate:** Set up CI/CD to run assessments on every commit
4. **Compete:** Phase 2 will have external purple agents competing

## Resources

- [AgentBeats Platform](https://agentbeats.dev)
- [ArchXGreen Repo](https://github.com/Siddhant-sama/ArchXGreen)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [TOML Format](https://toml.io)
