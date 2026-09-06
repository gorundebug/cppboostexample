# Pipeline: default

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s70[\"Process Order Item
OrderItemResult"/]
  end
  s64[/"ProcessOrderItemError
OrderState"/]
  s70 -.-> s64
```
