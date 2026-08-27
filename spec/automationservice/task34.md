# Task 34/36: `TemporalWorkflowScheduleSource`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `schedule-source` |
| File | `automationservice/internal/functions/workflow/temporalworkflowschedulesource.go` |
| Service | `Automation Service` |


## Behaviour

Create a Workflow job message identifying the durable scheduled firing.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/workflow/temporalworkflowschedulesource.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task34.md — TemporalWorkflowScheduleSource — Go — done`