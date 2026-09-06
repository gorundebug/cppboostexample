# Task 5/17: `KeyPaymentsForJoin`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `keyBy` |
| File | `analyticsservice/internal/functions/joinanalytics/key_payments_for_join.hpp` |
| Test | `analyticsservice/internal/functions/joinanalytics/key_payments_for_join_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Key the payment analytics event by correlation key.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`
- Output: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/joinanalytics/key_payments_for_join.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Inspect output type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/joinanalytics/key_payments_for_join_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task5.md — KeyPaymentsForJoin — C++/Boost — done`