# Pipeline: analytics

```mermaid
flowchart LR
  s1(["Consume Order Processed
OrderProcessed"])
  s2[["Count Order Processed
OrderProcessed"]]
  s2 --> s1
  s1 --> s2
```
