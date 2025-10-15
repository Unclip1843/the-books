# The Books

Knowledge base for remote-friendly development workflows.

## Layout

- `playbooks/` — curated guides, grouped by domain (remote access, tooling, sandboxing).
  - Each playbook ships with `playbook.md`, `rubric.md`, `scripts/`, and `implementation/`.
- `orbstack-tenancy/` — source files for a future OrbStack multi-tenant sandbox playbook.
- `text-444A-8C38-1A-0.txt` — original copy that inspired the first playbook.
- `mobile/` — proof-of-concept mobile clients (Flutter) for validating SSH/tmux connectivity from iOS and Android.

## Next Actions

- Flesh out the scaffolds under `playbooks/` as workflows are validated.
- Review `orbstack-tenancy/` to confirm no upstream git metadata or secrets remain before committing; migrate essentials into `playbooks/sandboxing/orbstack-multi-tenant/implementation/` once vetted.
- Standardize contribution workflow (linting, review template) once multiple authors collaborate.
