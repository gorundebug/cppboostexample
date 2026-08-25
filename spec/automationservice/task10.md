# Task 10/20: `ProcessFanoutActivityC`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/processfanoutactivityc.go` |
| Test | `automationservice/internal/functions/processfanoutactivityc_test.go` |
| Service | `Automation Service` |


## Behaviour

Return Activity C's typed fan-out result.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/processfanoutactivityc.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/processfanoutactivityc_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task10.md — ProcessFanoutActivityC — Go — done`