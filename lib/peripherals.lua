-- AE2 Inscriber Crafter - Peripherals Module
-- Discovers and wraps inscribers and chest with metadata

local peripherals = {}
local log = require("lib.log")

-- Wrap an inscriber with metadata for state tracking
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

-- Discover all peripherals (chest and inscribers)
function peripherals.discover()
    local result = {
        inscribers = {},
        chest = nil
    }

    -- Find chest
    local allNames = peripheral.getNames()
    for _, name in ipairs(allNames) do
        local pType = peripheral.getType(name)
        if pType and (pType:find("chest") or pType:find("inventory")) then
            result.chest = peripheral.wrap(name)
            log.info("peripherals", "Found chest: " .. name)
            break
        end
    end

    -- Find inscribers
    for _, name in ipairs(allNames) do
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

-- Re-scan peripherals (alias for discover)
function peripherals.refresh()
    return peripherals.discover()
end

return peripherals
