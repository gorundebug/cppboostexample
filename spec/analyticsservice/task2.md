# Task 2/26: `BuildSubstreamAnalyticsResult`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `map` |
| File | `analyticsservice/internal/functions/substreamanalytics/build_substream_analytics_result.hpp` |
| Test | `analyticsservice/internal/functions/substreamanalytics/build_substream_analytics_result_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Transform one callable SubStream input into its analytics result.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`
- Output: `AnalyticsResult` — `analyticsservice/internal/types/analytics_result.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/substreamanalytics/build_substream_analytics_result.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Inspect output type `AnalyticsResult` in `analyticsservice/internal/types/analytics_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/substreamanalytics/build_substream_analytics_result_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task2.md — BuildSubstreamAnalyticsResult — C++/Boost — done`