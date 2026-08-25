# Task 2/13: `LocalSchedule`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `schedule-source` |
| File | `automationservice/internal/functions/localschedule.go` |
| Service | `Automation Service` |


## Behaviour

Create a job message identifying the local scheduled firing.





## Stream types
- Input: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/localschedule.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task2.md — LocalSchedule — Go — done`