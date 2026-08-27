# Task 32/36: `FanoutWorkflowJobEndpointSink`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `custom-sink` |
| File | `automationservice/internal/functions/workflow/fanoutworkflowjobendpointsink.go` |
| Service | `Automation Service` |





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/workflow/fanoutworkflowjobendpointsink.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task32.md — FanoutWorkflowJobEndpointSink — Go — done`