-- AE2 Inscriber Crafter - UI Module
-- Terminal display for status monitoring

local ui = {}

local WIDTH = 51
local HEIGHT = 19

-- Clear screen and reset cursor
local function clearScreen()
    term.clear()
    term.setCursorPos(1, 1)
end

-- Draw text at specified line
local function drawLine(y, text)
    term.setCursorPos(1, y)
    term.write(text)
end

-- Draw centered text
local function centerText(y, text)
    local x = math.floor((WIDTH - #text) / 2) + 1
    term.setCursorPos(x, y)
    term.write(text)
end

-- Main status display
function ui.render(systemState, inscribers, queueLength, stats)
    clearScreen()

    drawLine(1, string.rep("-", WIDTH))
    centerText(2, "AE2 INSCRIBER CRAFTER v1.0")
    drawLine(3, string.rep("-", WIDTH))

    drawLine(5, "INSCRIBERS: " .. #inscribers .. " connected")

    -- Show each inscriber state
    local line = 6
    for i, ins in ipairs(inscribers) do
        local state = ins.state or "UNKNOWN"
        drawLine(line, string.format("  [%d] %s", i, state))
        line = line + 1
        if line > 10 then break end
    end

    drawLine(12, "QUEUE: " .. queueLength .. " jobs pending")

    drawLine(14, "PRODUCTION:")
    drawLine(15, string.format("  Logic: %d  Calc: %d  Eng: %d  Conc: %d",
        stats.logic or 0, stats.calculation or 0, stats.engineering or 0, stats.concurrent or 0))

    local total = (stats.logic or 0) + (stats.calculation or 0) + (stats.engineering or 0) + (stats.concurrent or 0)
    drawLine(16, string.format("  Total: %d processors", total))

    local status = systemState.running and "Running" or "PAUSED"
    drawLine(18, "STATUS: " .. status)
end

-- Display error screen
function ui.showError(errorMessage, errorSource)
    clearScreen()
    drawLine(1, string.rep("-", WIDTH))
    centerText(2, "ERROR")
    drawLine(3, string.rep("-", WIDTH))
    drawLine(6, "  " .. tostring(errorMessage))
    drawLine(8, "  Source: " .. tostring(errorSource))
    drawLine(10, "  Operations paused.")
    drawLine(13, "  Press any key to retry...")
end

-- Wait for user keypress to recover
function ui.showRecoveryPrompt()
    os.pullEvent("key")
end

return ui
