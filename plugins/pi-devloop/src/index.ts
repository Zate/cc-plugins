import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { PlanManager } from "./PlanManager.js";
import { registerTools } from "./tools.js";
import { getBaseline } from "./baseline.js";
import { promises as fs } from "node:fs";
import { join } from "node:path";

export default function (pi: ExtensionAPI) {
  registerTools(pi);

  pi.on("before_agent_start", async (event, ctx) => {
    const baseline = await getBaseline();
    let repoContext = "";
    try {
      repoContext = await fs.readFile(join(ctx.cwd, ".pi/context/repo.md"), "utf-8");
    } catch (e) {
      // Auto-initialize repo.md
      const dir = join(ctx.cwd, ".pi/context");
      await fs.mkdir(dir, { recursive: true });
      repoContext = `# Project DNA: ${ctx.sessionManager.getSessionFile() || "New Project"}\n## Overview\nInitialize this project overview.\n**ACTION REQUIRED**: Since this is a new project, scan the repository (README.md, CLAUDE.md, etc.) and update this file with a high-level overview, tech stack, directory map, and project conventions.`;
      await fs.writeFile(join(dir, "repo.md"), repoContext, "utf-8");
    }

    const manager = new PlanManager(ctx.cwd);
    const plan = await manager.loadPlan();
    const taskContext = plan ? `Current Plan: ${JSON.stringify(plan)}` : "No active plan.";

    const layeredSystemPrompt = `
# SYSTEM BASELINE
${baseline}

# REPO CONTEXT
${repoContext}

# TASK CONTEXT
${taskContext}
`;

    return { systemPrompt: event.systemPrompt + layeredSystemPrompt };
  });

  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.notify("pi-devloop extension loaded!", "info");
    const manager = new PlanManager(ctx.cwd);
    await manager.updateUI(ctx);
  });

  pi.on("turn_end", async (_event, ctx) => {
    const manager = new PlanManager(ctx.cwd);
    await manager.updateUI(ctx);
  });

  pi.on("tool_result", async (event, ctx) => {
    if (event.toolName === "devloop_update_task") {
      const status = (event.input as any).status;
      if (status === "done") {
        const manager = new PlanManager(ctx.cwd);
        const plan = await manager.loadPlan();
        
        if (plan) {
          const allDone = plan.phases.every(p => p.tasks.every(t => t.status === "done"));
          if (allDone) {
            // Check if we already sent the ritual instruction to avoid spamming
            const epic = await manager.loadEpic();
            if (epic) {
               // ... existing epic logic
            } else {
               // We use a small file-based flag or simply check if the plan is already 'archived' state?
               // Actually, easier: only send the followUp if it hasn't been sent.
               // Let's rely on the ritual tool call to delete the plan.
               ctx.ui.notify("All tasks in the plan are complete! Please run the devloop-ritual skill.", "info");
               await pi.sendUserMessage("All tasks in the plan are complete! You must now perform the 'devloop-ritual' skill (build, lint, test, commit) and then call the 'devloop_archive_plan' tool to archive this plan.");
               return;
            }
          }
        }

        ctx.ui.notify(`Task ${(event.input as any).taskId} marked done. Proceeding to next task.`, "info");
        try {
          await pi.sendUserMessage("Task complete. Proceed to the next pending task in the plan.", { deliverAs: "followUp" });
        } catch (e) {
          ctx.ui.notify("Could not queue followUp task.", "error");
        }
      } else if (status === "blocked") {
        ctx.ui.notify(`Task ${(event.input as any).taskId} blocked. Pausing execution.`, "warning");
      }
    }
  });

  pi.registerCommand("devloop", {
    description: "Devloop: The autonomous project orchestrator",
    handler: async (args, ctx) => {
      const manager = new PlanManager(ctx.cwd);
      const state = await manager.evaluateState();

      switch (state.action) {
        case "INIT":
          ctx.ui.notify(state.message, "info");
          await manager.initializeRepoContext();
          await pi.sendUserMessage("I have initialized the Project DNA file. Please scan the repository (README.md, AGENTS.md, CLAUDE.md, etc.), analyze the structure, and update this file with a high-level overview, tech stack, and conventions.", { triggerTurn: true });
          break;
        case "PLAN":
          const feature = await ctx.ui.input("What feature or epic should we build?");
          if (feature) {
            await pi.sendUserMessage(`Create a structured development plan for: ${feature}\n\nGuidelines:\n1. Keep exploration brief.\n2. Break work into phases and tasks.\n3. Use devloop_save_plan tool to save.`, { triggerTurn: true });
          }
          break;
        case "RUN":
          ctx.ui.notify(state.message, "info");
          const plan = await manager.loadPlan();
          if (!plan) return;
          await ctx.newSession({
            setup: async (sm) => {
              const planText = JSON.stringify(plan, null, 2);
              sm.appendMessage({
                role: "user",
                content: [{ type: "text", text: `Resuming execution. Current plan:\n\`\`\`json\n${planText}\n\`\`\`\n\nAssess status and continue.` }],
                timestamp: Date.now(),
              });
            }
          });
          break;
        case "RITUAL":
          ctx.ui.notify(state.message, "info");
          await pi.sendUserMessage("All tasks are done! You must now perform the 'devloop-ritual' skill (build, lint, test, commit) and then call the 'devloop_archive_plan' tool to archive this plan.", { deliverAs: "steer", triggerTurn: true });
          break;
        case "PROMOTION":
          ctx.ui.notify(state.message, "info");
          await manager.promoteNextPhase();
          const newPlan = await manager.loadPlan();
          if (newPlan) {
            await ctx.newSession({
              setup: async (sm) => {
                sm.appendMessage({
                  role: "user",
                  content: [{ type: "text", text: `Promoted to next epic phase. Plan:\n\`\`\`json\n${JSON.stringify(newPlan, null, 2)}\n\`\`\`\n\nContinue execution.` }],
                  timestamp: Date.now(),
                });
              }
            });
          }
          break;
      }
    }
  });
}
