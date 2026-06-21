---
name: hermes-tweet
description: "Use when the user needs X/Twitter search, public reads, social listening, community audits, giveaway evidence, or gated posting through Hermes Agent. Provides native Hermes Tweet install, route-selection, and safety guidance for Claude Code sessions."
user-invocable: true
argument-hint: "[X/Twitter task or Hermes Agent handoff]"
---

# Hermes Tweet

Hermes Tweet is the native Hermes Agent plugin for X/Twitter work. This
Claude Code plugin is a companion guide: it helps you plan the Hermes Agent
handoff and keeps route selection inside the Hermes Tweet contract.

## When to Use

- The user asks for X/Twitter search, profile, tweet, trend, list, follower,
  reply, or social listening work.
- The task needs Hermes Agent rather than a Claude Code-only command.
- The user wants brand monitoring, community audits, public metrics, or
  giveaway evidence.
- The user explicitly allows a posting workflow and wants action gating kept
  visible.

## When Not to Use

- The target is a generic prompt, local command pack, IDE extension, or MCP
  server with no Hermes Agent handoff.
- The task asks for an X/Twitter post, like, repost, follow, or reply but the
  operator has not enabled Hermes Tweet actions.
- The user only needs repository changes unrelated to X/Twitter or Hermes Agent.

## Install

Install Hermes Tweet in Hermes Agent:

```bash
hermes plugins install Xquik-dev/hermes-tweet --enable
```

Configure reads with `XQUIK_API_KEY`.

Keep posting disabled unless the operator intentionally enables it:

```bash
export HERMES_TWEET_ENABLE_ACTIONS=false
```

Use `true` only for sessions where the operator explicitly permits posting,
liking, reposting, following, or replying through Hermes Tweet.

## Route Selection

1. Start with `tweet_explore` to find catalog-listed routes.
2. Use `tweet_read` for searches, profiles, tweets, replies, lists, trends,
   monitors, metrics, and audit evidence.
3. Use `tweet_action` only after confirming
   `HERMES_TWEET_ENABLE_ACTIONS=true` and the user asked for an action.
4. If the user provides a copied endpoint URL, accept it only when it resolves
   to a catalog-listed `/api/v1/...` path.

## Planning Checklist

- Restate the X/Twitter goal and whether it is read-only or action-enabled.
- Identify the expected Hermes Tweet route with `tweet_explore` first.
- Keep account, API-key, and action-enable details out of public output.
- Prefer read evidence before any action route.
- For posting plans, draft content separately and ask for explicit operator
  confirmation before action execution.

## Useful Task Shapes

- Social listening: search terms, accounts, trends, and monitor candidates.
- Community audits: collect replies, follower signals, engagement, and public
  evidence before summarizing.
- Giveaway checks: gather tweet, reply, follower, list, and draw evidence before
  declaring eligibility.
- Posting workflows: prepare copy, validate target route, and keep action
  execution behind the explicit Hermes Tweet action gate.
