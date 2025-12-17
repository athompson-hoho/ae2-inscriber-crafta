-- AE2 Inscriber Crafter
-- Auto-runs on computer startup

local config = require("config")
local log = require("lib.log")
local peripherals = require("lib.peripherals")
local inventory = require("lib.inventory")
local recipes = require("lib.recipes")
local jobs = require("lib.jobs")
local ui = require("lib.ui")

-- Initialize logging
log.setLevel(config.logLevel)
log.info("startup", "AE2 Inscriber Crafter starting...")

-- Discover peripherals
local devices = peripherals.discover()

if not devices.chest then
    log.error("startup", "No chest found! Place a chest adjacent to the computer.")
    print("ERROR: No chest found!")
    print("Place a chest adjacent to the computer.")
    return
end

if #devices.inscribers == 0 then
    log.error("startup", "No inscribers found! Connect inscribers via modem or adjacency.")
    print("ERROR: No inscribers found!")
    print("Connect inscribers via modem or place adjacent to the computer.")
    return
end

log.info("startup", "Found " .. #devices.inscribers .. " inscribers")

-- Drain any leftover items from inscribers (recovery from reboot)
log.info("startup", "Draining inscribers...")
local drained = inventory.drainAllInscribers(devices.chest, devices.inscribers)
if drained > 0 then
    log.info("startup", "Recovered " .. drained .. " items from inscribers")
end

-- Shared state
local systemState = {
    running = true,
    error = nil,
    errorSource = nil,
}

local stats = {
    logic = 0,
    calculation = 0,
    engineering = 0,
}

-- Main loop function
local function mainLoop()
    while systemState.running do
        -- Only plan new jobs if queue is empty
        if jobs.getQueueLength() == 0 then
            local contents = inventory.scanChest(devices.chest)
            local newJobs = recipes.planCrafts(contents)

            for _, job in ipairs(newJobs) do
                jobs.enqueue(job)
            end

            if #newJobs > 0 then
                log.info("main", "Planned " .. #newJobs .. " jobs")
            end
        end

        -- Update UI
        ui.render(systemState, devices.inscribers, jobs.getQueueLength(), stats)

        -- Wait before next scan
        sleep(config.pollInterval)
    end
end

-- Main execution
local function run()
    -- Build worker list
    local workers = { mainLoop }

    for _, inscriber in ipairs(devices.inscribers) do
        table.insert(workers, jobs.createWorker(inscriber, systemState, devices.chest, stats))
    end

    -- Run all in parallel
    parallel.waitForAll(table.unpack(workers))
end

-- Outer loop with error recovery
while true do
    systemState.running = true
    systemState.error = nil
    systemState.errorSource = nil
    jobs.clearQueue()

    -- Drain inscribers before each run
    inventory.drainAllInscribers(devices.chest, devices.inscribers)

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
