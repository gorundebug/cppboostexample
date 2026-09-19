# Pipeline: order

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s77[/"ProcessOrderItemError
OrderState"/]
  end
  s78["Map Order Item Result To Order State
OrderState"]
  s79["MapToOrderProcessed
OrderProcessed"]
  s80["Map to Order State
OrderState"]
  s81(("Merge Results"))
  s82(["Process Order
Order"])
  s83[\"Process Order Item
OrderItemResult"/]
  s84["Process Order Items
OrderItem"]
  s85[\"Publish Order Processed
OrderProcessed"/]
  s86["Soft Deadline"]
  s87["Split Order Result"]
  s88["Split Pipeline"]
  s83 --> s78
  s87 --> s79
  s86 --> s80
  s80 --> s81
  s78 --> s81
  s77 -.-> s81
  s87 --> s82
  s84 --> s83
  s88 --> s84
  s79 --> s85
  s88 --> s86
  s81 --> s87
  s82 --> s88
```
