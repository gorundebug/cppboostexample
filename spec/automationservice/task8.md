# Task 8/20: `ProcessFanoutActivityA`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/processfanoutactivitya.go` |
| Test | `automationservice/internal/functions/processfanoutactivitya_test.go` |
| Service | `Automation Service` |


## Behaviour

Return Activity A's typed result before the Workflow Split.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/processfanoutactivitya.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/processfanoutactivitya_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task8.md — ProcessFanoutActivityA — Go — done`