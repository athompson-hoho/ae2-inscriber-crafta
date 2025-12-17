---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - bmad-output/product-brief.md
workflowType: 'architecture'
lastStep: 8
status: 'complete'
completedAt: '2025-12-17'
project_name: 'ae2-inscriber-crafta'
user_name: 'Developer'
date: '2025-12-17'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements (8 total):**

| FR | Name | Architectural Implication |
|----|------|---------------------------|
| FR-1 | Peripheral Discovery | Abstraction layer over CC peripheral API; dynamic device registry |
| FR-2 | Recipe Knowledge | Static data structure; slot-to-item mapping |
| FR-3 | Dynamic Job Allocation | Job queue + inscriber state machine; parallel execution |
| FR-4 | Press Management | Inventory tracking; presses are abundant (no contention) |
| FR-5 | Material Monitoring | Chest scanning loop; recipe-to-materials matching |
| FR-6 | Continuous Operation | Main event loop; coroutine-based concurrency |
| FR-7 | Status Display | Terminal rendering; compact UI layout (51x19) |
| FR-8 | Error Handling | Error detection; global pause state; alert display |

**Non-Functional Requirements (4 total):**

| NFR | Implication |
|-----|-------------|
| NFR-1: Scalability | No hardcoded limits; peripheral table must be dynamic |
| NFR-2: Single I/O | Simplifies design - one inventory to manage |
| NFR-3: No Priority | Simple FIFO job scheduling |
| NFR-4: Resilience | Graceful peripheral disconnect; optional state persistence |

### Scale & Complexity

- **Primary domain:** ComputerCraft Lua (embedded runtime)
- **Complexity level:** Medium-Low
- **Estimated architectural components:** 6-8 modules

**Complexity Rationale:**
- Parallel operations require coroutine management
- No resource contention (presses are abundant)
- Clear boundaries, single-node, well-defined domain
- Straightforward job-per-inscriber model

### Technical Constraints & Dependencies

| Constraint | Impact |
|------------|--------|
| CC:Tweaked Lua runtime | Coroutine-based concurrency, no true threads |
| Peripheral API | Must wrap `peripheral.wrap()`, `peripheral.find()` |
| AE2 Inscriber slots | Top/Middle/Bottom/Output - API slot names TBD |
| Terminal size | 51x19 character display limit |
| Single chest | All I/O through one inventory interface |

### Cross-Cutting Concerns Identified

1. **Concurrency Coordination** - Multiple inscribers running in parallel via coroutines
2. **Error Propagation** - Any inscriber error must pause system-wide
3. **Configuration** - Polling rate, debug mode, etc.
4. **Logging** - Debug output for development phase

## Technical Foundation

### Technology Stack

- **Runtime:** ComputerCraft CC:Tweaked (Lua 5.2 subset)
- **Target:** Minecraft 1.21.1 / AllTheMods10

### Project Structure

Multi-file organization using Lua `require()`:

| File | Purpose |
|------|---------|
| `startup.lua` | Entry point, main event loop |
| `config.lua` | User-configurable settings |
| `lib/log.lua` | Logging with levels (DEBUG/INFO/WARN/ERROR) |
| `lib/peripherals.lua` | Peripheral discovery and wrapping |
| `lib/inventory.lua` | Chest scanning and item transfer |
| `lib/recipes.lua` | Recipe definitions and matching logic |
| `lib/jobs.lua` | Job queue and inscriber state machine |
| `lib/ui.lua` | Terminal display rendering |
| `install.lua` | GitHub-based installer script |

### Development & Deployment

- **Source Control:** GitHub repository
- **Deployment:** `wget run` installer script
- **Configuration:** Editable `config.lua` without code changes

### Logging Strategy

Custom logging module with level filtering:
- **DEBUG:** Detailed job tracing (disabled in production)
- **INFO:** Normal operations, completions
- **WARN:** Recoverable issues
- **ERROR:** Failures requiring attention

Configuration-driven log level for easy debugging.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Inscriber state machine model
- Concurrency pattern (parallel.waitForAll)
- Error propagation (global state + pause)
- Item transfer method (pushItems/pullItems)

**Important Decisions (Shape Architecture):**
- Job representation structure
- Recipe matching strategy (bottom-up planning)
- Slot identification approach

