-- Test script: Check network connectivity between chest and inscribers

-- Logging helper: prints to console and appends to debug.log
local logFile = fs.open("debug.log", "w")
local function log(msg)
    print(msg)
    if logFile then
        logFile.writeLine(msg)
        logFile.flush()
    end
end

log("=== NETWORK CONNECTIVITY TEST ===")
log("")

-- Find all peripherals
local allNames = peripheral.getNames()
log("Total peripherals detected: " .. #allNames)
log("")

-- Find chest
local chest, chestName = nil, nil
for _, name in ipairs(allNames) do
    local pType = peripheral.getType(name)
    if pType and not pType:find("inscriber") then
        if pType:find("chest") or pType:find("barrel") or pType == "inventory" then
            chest = peripheral.wrap(name)
            chestName = name
            log("Chest: " .. name .. " (" .. pType .. ")")
            break
        end
    end
end

if not chest then
    log("ERROR: No chest found!")
    if logFile then logFile.close() end
    return
end

-- Find inscribers
local inscribers = {}
for _, name in ipairs(allNames) do
    local pType = peripheral.getType(name)
    if pType and pType:find("inscriber") then
        local shortType = pType:find("ex_inscriber") and "EX" or "AE2"
        table.insert(inscribers, {name = name, pType = pType, shortType = shortType})
    end
end

log("")
log("Found " .. #inscribers .. " inscribers:")
for i, ins in ipairs(inscribers) do
    log(string.format("  [%d] %s - %s", i, ins.shortType, ins.name))
end

log("")
log("=== TESTING PUSH/PULL CONNECTIVITY ===")
log("")

-- Test if chest can see each inscriber
for i, ins in ipairs(inscribers) do
    -- Try a zero-count push to test connectivity (won't move items)
    local ok, err = pcall(function()
        -- This tests if the peripheral is reachable
        local result = chest.pushItems(ins.name, 1, 0, 1)
        return result
    end)

    if ok then
        log(string.format("[%d] %s - OK (reachable)", i, ins.name))
    else
        log(string.format("[%d] %s - FAILED: %s", i, ins.name, tostring(err)))
    end
end

log("")
log("=== CHECKING PERIPHERAL METHODS ===")
log("")

-- Check what methods the chest has
log("Chest methods:")
local methods = peripheral.getMethods(chestName)
local hasRemote = false
for _, method in ipairs(methods) do
    if method == "pushItems" then
        log("  - pushItems: YES")
    end
    if method == "pullItems" then
        log("  - pullItems: YES")
    end
end

log("")
log("Done. If any inscribers show FAILED, check wired modem connections.")
if logFile then logFile.close() end
