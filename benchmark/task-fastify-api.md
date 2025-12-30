Create a Fastify REST API for user management. Follow these exact specifications - do not ask any questions.

## Endpoints
- GET /users - List all users (return array from users.json, or empty array if file doesn't exist)
- POST /users - Create user with {name, email} body, generate UUID v7 for id, append to users.json
- GET /users/:id - Get user by ID, return 404 with {error: "User not found"} if not found

## Technical Decisions (DO NOT ask about these)
- Use Fastify with ES modules (type: module)
- Store users in users.json in project root
- Use uuid package for UUID v7 generation
- Port 3000, host 0.0.0.0
- Validate POST body: name (string, required), email (string, required, must contain @)
- Return 400 with {error: "..."} for validation failures

## Testing Decisions (DO NOT ask about these)
- Use mocha as test framework
- Use superagent for HTTP requests
- Use c8 for coverage
- Tests go in test/users.test.js
- Test cases: list empty, create user, create invalid user, get user, get 404

## File Structure
```
package.json
server.js
test/users.test.js
README.md
```

## Instructions
1. Create package.json with all dependencies
2. Create server.js with Fastify server
3. Create test/users.test.js with tests
4. Create brief README.md
5. Run npm install
6. Run tests to verify

CRITICAL INSTRUCTIONS:
- Do NOT use AskUserQuestion tool
- Do NOT ask for clarification
- Do NOT ask for confirmation
- Start implementation immediately
- Make reasonable assumptions for anything not specified
- Complete the entire task without stopping
