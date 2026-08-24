# Task 4/5: `TemporalJob`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/temporaljob.go` |
| Test | `automationservice/internal/functions/temporaljob_test.go` |
| Service | `Automation Service` |


## Behaviour

Create a job message identifying the durable scheduled firing.





## Stream types
- Input: `ScheduleTrigger`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/temporaljob.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/temporaljob_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task4.md — TemporalJob — Go — done`