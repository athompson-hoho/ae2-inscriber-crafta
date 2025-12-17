-- AE2 Inscriber Crafter - Recipes Module
-- Defines all inscriber recipes and planning logic

local recipes = {}
local log = require("lib.log")

-- Press item IDs
recipes.PRESSES = {
    LOGIC = "ae2:logic_processor_press",
    CALCULATION = "ae2:calculation_processor_press",
    ENGINEERING = "ae2:engineering_processor_press",
    SILICON = "ae2:silicon_press",
}

-- Material and output item IDs
recipes.ITEMS = {
    -- Raw materials
    GOLD = "minecraft:gold_ingot",
    CERTUS = "ae2:certus_quartz_crystal",
    DIAMOND = "minecraft:diamond",
    SILICON = "ae2:silicon",
    REDSTONE = "minecraft:redstone",

    -- Printed intermediates
    PRINTED_LOGIC = "ae2:printed_logic_processor",
    PRINTED_CALCULATION = "ae2:printed_calculation_processor",
    PRINTED_ENGINEERING = "ae2:printed_engineering_processor",
    PRINTED_SILICON = "ae2:printed_silicon",

    -- Final processors
    LOGIC_PROCESSOR = "ae2:logic_processor",
    CALCULATION_PROCESSOR = "ae2:calculation_processor",
    ENGINEERING_PROCESSOR = "ae2:engineering_processor",
}

-- All recipe definitions
recipes.ALL = {
    -- Printing recipes (press + material -> printed)
    print_logic = {
        type = "print_logic",
        top = { item = recipes.PRESSES.LOGIC, consume = false },
        middle = { item = recipes.ITEMS.GOLD, consume = true },
        bottom = nil,
        output = recipes.ITEMS.PRINTED_LOGIC,
    },
    print_calculation = {
        type = "print_calculation",
        top = { item = recipes.PRESSES.CALCULATION, consume = false },
        middle = { item = recipes.ITEMS.CERTUS, consume = true },
        bottom = nil,
        output = recipes.ITEMS.PRINTED_CALCULATION,
    },
    print_engineering = {
        type = "print_engineering",
        top = { item = recipes.PRESSES.ENGINEERING, consume = false },
        middle = { item = recipes.ITEMS.DIAMOND, consume = true },
        bottom = nil,
        output = recipes.ITEMS.PRINTED_ENGINEERING,
    },
    print_silicon = {
        type = "print_silicon",
        top = { item = recipes.PRESSES.SILICON, consume = false },
        middle = { item = recipes.ITEMS.SILICON, consume = true },
        bottom = nil,
        output = recipes.ITEMS.PRINTED_SILICON,
    },

    -- Assembly recipes (printed + redstone + printed silicon -> processor)
    assemble_logic = {
        type = "assemble_logic",
        top = { item = recipes.ITEMS.PRINTED_LOGIC, consume = true },
        middle = { item = recipes.ITEMS.REDSTONE, consume = true },
        bottom = { item = recipes.ITEMS.PRINTED_SILICON, consume = true },
        output = recipes.ITEMS.LOGIC_PROCESSOR,
    },
    assemble_calculation = {
        type = "assemble_calculation",
        top = { item = recipes.ITEMS.PRINTED_CALCULATION, consume = true },
        middle = { item = recipes.ITEMS.REDSTONE, consume = true },
        bottom = { item = recipes.ITEMS.PRINTED_SILICON, consume = true },
        output = recipes.ITEMS.CALCULATION_PROCESSOR,
    },
    assemble_engineering = {
        type = "assemble_engineering",
        top = { item = recipes.ITEMS.PRINTED_ENGINEERING, consume = true },
        middle = { item = recipes.ITEMS.REDSTONE, consume = true },
        bottom = { item = recipes.ITEMS.PRINTED_SILICON, consume = true },
        output = recipes.ITEMS.ENGINEERING_PROCESSOR,
    },
}

-- Check if a recipe can be crafted with current chest contents
local function canCraftRecipe(recipe, contents)
    -- Check top slot requirement
    if recipe.top and recipe.top.item then
        if not contents[recipe.top.item] or contents[recipe.top.item] < 1 then
            return false
        end
    end

    -- Check middle slot requirement
    if recipe.middle and recipe.middle.item then
        if not contents[recipe.middle.item] or contents[recipe.middle.item] < 1 then
            return false
        end
    end

    -- Check bottom slot requirement
    if recipe.bottom and recipe.bottom.item then
        if not contents[recipe.bottom.item] or contents[recipe.bottom.item] < 1 then
            return false
        end
    end

    return true
