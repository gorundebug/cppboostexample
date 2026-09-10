# Pipeline: default

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s78[\"Process Order Item
OrderItemResult"/]
  end
  s72[/"ProcessOrderItemError
OrderState"/]
  s78 -.-> s72
```
