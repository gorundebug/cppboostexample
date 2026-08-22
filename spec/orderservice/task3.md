# Task 3/8: `MapToOrderState`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `map` |
| File | `orderservice/internal/functions/map_to_order_state.hpp` |
| Test | `orderservice/internal/functions/map_to_order_state_test.cpp` |
| Service | `Order Service` |


## Behaviour

Produce a TIMED_OUT order result that preserves the order ID and submitted total.
Do not add item results at this stage; results received before the timeout are included in the final response.





## Stream types
- Input: `Order` — `orderservice/internal/types/order.hpp`
- Output: `OrderState` — `orderservice/internal/types/order_state.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `orderservice/internal/functions/map_to_order_state.hpp` and preserve its generated contract
- [ ] Inspect input type `Order` in `orderservice/internal/types/order.hpp`
- [ ] Inspect output type `OrderState` in `orderservice/internal/types/order_state.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `orderservice/internal/functions/map_to_order_state_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] orderservice/task3.md — MapToOrderState — C++/Boost — done`