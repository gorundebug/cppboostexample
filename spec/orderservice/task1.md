# Task 1/8: `MapOrderItemResultToOrderState`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `map` |
| File | `orderservice/internal/functions/map_order_item_result_to_order_state.hpp` |
| Test | `orderservice/internal/functions/map_order_item_result_to_order_state_test.cpp` |
| Service | `Order Service` |


## Behaviour

Produce an order result containing one inventory result and preserving its order ID.
Mark it CONFIRMED when the item was reserved; otherwise mark it PARTIALLY_CONFIRMED.
Record the time when this result is produced.





## Stream types
- Input: `OrderItemResult` — `model/include/example/model/types/order_item_result.hpp`
- Output: `OrderState` — `orderservice/internal/types/order_state.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `orderservice/internal/functions/map_order_item_result_to_order_state.hpp` and preserve its generated contract
- [ ] Inspect input type `OrderItemResult` in `model/include/example/model/types/order_item_result.hpp`
- [ ] Inspect output type `OrderState` in `orderservice/internal/types/order_state.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `orderservice/internal/functions/map_order_item_result_to_order_state_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] orderservice/task1.md — MapOrderItemResultToOrderState — C++/Boost — done`