import { access } from "node:fs";
import { promisify } from "node:util";
import { spawn } from "node:child_process";
import path from "node:path";

const accessAsync = promisify(access);

export interface PreflightSnapshot {
  scripts: {
    bootstrap: string;
    verify: string;
    bootstrapExists: boolean;
    verifyExists: boolean;
  };
  tailscale: {
    path: string | null;
    isUp: boolean;
    ipOutput: string | null;
  };
  sudo: {
    cached: boolean;
  };
}

export async function collectPreflightSnapshot(playbookRoot: string): Promise<PreflightSnapshot> {
  const bootstrap = path.join(playbookRoot, "scripts", "bootstrap-mac-host.sh");
  const verify = path.join(playbookRoot, "scripts", "run-bootstrap-and-verify.sh");

  const [bootstrapExists, verifyExists] = await Promise.all([
    pathExists(bootstrap),
    pathExists(verify)
  ]);

  const tailscalePath = await commandPath("tailscale");
  const [tailscaleUp, tailscaleIp] = await Promise.all([
    checkTailscaleUp(tailscalePath),
    getTailscaleIp(tailscalePath)
  ]);
  const sudoCached = await hasSudoCachedCredentials();

  return {
    scripts: {
      bootstrap,
      verify,
      bootstrapExists,
      verifyExists
    },
    tailscale: {
      path: tailscalePath,
      isUp: tailscaleUp,
      ipOutput: tailscaleIp
    },
    sudo: {
      cached: sudoCached
    }
  };
}

async function pathExists(target: string): Promise<boolean> {
  try {
    await accessAsync(target);
    return true;
  } catch {
    return false;
  }
}

async function commandPath(binary: string): Promise<string | null> {
  return new Promise((resolve) => {
    const child = spawn("which", [binary], { stdio: ["ignore", "pipe", "ignore"] });
    let output = "";
    child.stdout.on("data", (chunk) => {
      output += chunk.toString();
    });
    child.once("close", (code) => {
      if (code === 0) {
        resolve(output.trim());
      } else {
        resolve(null);
      }
    });
    child.once("error", () => resolve(null));
  });
}

async function hasSudoCachedCredentials(): Promise<boolean> {
  return new Promise((resolve) => {
    const child = spawn("sudo", ["-n", "true"], { stdio: "ignore" });
    child.once("close", (code) => {
      resolve(code === 0);
    });
    child.once("error", () => resolve(false));
  });
}

export function formatPreflightForPrompt(snapshot: PreflightSnapshot): string {
  const lines: string[] = [
    "Preflight snapshot from orchestrator:",
    `- bootstrap script present: ${snapshot.scripts.bootstrapExists ? "yes" : "no"} (${snapshot.scripts.bootstrap})`,
    `- verify script present: ${snapshot.scripts.verifyExists ? "yes" : "no"} (${snapshot.scripts.verify})`,
    `- tailscale CLI on PATH: ${snapshot.tailscale.path ?? "not found"}`,
    `- sudo credentials cached: ${snapshot.sudo.cached ? "yes" : "no"}`,
    `- tailscale running: ${snapshot.tailscale.isUp ? "yes" : "no"}`,
    `- tailscale IPs: ${snapshot.tailscale.ipOutput ?? "unknown"}`
  ];

  if (!snapshot.sudo.cached) {
    lines.push("- ⚠️ sudo will require a password prompt. Ask the operator before proceeding.");
  }
  if (!snapshot.tailscale.path) {
    lines.push("- ℹ️ tailscale CLI missing; bootstrap script is expected to install it.");
  }
  if (!snapshot.tailscale.isUp) {
    lines.push("- ℹ️ tailscale appears down; bootstrap should include tailscale up.");
  }

  return lines.join("\n");
}

async function checkTailscaleUp(tailscalePath: string | null): Promise<boolean> {
  if (!tailscalePath) {
    return false;
  }
  return new Promise((resolve) => {
    const child = spawn(tailscalePath, ["status"], { stdio: "ignore" });
    child.once("close", (code) => resolve(code === 0));
    child.once("error", () => resolve(false));
  });
}

async function getTailscaleIp(tailscalePath: string | null): Promise<string | null> {
  if (!tailscalePath) {
    return null;
  }
  return new Promise((resolve) => {
    const child = spawn(tailscalePath, ["ip"], { stdio: ["ignore", "pipe", "ignore"] });
    let output = "";
    child.stdout.on("data", (chunk) => {
      output += chunk.toString();
    });
    child.once("close", (code) => {
      if (code === 0) {
        resolve(output.trim());
      } else {
        resolve(null);
      }
    });
    child.once("error", () => resolve(null));
  });
}
