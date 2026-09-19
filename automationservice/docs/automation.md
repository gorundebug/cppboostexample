# Pipeline: automation

```mermaid
flowchart LR
  s35["Activity Pause"]
  s36[\"Call Fan-Out Activity A
AutomationJob"/]
  s37[\"Call Fan-Out Activity B
AutomationJob"/]
  s38[\"Call Fan-Out Activity C
AutomationJob"/]
  s39[\"Call Sequential Activity A
AutomationJob"/]
  s40[\"Call Sequential Activity B
AutomationJob"/]
  s41(["Consume Activity Job
AutomationJob"])
  s42(["Consume Fan-Out Activity A
AutomationJob"])
  s43(["Consume Fan-Out Activity B
AutomationJob"])
  s44(["Consume Fan-Out Activity C
AutomationJob"])
  s45(["Consume Fan-Out Workflow Job
AutomationJob"])
  s46(["Consume Sequential Activity A
AutomationJob"])
  s47(["Consume Sequential Activity B
AutomationJob"])
  s48(["Consume Workflow Job
AutomationJob"])
  s49(["Local Schedule
AutomationJob"])
  s50["Observe Activity Result
AutomationJob"]
  s51["Observe Fan-Out Activity B
AutomationJob"]
  s52["Observe Fan-Out Activity C
AutomationJob"]
  s53["Observe Workflow Result
AutomationJob"]
  s54["Process Activity Job
AutomationJob"]
  s55["Process Fan-Out Activity A
AutomationJob"]
  s56["Process Fan-Out Activity B
AutomationJob"]
  s57["Process Fan-Out Activity C
AutomationJob"]
  s58["Process Scheduled Activity
AutomationJob"]
  s59["Process Scheduled Workflow
AutomationJob"]
  s60["Process Sequential Activity A
AutomationJob"]
  s61["Process Sequential Activity B
AutomationJob"]
  s62["Process Workflow Job
AutomationJob"]
  s63["Scheduled Activity Pause"]
  s64["Scheduled Workflow Pause"]
  s65["Split Activity A Result"]
  s66["Split On-Demand Jobs"]
  s67[\"Submit Activity Job
AutomationJob"/]
  s68[\"Submit Fan-Out Workflow Job
AutomationJob"/]
  s69[\"Submit Workflow Job
AutomationJob"/]
  s70(["Temporal Activity Schedule
AutomationJob"])
  s71(["Temporal Workflow Schedule
AutomationJob"])
  s72["Workflow Pause"]
  s41 --> s35
  s45 --> s36
  s65 --> s37
  s65 --> s38
  s72 --> s39
  s39 --> s40
  s54 --> s41
  s55 --> s42
  s56 --> s43
  s57 --> s44
  s60 --> s46
  s61 --> s47
  s62 --> s48
  s67 --> s50
  s37 --> s51
  s38 --> s52
  s69 --> s53
  s35 --> s54
  s42 --> s55
  s43 --> s56
  s44 --> s57
  s63 --> s58
  s64 --> s59
  s46 --> s60
  s47 --> s61
  s40 --> s62
  s70 --> s63
  s71 --> s64
  s36 --> s65
  s49 --> s66
  s66 --> s67
  s66 --> s68
  s66 --> s69
  s58 --> s70
  s59 --> s71
  s48 --> s72
```
