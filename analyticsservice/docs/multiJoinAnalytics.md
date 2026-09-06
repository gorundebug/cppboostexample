# Pipeline: multiJoinAnalytics

```mermaid
flowchart LR
  subgraph ext[" "]
    style ext fill:#f5f5f5,stroke:#bbb,stroke-dasharray:4
    s6(["Analytics Shipments
AnalyticsEvent"])
    s7["Split Analytics Orders"]
    s8["Split Analytics Payments"]
  end
  s13>"High Value Analytics
AnalyticsResult"]
  s14{{"Key Orders For Multi Join
AnalyticsEvent"}}
  s15{{"Key Payments For Multi Join
AnalyticsEvent"}}
  s16{{"Key Shipments For Multi Join
AnalyticsEvent"}}
  s17["Multi Join Analytics Events
AnalyticsResult"]
  s18{"Route Analytics Result"}
  s19>"Standard Analytics
AnalyticsResult"]
  s20[\"Write High Value Analytics
AnalyticsResult"/]
  s21[\"Write Standard Analytics
AnalyticsResult"/]
  s18 --> s13
  s7 -.-> s14
  s8 -.-> s15
  s6 -.-> s16
  s14 --> s17
  s15 --> s17
  s16 --> s17
  s17 --> s18
  s18 --> s19
  s13 --> s20
  s19 --> s21
```
