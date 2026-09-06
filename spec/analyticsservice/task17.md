# Task 17/17: `StandardAnalyticsSink`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `custom-sink` |
| File | `analyticsservice/internal/functions/endpoint/standard_analytics_sink.hpp` |
| Test | `analyticsservice/internal/functions/endpoint/standard_analytics_sink_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Validate and record analytics results routed to the standard Case branch.




## Stream types
- Input: `AnalyticsResult` — `analyticsservice/internal/types/analytics_result.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/endpoint/standard_analytics_sink.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsResult` in `analyticsservice/internal/types/analytics_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/endpoint/standard_analytics_sink_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task17.md — StandardAnalyticsSink — C++/Boost — done`