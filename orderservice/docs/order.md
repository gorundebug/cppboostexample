# Pipeline: order

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s78[/"ProcessOrderItemError
OrderState"/]
  end
  s79["Map Order Item Result To Order State
OrderState"]
  s80["MapToOrderProcessed
OrderProcessed"]
  s81["Map to Order State
OrderState"]
  s82(("Merge Results"))
  s83(["Process Order
Order"])
  s84[\"Process Order Item
OrderItemResult"/]
  s85["Process Order Items
OrderItem"]
  s86[\"Publish Order Processed
OrderProcessed"/]
  s87["Soft Deadline"]
  s88["Split Order Result"]
  s89["Split Pipeline"]
  s84 --> s79
  s88 --> s80
  s87 --> s81
  s81 --> s82
  s79 --> s82
  s78 -.-> s82
  s88 --> s83
  s85 --> s84
  s89 --> s85
  s80 --> s86
  s89 --> s87
  s82 --> s88
  s83 --> s89
```
