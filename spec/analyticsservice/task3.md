# Task 3/22: `ContinueCycleAnalytics`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `filter` |
| File | `analyticsservice/internal/functions/cycleanalytics/continue_cycle_analytics.hpp` |
| Test | `analyticsservice/internal/functions/cycleanalytics/continue_cycle_analytics_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Keep intermediate analytics events whose cycle counter is below three.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`
- Output: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/cycleanalytics/continue_cycle_analytics.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Inspect output type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/cycleanalytics/continue_cycle_analytics_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task3.md — ContinueCycleAnalytics — C++/Boost — done`