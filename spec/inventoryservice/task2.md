# Task 2/2: `ProcessOrderItemSource`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `grpc-source` |
| File | `inventoryservice/internal/functions/endpoint/process_order_item_source.hpp` |
| Test | `inventoryservice/internal/functions/endpoint/process_order_item_source_test.cpp` |
| Service | `Inventory Service` |


## Behaviour

Reserve inventory for one order item using its order ID, item ID, SKU, and quantity.
Return the available quantity, reservation outcome, and status. The caller combines this response with the original identity, requested quantity, and unit price.
If the inventory call fails, the caller returns a non-reserved PROCESSING_ERROR result with the failure message.




## External contract

| Field | Value |
|-------|-------|
| Format | `proto` |
| Request | `processorderitem::ProcessOrderItemRequest` |
| Response | `processorderitem::ProcessOrderItemResponse` |


## Stream types
- Input: `OrderItem` — `model/include/example/model/types/order_item.hpp`
- Output: `OrderItemResult` — `model/include/example/model/types/order_item_result.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `inventoryservice/internal/functions/endpoint/process_order_item_source.hpp` and preserve its generated contract
- [ ] Inspect input type `OrderItem` in `model/include/example/model/types/order_item.hpp`
- [ ] Inspect output type `OrderItemResult` in `model/include/example/model/types/order_item_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `inventoryservice/internal/functions/endpoint/process_order_item_source_test.cpp`
- [ ] Verify the endpoint/result lifecycle, including completion and error paths
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] inventoryservice/task2.md — ProcessOrderItemSource — C++/Boost — done`