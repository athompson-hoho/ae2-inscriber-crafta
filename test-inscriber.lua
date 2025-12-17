-- Test script: List all inscribers and their slot contents
local inscribers = {}

for _, name in ipairs(peripheral.getNames()) do
    local pType = peripheral.getType(name)
    if pType and pType:find("inscriber") then
        table.insert(inscribers, {name = name, p = peripheral.wrap(name)})
    end
end

if #inscribers == 0 then
    print("ERROR: No inscribers found!")
    return
end

print("=== INSCRIBERS ===")
print("")

for i, ins in ipairs(inscribers) do
    print("[" .. i .. "] " .. ins.name)
    print("    Size: " .. ins.p.size() .. " slots")

    for slot = 1, ins.p.size() do
        local item = ins.p.getItemDetail(slot)
        if item then
            print(string.format("    Slot %d: %s x%d", slot, item.name, item.count))
        else
            print(string.format("    Slot %d: (empty)", slot))
        end
    end
    print("")
end
