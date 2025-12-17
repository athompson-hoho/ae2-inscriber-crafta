-- AE2 Inscriber Crafter - Jobs Module
-- Job queue and inscriber worker state machine

local jobs = {}
local log = require("lib.log")
local inventory = require("lib.inventory")
local config = require("config")

-- Private job queue
local _queue = {}

-- Inscriber slot constants (verified for AE2)
local SLOTS = {
    TOP = 1,      -- Press (top)
    BOTTOM = 2,   -- Press (bottom) or printed silicon for assembly
    MIDDLE = 3,   -- Material input (gold, certus, diamond, silicon, redstone)
    OUTPUT = 4,   -- Result
}

-- Add job to queue
function jobs.enqueue(job)
    table.insert(_queue, job)
    log.debug("jobs", "Enqueued job: " .. job.type)
end

-- Get next job from queue (FIFO)
function jobs.dequeue()
    if #_queue == 0 then
        return nil
    end
    return table.remove(_queue, 1)
end

-- Get current queue length
function jobs.getQueueLength()
    return #_queue
end

-- Clear the queue
function jobs.clearQueue()
    _queue = {}
    log.debug("jobs", "Queue cleared")
end

-- Create a worker function for an inscriber
function jobs.createWorker(inscriber, systemState, chest, stats)
    return function()
        while systemState.running do
            inscriber.state = "IDLE"

            -- Wait for job
            local job = jobs.dequeue()
            if not job then
                sleep(0.5)
            else
                inscriber.currentJob = job
                inscriber.state = "LOADING"
                log.debug("jobs", inscriber.name .. " starting job: " .. job.type)

                local ok, err = pcall(function()
                    local recipe = job.recipe

                    -- Load top slot (press or printed circuit)
                    if recipe.top then
                        local slot = inventory.findItem(chest, recipe.top.item)
                        if not slot then
                            error("Cannot find " .. recipe.top.item)
                        end
                        local success, transferErr = inventory.transferToInscriber(chest, inscriber, slot, 1, SLOTS.TOP)
                        if not success then
                            error("Failed to load top: " .. (transferErr or "unknown"))
                        end
                    end

                    -- Load middle slot (main material)
                    if recipe.middle then
                        local slot = inventory.findItem(chest, recipe.middle.item)
                        if not slot then
                            error("Cannot find " .. recipe.middle.item)
                        end
                        local success, transferErr = inventory.transferToInscriber(chest, inscriber, slot, 1, SLOTS.MIDDLE)
                        if not success then
                            error("Failed to load middle: " .. (transferErr or "unknown"))
                        end
                    end

                    -- Load bottom slot (for assembly recipes)
                    if recipe.bottom then
                        local slot = inventory.findItem(chest, recipe.bottom.item)
                        if not slot then
                            error("Cannot find " .. recipe.bottom.item)
                        end
                        local success, transferErr = inventory.transferToInscriber(chest, inscriber, slot, 1, SLOTS.BOTTOM)
                        if not success then
                            error("Failed to load bottom: " .. (transferErr or "unknown"))
                        end
                    end

                    inscriber.state = "PROCESSING"
                    log.debug("jobs", inscriber.name .. " processing")

                    -- Poll for completion
                    while not inscriber.peripheral.getItemDetail(SLOTS.OUTPUT) do
                        if not systemState.running then return end
                        sleep(config.processingPollInterval)
                    end

                    inscriber.state = "UNLOADING"
                    log.debug("jobs", inscriber.name .. " unloading")

                    -- Extract output
                    local success, transferErr = inventory.transferFromInscriber(chest, inscriber, SLOTS.OUTPUT)
                    if not success then
                        error("Failed to extract output: " .. (transferErr or "unknown"))
                    end

                    -- Return press if not consumed (printing recipes)
                    if recipe.top and not recipe.top.consume then
                        inventory.transferFromInscriber(chest, inscriber, SLOTS.TOP)
                    end

                    -- Update stats if provided
                    if stats then
                        if job.type == "assemble_logic" then
                            stats.logic = (stats.logic or 0) + 1
                        elseif job.type == "assemble_calculation" then
                            stats.calculation = (stats.calculation or 0) + 1
                        elseif job.type == "assemble_engineering" then
                            stats.engineering = (stats.engineering or 0) + 1
                        end
                    end

                    log.info("jobs", inscriber.name .. " completed: " .. job.type)
                end)

                if not ok then
                    inscriber.state = "ERROR"
                    systemState.error = err
                    systemState.errorSource = inscriber.name
                    systemState.running = false
                    log.error("jobs", inscriber.name .. " error: " .. tostring(err))
                end

                inscriber.currentJob = nil
            end
        end
    end
end

return jobs
