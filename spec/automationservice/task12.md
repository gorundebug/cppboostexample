# Task 12/20: `ProcessScheduledWorkflow`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/processscheduledworkflow.go` |
| Test | `automationservice/internal/functions/processscheduledworkflow_test.go` |
| Service | `Automation Service` |


## Behaviour

Return the visible result of one scheduled Workflow execution.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/processscheduledworkflow.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/processscheduledworkflow_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task12.md — ProcessScheduledWorkflow — Go — done`