# Universal Attack-Surface Taxonomy

Use this taxonomy before finalizing findings. It is intentionally generic: apply it to desktop apps, web services, CLIs, libraries, mobile apps, agents, infrastructure repos, and external codebases.

For each category, record:

| Field | Meaning |
|---|---|
| Surface | Named endpoint/API/channel/parser/store/tool/config/etc. |
| Location | File and line evidence |
| Entry condition | What must happen for input/control to reach it |
| Caller / attacker | Who can invoke or influence it |
| Authority reached | What privilege, identity, data, OS, cloud, or tool authority it can reach |
| Data touched | Sensitive data, credentials, user/tenant data, logs, configs |
| Trust boundary | Lower-trust → higher-trust transition, tenant/user boundary, local→cloud, model→tool, etc. |
| Validation/auth | AuthN/AuthZ/schema/allowlist/rate-limit/sandbox controls |
| Open questions | Runtime/platform facts not visible from repo |

## 1. Network surfaces

Anything that accepts or initiates network communication.

Examples:
- HTTP routes, controllers, API handlers
- localhost APIs and local service clients
- listeners and bound ports
- WebSockets, SSE, gRPC, GraphQL
- webhooks and callbacks
- update feeds and downloaders
- cloud API clients and service discovery

Search concepts:
```text
listen createServer server.listen localhost 127.0.0.1 0.0.0.0 port route router endpoint websocket ws:// http:// https:// webhook callback fetch request axios net.request grpc graphql
```

## 2. IPC / RPC / message surfaces

Anything that crosses process, thread, worker, browser, queue, service, tool, or protocol boundaries.

Examples:
- IPC, RPC, JSON-RPC, MCP
- postMessage, workers, browser bridges
- queues, pub/sub, event buses
- named pipes, Unix sockets, stdio protocols
- background jobs and task dispatch

Search concepts:
```text
ipc postMessage worker queue pubsub event message channel invoke send handle subscribe publish stdio rpc mcp tool_call job task
```

## 3. User-controlled input and parser surfaces

Anything that parses, renders, accepts, or transforms attacker/user-controlled data.

Examples:
- forms and JSON bodies
- files, uploads, downloads, archives
- URLs and query parameters
- markdown, HTML, XML, YAML, templates
- images, audio, media, documents
- CLI args, environment variables, config files
- clipboard, drag/drop, browser content, model output

Search concepts:
```text
parse JSON.parse yaml xml html markdown file upload download archive clipboard argv env URL URLSearchParams FormData template sanitize validate decode deserialize
```

## 4. Privilege / authority surfaces

Anything that performs high-impact actions or reaches elevated authority.

Examples:
- auth tokens, secrets, credentials
- admin operations and settings changes
- file writes/deletes
- shell/tool execution
- cloud API calls and impersonation
- tenant switching and delegated authority
- OS permissions, keychain, browser opener

Search concepts:
```text
token secret credential admin permission scope role settings write delete exec spawn shell openExternal sudo keychain safeStorage impersonate delegate authorize policy
```

## 5. Persistence surfaces

Anything that stores, caches, logs, indexes, remembers, queues, or syncs state.

Examples:
- databases and local files
- caches, cookies, browser storage
- logs, telemetry, traces
- queues and durable jobs
- settings/config/state files
- backups, exports, vector stores, memory

Search concepts:
```text
writeFile readFile storage cache cookie localStorage sessionStorage indexedDB sqlite postgres redis log telemetry settings config queue export backup memory vector
```

## 6. Code execution and extension surfaces

Anything that runs code, tools, templates, scripts, plugins, native modules, dynamic content, or updates.

Examples:
- child processes, shell commands, subprocesses
- plugin/extension/tool systems
- MCP/tool execution
- eval/dynamic Function
- template engines and deserialization
- native modules
- browser rendering of untrusted content
- package scripts, CI scripts, auto-update installers

Search concepts:
```text
eval Function spawn exec fork child_process plugin extension tool script template deserialize native postinstall preinstall install update render webview mcp
```

## 7. Trust-boundary surfaces

Anything where data/control crosses from lower trust to higher trust, one principal to another, or one tenant/user/domain to another.

Examples:
- renderer → main, browser → native, model → tool
- user → service, tenant A → shared backend
- local process → app, external content → parser
- CI artifact → production release
- plugin/integration → host app
- service → service with preserved/delegated identity

Search concepts:
```text
boundary bridge contextBridge middleware auth authorize tenant scope principal actor origin referer sender issuer audience subject claim policy allowlist sandbox
```

## 8. Supply-chain / update surfaces

Anything that imports, builds, installs, signs, packages, updates, deploys, or verifies artifacts.

Examples:
- package manifests and lockfiles
- native dependencies and binaries
- build scripts and package lifecycle hooks
- container images
- CI/CD workflows and deployment scripts
- artifact signing, checksums, provenance
- update manifests and downloaders

Search concepts:
```text
package.json lock Dockerfile workflow pipeline release sign verify checksum sha256 update download install postinstall preinstall provenance sbom publish deploy
```

## 9. Observability / response surfaces

Anything that logs, alerts, audits, traces, records, suppresses, deletes evidence, or enables response.

Examples:
- audit logs and app logs
- security events and policy denials
- telemetry, Sentry, tracing, metrics
- redaction, retention, rotation
- alerting and dashboards
- revocation, quarantine, kill switches, feature flags
- evidence tampering and debug modes

Search concepts:
```text
audit log logger telemetry sentry trace metric alert redact retention rotate debug kill disable revoke quarantine featureFlag deny policy_denied security_event
```

## Breadth check

Before final findings:
- Every category should have inventoried surfaces or an evidence-backed “not applicable”.
- If one subsystem dominates findings, perform a breadth pass over the other categories.
- Do not call Deep mode complete if major source directories or surface categories are only implicitly covered.
