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
    CONCURRENT = "extendedae:concurrent_processor_press",
}

-- Material and output item IDs
recipes.ITEMS = {
    -- Raw materials
    GOLD = "minecraft:gold_ingot",
    CERTUS = "ae2:certus_quartz_crystal",
    DIAMOND = "minecraft:diamond",
    SILICON = "ae2:silicon",
    REDSTONE = "minecraft:redstone",
    ENTRO_CRYSTAL = "extendedae:entro_crystal",

    -- Printed intermediates
    PRINTED_LOGIC = "ae2:printed_logic_processor",
    PRINTED_CALCULATION = "ae2:printed_calculation_processor",
    PRINTED_ENGINEERING = "ae2:printed_engineering_processor",
    PRINTED_SILICON = "ae2:printed_silicon",
    PRINTED_CONCURRENT = "extendedae:concurrent_processor_print",

    -- Final processors
    LOGIC_PROCESSOR = "ae2:logic_processor",
    CALCULATION_PROCESSOR = "ae2:calculation_processor",
    ENGINEERING_PROCESSOR = "ae2:engineering_processor",
    CONCURRENT_PROCESSOR = "extendedae:concurrent_processor",
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
    print_concurrent = {
        type = "print_concurrent",
        top = { item = recipes.PRESSES.CONCURRENT, consume = false },
        middle = { item = recipes.ITEMS.ENTRO_CRYSTAL, consume = true },
        bottom = nil,
        output = recipes.ITEMS.PRINTED_CONCURRENT,
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
    assemble_concurrent = {
        type = "assemble_concurrent",
        top = { item = recipes.ITEMS.PRINTED_CONCURRENT, consume = true },
        middle = { item = recipes.ITEMS.REDSTONE, consume = true },
        bottom = { item = recipes.ITEMS.PRINTED_SILICON, consume = true },
        output = recipes.ITEMS.CONCURRENT_PROCESSOR,
    },
}

-- Recipe priority order (print first, then assemble)
recipes.PRIORITY = {
    "print_silicon",
    "print_logic",
    "print_calculation",
    "print_engineering",
    "print_concurrent",
    "assemble_logic",
    "assemble_calculation",
    "assemble_engineering",
    "assemble_concurrent",
}

-- Check how many of a recipe can be made with current contents
local function countCraftable(recipe, contents)
    local count = 999999  -- Start high, find minimum

    -- Check top slot
    if recipe.top and recipe.top.item then
        local have = contents[recipe.top.item] or 0
        if recipe.top.consume then
            count = math.min(count, have)
        elseif have < 1 then
            return 0  -- Need at least 1 press
        end
    end

    -- Check middle slot
    if recipe.middle and recipe.middle.item then
        local have = contents[recipe.middle.item] or 0
        if recipe.middle.consume then
            count = math.min(count, have)
        elseif have < 1 then
            return 0
        end
    end

    -- Check bottom slot
    if recipe.bottom and recipe.bottom.item then
        local have = contents[recipe.bottom.item] or 0
        if recipe.bottom.consume then
            count = math.min(count, have)
        elseif have < 1 then
            return 0
        end
    end

    if count == 999999 then count = 0 end
    return count
end

-- Plan crafting jobs based on what's actually in chest
function recipes.planCrafts(chestContents)
    local jobs = {}
    local contents = {}

    -- Copy contents for tracking
    for k, v in pairs(chestContents) do
        contents[k] = v
    end

    -- Helper to consume from tracking
    local function consume(item, count)
        contents[item] = (contents[item] or 0) - count
        if contents[item] < 0 then contents[item] = 0 end
    end

    -- Plan jobs in priority order
    for _, recipeName in ipairs(recipes.PRIORITY) do
        local recipe = recipes.ALL[recipeName]
        local canMake = countCraftable(recipe, contents)

        for _ = 1, canMake do
            table.insert(jobs, {
                recipe = recipe,
                type = recipeName,
            })

            -- Consume materials from tracking
            if recipe.top and recipe.top.consume then
                consume(recipe.top.item, 1)
            end
            if recipe.middle and recipe.middle.consume then
                consume(recipe.middle.item, 1)
            end
            if recipe.bottom and recipe.bottom.consume then
                consume(recipe.bottom.item, 1)
            end
        end
    end

    if #jobs > 0 then
        log.info("recipes", "Planned " .. #jobs .. " jobs")
    end

    return jobs
end

return recipes
