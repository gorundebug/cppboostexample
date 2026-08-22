# Task 6/8: `ProcessOrder`

> Rules: [`spec/rules.md`](../rules.md)

| Field | Value |
|-------|-------|
| Language | `C++/Boost` |
| Kind | `http-source` |
| File | `orderservice/internal/functions/process_order.hpp` |
| Test | `orderservice/internal/functions/process_order_test.cpp` |
| Service | `Order Service` |


## Behaviour

Accept orders with at least one item and positive quantities; reject malformed or invalid requests as client errors.
Reuse X-Request-ID when supplied, otherwise generate an order ID. Preserve customer, item, price, and X-Trace data, and apply the configured timeout of five seconds by default.
Return one response per order. When all items finish, use CONFIRMED only if every item was reserved; otherwise use PARTIALLY_CONFIRMED. If the deadline wins, return TIMED_OUT with the item results received so far.
Calculate the total from processed item prices, falling back to the submitted total when no item result arrived, and include individual item failures in the response.




## External contract

| Field | Value |
|-------|-------|
| Format | `openapi` |
| Request | `handlers::order_service_api::processorder::Request` |
| Response | `handlers::order_service_api::processorder::Response` |


## Stream types
- Input: `Order` — `orderservice/internal/types/order.hpp`
- Output: `OrderState` — `orderservice/internal/types/order_state.hpp`

## Checklist

- [ ] Read [`spec/rules.md`](../rules.md), especially the `C++/Boost` section
- [ ] Open `orderservice/internal/functions/process_order.hpp` and preserve its generated contract
- [ ] Inspect input type `Order` in `orderservice/internal/types/order.hpp`
- [ ] Inspect output type `OrderState` in `orderservice/internal/types/order_state.hpp`
- [ ] Implement the C++ function object without retaining borrowed payload/context references
- [ ] Run `./scripts/test.generated.sh`
- [ ] Implement meaningful assertions in `orderservice/internal/functions/process_order_test.cpp`
- [ ] Verify the endpoint/result lifecycle, including completion and error paths
- [ ] Re-read this checklist
- [ ] Append to `spec/progress.md`: `- [x] orderservice/task6.md — ProcessOrder — C++/Boost — done`