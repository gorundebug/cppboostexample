# Task 6/26: `InvokeAnalyticsSubstream`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `map` |
| File | `analyticsservice/internal/functions/substreamanalytics/invoke_analytics_substream.hpp` |
| Test | `analyticsservice/internal/functions/substreamanalytics/invoke_analytics_substream_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Invoke the service-local analytics SubStream and emit its returned result.




## Stream types
- Input: `AnalyticsEvent` — `analyticsservice/internal/types/analytics_event.hpp`
- Output: `AnalyticsResult` — `analyticsservice/internal/types/analytics_result.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/substreamanalytics/invoke_analytics_substream.hpp` and preserve its generated contract
- [ ] Inspect input type `AnalyticsEvent` in `analyticsservice/internal/types/analytics_event.hpp`
- [ ] Inspect output type `AnalyticsResult` in `analyticsservice/internal/types/analytics_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/substreamanalytics/invoke_analytics_substream_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task6.md — InvokeAnalyticsSubstream — C++/Boost — done`