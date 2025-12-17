# Story 1.3: Peripherals Module

Status: ready-for-dev

## Story

As a **system**,
I want a **peripheral discovery and wrapping module**,
so that **I can find all inscribers and the chest dynamically, with metadata for state tracking**.

## Acceptance Criteria

1. **AC1:** Module exports `peripherals.discover()` returning `{inscribers={}, chest=nil}`
2. **AC2:** Discovers inscribers via `peripheral.find("ae2:inscriber")` or similar
3. **AC3:** Discovers chest via `peripheral.find("minecraft:chest")` or inventory type
4. **AC4:** Each inscriber is wrapped with metadata: `{name, peripheral, state, currentJob}`
5. **AC5:** State initializes to "IDLE"
6. **AC6:** Module exports `peripherals.wrapInscriber(name)` for individual wrapping
7. **AC7:** Module exports `peripherals.refresh()` to re-scan peripherals
8. **AC8:** Logs discovery results via log module

## Tasks / Subtasks

- [ ] Task 1: Create lib/peripherals.lua structure (AC: 1)
  - [ ] Create file with module table
  - [ ] Require log module
- [ ] Task 2: Define inscriber wrapper structure (AC: 4, 5)
  - [ ] Create wrapInscriber(name) function
  - [ ] Include name, peripheral reference, state="IDLE", currentJob=nil
  - [ ] Add convenience methods if needed
- [ ] Task 3: Implement chest discovery (AC: 3)
  - [ ] Find chest peripheral (try multiple types: chest, minecraft:chest, inventory)
  - [ ] Return wrapped chest or nil with error
- [ ] Task 4: Implement inscriber discovery (AC: 2)
  - [ ] Use peripheral.find() or peripheral.getNames() + filtering
  - [ ] Wrap each found inscriber
  - [ ] Handle case of no inscribers found
- [ ] Task 5: Implement discover() main function (AC: 1, 8)
  - [ ] Find chest first (required)
  - [ ] Find all inscribers
  - [ ] Log counts found
  - [ ] Return structured result
- [ ] Task 6: Implement refresh() function (AC: 7)
  - [ ] Re-run discovery
  - [ ] Preserve state of existing inscribers if still present
  - [ ] Log changes

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#lib/peripherals.lua]
- [Source: bmad-output/project-context.md#CC:Tweaked API Rules]

### Critical CC:Tweaked Notes
- `peripheral.find(type)` returns multiple values, not a table
- Use `peripheral.getNames()` and filter for more control
- Peripheral names may change on world reload - re-discover on startup
- Always check `peripheral.isPresent(name)` before operations

### AE2 Inscriber Type
- Type string may be: `"ae2:inscriber"` or `"appliedenergistics2:inscriber"`
- VERIFY IN-GAME during testing

### Implementation Pattern
```lua
local peripherals = {}
local log = require("lib.log")

function peripherals.wrapInscriber(name)
    local raw = peripheral.wrap(name)
    if not raw then
        return nil, "peripheral not found: " .. name
    end

    return {
        name = name,
        peripheral = raw,
        state = "IDLE",
        currentJob = nil,
    }
end

function peripherals.discover()
    local result = {
        inscribers = {},
        chest = nil
    }

    -- Find chest
    local chestNames = peripheral.getNames()
    for _, name in ipairs(chestNames) do
        local pType = peripheral.getType(name)
        if pType and (pType:find("chest") or pType:find("inventory")) then
            result.chest = peripheral.wrap(name)
            log.info("peripherals", "Found chest: " .. name)
            break
        end
    end

    -- Find inscribers
    for _, name in ipairs(peripheral.getNames()) do
        local pType = peripheral.getType(name)
        if pType and pType:find("inscriber") then
            local wrapped, err = peripherals.wrapInscriber(name)
            if wrapped then
                table.insert(result.inscribers, wrapped)
                log.debug("peripherals", "Found inscriber: " .. name)
            end
        end
    end

    log.info("peripherals", "Discovered " .. #result.inscribers .. " inscribers")
    return result
end

function peripherals.refresh()
    return peripherals.discover()
end

return peripherals
```

### File Location
- Create: `lib/peripherals.lua`

### Dependencies
- Requires: `lib/log.lua` (Story 1.1)

## Dev Agent Record

### Agent Model Used
_To be filled by dev agent_

### Debug Log References
_To be filled during implementation_

### Completion Notes List
_To be filled during implementation_

### File List
- [ ] lib/peripherals.lua (CREATE)
