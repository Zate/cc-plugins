import { join } from "node:path";
import { promises as fs } from "node:fs";
import type { Plan, Epic } from "./types.js";
import type { ExtensionContext } from "@mariozechner/pi-coding-agent";

export class PlanManager {
  private cwd: string;

  constructor(cwd: string) {
    this.cwd = cwd;
  }

  private get planPath(): string {
    return join(this.cwd, ".devloop", "plan.json");
  }

  private get epicPath(): string {
    return join(this.cwd, ".devloop", "epic.json");
  }

  async loadEpic(): Promise<Epic | null> {
    try {
      const content = await fs.readFile(this.epicPath, "utf-8");
      return JSON.parse(content) as Epic;
    } catch (e: any) {
      if (e.code === "ENOENT") return null;
      throw e;
    }
  }

  async saveEpic(epic: Epic): Promise<void> {
    const dir = join(this.cwd, ".devloop");
    await fs.mkdir(dir, { recursive: true });
    await fs.writeFile(this.epicPath, JSON.stringify(epic, null, 2), "utf-8");
  }

  async promoteNextPhase(): Promise<boolean> {
    const epic = await this.loadEpic();
    if (!epic) return false;

    let foundNext = false;
    let nextPhasePlan: Plan | null = null;

    // Mark current in_progress phase as done
    for (const phase of epic.phases) {
      if (phase.status === "in_progress") {
        phase.status = "done";
      }
    }

    // Find the next pending phase and make it in_progress
    for (const phase of epic.phases) {
      if (phase.status === "pending") {
        phase.status = "in_progress";
        nextPhasePlan = phase.plan;
        foundNext = true;
        break;
      }
    }

    await this.saveEpic(epic);

    if (foundNext && nextPhasePlan) {
      await this.savePlan(nextPhasePlan);
    } else {
      // Epic is completely done, we might want to clear the active plan
      try {
        await fs.unlink(this.planPath);
      } catch (e) {
        // ignore
      }
    }

    return foundNext;
  }

  async evaluateState(): Promise<DevloopState> {
    const repoPath = join(this.cwd, ".pi/context/repo.md");
    const repoExists = await fs.access(repoPath).then(() => true).catch(() => false);
    
    if (repoExists) {
      const content = await fs.readFile(repoPath, "utf-8");
      if (content.includes("ACTION REQUIRED")) {
        return { action: "INIT", message: "Project DNA is unpopulated. Running initialization..." };
      }
    } else {
      return { action: "INIT", message: "Initializing Project DNA..." };
    }

    const plan = await this.loadPlan();
    const epic = await this.loadEpic();

    if (!plan) {
      return { action: "PLAN", message: "No active plan found." };
    }

    const allDone = plan.phases.every(p => p.tasks.every(t => t.status === "done"));
    if (allDone) {
      if (epic && epic.phases.some(p => p.status === "pending")) {
        return { action: "PROMOTION", message: "Epic phase done, promoting next phase..." };
      }
      return { action: "RITUAL", message: "All tasks done. Ritual required." };
    }

    return { action: "RUN", message: "Resuming execution." };
  }

  async initializeRepoContext(): Promise<void> {
    const dir = join(this.cwd, ".pi/context");
    await fs.mkdir(dir, { recursive: true });
    
    // Deterministic, local-only scan
    const entries = await fs.readdir(this.cwd, { withFileTypes: true });
    const topLevelFiles = entries.filter(e => e.isFile()).map(e => e.name).slice(0, 10);
    const topLevelDirs = entries.filter(e => e.isDirectory() && !e.name.startsWith('.')).map(e => e.name).slice(0, 10);

    const content = `# Project DNA: ${this.cwd}
## Overview
Automatically initialized overview.

## Tech Stack
- Discovered top-level files: ${topLevelFiles.join(", ")}
- Discovered sub-directories: ${topLevelDirs.join(", ")}

## Directory Map
- .pi/context/repo.md: Project DNA.
- .devloop/: Workflow state.

## Rules of Engagement
- **Do NOT perform deep or recursive file searches (e.g. no 'find' in project root or parent directories).**
- All relevant project information is either in the directory map or should be added to this Project DNA.
- If you need to know about a file, only 'ls' the specific directory.

## Conventions
- **ACTION REQUIRED**: Review the files above and complete this overview.`;
    
    await fs.writeFile(join(dir, "repo.md"), content, "utf-8");
  }

  async loadPlan(): Promise<Plan | null> {
    try {
      const content = await fs.readFile(this.planPath, "utf-8");
      return JSON.parse(content) as Plan;
    } catch (e: any) {
      if (e.code === "ENOENT") {
        // Auto-initialize directory
        await fs.mkdir(join(this.cwd, ".devloop"), { recursive: true });
        return null;
      }
      throw e;
    }
  }

  async savePlan(plan: Plan): Promise<void> {
    const dir = join(this.cwd, ".devloop");
    await fs.mkdir(dir, { recursive: true });
    await fs.writeFile(this.planPath, JSON.stringify(plan, null, 2), "utf-8");
  }

  async deletePlan(): Promise<void> {
    try {
      await fs.unlink(this.planPath);
    } catch (e: any) {
      if (e.code !== "ENOENT") throw e;
    }
  }

  async updateUI(ctx: ExtensionContext): Promise<void> {
    if (!ctx.hasUI) return;

    const plan = await this.loadPlan();
    if (!plan) {
      const repoContextExists = await fs.access(join(this.cwd, ".pi/context/repo.md")).then(() => true).catch(() => false);
      const messages = ["No active plan. Use /devloop plan to create one."];
      if (!repoContextExists) {
        messages.push("Project DNA is missing. Use /devloop init to initialize.");
      }
      ctx.ui.setWidget("devloop", messages);
      return;
    }

    const lines: string[] = [`📝 ${plan.title}`];
    
    for (const phase of plan.phases) {
      lines.push(`\n## ${phase.title}`);
      for (const task of phase.tasks) {
        let icon = " ";
        if (task.status === "done") icon = "✅";
        else if (task.status === "in_progress") icon = "⏳";
        else if (task.status === "blocked") icon = "🛑";
        
        lines.push(`  [${icon}] ${task.id}: ${task.title}`);
      }
    }

    ctx.ui.setWidget("devloop", lines);
  }

  // Helpers to assist LLM parsing
  static parsePlan(title: string, phases: Array<{ title: string; tasks: string[] }>): Plan {
    return {
      title,
      phases: phases.map((p, pIdx) => ({
        id: `phase-${pIdx + 1}`,
        title: p.title,
        tasks: p.tasks.map((t, tIdx) => ({
          id: `task-${pIdx + 1}-${tIdx + 1}`,
          title: t,
          status: "pending"
        }))
      }))
    };
  }

  static parseEpic(title: string, phases: string[]): Epic {
    return {
      title,
      phases: phases.map((p, pIdx) => ({
        id: `phase-${pIdx + 1}`,
        title: p,
        status: "pending",
        plan: { title: p, phases: [{ id: "main", title: p, tasks: [] }] }
      }))
    };
  }
}
