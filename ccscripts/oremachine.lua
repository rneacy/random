rednet.open("back")

BARREL_SLOT = 2

PRINT_DEBUG = false

local induction_smelter_requirement = {
    item_thermalfoundation_material_crystalCinnabar = {
        slot = 1,
        require_empty = true,
    },
    item_thermalfoundation_material_crystalSlagRich = {
        slot = 1,
        require_empty = true,
        if_no = "item_thermalfoundation_material_crystalCinnabar",
    }
}


-- Barrels
local barrels = {
    item_redstone = peripheral.wrap("yabba:item_barrel_0"),
    tile_ore_cinnabar = peripheral.wrap("yabba:item_barrel_1"),
    item_thermalfoundation_material_crystalCinnabar = peripheral.wrap("yabba:item_barrel_2"),
    item_blazePowder = peripheral.wrap("yabba:item_barrel_3"),
    item_thermalfoundation_material_dustSulfur = peripheral.wrap("yabba:item_barrel_4"),
    item_snowball = peripheral.wrap("yabba:item_barrel_5"),
    item_thermalfoundation_material_crystalSlagRich = peripheral.wrap("yabba:item_barrel_6")
}


-- What each thing we have to moderate needs
local inventories = {
    {
        name = "pyro crafter",
        block = peripheral.wrap("rftools:crafter1_0"),
        requirements = {
            item_redstone = {},
            item_blazePowder = {},
            item_thermalfoundation_material_dustSulfur = {},
        },
    },
    {
        name = "cryo crafter",
        block = peripheral.wrap("rftools:crafter1_1"),
        requirements = {
            item_redstone = {},
            item_snowball = {
                push_times = 4,
            },
        }
    },
    {
        name = "induction smelter",
        block = peripheral.wrap("thermalexpansion:machine_smelter_0"),
        requirements = induction_smelter_requirement,
    },
    {
        name = "induction smelter 2",
        block = peripheral.wrap("thermalexpansion:machine_smelter_1"),
        requirements = induction_smelter_requirement,
    },
    {
        name = "fluid transposer",
        block = peripheral.wrap("thermalexpansion:machine_transposer_0"),
        requirements = {
            item_snowball = {
                slot = 1,
                push_times = 4,
                require_empty = true,
            }
        },
    },
    {
        name = "fluid transposer (cinnabar ore)",
        block = peripheral.wrap("thermalexpansion:machine_transposer_1"),
        requirements = {
            tile_ore_cinnabar = {
                slot = 1,
                require_empty = true,
            }
        },
    }
}

-- Replace . with _ for stinky lua tables
local function nameconv(name)
    return name:gsub("%.", "_")
end

while true do
    for _, inv in pairs(inventories) do
        local inv_siz = inv.block.size()
        local slots_taken = inv.block.list()
        local inv_contents = {}

        -- Determine what is in inventory now
        for i, slot in pairs(slots_taken) do
            local stored_item = inv.block.getItemMeta(i)
            if stored_item then
                local si_name = nameconv(stored_item.rawName)
                local si_count = stored_item.count
                inv_contents[si_name] = (inv_contents[si_name] or 0) + si_count
            end
        end

        -- Two stacks of a particular item allowed at one time
        for requirement, options in pairs(inv.requirements) do
            local og_requirement = requirement
            
            local multiplier = 1

            local cancel = false

            -- aka only proceed if we dont have any of this option
            if options.if_no then
                if inv_contents[options.if_no] then cancel = true end
                if PRINT_DEBUG and cancel then print("Skipping "..requirement.." as "..options.if_no.." available.") end
            end

            if not cancel then
                -- If a requirement is actually made by something else
                if options.delegate then
                    requirement = options.delegate.name
                    multiplier = options.delegate.amount_made / 2
                end

                local push_limit = 64 * multiplier

                local do_push = options.require_empty and not inv_contents[requirement]

                if not do_push then
                    do_push = not inv_contents[requirement] or inv_contents[requirement] < push_limit
                end

                if do_push then
                    local barrel = barrels[og_requirement]

                    if barrel then
                        if not barrel.list()[BARREL_SLOT] then
                            if PRINT_DEBUG then print(og_requirement.." barrel is empty!") end
                        else
                            local block_name = peripheral.getName(inv.block)

                            print("Pushing "..og_requirement.." to "..block_name)

                            local times = 1
                            if options.push_times then times = options.push_times end

                            for i = 1, times do
                                barrel.pushItems(
                                    block_name,
                                    BARREL_SLOT,
                                    nil,
                                    options.slot
                                )
                            end
                        end
                    else
                        if PRINT_DEBUG then print("No barrel connected for "..og_requirement.."!") end
                    end
                end
            end
        end
    end
    os.sleep(1)
end