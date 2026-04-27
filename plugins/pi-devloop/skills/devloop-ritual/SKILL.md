---
name: devloop-ritual
description: Perform this ritual at the very end of a plan before archiving.
---

# Devloop Ritual
Perform these steps in order to archive your work:
1. **Sync Repo DNA**: Review .pi/context/repo.md and update it with architectural or convention changes from this plan.
2. **Docs Sync**: Ensure documentation reflects the current state.
3. **Build/Lint**: Run the project's build and lint commands.
4. **Validation**: Run tests to confirm the current state.
5. **Atomic Commit**: Perform a final commit with a clear message.
6. **Archive**: Mark the plan as 'done' and confirm you are ready.
