# Story 1.8: Startup Module (Main Orchestrator)

Status: ready-for-dev

## Story

As a **user**,
I want the **main startup.lua orchestrator**,
so that **the system initializes, discovers peripherals, spawns workers, and runs the main loop**.

## Acceptance Criteria

1. **AC1:** startup.lua is the entry point that auto-runs on computer boot
2. **AC2:** Loads config and initializes log level
3. **AC3:** Discovers all peripherals via peripherals module
4. **AC4:** Creates shared systemState table
5. **AC5:** Spawns parallel workers: main loop + one per inscriber
6. **AC6:** Main loop: scans chest, plans crafts, enqueues jobs, renders UI
7. **AC7:** Handles global error state: displays error, waits for recovery, restarts
8. **AC8:** Graceful startup with status messages

## Tasks / Subtasks

- [ ] Task 1: Create startup.lua structure (AC: 1)
  - [ ] Create file in project root
  - [ ] Add shebang/header comments
- [ ] Task 2: Implement initialization sequence (AC: 2, 3, 4, 8)
  - [ ] Load config
  - [ ] Initialize log level from config
  - [ ] Discover peripherals
  - [ ] Validate minimum requirements (chest + 1 inscriber)
  - [ ] Create systemState table
  - [ ] Create stats table for UI
- [ ] Task 3: Implement main loop function (AC: 6)
  - [ ] Scan chest for materials
  - [ ] Call recipes.planCrafts()
  - [ ] Enqueue new jobs
  - [ ] Render UI
  - [ ] Sleep for pollInterval
  - [ ] Check systemState.running
- [ ] Task 4: Implement worker spawning (AC: 5)
  - [ ] Create worker function for each inscriber
  - [ ] Use jobs.createWorker()
  - [ ] Prepare function list for parallel.waitForAll
- [ ] Task 5: Implement error recovery loop (AC: 7)
  - [ ] Detect systemState.error
  - [ ] Display error via ui.showError()
  - [ ] Wait for keypress via ui.showRecoveryPrompt()
  - [ ] Clear error state
  - [ ] Restart main execution
- [ ] Task 6: Implement main execution wrapper (AC: 5, 7)
  - [ ] Wrap parallel.waitForAll in outer loop
  - [ ] Handle recovery and restart

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#startup.lua]
- [Source: bmad-output/architecture.md#Concurrency Model]
- [Source: bmad-output/architecture.md#Error Handling]
- [Source: bmad-output/project-context.md#Critical Don't-Miss Rules]

### System State Structure
```lua
local systemState = {
    running = true,
    error = nil,
    errorSource = nil
}
```

### Stats Structure
```lua
local stats = {
    logic = 0,
    calculation = 0,
    engineering = 0
}
```

### Implementation Pattern
```lua
-- AE2 Inscriber Crafter
-- Auto-runs on computer startup

local config = require("config")
local log = require("lib.log")
local peripherals = require("lib.peripherals")
local inventory = require("lib.inventory")
local recipes = require("lib.recipes")
local jobs = require("lib.jobs")
local ui = require("lib.ui")

-- Initialize
log.setLevel(config.logLevel)
log.info("startup", "AE2 Inscriber Crafter starting...")

-- Discover peripherals
local devices = peripherals.discover()

if not devices.chest then
    log.error("startup", "No chest found! Place a chest adjacent to the computer.")
    return
end

if #devices.inscribers == 0 then
    log.error("startup", "No inscribers found! Connect inscribers via modem or adjacency.")
    return
end

log.info("startup", "Found " .. #devices.inscribers .. " inscribers")

-- Shared state
local systemState = {
    running = true,
    error = nil,
    errorSource = nil
}

local stats = {
    logic = 0,
    calculation = 0,
    engineering = 0
}

-- Main loop function
local function mainLoop()
    while systemState.running do
        -- Scan and plan
        local contents = inventory.scanChest(devices.chest)
        local newJobs = recipes.planCrafts(contents)

        -- Enqueue jobs
        for _, job in ipairs(newJobs) do
            jobs.enqueue(job)
        end

        -- Update UI
        ui.render(systemState, devices.inscribers, jobs.getQueueLength(), stats)

        -- Wait
        sleep(config.pollInterval)
    end
end

-- Main execution
local function run()
    -- Build worker list
    local workers = { mainLoop }

    for _, inscriber in ipairs(devices.inscribers) do
        table.insert(workers, jobs.createWorker(inscriber, systemState, devices.chest))
    end

    -- Run all in parallel
    parallel.waitForAll(table.unpack(workers))
end

-- Outer loop with error recovery
while true do
    systemState.running = true
    systemState.error = nil
    systemState.errorSource = nil

    local ok, err = pcall(run)

    if not ok then
        systemState.error = err
        systemState.errorSource = "system"
    end

    if systemState.error then
        ui.showError(systemState.error, systemState.errorSource)
        ui.showRecoveryPrompt()
        log.info("startup", "User triggered recovery, restarting...")
    else
        -- Clean exit
        break
    end
end
```

### Critical Notes
- Use `table.unpack()` for parallel.waitForAll (Lua 5.2)
- Outer while loop handles recovery
- pcall wraps the entire parallel execution
- Stats should be updated by workers when jobs complete (enhancement)

### File Location
- Create: `startup.lua`

### Dependencies
- Requires: ALL lib modules
- Requires: config.lua

## Dev Agent Record

### Agent Model Used
_To be filled by dev agent_

### Debug Log References
_To be filled during implementation_

### Completion Notes List
_To be filled during implementation_

### File List
- [ ] startup.lua (CREATE)
