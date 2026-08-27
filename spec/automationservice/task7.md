# Task 7/36: `FanoutActivityCEndpointSink`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `Go` |
| Kind | `custom-sink` |
| File | `automationservice/internal/functions/activity/fanoutactivitycendpointsink.go` |
| Service | `Automation Service` |





## Stream types
- Input: `AutomationJob`
- Output: `AutomationJob`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `Go` section
- [ ] Open `automationservice/internal/functions/activity/fanoutactivitycendpointsink.go` and preserve its generated contract
- [ ] Implement the Go function and propagate the received `context.Context`
- [ ] Run `make test`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] automationservice/task7.md — FanoutActivityCEndpointSink — Go — done`