# Task 10/13: `ScheduledWorkflowPause`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `delay` |
| File | `automationservice/internal/functions/scheduledworkflowpause.go` |
| Test | `automationservice/internal/functions/scheduledworkflowpause_test.go` |
| Service | `Automation Service` |


## Behaviour

Use the official Temporal Workflow timer for a scheduled Workflow.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/scheduledworkflowpause.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/scheduledworkflowpause_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task10.md — ScheduledWorkflowPause — Go — done`