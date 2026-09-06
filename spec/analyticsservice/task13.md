# Task 13/17: `AnalyticsPaymentsSource`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `custom-source` |
| File | `analyticsservice/internal/functions/endpoint/analytics_payments_source.hpp` |
| Test | `analyticsservice/internal/functions/endpoint/analytics_payments_source_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Produce a deterministic payment analytics event for the canonical join examples.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/endpoint/analytics_payments_source.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/endpoint/analytics_payments_source_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task13.md — AnalyticsPaymentsSource — C++/Boost — done`