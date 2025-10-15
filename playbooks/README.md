# Playbooks Index

Curated guides for repeatable setups. Each playbook folder should contain:

- `playbook.md` — the actionable guide with Overview → Implementation → Maintenance flow.
- `rubric.md` — success criteria and quality bar before calling a setup “done”.
- `scripts/` — ready-to-run helpers (shell, Python, etc.).
- `implementation/` — reusable configs, infra code, or templates backing the guide.

Top-level categories:

- `remote-computer-access/` — persistent shells, reverse tunnels, and away-from-desk workflows.
- `tooling/` — IDE alternatives, CLI automation, and agent-powered helpers.
- `sandboxing/` — isolated environments for multi-tenant or experimental work.

When adding a new playbook, clone the `_template` directory (coming soon) or mirror the structure of an existing one, then trim content to the essentials we actually use.
