# Task 2/3: `GetInventoryItemError`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `map` |
| File | `inventoryservice/internal/functions/inventory_item/get_inventory_item_error.hpp` |
| Test | `inventoryservice/internal/functions/inventory_item/get_inventory_item_error_test.cpp` |
| Service | `Inventory Service` |


## Behaviour

When inventory processing fails, return an OUT_OF_STOCK result with no available quantity.
Preserve the order and item identity and requested quantity, and record the failure.





## Stream types
- Input: `InventoryFailure` — `inventoryservice/internal/types/inventory_failure.hpp`
- Output: `OrderItemResult` — `model_cpp/include/example/model/types/order_item_result.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `inventoryservice/internal/functions/inventory_item/get_inventory_item_error.hpp` and preserve its generated contract
- [ ] Inspect input type `InventoryFailure` in `inventoryservice/internal/types/inventory_failure.hpp`
- [ ] Inspect output type `OrderItemResult` in `model_cpp/include/example/model/types/order_item_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `inventoryservice/internal/functions/inventory_item/get_inventory_item_error_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] inventoryservice/task2.md — GetInventoryItemError — C++/Boost — done`