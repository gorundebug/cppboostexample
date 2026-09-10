# Task 19/22: `CycleAnalyticsResultSink`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `custom-sink` |
| File | `analyticsservice/internal/functions/endpoint/cycle_analytics_result_sink.hpp` |
| Test | `analyticsservice/internal/functions/endpoint/cycle_analytics_result_sink_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Validate the terminal event emitted after three passes through the feedback cycle.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/endpoint/cycle_analytics_result_sink.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/endpoint/cycle_analytics_result_sink_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task19.md — CycleAnalyticsResultSink — C++/Boost — done`