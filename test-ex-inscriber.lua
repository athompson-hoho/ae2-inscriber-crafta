-- Test script: Discover EX Inscriber API and slot structure

local inscriber = nil

-- Find EX Inscriber
for _, name in ipairs(peripheral.getNames()) do
    local pType = peripheral.getType(name)
    if pType and pType:find("ex_inscriber") then
        inscriber = peripheral.wrap(name)
        print("Found: " .. name .. " (" .. pType .. ")")
        break
    end
end

if not inscriber then
    print("ERROR: No EX Inscriber found")
    return
end

print("")
print("=== EX INSCRIBER API ===")
print("")

-- List all methods
print("Available methods:")
for key, value in pairs(inscriber) do
    if type(value) == "function" then
        print("  - " .. key)
    end
end

print("")
print("=== SLOT STRUCTURE ===")
print("")

-- Try to discover slot structure
local ok, size = pcall(function() return inscriber.size() end)
if ok then
    print("Inscriber.size(): " .. size)
else
    print("No size() method")
end

print("")
print("Listing all slots with getItemDetail():")
for slot = 1, 32 do
    local ok, item = pcall(function() return inscriber.getItemDetail(slot) end)
    if ok and item then
        print(string.format("  Slot %2d: %s x%d", slot, item.name, item.count))
    end
end

print("")
print("=== JOB SLOT INFO ===")
print("")

-- Check if there's a job-specific API
if inscriber.getActiveJob then
    print("Has getActiveJob() method")
end
if inscriber.getJobs then
    print("Has getJobs() method")
    local jobs = inscriber.getJobs()
    if jobs then
        print("Current jobs: " .. #jobs)
        for i, job in ipairs(jobs) do
            print(string.format("  Job %d: %s", i, tostring(job)))
        end
    end
end
if inscriber.getJobDetails then
    print("Has getJobDetails() method")
end

print("")
print("=== TRY PUSHING TO DIFFERENT SLOTS ===")
print("")
print("Attempting chest.pushItems with different slot numbers")
local chest = peripheral.find("inventory")
if chest then
    print("Found chest, but not pushing (would consume items)")
else
    print("No chest found for test")
end
