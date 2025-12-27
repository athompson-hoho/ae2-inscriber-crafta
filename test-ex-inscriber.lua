-- Test script: Discover EX Inscriber API and slot structure

-- Logging helper: prints to console and writes to debug.log
local logFile = fs.open("debug.log", "w")
local function log(msg)
    print(msg)
    if logFile then
        logFile.writeLine(msg)
        logFile.flush()
    end
end

local inscriber = nil

-- Find EX Inscriber
for _, name in ipairs(peripheral.getNames()) do
    local pType = peripheral.getType(name)
    if pType and pType:find("ex_inscriber") then
        inscriber = peripheral.wrap(name)
        log("Found: " .. name .. " (" .. pType .. ")")
        break
    end
end

if not inscriber then
    log("ERROR: No EX Inscriber found")
    if logFile then logFile.close() end
    return
end

log("")
log("=== EX INSCRIBER API ===")
log("")

-- List all methods
log("Available methods:")
for key, value in pairs(inscriber) do
    if type(value) == "function" then
        log("  - " .. key)
    end
end

log("")
log("=== SLOT STRUCTURE ===")
log("")

-- Try to discover slot structure
local ok, size = pcall(function() return inscriber.size() end)
if ok then
    log("Inscriber.size(): " .. size)
else
    log("No size() method")
end

log("")
log("Listing all slots with getItemDetail():")
for slot = 1, 32 do
    local ok, item = pcall(function() return inscriber.getItemDetail(slot) end)
    if ok and item then
        log(string.format("  Slot %2d: %s x%d", slot, item.name, item.count))
    end
end

log("")
log("=== JOB SLOT INFO ===")
log("")

-- Check if there's a job-specific API
if inscriber.getActiveJob then
    log("Has getActiveJob() method")
end
if inscriber.getJobs then
    log("Has getJobs() method")
    local jobs = inscriber.getJobs()
    if jobs then
        log("Current jobs: " .. #jobs)
        for i, job in ipairs(jobs) do
            log(string.format("  Job %d: %s", i, tostring(job)))
        end
    end
end
if inscriber.getJobDetails then
    log("Has getJobDetails() method")
end

log("")
log("=== TRY PUSHING TO DIFFERENT SLOTS ===")
log("")
log("Attempting chest.pushItems with different slot numbers")
local chest = peripheral.find("inventory")
if chest then
    log("Found chest, but not pushing (would consume items)")
else
    log("No chest found for test")
end

if logFile then logFile.close() end
