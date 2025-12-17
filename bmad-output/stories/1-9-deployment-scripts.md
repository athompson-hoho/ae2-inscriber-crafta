# Story 1.9: Deployment Scripts (install.lua + update.lua)

Status: ready-for-dev

## Story

As a **user**,
I want **install.lua and update.lua scripts**,
so that **I can easily install the program from GitHub and update it without losing my config**.

## Acceptance Criteria

1. **AC1:** install.lua downloads all files from GitHub repository
2. **AC2:** install.lua creates lib/ directory structure
3. **AC3:** install.lua reports progress and success
4. **AC4:** update.lua downloads latest versions of all files EXCEPT config.lua
5. **AC5:** update.lua preserves user's config.lua (never overwrites)
6. **AC6:** update.lua reports what was updated
7. **AC7:** Both scripts use wget for downloads
8. **AC8:** Both scripts handle download failures gracefully

## Tasks / Subtasks

- [ ] Task 1: Create install.lua (AC: 1, 2, 3, 7, 8)
  - [ ] Define base URL for raw GitHub content
  - [ ] Define file list (all files including config.lua)
  - [ ] Create lib/ directory via fs.makeDir
  - [ ] Download each file via shell.run("wget", url, path)
  - [ ] Report progress for each file
  - [ ] Handle failures (retry or report)
  - [ ] Print success message with reboot instruction
- [ ] Task 2: Create update.lua (AC: 4, 5, 6, 7, 8)
  - [ ] Define base URL (same as install)
  - [ ] Define file list EXCLUDING config.lua
  - [ ] Download each file, overwriting existing
  - [ ] Report what was updated
  - [ ] Handle failures gracefully
  - [ ] Print success message

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#Development & Deployment]
- [Source: bmad-output/project-context.md#File Structure]

### GitHub Raw URL Pattern
```
https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{path}
```

Example:
```
https://raw.githubusercontent.com/username/ae2-inscriber-crafter/main/startup.lua
```

### File List
```lua
local files = {
    "startup.lua",
    "config.lua",          -- ONLY in install.lua, NOT in update.lua
    "lib/log.lua",
    "lib/peripherals.lua",
    "lib/inventory.lua",
    "lib/recipes.lua",
    "lib/jobs.lua",
    "lib/ui.lua",
}
```

### install.lua Pattern
```lua
-- AE2 Inscriber Crafter Installer
-- Run: wget run https://raw.githubusercontent.com/.../install.lua

local baseUrl = "https://raw.githubusercontent.com/USERNAME/ae2-inscriber-crafter/main/"

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
```

### update.lua Pattern
```lua
-- AE2 Inscriber Crafter Updater
-- Preserves your config.lua

local baseUrl = "https://raw.githubusercontent.com/USERNAME/ae2-inscriber-crafter/main/"

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
```

### Critical Notes
- **NEVER include config.lua in update.lua file list**
- Use `fs.delete()` before wget to ensure clean download
- `shell.run("wget", url, path)` returns boolean success
- User must replace USERNAME with actual GitHub username

### File Locations
- Create: `install.lua`
- Create: `update.lua`

### Dependencies
- None (standalone scripts)

## Dev Agent Record

### Agent Model Used
_To be filled by dev agent_

### Debug Log References
_To be filled during implementation_

### Completion Notes List
_To be filled during implementation_

### File List
- [ ] install.lua (CREATE)
- [ ] update.lua (CREATE)
