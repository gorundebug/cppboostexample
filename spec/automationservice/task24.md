# Task 24/36: `ProcessScheduledWorkflow`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/automation/processscheduledworkflow.go` |
| Test | `automationservice/internal/functions/automation/processscheduledworkflow_test.go` |
| Service | `Automation Service` |


## Behaviour

Return the visible result of one scheduled Workflow execution.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/automation/processscheduledworkflow.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/automation/processscheduledworkflow_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task24.md — ProcessScheduledWorkflow — Go — done`