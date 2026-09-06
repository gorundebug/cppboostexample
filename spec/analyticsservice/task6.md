# Task 6/17: `KeyPaymentsForMultiJoin`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `keyBy` |
| File | `analyticsservice/internal/functions/multijoinanalytics/key_payments_for_multi_join.hpp` |
| Test | `analyticsservice/internal/functions/multijoinanalytics/key_payments_for_multi_join_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Key the payment analytics event for the multi-way join.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`
- Output: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/multijoinanalytics/key_payments_for_multi_join.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Inspect output type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/multijoinanalytics/key_payments_for_multi_join_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task6.md — KeyPaymentsForMultiJoin — C++/Boost — done`