# Task 1/2: `CountOrderProcessed`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `process` |
| File | `analyticsservice/internal/functions/count_order_processed.hpp` |
| Test | `analyticsservice/internal/functions/count_order_processed_test.cpp` |
| Service | `Analytics Service` |


## Behaviour

Count successful and unsuccessful orders independently, then return the event unchanged.





## Stream types
- Input: `OrderProcessed` — `model/include/example/model/types/order_processed.hpp`
- Output: `OrderProcessed` — `model/include/example/model/types/order_processed.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `analyticsservice/internal/functions/count_order_processed.hpp` and preserve its generated contract
- [ ] Inspect input type `OrderProcessed` in `model/include/example/model/types/order_processed.hpp`
- [ ] Inspect output type `OrderProcessed` in `model/include/example/model/types/order_processed.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `analyticsservice/internal/functions/count_order_processed_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] analyticsservice/task1.md — CountOrderProcessed — C++/Boost — done`