# Story 1.4: Inventory Module

Status: ready-for-dev

## Story

As a **system**,
I want an **inventory management module for chest scanning and item transfers**,
so that **I can find materials and move items between chest and inscribers reliably**.

## Acceptance Criteria

1. **AC1:** Module exports `inventory.scanChest(chest)` returning `{itemId = count, ...}`
2. **AC2:** Module exports `inventory.findItem(chest, itemId)` returning slot number or nil
3. **AC3:** Module exports `inventory.transferToInscriber(chest, inscriber, fromSlot, count, toSlot)`
4. **AC4:** Module exports `inventory.transferFromInscriber(chest, inscriber, fromSlot)`
5. **AC5:** Transfer functions return `true` on success, `false, errorString` on failure
6. **AC6:** scanChest aggregates item counts across all slots
7. **AC7:** All functions log operations at DEBUG level

## Tasks / Subtasks

- [ ] Task 1: Create lib/inventory.lua structure (AC: 1)
  - [ ] Create file with module table
  - [ ] Require log module
- [ ] Task 2: Implement scanChest function (AC: 1, 6, 7)
  - [ ] Iterate all slots in chest via chest.list() or chest.size()
  - [ ] Get item details for each slot
  - [ ] Aggregate counts by item ID
  - [ ] Return totals table
- [ ] Task 3: Implement findItem function (AC: 2, 7)
  - [ ] Iterate slots looking for matching itemId
  - [ ] Return first slot number found or nil
- [ ] Task 4: Implement transferToInscriber function (AC: 3, 5, 7)
  - [ ] Use chest.pushItems(inscriberName, fromSlot, count, toSlot)
  - [ ] Check return value (0 = failure)
  - [ ] Return true/false with error message
- [ ] Task 5: Implement transferFromInscriber function (AC: 4, 5, 7)
  - [ ] Use chest.pullItems(inscriberName, fromSlot, count)
  - [ ] Check return value
  - [ ] Return true/false with error message

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#Inventory Operations]
- [Source: bmad-output/architecture.md#lib/inventory.lua]
- [Source: bmad-output/project-context.md#CC:Tweaked API Rules]

### Critical CC:Tweaked Notes
- `pushItems(toName, fromSlot, limit, toSlot)` returns count transferred
- `pullItems(fromName, fromSlot, limit, toSlot)` returns count transferred
- Return value of 0 means transfer failed
- Slot numbers are 1-indexed

### Implementation Pattern
```lua
local inventory = {}
local log = require("lib.log")

function inventory.scanChest(chest)
    local contents = {}
    local items = chest.list()

    for slot, item in pairs(items) do
        local id = item.name
        contents[id] = (contents[id] or 0) + item.count
    end

    log.debug("inventory", "Scanned chest: " .. tostring(#items) .. " stacks")
    return contents
end

function inventory.findItem(chest, itemId)
    local items = chest.list()

    for slot, item in pairs(items) do
        if item.name == itemId then
            log.debug("inventory", "Found " .. itemId .. " in slot " .. slot)
            return slot
        end
    end

    return nil
end

function inventory.transferToInscriber(chest, inscriber, fromSlot, count, toSlot)
    local transferred = chest.pushItems(inscriber.name, fromSlot, count, toSlot)

    if transferred == 0 then
        log.debug("inventory", "Transfer failed: slot " .. fromSlot .. " -> inscriber slot " .. toSlot)
        return false, "transfer failed: destination full or source empty"
    end

    log.debug("inventory", "Transferred " .. transferred .. " items to inscriber")
    return true
end

function inventory.transferFromInscriber(chest, inscriber, fromSlot)
    local transferred = chest.pullItems(inscriber.name, fromSlot, 64)

    if transferred == 0 then
        log.debug("inventory", "Pull failed from inscriber slot " .. fromSlot)
        return false, "transfer failed: chest full or slot empty"
    end

    log.debug("inventory", "Pulled " .. transferred .. " items from inscriber")
    return true
end

return inventory
```

### File Location
- Create: `lib/inventory.lua`

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
- [ ] lib/inventory.lua (CREATE)
