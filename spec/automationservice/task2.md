# Task 2/3: `ProcessDurableJob`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/processdurablejob.go` |
| Test | `automationservice/internal/functions/processdurablejob_test.go` |
| Service | `Automation Service` |


## Behaviour

Process one accepted automation job and return its result.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/processdurablejob.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/processdurablejob_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task2.md — ProcessDurableJob — Go — done`