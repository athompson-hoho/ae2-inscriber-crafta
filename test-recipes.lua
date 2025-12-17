-- Test script: Show all recipe item IDs and check what's in chest
local recipes = require("lib.recipes")

local chest = peripheral.find("inventory")
if not chest then
    print("ERROR: No chest found!")
    return
end

local contents = {}
for slot, item in pairs(chest.list()) do
    contents[item.name] = (contents[item.name] or 0) + item.count
end

print("=== EXPECTED ITEM IDS ===")
print("")
print("PRESSES:")
for name, id in pairs(recipes.PRESSES) do
    local have = contents[id] or 0
    local status = have > 0 and ("OK x" .. have) or "MISSING"
    print(string.format("  %s: %s [%s]", name, id, status))
end

print("")
print("MATERIALS:")
local materials = {
    {"GOLD", recipes.ITEMS.GOLD},
    {"CERTUS", recipes.ITEMS.CERTUS},
    {"DIAMOND", recipes.ITEMS.DIAMOND},
    {"SILICON", recipes.ITEMS.SILICON},
    {"REDSTONE", recipes.ITEMS.REDSTONE},
}
for _, m in ipairs(materials) do
    local have = contents[m[2]] or 0
    local status = have > 0 and ("OK x" .. have) or "MISSING"
    print(string.format("  %s: %s [%s]", m[1], m[2], status))
end

print("")
print("=== UNRECOGNIZED ITEMS IN CHEST ===")
print("")

local known = {}
for _, id in pairs(recipes.PRESSES) do known[id] = true end
for _, id in pairs(recipes.ITEMS) do known[id] = true end

local found = false
for id, count in pairs(contents) do
    if not known[id] then
        print(string.format("  %s x%d", id, count))
        found = true
    end
end

if not found then
    print("  (none - all items recognized)")
end
