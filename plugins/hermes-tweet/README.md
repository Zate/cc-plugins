# hermes-tweet

Guidance for using [Hermes Tweet](https://github.com/Xquik-dev/hermes-tweet),
the native Hermes Agent plugin for X/Twitter search, public reads, social
listening, community audits, and explicitly gated posting.

## Install

Install this Claude Code companion from the cc-plugins marketplace:

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install hermes-tweet
```

Install the actual Hermes Agent plugin in a Hermes Agent environment:

```bash
hermes plugins install Xquik-dev/hermes-tweet --enable
```

Set `XQUIK_API_KEY` for read routes. Leave posting disabled unless the operator
explicitly opts in:

```bash
export HERMES_TWEET_ENABLE_ACTIONS=false
```

Use `true` only when a session is intentionally allowed to post, like, repost,
or reply through Hermes Tweet.

## Usage

Invoke the skill when Claude Code needs to plan or hand off X/Twitter work to
Hermes Agent:

```bash
/hermes-tweet monitor launch mentions for our product
```

The skill keeps Claude Code focused on the Hermes Tweet contract:

- Use `tweet_explore` first to find catalog-listed routes.
- Use `tweet_read` for public reads, social listening, metrics, and audits.
- Use `tweet_action` only when `HERMES_TWEET_ENABLE_ACTIONS=true`.
- Keep copied endpoint URLs limited to catalog-listed `/api/v1/...` paths.

## When to Use

- Search X/Twitter content from a Hermes Agent workflow.
- Audit public replies, followers, trends, lists, or giveaway evidence.
- Build social listening or brand monitoring plans that need Hermes-native
  tooling.
- Draft a safe posting workflow where actions are explicitly operator-gated.

## When Not to Use

- You only need a generic Claude Code prompt or command pack.
- You need an MCP server, browser extension, or IDE-specific integration.
- The task should run entirely inside Claude Code without Hermes Agent.

## Safety

Hermes Tweet separates discovery, reads, and actions. Read tasks need
`XQUIK_API_KEY`. Write actions also require
`HERMES_TWEET_ENABLE_ACTIONS=true`, so review plans before enabling them.
