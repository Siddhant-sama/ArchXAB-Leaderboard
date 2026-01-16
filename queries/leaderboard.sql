-- ArchXGreen Leaderboard SQL Queries
-- These queries power the leaderboard display on AgentBeats
-- 
-- SQL queries follow the AgentBeats leaderboard query format.
-- Results are used to render customizable leaderboard tables and visualizations.

-- ========== Main Leaderboard Query ==========
-- Displays ranking of purple agents by weighted score and pass rate

SELECT
  ROW_NUMBER() OVER (ORDER BY weighted_score DESC) as rank,
  purple_agent_name,
  total_tasks_evaluated,
  tasks_passed,
  ROUND(pass_rate * 100, 2) as pass_rate_pct,
  ROUND(weighted_score, 2) as weighted_score,
  best_submission_timestamp,
  submission_count,
  latest_submission_timestamp
FROM (
  SELECT
    purple_agent_name,
    COUNT(DISTINCT task_id) as total_tasks_evaluated,
    COUNT(DISTINCT CASE WHEN task_passed = true THEN task_id END) as tasks_passed,
    CAST(COUNT(DISTINCT CASE WHEN task_passed = true THEN task_id END) AS FLOAT) 
      / COUNT(DISTINCT task_id) as pass_rate,
    -- Weighted score: sum of (difficulty_weight * task_passed) / total_weight
    ROUND(
      SUM(CASE WHEN task_passed = true THEN difficulty_weight ELSE 0 END) 
        / SUM(difficulty_weight), 
      2
    ) as weighted_score,
    MAX(submission_timestamp) as best_submission_timestamp,
    COUNT(DISTINCT submission_id) as submission_count,
    MAX(submission_timestamp) as latest_submission_timestamp
  FROM assessment_results
  WHERE submission_status = 'completed'
  GROUP BY purple_agent_name
) leaderboard_data
ORDER BY weighted_score DESC, pass_rate DESC;

-- ========== Per-Level Performance ==========
-- Shows how each purple agent performs on each difficulty level

SELECT
  purple_agent_name,
  difficulty_level,
  COUNT(DISTINCT task_id) as tasks_in_level,
  COUNT(DISTINCT CASE WHEN task_passed = true THEN task_id END) as tasks_passed_in_level,
  ROUND(
    CAST(COUNT(DISTINCT CASE WHEN task_passed = true THEN task_id END) AS FLOAT) 
      / COUNT(DISTINCT task_id) * 100, 
    2
  ) as pass_rate_pct,
  AVG(evaluation_time_seconds) as avg_eval_time_sec,
  MAX(submission_timestamp) as latest_submission
FROM assessment_results
WHERE submission_status = 'completed'
GROUP BY purple_agent_name, difficulty_level
ORDER BY purple_agent_name, difficulty_level;

-- ========== Submission History ==========
-- Timeline of all submissions with progressive scores

SELECT
  submission_timestamp,
  purple_agent_name,
  submission_id,
  tasks_passed,
  total_tasks_evaluated,
  ROUND(
    CAST(tasks_passed AS FLOAT) / total_tasks_evaluated * 100, 
    2
  ) as pass_rate_pct,
  ROUND(weighted_score, 2) as weighted_score,
  github_commit_sha,
  github_actor,
  submission_status
FROM (
  SELECT
    MAX(submission_timestamp) as submission_timestamp,
    purple_agent_name,
    submission_id,
    COUNT(DISTINCT CASE WHEN task_passed = true THEN task_id END) as tasks_passed,
    COUNT(DISTINCT task_id) as total_tasks_evaluated,
    SUM(CASE WHEN task_passed = true THEN difficulty_weight ELSE 0 END) 
      / SUM(difficulty_weight) as weighted_score,
    github_commit_sha,
    github_actor,
    submission_status
  FROM assessment_results
  GROUP BY submission_id, purple_agent_name, github_commit_sha, github_actor, submission_status
) submission_summary
ORDER BY submission_timestamp DESC;

-- ========== Task Performance Summary ==========
-- Which tasks are hardest/easiest and which agents solve them

SELECT
  task_id,
  difficulty_level,
  difficulty_weight,
  COUNT(DISTINCT CASE WHEN task_passed = true THEN purple_agent_name END) as agents_passed_count,
  COUNT(DISTINCT purple_agent_name) as total_attempts,
  ROUND(
    CAST(COUNT(DISTINCT CASE WHEN task_passed = true THEN purple_agent_name END) AS FLOAT)
      / COUNT(DISTINCT purple_agent_name) * 100,
    2
  ) as pass_rate_pct,
  ROUND(AVG(evaluation_time_seconds), 2) as avg_eval_time_sec,
  MAX(submission_timestamp) as last_attempted
FROM assessment_results
WHERE submission_status = 'completed'
GROUP BY task_id, difficulty_level, difficulty_weight
ORDER BY pass_rate_pct ASC, difficulty_weight DESC;

-- ========== Best Performers by Level ==========
-- Top agent for each difficulty level

SELECT DISTINCT
  difficulty_level,
  purple_agent_name,
  level_pass_rate,
  level_rank
FROM (
  SELECT
    difficulty_level,
    purple_agent_name,
    ROUND(
      CAST(COUNT(DISTINCT CASE WHEN task_passed = true THEN task_id END) AS FLOAT)
        / COUNT(DISTINCT task_id) * 100,
      2
    ) as level_pass_rate,
    ROW_NUMBER() OVER (
      PARTITION BY difficulty_level 
      ORDER BY COUNT(CASE WHEN task_passed = true THEN task_id END) DESC
    ) as level_rank
  FROM assessment_results
  WHERE submission_status = 'completed'
  GROUP BY difficulty_level, purple_agent_name
) ranked
WHERE level_rank = 1
ORDER BY difficulty_level;

-- ========== Recent Activity ==========
-- Last 10 submissions across all agents

SELECT
  submission_timestamp,
  purple_agent_name,
  tasks_passed,
  total_tasks,
  ROUND(
    CAST(tasks_passed AS FLOAT) / total_tasks * 100,
    2
  ) as pass_rate_pct,
  github_actor,
  submission_status
FROM (
  SELECT
    submission_timestamp,
    purple_agent_name,
    SUM(CASE WHEN task_passed = true THEN 1 ELSE 0 END) as tasks_passed,
    COUNT(*) as total_tasks,
    github_actor,
    submission_status,
    ROW_NUMBER() OVER (PARTITION BY submission_id ORDER BY submission_timestamp DESC) as rn
  FROM assessment_results
  GROUP BY submission_timestamp, purple_agent_name, github_actor, submission_status, submission_id
) recent
WHERE rn = 1
ORDER BY submission_timestamp DESC
LIMIT 10;
