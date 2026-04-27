import { Type } from "typebox";
import { StringEnum } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { PlanManager } from "./PlanManager.js";

export function registerTools(pi: ExtensionAPI) {
  pi.registerTool({
    name: "devloop_update_task",
    label: "Devloop: Update Task",
    description: "Update the status of a specific task in the devloop plan",
    parameters: Type.Object({
      taskId: Type.String({ description: "The ID of the task to update" }),
      status: StringEnum(["done", "blocked", "in_progress", "pending"] as const),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const manager = new PlanManager(ctx.cwd);
      const plan = await manager.loadPlan();
      if (!plan) return { content: [{ type: "text", text: "Error: No active plan." }], details: {} };

      let found = false;
      for (const phase of plan.phases) {
        for (const task of phase.tasks) {
          if (task.id === params.taskId) {
            task.status = params.status as any;
            found = true;
            break;
          }
        }
        if (found) break;
      }

      if (!found) return { content: [{ type: "text", text: `Error: Task ${params.taskId} not found.` }], details: {} };

      await manager.savePlan(plan);
      await manager.updateUI(ctx);

      return { content: [{ type: "text", text: `Task ${params.taskId} updated to ${params.status}.` }], details: {} };
    }
  });

  pi.registerTool({
    name: "devloop_add_task",
    label: "Devloop: Add Task",
    description: "Add a new task to a specific phase in the devloop plan",
    parameters: Type.Object({
      phaseId: Type.String({ description: "The ID of the phase to add the task to" }),
      taskId: Type.String({ description: "A unique short ID for the new task" }),
      title: Type.String({ description: "The title of the task" }),
      description: Type.Optional(Type.String({ description: "Detailed description of what to do" }))
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const manager = new PlanManager(ctx.cwd);
      const plan = await manager.loadPlan();
      if (!plan) return { content: [{ type: "text", text: "Error: No active plan." }], details: {} };

      const phase = plan.phases.find(p => p.id === params.phaseId);
      if (!phase) return { content: [{ type: "text", text: `Error: Phase ${params.phaseId} not found.` }], details: {} };

      phase.tasks.push({
        id: params.taskId,
        title: params.title,
        description: params.description,
        status: "pending"
      });

      await manager.savePlan(plan);
      await manager.updateUI(ctx);

      return { content: [{ type: "text", text: `Task ${params.taskId} added to phase ${params.phaseId}.` }], details: {} };
    }
  });

  pi.registerTool({
    name: "devloop_save_plan",
    label: "Devloop: Save Plan",
    description: "Save a new plan.",
    parameters: Type.Object({
      title: Type.String(),
      phases: Type.Array(Type.Object({
        title: Type.String(),
        tasks: Type.Array(Type.String({ description: "Task title" }))
      }))
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const manager = new PlanManager(ctx.cwd);
      const plan = PlanManager.parsePlan(params.title, params.phases);
      await manager.savePlan(plan);
      await manager.updateUI(ctx);
      return { content: [{ type: "text", text: "Plan saved successfully." }], details: {} };
    }
  });

  pi.registerTool({
    name: "devloop_save_epic",
    label: "Devloop: Save Epic",
    description: "Save a multi-phase epic.",
    parameters: Type.Object({
      title: Type.String(),
      phases: Type.Array(Type.String({ description: "Phase title" }))
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const manager = new PlanManager(ctx.cwd);
      const epic = PlanManager.parseEpic(params.title, params.phases);
      await manager.saveEpic(epic);
      
      // Automatically promote first phase
      const savedEpic = await manager.loadEpic();
      if (savedEpic && savedEpic.phases.length > 0) {
        savedEpic.phases[0].status = "in_progress";
        await manager.saveEpic(savedEpic);
        await manager.savePlan(savedEpic.phases[0].plan);
      }
      
      return { content: [{ type: "text", text: "Epic saved and first phase promoted." }], details: {} };
    }
  });

  pi.registerTool({
    name: "devloop_complete_epic_phase",
    label: "Devloop: Complete Epic Phase",
    description: "Mark the current epic phase as done and queue the next phase.",
    parameters: Type.Object({}),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      pi.sendUserMessage("/devloop next-phase", { deliverAs: "followUp" });
      return { content: [{ type: "text", text: "Queued /devloop next-phase." }], details: {} };
    }
  });

  pi.registerTool({
    name: "devloop_archive_plan",
    label: "Devloop: Archive Plan",
    description: "Permanently archive the plan after the ritual is complete.",
    parameters: Type.Object({}),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const manager = new PlanManager(ctx.cwd);
      await manager.deletePlan();
      await manager.updateUI(ctx);
      return { content: [{ type: "text", text: "Plan archived." }], details: {} };
    }
  });
}
