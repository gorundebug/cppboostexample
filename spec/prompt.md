# Starting Prompt — `Example`

You are implementing business logic for the **Example** project.

---

## Before you start

1. Read **[`spec/rules.md`](rules.md)** in full — it contains hard constraints you must not violate.
2. Open **[`spec/progress.md`](progress.md)** and identify which tasks are already marked `[x]`.
3. Find the first unchecked task in `spec/` and start there.

---

## Workflow

```
for each task file spec/*/task1.md, task2.md, … in owner order:
  if already marked [x] in progress.md → skip
  else → implement, verify, mark done, move to next
```

**Complete and close each task before opening the next one.**
Do not batch progress.md updates to the end of the session.

### Task execution order (STRICT)

1. Open the task file.
2. Work through its checklist **top to bottom, one item at a time**.
3. Do not move to the next checklist item until the current one is done.
4. Before finishing the task, re-read every checklist item and confirm each is satisfied.
5. Mark the task done in `spec/progress.md`.
6. Only then open the next task file.

> **Never work on two tasks simultaneously.**
> Finish task N completely before reading task N+1.

---

## Project location

```
example/
```

Quick orientation:

```bash
# List all task files
find example/spec -name 'task*.md' -print

# Check what is already done
cat example/spec/progress.md

# Language-specific commands are listed in rules.md and in every task.
```

---

## Key constraints (summary — full list in `rules.md`)

- **Never modify generated files.** Extend only via addition.
- **Use the build, generation and test commands from the task's language section.**
- **Mark each task done immediately** after implementing it — copy the exact progress entry from the task's own checklist into `spec/progress.md`.

---

Start by reading `spec/rules.md`, then open the first uncompleted task.