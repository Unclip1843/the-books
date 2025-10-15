# Rubric — Agent Ops

Finalize these criteria before promoting the workflow to production use.

## Safety

- [ ] Command execution sandboxed with explicit allow/deny lists.
- [ ] Resource quotas (CPU, memory, time) enforced per agent task.
- [ ] Human-in-the-loop or approval path defined for high-risk actions.

## Reliability

- [ ] Agents gracefully resume or retry after network hiccups.
- [ ] Task queue / scheduler handles back-pressure without data loss.
- [ ] Health checks detect stalled agents and trigger remediation.

## Observability

- [ ] Structured logs with correlation IDs across agent steps.
- [ ] Metrics exported (success rate, latency, error types).
- [ ] Alerting thresholds defined for critical failures.

## Developer Experience

- [ ] Local dev harness documented for rapid iteration.
- [ ] Clear runbooks for upgrading models or SDKs.
- [ ] Secrets rotation play documented and tested.
