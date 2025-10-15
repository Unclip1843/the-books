import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import { query } from "@anthropic-ai/claude-agent-sdk";
import { buildAgentDefinitions } from "./agents/index.js";
import { config as loadEnv } from "dotenv";
import { collectPreflightSnapshot, formatPreflightForPrompt } from "./utils/preflight.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const playbookRoot = path.resolve(__dirname, "..", "..", "..");
const scriptsDir = path.join(playbookRoot, "scripts");
const implementationDir = path.join(playbookRoot, "implementation");
const repoRoot = path.resolve(playbookRoot, "..", "..", "..");

// Load environment variables from repo-level .env files first, then local overrides.
const rootEnvPath = path.join(repoRoot, ".env");
const rootEnvLocalPath = path.join(repoRoot, ".env.local");
const projectEnvPath = path.resolve(__dirname, "..", ".env");

loadEnv({ path: rootEnvPath, override: false });
loadEnv({ path: rootEnvLocalPath, override: true });
loadEnv({ path: projectEnvPath, override: false });

const agents = buildAgentDefinitions({ playbookRoot, scriptsDir, implementationDir });

async function main() {
  if (!process.env.ANTHROPIC_API_KEY) {
    console.error("ANTHROPIC_API_KEY is missing. Copy .env.example to .env and set your key.");
    process.exit(1);
  }

const args = process.argv.slice(2);
const task = args[0] ?? "bootstrap";
const flags = args.slice(1);
const dryRun = process.argv.includes("--dry-run");
const autoConfirm = process.argv.includes("--auto") || process.env.AUTO_CONFIRM === "1";
const snapshot = await collectPreflightSnapshot(playbookRoot);
const preflight = formatPreflightForPrompt(snapshot);

  switch (task) {
    case "bootstrap":
      await runBootstrap({ dryRun, autoConfirm, preflight, snapshot });
      break;
    case "tailscale-status":
      await runTailscaleAudit({ preflight });
      break;
    default:
      console.error(`Unknown task "${task}". Use "bootstrap" or "tailscale-status".`);
      process.exit(1);
  }
}

interface RunBootstrapOptions {
  dryRun: boolean;
  autoConfirm: boolean;
  preflight: string;
  snapshot: Awaited<ReturnType<typeof collectPreflightSnapshot>>;
}

async function runBootstrap({ dryRun, autoConfirm, preflight, snapshot }: RunBootstrapOptions) {
  const prompt = [
    "Bootstrap the Mac Studio host per the Code From Anywhere playbook.",
    "Steps to perform:",
    "- Run the bootstrap script with sudo privileges.",
    "- If TAILSCALE_AUTH_KEY is present, pass it through to avoid interactive login.",
    "- Confirm sshd hardening and tmux helper files exist in the implementation directory.",
    "- Report remaining manual items (e.g., approving Tailscale in the admin console).",
    "",
    preflight,
    "",
    `Dry run requested: ${dryRun ? "yes" : "no"} (set DRY_RUN=1 when executing commands if yes).`,
    `TAILSCALE_AUTH_KEY present: ${process.env.TAILSCALE_AUTH_KEY ? "yes" : "no"}`,
    `Auto-confirm mode: ${autoConfirm ? "yes" : "no"} (proceed without asking if yes).`,
    snapshot.sudo.cached
      ? "- Sudo credential is cached; initial sudo commands should succeed without prompts."
      : "- Sudo credential is NOT cached; prompt the operator before issuing sudo commands."
  ].join("\n");

  const environment = {
    ...(dryRun ? { DRY_RUN: "1" } : {}),
    ...(autoConfirm ? { AUTO_CONFIRM: "1" } : {}),
    ...(process.env.TAILSCALE_AUTH_KEY
      ? { TAILSCALE_AUTH_KEY: process.env.TAILSCALE_AUTH_KEY }
      : {})
  };

  await streamAgentConversation("mac-bootstrap", prompt, environment);
}

interface RunAuditOptions {
  preflight: string;
}

async function runTailscaleAudit({ preflight }: RunAuditOptions) {
  const prompt = [
    "Audit Tailscale on the Mac Studio host.",
    "Collect:",
    "- tailscale status --peers=false --json",
    "- tailscale ip",
    "- tailscale netcheck (only if status indicates an issue).",
    "Summarise whether the device is tagged with tag:devhost and if SSH is enabled.",
    "",
    preflight
  ].join("\n");

  await streamAgentConversation("tailscale-auditor", prompt);
}

type EnvOverrides = Record<string, string>;

async function streamAgentConversation(
  agentKey: string,
  userPrompt: string,
  env: EnvOverrides = {}
) {
  if (!agents[agentKey]) {
    throw new Error(`Agent "${agentKey}" is not defined.`);
  }

  const responseStream = query({
    prompt: userPrompt,
    options: {
      agent: agentKey,
      agents,
      environment: env
    } as any
  });

  for await (const message of responseStream as AsyncIterable<any>) {
    if (typeof message === "string") {
      process.stdout.write(message);
    } else if (message?.type === "text-delta" && typeof message.delta === "string") {
      process.stdout.write(message.delta);
    } else if (message?.type === "text" && typeof message.text === "string") {
      process.stdout.write(message.text);
    } else if (message?.type === "event") {
      if (message.event === "completed") {
        process.stdout.write("\n✔️ Agent run completed.\n");
      } else if (message.event === "error" && message.error) {
        process.stderr.write(`\nAgent error: ${message.error}\n`);
      }
    } else {
      process.stdout.write(JSON.stringify(message, null, 2));
    }
  }
}

main().catch((error) => {
  console.error("\nAgent run failed:", error);
  process.exit(1);
});
