# Story 1.5: Recipes Module

Status: ready-for-dev

## Story

As a **system**,
I want a **recipes module with all AE2 inscriber recipes and planning logic**,
so that **I can determine what can be crafted and plan the job sequence**.

## Acceptance Criteria

1. **AC1:** Module exports `recipes.ALL` table with all recipe definitions
2. **AC2:** Module exports `recipes.PRESSES` table with press item IDs
3. **AC3:** Each recipe defines: type, top slot, middle slot, bottom slot, output
4. **AC4:** Module exports `recipes.canCraft(chestContents)` returning list of immediately craftable recipes
5. **AC5:** Module exports `recipes.planCrafts(chestContents)` implementing bottom-up planning
6. **AC6:** Planning returns ordered job list (intermediates first, then assembly)
7. **AC7:** Recipes include all 3 processor types + printed silicon

## Tasks / Subtasks

- [ ] Task 1: Create lib/recipes.lua structure (AC: 1)
  - [ ] Create file with module table
  - [ ] Require log module
- [ ] Task 2: Define item ID constants (AC: 2)
  - [ ] Define PRESSES table with all 4 press IDs
  - [ ] Define ITEMS table with all material/output IDs
- [ ] Task 3: Define recipe structures (AC: 1, 3, 7)
  - [ ] print_logic: Logic Press + Gold -> Printed Logic
  - [ ] print_calculation: Calc Press + Certus -> Printed Calc
  - [ ] print_engineering: Eng Press + Diamond -> Printed Eng
  - [ ] print_silicon: Silicon Press + Silicon -> Printed Silicon
  - [ ] assemble_logic: Printed Logic + Redstone + Printed Silicon -> Logic Processor
  - [ ] assemble_calculation: Printed Calc + Redstone + Printed Silicon -> Calc Processor
  - [ ] assemble_engineering: Printed Eng + Redstone + Printed Silicon -> Eng Processor
- [ ] Task 4: Implement canCraft function (AC: 4)
  - [ ] Check chest contents against each recipe
  - [ ] Return list of recipes that can be started NOW
- [ ] Task 5: Implement planCrafts function (AC: 5, 6)
  - [ ] Calculate what final processors are achievable
  - [ ] Work backwards to determine intermediate needs
  - [ ] Return ordered job list (print jobs before assembly jobs)

## Dev Notes

### Architecture Reference
- [Source: bmad-output/architecture.md#Recipe Matching]
- [Source: bmad-output/architecture.md#FR-2: Recipe Knowledge]
- [Source: bmad-output/product-brief.md#Item Registry]

### AE2 Item IDs (VERIFY IN-GAME)
```lua
-- Presses
ae2:logic_processor_press
ae2:calculation_processor_press
ae2:engineering_processor_press
ae2:silicon_press

-- Materials
minecraft:gold_ingot
ae2:certus_quartz_crystal
minecraft:diamond
ae2:silicon
minecraft:redstone

-- Intermediates
ae2:printed_logic_processor
ae2:printed_calculation_processor
ae2:printed_engineering_processor
ae2:printed_silicon

-- Final Products
ae2:logic_processor
ae2:calculation_processor
ae2:engineering_processor
```

### Recipe Structure
```lua
{
    type = "print_logic",
    top = { item = "ae2:logic_processor_press", consume = false },
    middle = { item = "minecraft:gold_ingot", consume = true },
    bottom = nil,  -- or { item = "...", consume = true } for assembly
    output = "ae2:printed_logic_processor"
}
```

### AE2 Inscriber Slot Layout
- **Top slot:** Press OR printed circuit (for assembly)
- **Middle slot:** Main material input
- **Bottom slot:** Empty for printing, OR printed silicon for assembly
- **Output slot:** Result

### Planning Algorithm (Bottom-Up)
1. Count raw materials: gold, certus, diamond, silicon, redstone
2. Count existing intermediates: printed circuits, printed silicon
3. For each processor type:
   - Calculate how many can be made (limited by materials)
   - Queue print jobs for missing intermediates
   - Queue assembly jobs
4. Return jobs in dependency order

### File Location
- Create: `lib/recipes.lua`

### Dependencies
- Requires: `lib/log.lua` (Story 1.1)

## Dev Agent Record

### Agent Model Used
_To be filled by dev agent_

### Debug Log References
_To be filled during implementation_

### Completion Notes List
_To be filled during implementation_

### File List
- [ ] lib/recipes.lua (CREATE)
