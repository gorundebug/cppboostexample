# Task 22/36: `ProcessFanoutActivityC`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/automation/processfanoutactivityc.go` |
| Test | `automationservice/internal/functions/automation/processfanoutactivityc_test.go` |
| Service | `Automation Service` |


## Behaviour

Return Activity C's typed fan-out result.





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/automation/processfanoutactivityc.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/automation/processfanoutactivityc_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task22.md — ProcessFanoutActivityC — Go — done`