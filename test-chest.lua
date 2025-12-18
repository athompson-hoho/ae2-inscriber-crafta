-- Test script: List all items in chest with exact IDs

-- Find chest by trying different methods
local chest = nil
local chestName = nil

-- Method 1: peripheral.find with inventory
chest = peripheral.find("inventory")
if chest then
    chestName = peripheral.getName(chest)
end

-- Method 2: Search all peripherals
if not chest then
    for _, name in ipairs(peripheral.getNames()) do
        local pType = peripheral.getType(name)
        if pType then
            print("Found peripheral: " .. name .. " (" .. pType .. ")")
            if pType:find("chest") or pType:find("inventory") or pType:find("barrel") then
                chest = peripheral.wrap(name)
                chestName = name
                break
            end
        end
    end
end

if not chest then
    print("ERROR: No chest found!")
    print("")
    print("Available peripherals:")
    for _, name in ipairs(peripheral.getNames()) do
        print("  " .. name .. " (" .. peripheral.getType(name) .. ")")
    end
    return
end

print("=== CHEST CONTENTS ===")
print("Chest: " .. chestName)
print("Type: " .. peripheral.getType(chestName))
print("")

-- Try to get size
local ok, size = pcall(function() return chest.size() end)
if ok then
    print("Size: " .. size .. " slots")
else
    print("Size: unknown")
end

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

if count == 0 then
    print("")
    print("Chest appears empty. Try:")
    print("  1. Make sure items are in the chest")
    print("  2. Check chest is connected to computer")
end
