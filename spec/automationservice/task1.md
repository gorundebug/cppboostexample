# Task 1/20: `ActivityPause`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `delay` |
| File | `automationservice/internal/functions/activitypause.go` |
| Test | `automationservice/internal/functions/activitypause_test.go` |
| Service | `Automation Service` |


## Behaviour

Apply the ordinary local Delay while processing an on-demand Temporal Activity.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/activitypause.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/activitypause_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task1.md — ActivityPause — Go — done`