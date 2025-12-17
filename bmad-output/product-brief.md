# Product Brief: AE2 Inscriber Crafter

**Date:** 2025-12-17
**Author:** Developer
**Analyst:** Mary (Business Analyst)

---

## 1. Executive Summary

A ComputerCraft (CC:Tweaked) Lua program for Minecraft 1.21.1 / AllTheMods10 that automates Applied Energistics 2 (AE2) processor crafting. The system dynamically manages a pool of inscribers, automatically distributing materials and presses to craft Logic, Calculation, and Engineering processors with zero manual intervention.

---

## 2. Problem Statement

AE2 processor crafting is tedious and multi-step:
- Each processor requires 3 inscribing operations (print circuit, print silicon, assemble)
- Manual management of 4 different presses across inscribers
- Repetitive item shuffling between machines and storage

**This program eliminates manual processor crafting entirely.**

---

## 3. Target Platform

| Attribute | Value |
|-----------|-------|
| Minecraft Version | 1.21.1 |
| Modpack | AllTheMods10 |
| Primary Mod | ComputerCraft (CC:Tweaked) |
| Integration | Applied Energistics 2 |
| Language | Lua |

---

## 4. Functional Requirements

### FR-1: Peripheral Discovery
- Detect all inscribers attached directly to the computer
- Detect inscribers connected via wired modems on the network
- Detect the input/output chest (single chest for all I/O)
- Dynamically scale as peripherals are added or removed
- Minimum starting configuration: 3 inscribers + 1 chest

### FR-2: Recipe Knowledge

The program must understand and execute the following recipes:

#### Intermediate Products

| Recipe Name | Top Slot | Middle Slot | Bottom Slot | Output |
|-------------|----------|-------------|-------------|--------|
| Printed Logic Circuit | Logic Press | Gold Ingot | *(empty)* | Printed Logic Circuit |
| Printed Calculation Circuit | Calculation Press | Certus Quartz Crystal | *(empty)* | Printed Calculation Circuit |
| Printed Engineering Circuit | Engineering Press | Diamond | *(empty)* | Printed Engineering Circuit |
| Printed Silicon | Silicon Press | Silicon | *(empty)* | Printed Silicon |

#### Final Assembly

| Recipe Name | Top Slot | Middle Slot | Bottom Slot | Output |
|-------------|----------|-------------|-------------|--------|
| Logic Processor | Printed Logic Circuit | Redstone | Printed Silicon | Logic Processor |
| Calculation Processor | Printed Calculation Circuit | Redstone | Printed Silicon | Calculation Processor |
| Engineering Processor | Printed Engineering Circuit | Redstone | Printed Silicon | Engineering Processor |

### FR-3: Dynamic Job Allocation
- Any inscriber can perform any recipe (no dedicated machines)
- Inscribers are allocated to jobs from a shared pool
- Multiple inscribers can work in parallel on different jobs
- Jobs are queued when all inscribers are busy

### FR-4: Press Management
- 4 presses managed: Silicon, Logic, Calculation, Engineering
- Presses stored in the chest when not in use
- Program inserts required press before starting a job
- Program retrieves press after job completion and returns to chest
- Press lifecycle: Chest → Inscriber Top Slot → Job Runs → Chest

### FR-5: Material Monitoring
- Continuously scan chest for available materials
- Identify craftable products based on material availability
- Automatically queue jobs when sufficient materials detected
- Materials required per processor:
  - **Logic:** 1 Gold, 1 Silicon, 1 Redstone
  - **Calculation:** 1 Certus Quartz, 1 Silicon, 1 Redstone
  - **Engineering:** 1 Diamond, 1 Silicon, 1 Redstone

### FR-6: Continuous Operation
- Main loop runs indefinitely
- Polling interval for chest scanning (configurable recommended)
- No manual triggering required after startup

### FR-7: Status Display
- Compact real-time output on the computer terminal
- Display information:
  - Number of connected inscribers
  - Currently active jobs per inscriber
  - Queue depth (pending jobs)
  - Recent completions / production count
- Must fit on standard ComputerCraft terminal (51x19 characters)

### FR-8: Error Handling
- **Pause and Alert** behavior during development phase
- Detectable error conditions:
  - Chest full (cannot output finished products)
  - Missing press (expected press not found in chest)
  - Inscriber unresponsive or disconnected
  - Insufficient materials for queued job
- Display clear error message identifying the problem
- Halt all operations until manual intervention
- Future enhancement: configurable error handling strategies

