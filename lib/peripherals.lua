-- AE2 Inscriber Crafter - Peripherals Module
-- Discovers and wraps inscribers and chest with metadata

local peripherals = {}
local log = require("lib.log")

-- Wrap an inscriber with metadata for state tracking
function peripherals.wrapInscriber(name, pType)
    local raw = peripheral.wrap(name)
    if not raw then
        return nil, "peripheral not found: " .. name
    end

    -- Determine short type name for display
    local shortType = "AE2"
    if pType and pType:find("ex_inscriber") then
        shortType = "EX"
    end

    return {
        name = name,
        peripheral = raw,
        state = "IDLE",
        currentJob = nil,
        type = pType,
        shortType = shortType,
    }
end

-- Discover all peripherals (chest and inscribers)
function peripherals.discover()
    local result = {
        inscribers = {},
        chest = nil,
        chestName = nil
    }

    -- Find chest (excluding inscribers which also have inventory)
    local allNames = peripheral.getNames()
    for _, name in ipairs(allNames) do
        local pType = peripheral.getType(name)
        if pType and not pType:find("inscriber") then
            if pType:find("chest") or pType:find("barrel") or pType == "inventory" then
                result.chest = peripheral.wrap(name)
                result.chestName = name
                log.info("peripherals", "Found chest: " .. name .. " (" .. pType .. ")")
                break
            end
        end
    end

    -- Find inscribers (both ae2:inscriber and extendedae:ex_inscriber)
    -- Determine if chest is on network (has : in name) to filter duplicates
    local chestOnNetwork = result.chestName and result.chestName:find(":")
    local directionalNames = {top=true, bottom=true, left=true, right=true, front=true, back=true}

    local skipped = 0
    for _, name in ipairs(allNames) do
        local pType = peripheral.getType(name)
        if pType and pType:find("inscriber") then
            -- Skip directional names when chest is on network (they're duplicates)
            local isDirectional = directionalNames[name]
            log.debug("peripherals", "Checking: " .. name .. " directional=" .. tostring(isDirectional) .. " chestOnNetwork=" .. tostring(chestOnNetwork))
            if chestOnNetwork and isDirectional then
                skipped = skipped + 1
                log.info("peripherals", "Skipped directional duplicate: " .. name)
            else
                -- Test if chest can reach this inscriber by trying to pull 0 items
                -- This will error if the target doesn't exist on the same network
                local reachable = false
                if result.chest then
                    local ok, err = pcall(function()
                        return result.chest.pullItems(name, 1, 0)
                    end)
                    reachable = ok
                    if not ok then
                        log.debug("peripherals", "Connectivity test failed for " .. name .. ": " .. tostring(err))
                    end
                end

                if reachable then
                    local wrapped, err = peripherals.wrapInscriber(name, pType)
                    if wrapped then
                        table.insert(result.inscribers, wrapped)
                        log.debug("peripherals", "Found inscriber: " .. name .. " (" .. wrapped.shortType .. ")")
                    end
                else
                    skipped = skipped + 1
                    log.debug("peripherals", "Skipped unreachable inscriber: " .. name)
                end
            end
        end
    end

    -- Count inscriber types
    local ae2Count, exCount = 0, 0
    for _, ins in ipairs(result.inscribers) do
        if ins.shortType == "EX" then
            exCount = exCount + 1
        else
            ae2Count = ae2Count + 1
        end
    end
    log.info("peripherals", string.format("Discovered %d inscribers (%d AE2, %d EX), skipped %d unreachable",
        #result.inscribers, ae2Count, exCount, skipped))
    return result
end

-- Re-scan peripherals (alias for discover)
function peripherals.refresh()
    return peripherals.discover()
end

return peripherals