**Deferred Decisions (Post-MVP):**
- State persistence on restart (NFR-4 stretch goal)

### State Management

**Inscriber State Machine:**
```
IDLE → LOADING → PROCESSING → UNLOADING → IDLE
                     ↓
                   ERROR
```

| State | Description |
|-------|-------------|
| IDLE | Available for new job |
| LOADING | Inserting press + materials |
| PROCESSING | Waiting for inscriber to complete |
| UNLOADING | Extracting output + returning press |
| ERROR | Fault condition, triggers system pause |

**Job Representation:**
```lua
{
    type = "print_logic",
    recipe = recipes.print_logic,
    inscriber = nil,
    status = "queued"  -- queued, active, complete, failed
}
```

### Concurrency Model

**Pattern:** `parallel.waitForAll` with main loop + per-inscriber workers

**Rationale:** CC:Tweaked's parallel API is battle-tested. Each inscriber runs its own coroutine. Errors isolated via `pcall()`.

**Completion Detection:** Poll output slot until item appears (0.5s interval)

### Inventory Operations

**Transfer Method:** Chest `pushItems()`/`pullItems()` to inscriber peripheral

**Slot Constants** (verify in-game):
```lua
SLOTS = { TOP = 1, MIDDLE = 2, BOTTOM = 3, OUTPUT = 4 }
```

Isolated in `lib/peripherals.lua` for easy adjustment.

### Error Handling

**Pattern:** Global error state with pause-and-alert

| Condition | Behavior |
|-----------|----------|
| Chest full | ERROR - Pause and alert |
| Missing press | ERROR - Pause and alert |
| Inscriber disconnect | ERROR - Pause and alert |
| Insufficient materials | IDLE - Wait, keep polling |

**Recovery:** User keypress clears error, restarts main loop.

### Recipe Matching

**Strategy:** Bottom-Up Planning

1. Scan chest for raw materials and intermediates
2. Calculate what final processors are achievable
3. Work backwards to queue intermediate jobs first
4. Dispatch jobs to available inscribers

**Benefit:** Optimizes throughput by planning full craft chains.

## Implementation Patterns & Consistency Rules

### Naming Patterns

**Functions:** `camelCase` (matches CC:Tweaked API style)
```lua
function getAvailableInscribers() end
function scanChestForMaterials() end
```

**Variables:** `camelCase` for locals, `UPPER_SNAKE_CASE` for constants
```lua
local currentJob = nil
local MAX_RETRIES = 3
```

**Private/Internal:** Prefix with underscore
```lua
local _internalCache = {}
local function _helperFunction() end
```

### Module Interface Pattern

**Standard: Return table with public functions**
```lua
local module = {}

function module.publicFunction() end

local function _privateHelper() end

return module
```

### Error Handling Convention

| Return Type | Pattern | Example |
|-------------|---------|---------|
| Data operations | `nil, errorString` | `return nil, "not found"` |
| Boolean operations | `false, errorString` | `return false, "failed"` |
| Programmer errors | `error()` | `error("invalid argument")` |

**Callers must check:**
```lua
local result, err = someOperation()
if not result then
    log.error("source", "Operation failed: " .. err)
end
```

### State Sharing Pattern

**Global system state:** Minimal shared table for cross-cutting concerns
```lua
local systemState = {
    running = true,
    error = nil,
    errorSource = nil
}
```

**Module-local state:** Each module owns its internal data
```lua
-- Inside lib/jobs.lua
local _queue = {}  -- private to module
```

### Log Message Format

**Format:** `[LEVEL] [source] message`

```
[DEBUG] [jobs] Enqueued job: print_logic
[INFO] [inscriber:1] Starting job: print_silicon
[ERROR] [inventory] Transfer failed: slot occupied
```

### Peripheral Wrapping Pattern

**Wrap peripherals with metadata and state:**
```lua
{
    name = "ae2:inscriber_0",
    peripheral = <raw_peripheral>,
    state = "IDLE",
    currentJob = nil
}
```

### Enforcement Guidelines

**All code MUST:**
- Use `camelCase` for functions and variables
- Return `nil/false + error` instead of throwing
- Use the standard module return pattern
- Log with `[LEVEL] [source] message` format
- Wrap peripherals with the metadata pattern

## Project Structure & Boundaries

