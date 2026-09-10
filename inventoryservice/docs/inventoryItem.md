# Pipeline: inventoryItem

```mermaid
flowchart LR
  s68[["Get Inventory Item Data
OrderItemResult"]]
  s69[/"Get Inventory Item Error
OrderItemResult"/]
  s70(("Merge Inventory Result"))
  s71(["Process Inventory Item
OrderItem"])
  s71 --> s68
  s68 --> s69
  s68 --> s70
  s69 --> s70
  s70 --> s71
```
