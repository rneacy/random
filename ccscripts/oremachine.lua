rednet.open("back")

BARREL_SLOT = 2


-- Barrels
local barrels = {
    item_redstone = peripheral.wrap("yabba:item_barrel_0"),
    tile_ore_cinnabar = peripheral.wrap("yabba:item_barrel_1"),
    item_thermalfoundation_material_crystalCinnabar = peripheral.wrap("yabba:item_barrel_2"),
    item_blazeRod = peripheral.wrap("yabba:item_barrel_3"),
    item_thermalfoundation_material_dustSulfur = peripheral.wrap("yabba:item_barrel_4"),
    item_snowball = peripheral.wrap("yabba:item_barrel_5"),
}


-- What each thing we have to moderate needs
local inventories = {
    {
        name = "pyro crafter",
        block = peripheral.wrap("rftools:crafter1_0"),
        requirements = {
            item_redstone = {},
            item_blazeRod = {
                delegate = {
                    name = "item_blazePowder",
                    amount_made = 4,
                },
            },
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
        requirements = {
            item_thermalfoundation_material_crystalCinnabar = {
                slot = 1,
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
            local si_name = nameconv(stored_item.rawName)
            local si_count = stored_item.count
            inv_contents[si_name] = (inv_contents[si_name] or 0) + si_count
        end

        -- Two stacks of a particular item allowed at one time
        for requirement, options in pairs(inv.requirements) do
            local og_requirement = requirement
            
            local multiplier = 1

             -- If a requirement is actually made by something else
            if options.delegate then
                requirement = options.delegate.name
                multiplier = options.delegate.amount_made / 2
            end

            local push_limit = 64 * multiplier

            if not inv_contents[requirement] or inv_contents[requirement] < push_limit then
                local barrel = barrels[requirement]

                if barrel then
                    if not barrel.list() then
                        print(og_requirement.." barrel is empty!")
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
                    print("No barrel connected for "..og_requirement.."!")
                end
            end
        end
    end
    os.sleep(1)
end