---

## 5. Non-Functional Requirements

### NFR-1: Scalability
- Support minimum 3 inscribers (direct-attached)
- Scale to unlimited inscribers via wired modem networks
- Each modem node can have multiple inscribers attached
- No hard-coded limits on peripheral count

### NFR-2: Single I/O Point
- One chest serves as both input and output
- All materials enter via this chest
- All finished products return to this chest
- All presses stored in this chest when idle

### NFR-3: No Job Priority
- Process materials in discovery order
- No preference between processor types
- First-available materials, first-served

### NFR-4: Resilience
- Graceful handling of peripheral disconnection
- State recovery if computer restarts mid-job (stretch goal)

---

## 6. Item Registry

The program must recognize these AE2 items by their Minecraft IDs:

| Item | Expected ID (verify in-game) |
|------|------------------------------|
| Logic Press | `ae2:logic_processor_press` |
| Calculation Press | `ae2:calculation_processor_press` |
| Engineering Press | `ae2:engineering_processor_press` |
| Silicon Press | `ae2:silicon_press` |
| Gold Ingot | `minecraft:gold_ingot` |
| Certus Quartz Crystal | `ae2:certus_quartz_crystal` |
| Diamond | `minecraft:diamond` |
| Silicon | `ae2:silicon` |
| Redstone | `minecraft:redstone` |
| Printed Logic Circuit | `ae2:printed_logic_processor` |
| Printed Calculation Circuit | `ae2:printed_calculation_processor` |
| Printed Engineering Circuit | `ae2:printed_engineering_processor` |
| Printed Silicon | `ae2:printed_silicon` |
| Logic Processor | `ae2:logic_processor` |
| Calculation Processor | `ae2:calculation_processor` |
| Engineering Processor | `ae2:engineering_processor` |

*Note: Item IDs should be verified in AllTheMods10 as they may vary.*

---

## 7. Physical Setup Requirements

### Minimum Configuration
```
       [Inscriber]
           |
[Inscriber]-[Computer]-[Chest]
           |
       [Inscriber]
```

### Scaled Configuration (via Wired Modems)
```
[Computer]---[Modem]=====[Modem]---[Inscriber]
                ||         |-------[Inscriber]
                ||         |-------[Inscriber]
                ||
             [Modem]---[Inscriber]
                |-------[Inscriber]
```

---

## 8. Success Criteria

1. Program discovers all connected inscribers and chest on startup
2. Program correctly identifies available materials in chest
3. Program successfully crafts all three processor types
4. Program manages presses without manual intervention
5. Program displays real-time status on terminal
6. Program pauses and alerts on error conditions
7. Program scales when additional inscribers added via modem

---

## 9. Out of Scope (v1.0)

- Multiple input/output chests
- ME system integration (direct AE2 network connection)
- Priority queuing between processor types
- Automatic press crafting (presses must be provided)
- GUI beyond terminal text display
- Remote monitoring / wireless modem support

---

## 10. Open Questions

1. **Item IDs:** Need to verify exact item IDs in AllTheMods10 environment
2. **Polling Rate:** What interval should the chest be scanned? (100ms? 1s? 5s?)
3. **Inscriber Slot Names:** Verify CC:Tweaked peripheral API slot naming for AE2 inscribers
4. **Startup Behavior:** Should the program wait for all presses to be present before starting, or work with available presses?

---

## Appendix A: Crafting Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        INPUT CHEST                          │
│  [Gold] [Certus] [Diamond] [Silicon] [Redstone] [Presses]  │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    INSCRIBER POOL                           │
│                                                             │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐            │
│   │Inscriber1│    │Inscriber2│    │Inscriber3│    ...      │
│   └──────────┘    └──────────┘    └──────────┘            │
│        │               │               │                    │
│        └───────────────┴───────────────┘                    │
│                        │                                    │
│            ┌───────────┴───────────┐                       │
│            ▼                       ▼                       │
│    [Print Circuits]         [Print Silicon]                │
│            │                       │                       │
│            └───────────┬───────────┘                       │
│                        ▼                                    │
│              [Assemble Processor]                          │
│                        │                                    │
└────────────────────────┼────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                       OUTPUT CHEST                          │
│        [Logic] [Calculation] [Engineering] Processors       │
│                     (Same chest as input)                   │
└─────────────────────────────────────────────────────────────┘
```

---

*Document generated through collaborative requirements gathering.*
*Ready for Architecture and Development handoff.*
