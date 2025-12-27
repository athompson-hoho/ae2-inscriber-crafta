-- Test script: List all inscribers and their slot contents

-- Logging helper: prints to console and writes to debug.log
local logFile = fs.open("debug.log", "w")
local function log(msg)
    print(msg)
    if logFile then
        logFile.writeLine(msg)
        logFile.flush()
    end
end

local inscribers = {}

for _, name in ipairs(peripheral.getNames()) do
    local pType = peripheral.getType(name)
    if pType and pType:find("inscriber") then
        local shortType = pType:find("ex_inscriber") and "EX" or "AE2"
        table.insert(inscribers, {name = name, pType = pType, shortType = shortType, p = peripheral.wrap(name)})
    end
end

if #inscribers == 0 then
    log("ERROR: No inscribers found!")
    if logFile then logFile.close() end
    return
end

log("=== INSCRIBERS ===")
log("")

for i, ins in ipairs(inscribers) do
    log("[" .. i .. "] " .. ins.shortType .. " - " .. ins.name .. " (" .. ins.pType .. ")")
    log("    Size: " .. ins.p.size() .. " slots")

    for slot = 1, ins.p.size() do
        local item = ins.p.getItemDetail(slot)
        if item then
            log(string.format("    Slot %d: %s x%d", slot, item.name, item.count))
        else
            log(string.format("    Slot %d: (empty)", slot))
        end
    end
    log("")
end

if logFile then logFile.close() end
