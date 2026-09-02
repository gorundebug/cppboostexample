# Pipeline: inventoryItem

```mermaid
flowchart LR
  s42[["Get Inventory Item Data
OrderItemResult"]]
  s43[/"Get Inventory Item Error
OrderItemResult"/]
  s44(("Merge Inventory Result"))
  s45(["Process Inventory Item
OrderItem"])
  s45 --> s42
  s42 --> s43
  s42 --> s44
  s43 --> s44
  s44 --> s45
```
