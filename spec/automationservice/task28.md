# Task 28/36: `ScheduledActivityPause`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `delay` |
| File | `automationservice/internal/functions/automation/scheduledactivitypause.go` |
| Test | `automationservice/internal/functions/automation/scheduledactivitypause_test.go` |
| Service | `Automation Service` |


## Behaviour

Apply the ordinary local Delay inside an Activity started by Temporal Schedule.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/automation/scheduledactivitypause.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/automation/scheduledactivitypause_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task28.md — ScheduledActivityPause — Go — done`