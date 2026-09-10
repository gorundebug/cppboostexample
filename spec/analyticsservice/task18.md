# Task 18/22: `CycleAnalyticsInputSource`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `custom-source` |
| File | `analyticsservice/internal/functions/endpoint/cycle_analytics_input_source.hpp` |
| Test | `analyticsservice/internal/functions/endpoint/cycle_analytics_input_source_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Produce one deterministic analytics event that exercises the finite feedback cycle.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/endpoint/cycle_analytics_input_source.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/endpoint/cycle_analytics_input_source_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task18.md — CycleAnalyticsInputSource — C++/Boost — done`