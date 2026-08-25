# Task 4/20: `ObserveFanoutActivityB`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/observefanoutactivityb.go` |
| Test | `automationservice/internal/functions/observefanoutactivityb_test.go` |
| Service | `Automation Service` |


## Behaviour

Observe the typed result returned by the Activity B fan-out branch.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/observefanoutactivityb.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/observefanoutactivityb_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task4.md — ObserveFanoutActivityB — Go — done`