# Task 1/4: `DurablePause`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `delay` |
| File | `automationservice/internal/functions/durablepause.go` |
| Test | `automationservice/internal/functions/durablepause_test.go` |
| Service | `Automation Service` |


## Behaviour

Suspend a DurableCall through a Temporal timer, then resume the pipeline without occupying an Activity slot.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/durablepause.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/durablepause_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task1.md — DurablePause — Go — done`