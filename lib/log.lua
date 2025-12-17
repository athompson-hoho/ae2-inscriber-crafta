-- AE2 Inscriber Crafter - Logging Module
-- Provides configurable log levels for debugging and monitoring

local log = {}

-- Log level constants
local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

-- Current log level (default: INFO)
local _currentLevel = LOG_LEVELS.INFO

-- Private logging helper
local function _log(levelName, levelValue, source, message)
    if levelValue >= _currentLevel then
        print(string.format("[%s] [%s] %s", levelName, source, message))
    end
end

-- Set the minimum log level
function log.setLevel(level)
    local upperLevel = string.upper(level)
    if LOG_LEVELS[upperLevel] then
        _currentLevel = LOG_LEVELS[upperLevel]
    end
end

-- Public logging functions
function log.debug(source, message)
    _log("DEBUG", LOG_LEVELS.DEBUG, source, message)
end

function log.info(source, message)
    _log("INFO", LOG_LEVELS.INFO, source, message)
end

function log.warn(source, message)
    _log("WARN", LOG_LEVELS.WARN, source, message)
end

function log.error(source, message)
    _log("ERROR", LOG_LEVELS.ERROR, source, message)
end

return log
