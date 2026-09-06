# Pipeline: inventoryItem

```mermaid
flowchart LR
  s60[["Get Inventory Item Data
OrderItemResult"]]
  s61[/"Get Inventory Item Error
OrderItemResult"/]
  s62(("Merge Inventory Result"))
  s63(["Process Inventory Item
OrderItem"])
  s63 --> s60
  s60 --> s61
  s60 --> s62
  s61 --> s62
  s62 --> s63
```
