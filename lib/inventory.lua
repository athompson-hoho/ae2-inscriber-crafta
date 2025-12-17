-- AE2 Inscriber Crafter - Inventory Module
-- Manages chest scanning and item transfers

local inventory = {}
local log = require("lib.log")

-- Scan chest and return aggregated item counts
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

-- Find first slot containing specified item
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

-- Transfer items from chest to inscriber slot
function inventory.transferToInscriber(chest, inscriber, fromSlot, count, toSlot)
    local transferred = chest.pushItems(inscriber.name, fromSlot, count, toSlot)

    if transferred == 0 then
        log.debug("inventory", "Transfer failed: slot " .. fromSlot .. " -> inscriber slot " .. toSlot)
        return false, "transfer failed: destination full or source empty"
    end

    log.debug("inventory", "Transferred " .. transferred .. " items to inscriber")
    return true
end

-- Transfer items from inscriber slot to chest
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
