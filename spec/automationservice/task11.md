# Task 11/20: `ProcessScheduledActivity`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/processscheduledactivity.go` |
| Test | `automationservice/internal/functions/processscheduledactivity_test.go` |
| Service | `Automation Service` |


## Behaviour

Return the visible result of one scheduled Activity execution.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/processscheduledactivity.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/processscheduledactivity_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task11.md — ProcessScheduledActivity — Go — done`