end

-- Get list of recipes that can be crafted immediately
function recipes.canCraft(chestContents)
    local craftable = {}

    for name, recipe in pairs(recipes.ALL) do
        if canCraftRecipe(recipe, chestContents) then
            table.insert(craftable, recipe)
            log.debug("recipes", "Can craft: " .. name)
        end
    end

    return craftable
end

-- Plan crafting jobs using bottom-up approach
function recipes.planCrafts(chestContents)
    local jobs = {}
    local contents = {}

    -- Copy contents for simulation
    for k, v in pairs(chestContents) do
        contents[k] = v
    end

    -- Helper to get count
    local function getCount(item)
        return contents[item] or 0
    end

    -- Helper to consume from simulation
    local function consume(item, count)
        contents[item] = (contents[item] or 0) - count
        if contents[item] < 0 then contents[item] = 0 end
    end

    -- Helper to add to simulation
    local function produce(item, count)
        contents[item] = (contents[item] or 0) + count
    end

    -- Phase 1: Queue print jobs for silicon (needed for all assembly)
    local siliconCount = getCount(recipes.ITEMS.SILICON)
    local siliconPressAvailable = getCount(recipes.PRESSES.SILICON) > 0

    if siliconPressAvailable and siliconCount > 0 then
        for i = 1, siliconCount do
            table.insert(jobs, {
                recipe = recipes.ALL.print_silicon,
                type = "print_silicon",
            })
            consume(recipes.ITEMS.SILICON, 1)
            produce(recipes.ITEMS.PRINTED_SILICON, 1)
        end
    end

    -- Phase 2: Queue print jobs for each processor type
    local printRecipes = {
        { recipe = recipes.ALL.print_logic, material = recipes.ITEMS.GOLD, press = recipes.PRESSES.LOGIC, output = recipes.ITEMS.PRINTED_LOGIC },
        { recipe = recipes.ALL.print_calculation, material = recipes.ITEMS.CERTUS, press = recipes.PRESSES.CALCULATION, output = recipes.ITEMS.PRINTED_CALCULATION },
        { recipe = recipes.ALL.print_engineering, material = recipes.ITEMS.DIAMOND, press = recipes.PRESSES.ENGINEERING, output = recipes.ITEMS.PRINTED_ENGINEERING },
    }

    for _, p in ipairs(printRecipes) do
        local materialCount = getCount(p.material)
        local pressAvailable = getCount(p.press) > 0

        if pressAvailable and materialCount > 0 then
            for i = 1, materialCount do
                table.insert(jobs, {
                    recipe = p.recipe,
                    type = p.recipe.type,
                })
                consume(p.material, 1)
                produce(p.output, 1)
            end
        end
    end

    -- Phase 3: Queue assembly jobs
    local assemblyRecipes = {
        { recipe = recipes.ALL.assemble_logic, printed = recipes.ITEMS.PRINTED_LOGIC },
        { recipe = recipes.ALL.assemble_calculation, printed = recipes.ITEMS.PRINTED_CALCULATION },
        { recipe = recipes.ALL.assemble_engineering, printed = recipes.ITEMS.PRINTED_ENGINEERING },
    }

    for _, a in ipairs(assemblyRecipes) do
        local printedCount = getCount(a.printed)
        local redstoneCount = getCount(recipes.ITEMS.REDSTONE)
        local siliconPrintedCount = getCount(recipes.ITEMS.PRINTED_SILICON)

        -- Can assemble min(printed, redstone, printedSilicon)
        local canAssemble = math.min(printedCount, redstoneCount, siliconPrintedCount)

        for i = 1, canAssemble do
            table.insert(jobs, {
                recipe = a.recipe,
                type = a.recipe.type,
            })
            consume(a.printed, 1)
            consume(recipes.ITEMS.REDSTONE, 1)
            consume(recipes.ITEMS.PRINTED_SILICON, 1)
        end
    end

    log.debug("recipes", "Planned " .. #jobs .. " jobs")
    return jobs
end

return recipes
