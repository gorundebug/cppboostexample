# Task 33/36: `FanoutWorkflowJobEndpointSource`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `schedule-source` |
| File | `automationservice/internal/functions/workflow/fanoutworkflowjobendpointsource.go` |
| Service | `Automation Service` |





## Stream types
- Input: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/workflow/fanoutworkflowjobendpointsource.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task33.md — FanoutWorkflowJobEndpointSource — Go — done`