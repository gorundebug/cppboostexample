# Task 12/22: `RouteAnalyticsResult`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `case` |
| File | `analyticsservice/internal/functions/multijoinanalytics/route_analytics_result.hpp` |
| Test | `analyticsservice/internal/functions/multijoinanalytics/route_analytics_result_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Route high-value analytics results to the first branch and all others to the second branch.




## Stream types
- Input: `AnalyticsResult` — `analyticsservice/internal/types/analytics_result.hpp`
- Output: `AnalyticsResult` — `analyticsservice/internal/types/analytics_result.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/multijoinanalytics/route_analytics_result.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsResult` in `analyticsservice/internal/types/analytics_result.hpp`
- [ ] Inspect output type `AnalyticsResult` in `analyticsservice/internal/types/analytics_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/multijoinanalytics/route_analytics_result_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task12.md — RouteAnalyticsResult — C++/Boost — done`