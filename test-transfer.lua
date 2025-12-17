-- Test script: Test item transfer from chest to inscriber
-- Usage: test-transfer <inscriber_name> <chest_slot> <inscriber_slot>

local args = {...}

if #args < 3 then
    print("Usage: test-transfer <inscriber> <from_slot> <to_slot>")
    print("")
    print("Example: test-transfer back 1 2")
    print("  (transfers from chest slot 1 to inscriber slot 2)")
    print("")
    print("Run 'test-inscriber' to see inscriber names")
    print("Run 'test-chest' to see chest slots")
    return
end

local insName = args[1]
local fromSlot = tonumber(args[2])
local toSlot = tonumber(args[3])

local chest = peripheral.find("inventory")
if not chest then
    print("ERROR: No chest found!")
    return
end

local chestName = peripheral.getName(chest)

-- Show what we're transferring
local item = chest.getItemDetail(fromSlot)
if not item then
    print("ERROR: Chest slot " .. fromSlot .. " is empty!")
    return
end

print("Transferring: " .. item.name)
print("From: chest slot " .. fromSlot)
print("To: " .. insName .. " slot " .. toSlot)
print("")

local transferred = chest.pushItems(insName, fromSlot, 1, toSlot)

if transferred > 0 then
    print("SUCCESS: Transferred " .. transferred .. " item(s)")
else
    print("FAILED: Transfer returned 0")
    print("")
    print("Possible causes:")
    print("- Inscriber slot doesn't accept this item")
    print("- Inscriber slot is full")
    print("- Wrong slot number")
end