### Complete Project Directory Structure

```
ae2-inscriber-crafter/
├── startup.lua              -- Entry point: main loop, parallel workers
├── config.lua               -- User settings: pollInterval, logLevel
├── install.lua              -- GitHub wget installer script
├── update.lua               -- Update from GitHub (preserves config.lua)
│
├── lib/
│   ├── log.lua              -- Logging module (DEBUG/INFO/WARN/ERROR)
│   ├── peripherals.lua      -- Peripheral discovery, inscriber wrapping
│   ├── inventory.lua        -- Chest scanning, item transfers
│   ├── recipes.lua          -- Recipe definitions, matching logic
│   ├── jobs.lua             -- Job queue, state machine
│   └── ui.lua               -- Terminal display rendering
│
└── README.md                -- Setup instructions (for GitHub)
```

### Requirements to Structure Mapping

| Requirement | Primary File(s) | Supporting Files |
|-------------|-----------------|------------------|
| FR-1: Peripheral Discovery | `lib/peripherals.lua` | `startup.lua` (initialization) |
| FR-2: Recipe Knowledge | `lib/recipes.lua` | - |
| FR-3: Dynamic Job Allocation | `lib/jobs.lua` | `startup.lua` (dispatch) |
| FR-4: Press Management | `lib/inventory.lua` | `lib/recipes.lua` (press lookup) |
| FR-5: Material Monitoring | `lib/inventory.lua` | `lib/recipes.lua` (matching) |
| FR-6: Continuous Operation | `startup.lua` | `lib/jobs.lua` (workers) |
| FR-7: Status Display | `lib/ui.lua` | `startup.lua` (render loop) |
| FR-8: Error Handling | `startup.lua` | All modules (error returns) |

### Module Responsibilities & Boundaries

#### startup.lua
**Role:** Orchestrator
- Initialize: load config, discover peripherals
- Create shared systemState
- Spawn parallel workers (main loop + inscriber workers)
- Handle global error state and user recovery

**Boundary:** Only file that uses `parallel.waitForAll`. All other modules are pure libraries.

#### lib/peripherals.lua
**Role:** Peripheral abstraction layer
```lua
-- Public API:
peripherals.discover()           -- Find all inscribers + chest
peripherals.wrapInscriber(name)  -- Wrap with metadata
peripherals.wrapChest(name)      -- Wrap chest peripheral
peripherals.refresh()            -- Re-scan for changes
```
**Boundary:** Only module that calls `peripheral.*` APIs directly.

#### lib/inventory.lua
**Role:** Item management
```lua
-- Public API:
inventory.scanChest(chest)                    -- Returns {itemId: count, ...}
inventory.findItem(chest, itemId)             -- Returns slot number or nil
inventory.transferToInscriber(chest, inscriber, slot, itemId, count, targetSlot)
inventory.transferFromInscriber(chest, inscriber, sourceSlot)
```
**Boundary:** Handles all chest/inscriber item movement. Does NOT know about recipes.

#### lib/recipes.lua
**Role:** Recipe definitions and planning
```lua
-- Public API:
recipes.ALL                      -- Table of all recipe definitions
recipes.PRESSES                  -- Table of press item IDs
recipes.canCraft(chestContents)  -- Returns list of craftable jobs
recipes.planCrafts(chestContents) -- Bottom-up planning, returns job list
```
**Boundary:** Pure data + logic. No peripheral access.

#### lib/jobs.lua
**Role:** Job queue and inscriber state machine
```lua
-- Public API:
jobs.enqueue(job)               -- Add job to queue
jobs.dequeue()                  -- Get next job (FIFO)
jobs.getQueueLength()           -- For UI display
jobs.createWorker(inscriber, systemState, chest)  -- Returns coroutine function
```
**Boundary:** Owns job queue. Workers coordinate with inventory module.

#### lib/ui.lua
**Role:** Terminal rendering
```lua
-- Public API:
ui.render(systemState, inscribers, queueLength, stats)
ui.showError(errorMessage, errorSource)
ui.showRecoveryPrompt()
```
**Boundary:** Only module that writes to terminal (except log). Renders to 51x19.

#### lib/log.lua
**Role:** Logging utility
```lua
-- Public API:
log.debug(source, message)
log.info(source, message)
log.warn(source, message)
log.error(source, message)
log.setLevel(level)
```
**Boundary:** Respects config.logLevel.

