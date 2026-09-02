# Pipeline: order

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s46[/"ProcessOrderItemError
OrderState"/]
  end
  s47["Map Order Item Result To Order State
OrderState"]
  s48["MapToOrderProcessed
OrderProcessed"]
  s49["Map to Order State
OrderState"]
  s50(("Merge Results"))
  s51(["Process Order
Order"])
  s52[\"Process Order Item
OrderItemResult"/]
  s53["Process Order Items
OrderItem"]
  s54[\"Publish Order Processed
OrderProcessed"/]
  s55["Soft Deadline"]
  s56["Split Order Result"]
  s57["Split Pipeline"]
  s52 --> s47
  s56 --> s48
  s55 --> s49
  s49 --> s50
  s47 --> s50
  s46 -.-> s50
  s56 --> s51
  s53 --> s52
  s57 --> s53
  s48 --> s54
  s57 --> s55
  s50 --> s56
  s51 --> s57
```
