-- Test script: Show all recipe item IDs and check what's in chest

-- Logging helper: prints to console and writes to debug.log
local logFile = fs.open("debug.log", "w")
local function log(msg)
    print(msg)
    if logFile then
        logFile.writeLine(msg)
        logFile.flush()
    end
end

local recipes = require("lib.recipes")

local chest = peripheral.find("inventory")
if not chest then
    log("ERROR: No chest found!")
    if logFile then logFile.close() end
    return
end

local contents = {}
for slot, item in pairs(chest.list()) do
    contents[item.name] = (contents[item.name] or 0) + item.count
end

log("=== EXPECTED ITEM IDS ===")
log("")
log("PRESSES:")
for name, id in pairs(recipes.PRESSES) do
    local have = contents[id] or 0
    local status = have > 0 and ("OK x" .. have) or "MISSING"
    log(string.format("  %s: %s [%s]", name, id, status))
end

log("")
log("MATERIALS:")
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
    log(string.format("  %s: %s [%s]", m[1], m[2], status))
end

log("")
log("=== UNRECOGNIZED ITEMS IN CHEST ===")
log("")

local known = {}
for _, id in pairs(recipes.PRESSES) do known[id] = true end
for _, id in pairs(recipes.ITEMS) do known[id] = true end

local found = false
for id, count in pairs(contents) do
    if not known[id] then
        log(string.format("  %s x%d", id, count))
        found = true
    end
end

if not found then
    log("  (none - all items recognized)")
end

if logFile then logFile.close() end