#### config.lua
**Role:** User configuration
```lua
return {
    pollInterval = 1,
    logLevel = "INFO",
    processingPollInterval = 0.5,
}
```
**Boundary:** Pure data, no logic.

### Data Flow

```
startup.lua
    │
    ├── peripherals.discover() → inscribers[], chest
    │
    └── parallel.waitForAll(mainLoop, worker1, worker2, ...)
            │                    │
            │                    └── jobs.createWorker()
            │                            │
            │                            ├── LOADING: inventory.transfer()
            │                            ├── PROCESSING: poll output slot
            │                            └── UNLOADING: inventory.transfer()
            │
            └── mainLoop:
                    ├── inventory.scanChest()
                    ├── recipes.planCrafts()
                    ├── jobs.enqueue()
                    └── ui.render()
```

## Architecture Validation Results

### Coherence Validation ✅

- All technology choices (Lua, parallel API, require) work together
- Patterns align with CC:Tweaked conventions
- Project structure supports all architectural decisions
- No conflicting decisions detected

### Requirements Coverage ✅

| Category | Coverage |
|----------|----------|
| Functional Requirements | 8/8 (100%) |
| Non-Functional Requirements | 4/4 (100%) |

All requirements have explicit architectural support mapped to specific modules.

### Implementation Readiness ✅

- State machine fully defined (IDLE/LOADING/PROCESSING/UNLOADING/ERROR)
- Module APIs specified with public functions
- Patterns documented with examples
- Boundaries clearly established

### Open Items for Implementation

1. Verify AE2 item IDs in AllTheMods10 environment
2. Verify inscriber slot names via CC:Tweaked peripheral API
3. Tune `pollInterval` and `processingPollInterval` based on testing

### Architecture Completeness Checklist

- [x] Project context analyzed
- [x] Technical constraints identified
- [x] Core decisions documented
- [x] Implementation patterns defined
- [x] Project structure mapped
- [x] Requirements coverage verified
- [x] Validation complete

**Status: READY FOR IMPLEMENTATION**

## Architecture Completion Summary

### Workflow Completion

| Item | Status |
|------|--------|
| Architecture Decision Workflow | COMPLETED ✅ |
| Total Steps Completed | 8 |
| Date Completed | 2025-12-17 |
| Document Location | `bmad-output/architecture.md` |

### Final Architecture Deliverables

**Complete Architecture Document**
- All architectural decisions documented
- Implementation patterns ensuring consistency
- Complete project structure with all files
- Requirements to architecture mapping
- Validation confirming coherence

**Implementation Ready Foundation**
- 12+ architectural decisions made
- 6 implementation patterns defined
- 8 modules specified
- 12 requirements fully supported (8 FR + 4 NFR)

### Implementation Handoff

**For AI Agents:**
This architecture document is your complete guide for implementing ae2-inscriber-crafter. Follow all decisions, patterns, and structures exactly as documented.

**First Implementation Priority:**
1. Create project directory structure
2. Implement `lib/log.lua` (foundation module)
3. Implement `config.lua`
4. Implement `lib/peripherals.lua`
5. Build remaining modules following dependency order

**Development Sequence:**
1. Create all files per project structure
2. Implement modules bottom-up (log → peripherals → inventory → recipes → jobs → ui → startup)
3. Test each module in isolation where possible
4. Integration test with actual AE2 inscribers

### Quality Assurance Checklist

**Architecture Coherence**
- [x] All decisions work together without conflicts
- [x] Technology choices are compatible (Lua + CC:Tweaked)
- [x] Patterns support the architectural decisions
- [x] Structure aligns with all choices

**Requirements Coverage**
- [x] All functional requirements are supported
- [x] All non-functional requirements are addressed
- [x] Cross-cutting concerns are handled
- [x] Module boundaries are defined

**Implementation Readiness**
- [x] Decisions are specific and actionable
- [x] Patterns prevent implementation conflicts
- [x] Structure is complete and unambiguous
- [x] Examples are provided for clarity

---

**Architecture Status:** READY FOR IMPLEMENTATION ✅

**Next Phase:** Begin implementation using the architectural decisions and patterns documented herein.

