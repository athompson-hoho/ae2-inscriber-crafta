-- AE2 Inscriber Crafter Updater
-- Preserves your config.lua

local baseUrl = "https://raw.githubusercontent.com/athompson-hoho/ae2-inscriber-crafta/main/"

-- Note: config.lua is NOT in this list
local files = {
    "startup.lua",
    "lib/log.lua",
    "lib/peripherals.lua",
    "lib/inventory.lua",
    "lib/recipes.lua",
    "lib/jobs.lua",
    "lib/ui.lua",
    "install.lua",
    "update.lua",
}

print("AE2 Inscriber Crafter Updater")
print("==============================")
print("")
print("Note: Your config.lua will NOT be changed.")
print("")

-- Ensure lib directory exists
if not fs.exists("lib") then
    fs.makeDir("lib")
end

-- Download files
local updated = 0
local failed = 0

for _, file in ipairs(files) do
    print("Updating: " .. file)
    local url = baseUrl .. file

    -- Delete existing file first
    if fs.exists(file) then
        fs.delete(file)
    end

    local ok = shell.run("wget", url, file)
    if not ok then
        print("  FAILED!")
        failed = failed + 1
    else
        print("  OK")
        updated = updated + 1
    end
end

print("")
print("Updated: " .. updated .. " files")
if failed > 0 then
    print("Failed: " .. failed .. " files")
end
print("")
print("Run 'reboot' to apply updates.")
