# Task 4/8: `ProcessOrderItems`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `flatMap` |
| File | `orderservice/internal/functions/order/process_order_items.hpp` |
| Test | `orderservice/internal/functions/order/process_order_items_test.cpp` |
| Service | `Order Service` |


## Behaviour

Emit every order item independently for inventory processing.
Preserve each item's data and assign the parent order ID.





## Stream types
- Input: `Order` — `orderservice/internal/types/order.hpp`
- Output: `OrderItem` — `model/include/example/model/types/order_item.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `orderservice/internal/functions/order/process_order_items.hpp` and preserve its generated contract
- [ ] Inspect input type `Order` in `orderservice/internal/types/order.hpp`
- [ ] Inspect output type `OrderItem` in `model/include/example/model/types/order_item.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `orderservice/internal/functions/order/process_order_items_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] orderservice/task4.md — ProcessOrderItems — C++/Boost — done`