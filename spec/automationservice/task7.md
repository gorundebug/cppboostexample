# Task 7/20: `ProcessActivityJob`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/processactivityjob.go` |
| Test | `automationservice/internal/functions/processactivityjob_test.go` |
| Service | `Automation Service` |


## Behaviour

Record Activity progress with DurableCallHeartbeat and return the processed job result.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/processactivityjob.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/processactivityjob_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task7.md — ProcessActivityJob — Go — done`