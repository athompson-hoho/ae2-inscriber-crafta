# Story 1.1: Log Module

Status: ready-for-dev

## Story

As a **developer**,
I want a **logging module with configurable levels**,
so that **I can debug and monitor the inscriber system with appropriate verbosity**.

## Acceptance Criteria

1. **AC1:** Module exports `log.debug()`, `log.info()`, `log.warn()`, `log.error()` functions
2. **AC2:** Each function accepts `(source, message)` parameters
3. **AC3:** Output format is `[LEVEL] [source] message`
4. **AC4:** Log level is configurable via `log.setLevel(level)`
5. **AC5:** Levels filter appropriately (ERROR shows only errors, DEBUG shows all)
6. **AC6:** Module follows standard interface pattern (returns table)

## Tasks / Subtasks

- [ ] Task 1: Create lib/log.lua file structure (AC: 6)
  - [ ] Create lib/ directory if not exists
  - [ ] Initialize module table
  - [ ] Add return statement
- [ ] Task 2: Implement log level constants (AC: 5)
  - [ ] Define LOG_LEVELS table with numeric values (DEBUG=1, INFO=2, WARN=3, ERROR=4)
  - [ ] Create private _currentLevel variable defaulting to INFO
- [ ] Task 3: Implement setLevel function (AC: 4)
  - [ ] Accept string level name
  - [ ] Validate level exists
  - [ ] Update _currentLevel
- [ ] Task 4: Implement core logging function (AC: 1, 2, 3)
  - [ ] Create private _log(level, source, message) helper
  - [ ] Check if level >= _currentLevel before printing
  - [ ] Format output as [LEVEL] [source] message
- [ ] Task 5: Implement public API functions (AC: 1, 2)
  - [ ] log.debug(source, message)
  - [ ] log.info(source, message)
  - [ ] log.warn(source, message)
  - [ ] log.error(source, message)

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#Logging Strategy]
- [Source: bmad-output/project-context.md#Logging Format]

### Implementation Pattern
```lua
local log = {}

local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

local _currentLevel = LOG_LEVELS.INFO

local function _log(levelName, levelValue, source, message)
    if levelValue >= _currentLevel then
        print(string.format("[%s] [%s] %s", levelName, source, message))
    end
end

function log.setLevel(level)
    local upperLevel = string.upper(level)
    if LOG_LEVELS[upperLevel] then
        _currentLevel = LOG_LEVELS[upperLevel]
    end
end

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
```

### Testing Notes
- ComputerCraft has no built-in test framework
- Manual testing: call each function, verify output
- Test level filtering by setting DEBUG then ERROR

### File Location
- Create: `lib/log.lua`

## Dev Agent Record

### Agent Model Used
_To be filled by dev agent_

### Debug Log References
_To be filled during implementation_

### Completion Notes List
_To be filled during implementation_

### File List
- [ ] lib/log.lua (CREATE)
