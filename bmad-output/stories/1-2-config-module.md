# Story 1.2: Config Module

Status: ready-for-dev

## Story

As a **user**,
I want a **configuration file for runtime settings**,
so that **I can customize polling intervals and log levels without modifying code**.

## Acceptance Criteria

1. **AC1:** config.lua returns a table with all settings
2. **AC2:** Contains `pollInterval` (number, seconds between chest scans)
3. **AC3:** Contains `logLevel` (string, one of DEBUG/INFO/WARN/ERROR)
4. **AC4:** Contains `processingPollInterval` (number, seconds between inscriber output checks)
5. **AC5:** All values have sensible defaults
6. **AC6:** File is valid Lua that can be loaded via require()

## Tasks / Subtasks

- [ ] Task 1: Create config.lua file (AC: 1, 6)
  - [ ] Create file in project root
  - [ ] Structure as return table
- [ ] Task 2: Add polling configuration (AC: 2, 4, 5)
  - [ ] Set pollInterval = 1 (1 second default)
  - [ ] Set processingPollInterval = 0.5 (500ms default)
- [ ] Task 3: Add logging configuration (AC: 3, 5)
  - [ ] Set logLevel = "INFO" (default)
- [ ] Task 4: Add comments for user documentation (AC: 5)
  - [ ] Document each setting's purpose
  - [ ] Document valid values/ranges

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#Technical Foundation]
- [Source: bmad-output/project-context.md#File Structure]

### Implementation Pattern
```lua
-- AE2 Inscriber Crafter Configuration
-- Edit these values to customize behavior
-- DO NOT delete this file - it will NOT be overwritten by update.lua

return {
    -- How often to scan the chest for materials (seconds)
    pollInterval = 1,

    -- How often to check inscriber output slot (seconds)
    processingPollInterval = 0.5,

    -- Log verbosity: DEBUG, INFO, WARN, ERROR
    logLevel = "INFO",
}
```

### Critical Note
- update.lua MUST preserve this file (never overwrite)
- User customizations live here

### File Location
- Create: `config.lua`

## Dev Agent Record

### Agent Model Used
_To be filled by dev agent_

### Debug Log References
_To be filled during implementation_

### Completion Notes List
_To be filled during implementation_

### File List
- [ ] config.lua (CREATE)
