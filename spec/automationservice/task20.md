# Task 20/20: `WorkflowPause`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `delay` |
| File | `automationservice/internal/functions/workflowpause.go` |
| Test | `automationservice/internal/functions/workflowpause_test.go` |
| Service | `Automation Service` |


## Behaviour

Use the same Delay contract backed by the Temporal Workflow timer.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/workflowpause.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/workflowpause_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task20.md — WorkflowPause — Go — done`