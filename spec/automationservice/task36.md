# Task 36/36: `WorkflowJobEndpointSource`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `schedule-source` |
| File | `automationservice/internal/functions/workflow/workflowjobendpointsource.go` |
| Service | `Automation Service` |





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/workflow/workflowjobendpointsource.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task36.md — WorkflowJobEndpointSource — Go — done`