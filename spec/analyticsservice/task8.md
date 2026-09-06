# Task 8/17: `MultiJoinAnalyticsEvents`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `multiJoin` |
| File | `analyticsservice/internal/functions/multijoinanalytics/multi_join_analytics_events.hpp` |
| Test | `analyticsservice/internal/functions/multijoinanalytics/multi_join_analytics_events_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Combine matching order, payment, and shipment analytics events.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`
- Output: `AnalyticsResult` — `analyticsservice/internal/types/analytics_result.hpp`
- Key: `AnalyticsKey` — `analyticsservice/internal/types/analytics_key.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/multijoinanalytics/multi_join_analytics_events.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Inspect output type `AnalyticsResult` in `analyticsservice/internal/types/analytics_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/multijoinanalytics/multi_join_analytics_events_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task8.md — MultiJoinAnalyticsEvents — C++/Boost — done`