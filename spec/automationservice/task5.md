# Task 5/20: `ObserveFanoutActivityC`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/observefanoutactivityc.go` |
| Test | `automationservice/internal/functions/observefanoutactivityc_test.go` |
| Service | `Automation Service` |


## Behaviour

Observe the typed result returned by the Activity C fan-out branch.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/observefanoutactivityc.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/observefanoutactivityc_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task5.md — ObserveFanoutActivityC — Go — done`