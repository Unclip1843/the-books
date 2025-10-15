import path from "node:path";
import type { AgentDefinition } from "@anthropic-ai/claude-agent-sdk";

export interface AgentContext {
  playbookRoot: string;
  scriptsDir: string;
  implementationDir: string;
}

/**
 * Build the set of Claude subagents that automate the playbook workflows.
 */
export function buildAgentDefinitions(context: AgentContext): Record<string, AgentDefinition> {
  const { scriptsDir, implementationDir } = context;
  const bootstrapScript = path.join(scriptsDir, "bootstrap-mac-host.sh");
  const verifyScript = path.join(scriptsDir, "run-bootstrap-and-verify.sh");
  const sshdConfig = path.join(implementationDir, "ssh", "sshd_config.macos");
  const tmuxConfig = path.join(implementationDir, "tmux.conf");

  return {
    "mac-bootstrap": {
      description: "Provision and harden the Mac Studio host per the Code From Anywhere playbook.",
      prompt: [
        "You are a senior operations engineer automating the Code From Anywhere Mac Studio host.",
        "Follow these practices:",
        "1. Run lightweight checks before changing anything:",
        `   - bash -n ${bootstrapScript}`,
        "   - sudo -n true (to confirm cached credentials; if it fails, prompt the operator).",
        `   - command -v tailscale || note it will be installed by ${bootstrapScript}.`,
        "2. Execute the bootstrap script with Bash tool:",
        `   - DRY_RUN set when requested by the caller.`,
        `   - TAILSCALE_AUTH_KEY passed if provided by the orchestrator.`,
        `   - ${bootstrapScript}`,
        "3. If the caller asked for verification, run the follow-up script:",
        `   - ${verifyScript}`,
        "4. Keep prompts to the human minimal. Only ask when sudo password or Tailscale approval is required.",
        "5. After each significant command, capture output and surface warnings.",
        "6. Finish with a concise summary:",
        "   - ✅ Steps completed",
        "   - ⚠️ Items needing attention",
        "   - 🔁 Next actions / reminders (e.g., approve device in Tailscale admin).",
        "",
        "Reference assets (read-only):",
        `- sshd config template: ${sshdConfig}`,
        `- tmux config template: ${tmuxConfig}`
      ].join("\n"),
      tools: ["Bash", "Read", "Grep"],
      model: "sonnet"
    },
    "tailscale-auditor": {
      description: "Check Tailscale status, tags, and recent connections on the Mac Studio host.",
      prompt: [
        "You audit Tailscale connectivity for the Code From Anywhere Mac Studio host.",
        "Commands to run (in order):",
        "1. tailscale status --peers=false --json",
        "2. tailscale ip",
        "3. tailscale netcheck  # only when status indicates an error or offline state",
        "",
        "Extract and report:",
        "- Device hostname and tailnet name",
        "- SSH capability (enabled/disabled)",
        "- Online/offline + last seen",
        "- Tags (ensure tag:devhost present)",
        "- Any pending approvals",
        "",
        "Output format:",
        "✅ Health summary (one paragraph)",
        "Details (bullets for SSH, IPs, tags)",
        "⚠️ Actions if remediation is needed"
      ].join("\n"),
      tools: ["Bash", "Read"],
      model: "sonnet"
    },
    "client-advisor": {
      description: "Offer quickstart guidance for client devices (MacBook, iPad/iPhone, Android Termux).",
      prompt: [
        "You are a documentation-focused assistant that references the Code From Anywhere playbook.",
        "Instructions:",
        "- Use the Read tool to pull exact snippets from playbook.md or implementation templates.",
        "- Respond with short bullet checklists (≤8 bullets).",
        "- Provide concrete file paths for config templates under implementation/.",
        "- Never invent commands; quote from the playbook.",
        "- If automation is required, direct the operator to run the relevant agent task instead of guessing."
      ].join("\n"),
      tools: ["Read", "Grep"],
      model: "sonnet"
    }
  };
}
