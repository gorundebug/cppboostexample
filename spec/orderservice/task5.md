# Task 5/8: `SoftDeadline`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `delay` |
| File | `orderservice/internal/functions/order/soft_deadline.hpp` |
| Test | `orderservice/internal/functions/order/soft_deadline_test.cpp` |
| Service | `Order Service` |


## Behaviour

Trigger the timeout branch shortly before the request deadline, leaving the configured duration to assemble a response.
When no request deadline exists, use the configured duration itself. Never wait past an existing deadline.





## Stream types
- Input: `Order` — `orderservice/internal/types/order.hpp`
- Output: `Order` — `orderservice/internal/types/order.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `orderservice/internal/functions/order/soft_deadline.hpp` and preserve its generated contract
- [ ] Inspect input type `Order` in `orderservice/internal/types/order.hpp`
- [ ] Inspect output type `Order` in `orderservice/internal/types/order.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `orderservice/internal/functions/order/soft_deadline_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] orderservice/task5.md — SoftDeadline — C++/Boost — done`