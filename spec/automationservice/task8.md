# Task 8/13: `ProcessWorkflowJob`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `map` |
| File | `automationservice/internal/functions/processworkflowjob.go` |
| Test | `automationservice/internal/functions/processworkflowjob_test.go` |
| Service | `Automation Service` |


## Behaviour

Continue the Workflow as new once, then return its final result.





## Stream types
- Input: `string`
- Output: `string`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/processworkflowjob.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Implement meaningful assertions in `automationservice/internal/functions/processworkflowjob_test.go`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task8.md — ProcessWorkflowJob — Go — done`