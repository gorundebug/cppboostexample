# Pipeline: default

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s10[\"Process Order Item
OrderItemResult"/]
  end
  s5[/"ProcessOrderItemError
OrderState"/]
  s10 -.-> s5
```
