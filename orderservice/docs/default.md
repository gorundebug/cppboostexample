# Pipeline: default

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s52[\"Process Order Item
OrderItemResult"/]
  end
  s46[/"ProcessOrderItemError
OrderState"/]
  s52 -.-> s46
```
