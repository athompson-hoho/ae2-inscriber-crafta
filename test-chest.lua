-- Test script: List all items in chest with exact IDs
local chest = peripheral.find("inventory")

if not chest then
    print("ERROR: No chest found!")
    return
end

print("=== CHEST CONTENTS ===")
print("")

local items = chest.list()
local count = 0

for slot, item in pairs(items) do
    print(string.format("[%2d] %s x%d", slot, item.name, item.count))
    count = count + 1
end

print("")
print("Total: " .. count .. " stacks")
