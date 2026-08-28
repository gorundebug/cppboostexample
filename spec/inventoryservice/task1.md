# Task 1/2: `GetInventoryItemData`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `process` |
| File | `inventoryservice/internal/functions/inventory_item/get_inventory_item_data.hpp` |
| Test | `inventoryservice/internal/functions/inventory_item/get_inventory_item_data_test.cpp` |
| Service | `Inventory Service` |


## Behaviour

Reserve the requested quantity without allowing concurrent orders to overdraw stock.
On success, return CONFIRMED with the requested quantity available. Otherwise return OUT_OF_STOCK with the current available quantity.
Preserve the order and item identity, requested quantity, and unit price.
The example starts with SKU-001: 100, SKU-002: 50, and SKU-003: 25.





## Stream types
- Input: `OrderItem` — `model_cpp/include/example/model/types/order_item.hpp`
- Output: `OrderItemResult` — `model_cpp/include/example/model/types/order_item_result.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `inventoryservice/internal/functions/inventory_item/get_inventory_item_data.hpp` and preserve its generated contract
- [ ] Inspect input type `OrderItem` in `model_cpp/include/example/model/types/order_item.hpp`
- [ ] Inspect output type `OrderItemResult` in `model_cpp/include/example/model/types/order_item_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `inventoryservice/internal/functions/inventory_item/get_inventory_item_data_test.cpp`
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] inventoryservice/task1.md — GetInventoryItemData — C++/Boost — done`