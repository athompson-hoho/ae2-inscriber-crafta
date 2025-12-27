-- Test script: List all items in chest with exact IDs

-- Logging helper: prints to console and writes to debug.log
local logFile = fs.open("debug.log", "w")
local function log(msg)
    print(msg)
    if logFile then
        logFile.writeLine(msg)
        logFile.flush()
    end
end

-- Find chest (excluding inscribers)
local chest = nil
local chestName = nil

log("Scanning peripherals...")
log("")

for _, name in ipairs(peripheral.getNames()) do
    local pType = peripheral.getType(name)
    log("  " .. name .. " = " .. pType)

    -- Skip inscribers - they also have inventory but aren't chests
    if not pType:find("inscriber") then
        if pType:find("chest") or pType:find("barrel") or pType == "inventory" then
            chest = peripheral.wrap(name)
            chestName = name
        end
    end
end

log("")

if not chest then
    log("ERROR: No chest found!")
    log("Make sure a chest (not inscriber) is connected.")
    if logFile then logFile.close() end
    return
end

log("=== CHEST CONTENTS ===")
log("Using: " .. chestName .. " (" .. peripheral.getType(chestName) .. ")")
log("")

-- List items
local items = chest.list()
if not items then
    log("ERROR: chest.list() returned nil")
    if logFile then logFile.close() end
    return
end

local count = 0
for slot, item in pairs(items) do
    log(string.format("[%2d] %s x%d", slot, item.name, item.count))
    count = count + 1
end

log("")
log("Total: " .. count .. " stacks")

if logFile then logFile.close() end
