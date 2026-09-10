# Pipeline: automation

```mermaid
flowchart LR
  s30["Activity Pause"]
  s31[\"Call Fan-Out Activity A
AutomationJob"/]
  s32[\"Call Fan-Out Activity B
AutomationJob"/]
  s33[\"Call Fan-Out Activity C
AutomationJob"/]
  s34[\"Call Sequential Activity A
AutomationJob"/]
  s35[\"Call Sequential Activity B
AutomationJob"/]
  s36(["Consume Activity Job
AutomationJob"])
  s37(["Consume Fan-Out Activity A
AutomationJob"])
  s38(["Consume Fan-Out Activity B
AutomationJob"])
  s39(["Consume Fan-Out Activity C
AutomationJob"])
  s40(["Consume Fan-Out Workflow Job
AutomationJob"])
  s41(["Consume Sequential Activity A
AutomationJob"])
  s42(["Consume Sequential Activity B
AutomationJob"])
  s43(["Consume Workflow Job
AutomationJob"])
  s44(["Local Schedule
AutomationJob"])
  s45["Observe Activity Result
AutomationJob"]
  s46["Observe Fan-Out Activity B
AutomationJob"]
  s47["Observe Fan-Out Activity C
AutomationJob"]
  s48["Observe Workflow Result
AutomationJob"]
  s49["Process Activity Job
AutomationJob"]
  s50["Process Fan-Out Activity A
AutomationJob"]
  s51["Process Fan-Out Activity B
AutomationJob"]
  s52["Process Fan-Out Activity C
AutomationJob"]
  s53["Process Scheduled Activity
AutomationJob"]
  s54["Process Scheduled Workflow
AutomationJob"]
  s55["Process Sequential Activity A
AutomationJob"]
  s56["Process Sequential Activity B
AutomationJob"]
  s57["Process Workflow Job
AutomationJob"]
  s58["Scheduled Activity Pause"]
  s59["Scheduled Workflow Pause"]
  s60["Split Activity A Result"]
  s61["Split On-Demand Jobs"]
  s62[\"Submit Activity Job
AutomationJob"/]
  s63[\"Submit Fan-Out Workflow Job
AutomationJob"/]
  s64[\"Submit Workflow Job
AutomationJob"/]
  s65(["Temporal Activity Schedule
AutomationJob"])
  s66(["Temporal Workflow Schedule
AutomationJob"])
  s67["Workflow Pause"]
  s36 --> s30
  s40 --> s31
  s60 --> s32
  s60 --> s33
  s67 --> s34
  s34 --> s35
  s49 --> s36
  s50 --> s37
  s51 --> s38
  s52 --> s39
  s55 --> s41
  s56 --> s42
  s57 --> s43
  s62 --> s45
  s32 --> s46
  s33 --> s47
  s64 --> s48
  s30 --> s49
  s37 --> s50
  s38 --> s51
  s39 --> s52
  s58 --> s53
  s59 --> s54
  s41 --> s55
  s42 --> s56
  s35 --> s57
  s65 --> s58
  s66 --> s59
  s31 --> s60
  s44 --> s61
  s61 --> s62
  s61 --> s63
  s61 --> s64
  s53 --> s65
  s54 --> s66
  s43 --> s67
```
