Create a Fastify REST API for user management with the following requirements:

## Endpoints
- GET /users - List all users
- POST /users - Create a new user (requires name and email, generates UUID v7 for id)
- GET /users/:id - Get user by ID (return 404 if not found)

## Technical Requirements
- Persist users to users.json file
- Use ES modules (type: module in package.json)
- Include proper error handling
- Add input validation for POST

## Testing Requirements
- Write tests using mocha and superagent
- Include test coverage using c8
- Tests should cover: list users, create user, get user, 404 case

## Deliverables
- Working server.js (or index.js)
- package.json with all dependencies
- test/users.test.js with tests
- README.md with setup instructions

Start implementation now. Do not ask clarifying questions.
