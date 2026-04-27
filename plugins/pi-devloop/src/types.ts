export type TaskStatus = "pending" | "in_progress" | "done" | "blocked";

export interface Task {
  id: string;
  title: string;
  status: TaskStatus;
  description?: string;
}

export interface Phase {
  id: string;
  title: string;
  tasks: Task[];
}

export interface Plan {
  title: string;
  phases: Phase[];
}

export interface EpicPhase {
  id: string;
  title: string;
  description?: string;
  status: "pending" | "in_progress" | "done";
  plan: Plan;
}

export interface Epic {
  title: string;
  phases: EpicPhase[];
}

export type DevloopAction = "INIT" | "PLAN" | "RUN" | "RITUAL" | "PROMOTION";

export interface DevloopState {
  action: DevloopAction;
  message: string;
}
