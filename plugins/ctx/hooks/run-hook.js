#!/usr/bin/env node
// Cross-platform hook dispatcher for ctx plugin.
// Spawns .sh (Unix) or .ps1 (Windows) based on platform.
// Usage: node run-hook.js <hook-name>
//   e.g. node run-hook.js session-start

const { spawn } = require("child_process");
const path = require("path");

const hookName = process.argv[2];
if (!hookName) {
  process.stdout.write("{}");
  process.exit(0);
}

const hooksDir = __dirname;
const pluginRoot = path.dirname(hooksDir);
const isWindows = process.platform === "win32";

let child;
if (isWindows) {
  const ps1 = path.join(hooksDir, `${hookName}.ps1`);
  child = spawn(
    "powershell.exe",
    ["-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", ps1],
    { stdio: ["pipe", "pipe", "pipe"], env: { ...process.env, PLUGIN_ROOT: pluginRoot } }
  );
} else {
  const sh = path.join(hooksDir, `${hookName}.sh`);
  child = spawn("bash", [sh], {
    stdio: ["pipe", "pipe", "pipe"],
    env: { ...process.env, PLUGIN_ROOT: pluginRoot },
  });
}

process.stdin.pipe(child.stdin);
child.stdout.pipe(process.stdout);
child.stderr.pipe(process.stderr);

child.on("error", () => {
  process.stdout.write("{}");
  process.exit(0);
});

child.on("close", (code) => {
  process.exit(code || 0);
});
