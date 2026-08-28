# Task 2/3: `AnalyticsScheduleSource`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `schedule-source` |
| File | `analyticsservice/internal/functions/cron/analytics_schedule_source.hpp` |
| Test | `analyticsservice/internal/functions/cron/analytics_schedule_source_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Create an analytics job message identifying the local scheduled firing.





## Stream types
- Input: `AutomationJob` — `model_cpp/include/example/model/types/automation_job.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/cron/analytics_schedule_source.hpp` and preserve its generated contract
- [ ] Inspect input type `AutomationJob` in `model_cpp/include/example/model/types/automation_job.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/cron/analytics_schedule_source_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task2.md — AnalyticsScheduleSource — C++/Boost — done`