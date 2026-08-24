# Task 5/5: `TemporalSchedule`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `schedule-source` |
| File | `automationservice/internal/functions/temporalschedule.go` |
| Service | `Automation Service` |





## Stream types
- Input: `ScheduleTrigger`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/temporalschedule.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task5.md — TemporalSchedule — Go — done`