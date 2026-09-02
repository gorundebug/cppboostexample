# Pipeline: automation

```mermaid
flowchart LR
  s4["Activity Pause"]
  s5[\"Call Fan-Out Activity A
AutomationJob"/]
  s6[\"Call Fan-Out Activity B
AutomationJob"/]
  s7[\"Call Fan-Out Activity C
AutomationJob"/]
  s8[\"Call Sequential Activity A
AutomationJob"/]
  s9[\"Call Sequential Activity B
AutomationJob"/]
  s10(["Consume Activity Job
AutomationJob"])
  s11(["Consume Fan-Out Activity A
AutomationJob"])
  s12(["Consume Fan-Out Activity B
AutomationJob"])
  s13(["Consume Fan-Out Activity C
AutomationJob"])
  s14(["Consume Fan-Out Workflow Job
AutomationJob"])
  s15(["Consume Sequential Activity A
AutomationJob"])
  s16(["Consume Sequential Activity B
AutomationJob"])
  s17(["Consume Workflow Job
AutomationJob"])
  s18(["Local Schedule
AutomationJob"])
  s19["Observe Activity Result
AutomationJob"]
  s20["Observe Fan-Out Activity B
AutomationJob"]
  s21["Observe Fan-Out Activity C
AutomationJob"]
  s22["Observe Workflow Result
AutomationJob"]
  s23["Process Activity Job
AutomationJob"]
  s24["Process Fan-Out Activity A
AutomationJob"]
  s25["Process Fan-Out Activity B
AutomationJob"]
  s26["Process Fan-Out Activity C
AutomationJob"]
  s27["Process Scheduled Activity
AutomationJob"]
  s28["Process Scheduled Workflow
AutomationJob"]
  s29["Process Sequential Activity A
AutomationJob"]
  s30["Process Sequential Activity B
AutomationJob"]
  s31["Process Workflow Job
AutomationJob"]
  s32["Scheduled Activity Pause"]
  s33["Scheduled Workflow Pause"]
  s34["Split Activity A Result"]
  s35["Split On-Demand Jobs"]
  s36[\"Submit Activity Job
AutomationJob"/]
  s37[\"Submit Fan-Out Workflow Job
AutomationJob"/]
  s38[\"Submit Workflow Job
AutomationJob"/]
  s39(["Temporal Activity Schedule
AutomationJob"])
  s40(["Temporal Workflow Schedule
AutomationJob"])
  s41["Workflow Pause"]
  s10 --> s4
  s14 --> s5
  s34 --> s6
  s34 --> s7
  s41 --> s8
  s8 --> s9
  s23 --> s10
  s24 --> s11
  s25 --> s12
  s26 --> s13
  s29 --> s15
  s30 --> s16
  s31 --> s17
  s36 --> s19
  s6 --> s20
  s7 --> s21
  s38 --> s22
  s4 --> s23
  s11 --> s24
  s12 --> s25
  s13 --> s26
  s32 --> s27
  s33 --> s28
  s15 --> s29
  s16 --> s30
  s9 --> s31
  s39 --> s32
  s40 --> s33
  s5 --> s34
  s18 --> s35
  s35 --> s36
  s35 --> s37
  s35 --> s38
  s27 --> s39
  s28 --> s40
  s17 --> s41
```
