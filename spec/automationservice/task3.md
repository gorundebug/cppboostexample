# Task 3/13: `ObserveActivityResult`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/observeactivityresult.go` |
| Test | `automationservice/internal/functions/observeactivityresult_test.go` |
| Service | `Automation Service` |


## Behaviour

Preserve the result returned through the on-demand Activity endpoint.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/observeactivityresult.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/observeactivityresult_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task3.md — ObserveActivityResult — Go — done`