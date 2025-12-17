---
project_name: 'ae2-inscriber-crafter'
user_name: 'Developer'
date: '2025-12-17'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'module_rules', 'critical_rules']
---

# Project Context for AI Agents

_Critical rules for implementing ae2-inscriber-crafter. Follow exactly._

---

## Technology Stack

| Component | Details |
|-----------|---------|
| Runtime | ComputerCraft CC:Tweaked (Lua 5.2 subset) |
| Target | Minecraft 1.21.1 / AllTheMods10 |
| Integration | Applied Energistics 2 inscribers |
| Deployment | GitHub + wget |

---

## Lua Language Rules

**MUST follow:**
- Use `local` for all variables and functions (no globals except modules)
- Strings: prefer double quotes `"string"`
- Tables: use `{}` initialization, trailing commas allowed
- Nil checks: `if not value then` (not `if value == nil`)
- String concat: use `..` operator
- No semicolons at end of statements

**Lua 5.2 Subset Constraints:**
- NO `goto` statement
- NO bitwise operators (use `bit32` API if needed)
- `require()` paths use dots: `require("lib.module")`

---

## CC:Tweaked API Rules

**Peripheral Access:**
- Always check `peripheral.isPresent(name)` before operations
- Use `peripheral.find("type")` for discovery, returns multiple values
- Wrap peripherals immediately after discovery
- Peripheral names may change on world reload - re-discover on startup

**Inventory Operations:**
- `pushItems(toName, fromSlot, limit, toSlot)` - returns count transferred
- `pullItems(fromName, fromSlot, limit, toSlot)` - returns count transferred
- Return value of 0 means transfer failed (destination full or source empty)
- Slot numbers are 1-indexed (not 0-indexed)

**Parallel Execution:**
- Use `parallel.waitForAll(fn1, fn2, ...)` for concurrent operations
- Each function runs as coroutine - use `sleep()` to yield
- Wrap risky operations in `pcall()` for error isolation
- Coroutines share globals - use local variables

**Terminal:**
- Standard size: 51 wide x 19 tall
- Use `term.clear()` and `term.setCursorPos(x, y)`
- Colors via `term.setTextColor(colors.white)`

---

## Module Rules

**Module Interface Pattern:**
```lua
local moduleName = {}

function moduleName.publicFunction()
end

local function _privateHelper()
end

return moduleName
```

**Naming:**
- Functions: `camelCase` - `getAvailableInscribers()`
- Variables: `camelCase` - `currentJob`
- Constants: `UPPER_SNAKE` - `MAX_RETRIES`
- Private: underscore prefix - `_internalState`

**Error Returns:**
- Data operations: `return nil, "error message"`
- Boolean operations: `return false, "error message"`
- Caller MUST check: `if not result then handle(err) end`

---

## State Machine States

Inscriber states (use these exact strings):
- `"IDLE"` - Available for job
- `"LOADING"` - Inserting press + materials
- `"PROCESSING"` - Waiting for inscriber
- `"UNLOADING"` - Extracting output
- `"ERROR"` - Fault condition

---

## File Structure

```
/
├── startup.lua       -- Entry point (auto-runs on boot)
├── config.lua        -- User settings (DO NOT overwrite on update)
├── install.lua       -- Fresh installation script
├── update.lua        -- Update from GitHub (preserves config.lua)
└── lib/
    ├── log.lua
    ├── peripherals.lua
    ├── inventory.lua
    ├── recipes.lua
    ├── jobs.lua
    └── ui.lua
```

---

## Critical Don't-Miss Rules

**DO:**
- Check peripheral presence before every operation
- Use `sleep(0.05)` in tight loops to yield
- Return errors, don't throw (except programmer mistakes)
- Log with format: `[LEVEL] [source] message`

**DON'T:**
- Don't use global variables (except module tables)
- Don't assume peripheral names persist across restarts
- Don't block without yielding (causes "too long without yielding")
- Don't overwrite config.lua in update.lua

**AE2 Inscriber Slots** (verify in-game):
- Top slot: Press or printed circuit
- Middle slot: Main input material
- Bottom slot: Press or printed silicon (assembly only)
- Output slot: Result

---

## Logging Format

```
[DEBUG] [jobs] Enqueued job: print_logic
[INFO] [inscriber:1] Starting job: print_silicon
[WARN] [inventory] Chest nearly full
[ERROR] [inscriber:2] Transfer failed: slot occupied
```

---

_Reference: bmad-output/architecture.md for full architectural decisions._
