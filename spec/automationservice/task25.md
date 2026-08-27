# Task 25/36: `ProcessSequentialActivityA`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/automation/processsequentialactivitya.go` |
| Test | `automationservice/internal/functions/automation/processsequentialactivitya_test.go` |
| Service | `Automation Service` |


## Behaviour

Return sequential Activity A's typed result to its Temporal sink.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/automation/processsequentialactivitya.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/automation/processsequentialactivitya_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task25.md — ProcessSequentialActivityA — Go — done`