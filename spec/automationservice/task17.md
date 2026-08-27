# Task 17/36: `ObserveFanoutActivityC`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/automation/observefanoutactivityc.go` |
| Test | `automationservice/internal/functions/automation/observefanoutactivityc_test.go` |
| Service | `Automation Service` |


## Behaviour

Observe the typed result returned by the Activity C fan-out branch.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/automation/observefanoutactivityc.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/automation/observefanoutactivityc_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task17.md — ObserveFanoutActivityC — Go — done`