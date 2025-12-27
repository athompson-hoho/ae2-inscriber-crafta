-- Test script: Auto-test all inscriber slots with press and material
-- Usage: test-transfer [inscriber_name]

-- Logging helper: prints to console and writes to debug.log
local logFile = fs.open("debug.log", "w")
local function log(msg)
    print(msg)
    if logFile then
        logFile.writeLine(msg)
        logFile.flush()
    end
end

local args = {...}

local chest = peripheral.find("inventory")
if not chest then
    log("ERROR: No chest found!")
    if logFile then logFile.close() end
    return
end

-- Find inscriber
local insName = args[1]
local inscriber = nil

if insName then
    inscriber = peripheral.wrap(insName)
else
    -- Find first inscriber
    for _, name in ipairs(peripheral.getNames()) do
        local pType = peripheral.getType(name)
        if pType and pType:find("inscriber") then
            insName = name
            inscriber = peripheral.wrap(name)
            break
        end
    end
end

if not inscriber then
    log("ERROR: No inscriber found!")
    if logFile then logFile.close() end
    return
end

log("=== SLOT TRANSFER TEST ===")
log("Inscriber: " .. insName)
log("Slots: " .. inscriber.size())
log("")

-- Find a press and a material in chest
local pressSlot = nil
local pressName = nil
local materialSlot = nil
local materialName = nil

for slot, item in pairs(chest.list()) do
    if item.name:find("press") then
        pressSlot = slot
        pressName = item.name
    elseif item.name:find("gold") or item.name:find("ingot") then
        materialSlot = slot
        materialName = item.name
    end
end

if not pressSlot then
    log("WARNING: No press found in chest")
end
if not materialSlot then
    log("WARNING: No gold/ingot found in chest")
end

log("Press: " .. (pressName or "none") .. " (slot " .. (pressSlot or "?") .. ")")
log("Material: " .. (materialName or "none") .. " (slot " .. (materialSlot or "?") .. ")")
log("")

-- Test each slot
log("=== TESTING PRESS TO EACH SLOT ===")
if pressSlot then
    for slot = 1, inscriber.size() do
        local transferred = chest.pushItems(insName, pressSlot, 1, slot)
        local result = transferred > 0 and "OK" or "REJECTED"
        log(string.format("  Slot %d: %s", slot, result))

        -- Pull it back if successful
        if transferred > 0 then
            chest.pullItems(insName, slot, 64)
        end
        sleep(0.1)
    end
else
    log("  (skipped - no press)")
end

log("")
log("=== TESTING MATERIAL TO EACH SLOT ===")
if materialSlot then
    for slot = 1, inscriber.size() do
        local transferred = chest.pushItems(insName, materialSlot, 1, slot)
        local result = transferred > 0 and "OK" or "REJECTED"
        log(string.format("  Slot %d: %s", slot, result))

        -- Pull it back if successful
        if transferred > 0 then
            chest.pullItems(insName, slot, 64)
        end
        sleep(0.1)
    end
else
    log("  (skipped - no material)")
end

log("")
log("=== SLOT SUMMARY ===")
log("Based on results above, update lib/recipes.lua SLOTS if needed")

if logFile then logFile.close() end
