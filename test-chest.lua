-- Test script: List all items in chest with exact IDs

-- Find chest (excluding inscribers)
local chest = nil
local chestName = nil

print("Scanning peripherals...")
print("")

for _, name in ipairs(peripheral.getNames()) do
    local pType = peripheral.getType(name)
    print("  " .. name .. " = " .. pType)

    -- Skip inscribers - they also have inventory but aren't chests
    if not pType:find("inscriber") then
        if pType:find("chest") or pType:find("barrel") or pType == "inventory" then
            chest = peripheral.wrap(name)
            chestName = name
        end
    end
end

print("")

if not chest then
    print("ERROR: No chest found!")
    print("Make sure a chest (not inscriber) is connected.")
    return
end

print("=== CHEST CONTENTS ===")
print("Using: " .. chestName .. " (" .. peripheral.getType(chestName) .. ")")
print("")

-- List items
local items = chest.list()
if not items then
    print("ERROR: chest.list() returned nil")
    return
end

local count = 0
for slot, item in pairs(items) do
    print(string.format("[%2d] %s x%d", slot, item.name, item.count))
    count = count + 1
end

print("")
print("Total: " .. count .. " stacks")
