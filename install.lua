-- AE2 Inscriber Crafter Installer
-- Run: wget run https://raw.githubusercontent.com/athompson-hoho/ae2-inscriber-crafta/main/install.lua

local baseUrl = "https://raw.githubusercontent.com/athompson-hoho/ae2-inscriber-crafta/main/"

local files = {
    "startup.lua",
    "config.lua",
    "lib/log.lua",
    "lib/peripherals.lua",
    "lib/inventory.lua",
    "lib/recipes.lua",
    "lib/jobs.lua",
    "lib/ui.lua",
}

print("AE2 Inscriber Crafter Installer")
print("================================")
print("")

-- Create lib directory
if not fs.exists("lib") then
    fs.makeDir("lib")
    print("Created lib/ directory")
end

-- Download files
local success = true
for _, file in ipairs(files) do
    print("Downloading: " .. file)
    local url = baseUrl .. file

    -- Delete existing file first
    if fs.exists(file) then
        fs.delete(file)
    end

    local ok = shell.run("wget", url, file)
    if not ok then
        print("  FAILED!")
        success = false
    else
        print("  OK")
    end
end

print("")
if success then
    print("Installation complete!")
    print("Run 'reboot' to start the program.")
else
    print("Some files failed to download.")
    print("Check your internet connection and try again.")
end
