# Task 7/8: `ProcessOrderItemSink`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `grpc-sink` |
| File | `orderservice/internal/functions/endpoint/process_order_item_sink.hpp` |
| Test | `orderservice/internal/functions/endpoint/process_order_item_sink_test.cpp` |
| Service | `Order Service` |


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
- Input: `OrderItem` — `model_cpp/include/example/model/types/order_item.hpp`
- Output: `OrderItemResult` — `model_cpp/include/example/model/types/order_item_result.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `orderservice/internal/functions/endpoint/process_order_item_sink.hpp` and preserve its generated contract
- [ ] Inspect input type `OrderItem` in `model_cpp/include/example/model/types/order_item.hpp`
- [ ] Inspect output type `OrderItemResult` in `model_cpp/include/example/model/types/order_item_result.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `orderservice/internal/functions/endpoint/process_order_item_sink_test.cpp`
- [ ] Verify the endpoint/result lifecycle, including completion and error paths
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] orderservice/task7.md — ProcessOrderItemSink — C++/Boost — done`