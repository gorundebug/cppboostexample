# Pipeline: default

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s84[\"Process Order Item
OrderItemResult"/]
  end
  s78[/"ProcessOrderItemError
OrderState"/]
  s84 -.-> s78
```
