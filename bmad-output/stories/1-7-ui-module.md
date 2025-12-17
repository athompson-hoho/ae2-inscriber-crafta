# Story 1.7: UI Module

Status: ready-for-dev

## Story

As a **user**,
I want a **compact terminal display showing system status**,
so that **I can monitor inscriber activity, queue depth, and any errors at a glance**.

## Acceptance Criteria

1. **AC1:** Module exports `ui.render(systemState, inscribers, queueLength, stats)` for main display
2. **AC2:** Module exports `ui.showError(errorMessage, errorSource)` for error display
3. **AC3:** Module exports `ui.showRecoveryPrompt()` for user recovery interaction
4. **AC4:** Display fits within 51x19 terminal (standard CC terminal size)
5. **AC5:** Shows number of connected inscribers and their states
6. **AC6:** Shows current queue depth
7. **AC7:** Shows production stats (processors completed)
8. **AC8:** Error display is clear and actionable

## Tasks / Subtasks

- [ ] Task 1: Create lib/ui.lua structure (AC: 1)
  - [ ] Create file with module table
  - [ ] Store terminal dimensions as constants
- [ ] Task 2: Implement helper functions
  - [ ] clearScreen() - term.clear() + cursor reset
  - [ ] drawLine(y, text) - position and print
  - [ ] centerText(y, text) - center aligned text
- [ ] Task 3: Implement main render function (AC: 1, 4, 5, 6, 7)
  - [ ] Clear screen
  - [ ] Draw header with title
  - [ ] Draw inscriber status section
  - [ ] Draw queue status
  - [ ] Draw production stats
  - [ ] Draw footer
- [ ] Task 4: Implement error display (AC: 2, 8)
  - [ ] Clear screen
  - [ ] Show ERROR header
  - [ ] Display error message
  - [ ] Show source (which inscriber/component)
- [ ] Task 5: Implement recovery prompt (AC: 3)
  - [ ] Display "Press any key to retry"
  - [ ] Wait for keypress via os.pullEvent("key")
  - [ ] Return to allow system restart

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#lib/ui.lua]
- [Source: bmad-output/architecture.md#FR-7: Status Display]
- [Source: bmad-output/project-context.md#CC:Tweaked API Rules]

### Terminal Size
- Standard ComputerCraft terminal: 51 wide x 19 tall
- Advanced Computer: same size but supports colors

### UI Layout Design
```
+--------------------------------------------------+
|          AE2 INSCRIBER CRAFTER v1.0              |  Line 1
+--------------------------------------------------+
|                                                  |  Line 2
| INSCRIBERS: 3 connected                          |  Line 3
|   [1] IDLE        [2] PROCESSING   [3] LOADING   |  Line 4
|                                                  |  Line 5
| QUEUE: 5 jobs pending                            |  Line 6
|                                                  |  Line 7
| PRODUCTION:                                      |  Line 8
|   Logic:       12    Calculation:  8             |  Line 9
|   Engineering: 5     Total:        25            |  Line 10
|                                                  |  Line 11-17
| STATUS: Running                                  |  Line 18
+--------------------------------------------------+  Line 19
```

### Error Screen Design
```
+--------------------------------------------------+
|                     ERROR                         |
+--------------------------------------------------+
|                                                  |
|  Chest is full - cannot output processors        |
|                                                  |
|  Source: inscriber_0                             |
|                                                  |
|  Operations paused.                              |
|                                                  |
|  Press any key to retry...                       |
|                                                  |
+--------------------------------------------------+
```

### Implementation Pattern
```lua
local ui = {}

local WIDTH = 51
local HEIGHT = 19

local function clearScreen()
    term.clear()
    term.setCursorPos(1, 1)
end

local function drawLine(y, text)
    term.setCursorPos(1, y)
    term.write(text)
end

function ui.render(systemState, inscribers, queueLength, stats)
    clearScreen()

    drawLine(1, string.rep("-", WIDTH))
    drawLine(2, "       AE2 INSCRIBER CRAFTER v1.0")
    drawLine(3, string.rep("-", WIDTH))

    drawLine(5, "INSCRIBERS: " .. #inscribers .. " connected")

    -- Show each inscriber state
    local line = 6
    for i, ins in ipairs(inscribers) do
        local state = ins.state or "UNKNOWN"
        drawLine(line, string.format("  [%d] %s", i, state))
        line = line + 1
        if line > 10 then break end  -- Limit display
    end

    drawLine(12, "QUEUE: " .. queueLength .. " jobs pending")

    drawLine(14, "PRODUCTION:")
    drawLine(15, string.format("  Logic: %d  Calc: %d  Eng: %d",
        stats.logic or 0, stats.calculation or 0, stats.engineering or 0))

    local status = systemState.running and "Running" or "PAUSED"
    drawLine(18, "STATUS: " .. status)
end

function ui.showError(errorMessage, errorSource)
    clearScreen()
    drawLine(1, string.rep("-", WIDTH))
    drawLine(2, "                  ERROR")
    drawLine(3, string.rep("-", WIDTH))
    drawLine(6, "  " .. tostring(errorMessage))
    drawLine(8, "  Source: " .. tostring(errorSource))
    drawLine(10, "  Operations paused.")
    drawLine(13, "  Press any key to retry...")
end

function ui.showRecoveryPrompt()
    os.pullEvent("key")
end

return ui
```

### File Location
- Create: `lib/ui.lua`

### Dependencies
- None (uses only term API)

## Dev Agent Record

### Agent Model Used
_To be filled by dev agent_

### Debug Log References
_To be filled during implementation_

### Completion Notes List
_To be filled during implementation_

### File List
- [ ] lib/ui.lua (CREATE)
