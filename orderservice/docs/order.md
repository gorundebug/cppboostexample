# Pipeline: order

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s72[/"ProcessOrderItemError
OrderState"/]
  end
  s73["Map Order Item Result To Order State
OrderState"]
  s74["MapToOrderProcessed
OrderProcessed"]
  s75["Map to Order State
OrderState"]
  s76(("Merge Results"))
  s77(["Process Order
Order"])
  s78[\"Process Order Item
OrderItemResult"/]
  s79["Process Order Items
OrderItem"]
  s80[\"Publish Order Processed
OrderProcessed"/]
  s81["Soft Deadline"]
  s82["Split Order Result"]
  s83["Split Pipeline"]
  s78 --> s73
  s82 --> s74
  s81 --> s75
  s75 --> s76
  s73 --> s76
  s72 -.-> s76
  s82 --> s77
  s79 --> s78
  s83 --> s79
  s74 --> s80
  s83 --> s81
  s76 --> s82
  s77 --> s83
```
