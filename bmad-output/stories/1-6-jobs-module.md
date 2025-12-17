# Story 1.6: Jobs Module

Status: ready-for-dev

## Story

As a **system**,
I want a **job queue and inscriber state machine module**,
so that **I can manage concurrent inscriber operations with proper state tracking**.

## Acceptance Criteria

1. **AC1:** Module exports `jobs.enqueue(job)` to add jobs to queue
2. **AC2:** Module exports `jobs.dequeue()` to get next job (FIFO)
3. **AC3:** Module exports `jobs.getQueueLength()` for UI display
4. **AC4:** Module exports `jobs.createWorker(inscriber, systemState, chest)` returning worker function
5. **AC5:** Worker implements state machine: IDLE -> LOADING -> PROCESSING -> UNLOADING -> IDLE
6. **AC6:** Worker sets inscriber.state appropriately at each transition
7. **AC7:** Worker respects systemState.running flag (stops when false)
8. **AC8:** Worker sets systemState.error on failure, triggering global pause

## Tasks / Subtasks

- [ ] Task 1: Create lib/jobs.lua structure (AC: 1)
  - [ ] Create file with module table
  - [ ] Require log, inventory modules
  - [ ] Create private _queue table
- [ ] Task 2: Implement queue functions (AC: 1, 2, 3)
  - [ ] enqueue(job) - table.insert
  - [ ] dequeue() - table.remove(queue, 1)
  - [ ] getQueueLength() - return #_queue
- [ ] Task 3: Implement worker state machine (AC: 4, 5, 6)
  - [ ] IDLE: wait for job from queue
  - [ ] LOADING: insert press + materials into inscriber
  - [ ] PROCESSING: poll output slot until item appears
  - [ ] UNLOADING: extract output + return press to chest
  - [ ] Transition back to IDLE
- [ ] Task 4: Implement error handling in worker (AC: 7, 8)
  - [ ] Check systemState.running each loop
  - [ ] Wrap operations in pcall
  - [ ] On error: set systemState.error, systemState.errorSource
- [ ] Task 5: Implement inscriber operations (AC: 5)
  - [ ] Load press into top slot
  - [ ] Load material into middle slot
  - [ ] Load bottom material if assembly recipe
  - [ ] Poll for output
  - [ ] Extract output and press

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#State Management]
- [Source: bmad-output/architecture.md#Concurrency Model]
- [Source: bmad-output/architecture.md#lib/jobs.lua]
- [Source: bmad-output/project-context.md#State Machine States]

### State Machine
```
IDLE → LOADING → PROCESSING → UNLOADING → IDLE
                     ↓
                   ERROR
```

### Inscriber Slot Constants (VERIFY IN-GAME)
```lua
local SLOTS = {
    TOP = 1,      -- Press or printed circuit
    MIDDLE = 2,   -- Material input
    BOTTOM = 3,   -- Press (printing) or printed silicon (assembly)
    OUTPUT = 4    -- Result
}
```

### Worker Pattern
```lua
function jobs.createWorker(inscriber, systemState, chest)
    return function()
        while systemState.running do
            inscriber.state = "IDLE"

            -- Wait for job
            local job = jobs.dequeue()
            if not job then
                sleep(0.5)
            else
                inscriber.currentJob = job
                inscriber.state = "LOADING"

                local ok, err = pcall(function()
                    -- Load materials
                    -- ... transfer operations ...

                    inscriber.state = "PROCESSING"
                    -- Poll for completion
                    while not inscriber.peripheral.getItemDetail(SLOTS.OUTPUT) do
                        if not systemState.running then return end
                        sleep(config.processingPollInterval)
                    end

                    inscriber.state = "UNLOADING"
                    -- Extract output and press
                    -- ... transfer operations ...
                end)

                if not ok then
                    inscriber.state = "ERROR"
                    systemState.error = err
                    systemState.errorSource = inscriber.name
                    systemState.running = false
                end

                inscriber.currentJob = nil
            end
        end
    end
end
```

### Critical Notes
- Use `sleep()` in loops to yield (prevents "too long without yielding")
- Check `systemState.running` frequently for responsive shutdown
- Transfer failures should trigger ERROR state

### File Location
- Create: `lib/jobs.lua`

### Dependencies
- Requires: `lib/log.lua` (Story 1.1)
- Requires: `lib/inventory.lua` (Story 1.4)
- Uses: `config.lua` (Story 1.2)

## Dev Agent Record

### Agent Model Used
_To be filled by dev agent_

### Debug Log References
_To be filled during implementation_

### Completion Notes List
_To be filled during implementation_

### File List
- [ ] lib/jobs.lua (CREATE)
