rednet.open("back")

BARREL_SLOT = 2

-- Mapping from nice name to internal name
local itemdefs = {
    redstone = "item.redstone",
    cinnabar_ore = "tile.ore_cinnabar",
    cinnabar = "item.thermalfoundation.material.crystalCinnabar",
    blaze_road = "item.blazeRod",
    snowball = "item.snowball",
    sulfur = "item.thermalfoundation.material.dustSulfur",
}


-- Barrels
local barrels = {
    item_redstone = peripheral.wrap("yabba:item_barrel_0"),
    tile_ore_cinnabar = peripheral.wrap("yabba:item_barrel_1"),
    item_thermalfoundation_material_crystalCinnabar = peripheral.wrap("yabba:item_barrel_2"),
}


-- What each thing we have to moderate needs
local inventories = {
    {
        name = "pyro crafter",
        block = peripheral.wrap("rftools:crafter1_0"),
        requirements = {
            "item.redstone",
            "item.blazeRod",
            "item.thermalfoundation.material.dustSulfur",
        }
    },
    {
        name = "cryo crafter",
        block = peripheral.wrap("rftools:crafter1_1"),
        requirements = {
            "item.redstone",
            "item.snowball",
        }
    },
}


while true do
    for _, inv in pairs(inventories) do
        local inv_siz = inv.block.size()
        local slots_taken = inv.block.list()
        local inv_contents = {}

        -- Determine what is in inventory now
        for i, slot in pairs(slots_taken) do
            local stored_item = inv.block.getItemMeta(i)
            local si_name = stored_item.rawName
            local si_count = stored_item.count
            inv_contents[si_name] = (inv_contents[si_name] or 0) + si_count
        end

        -- Two stacks of a particular item allowed at one time
        for _, requirement in pairs(inv.requirements) do
            if inv_contents[requirement] < 64 then
                local barrelName = requirement:gsub("%.", "_") -- so stinky
                local barrel = barrels[barrelName]

                if barrel then
                    if not barrel.list() then
                        print(requirement.." barrel is empty!")
                    else
                        local block_name = peripheral.getName(inv.block)

                        print("Pushing "..requirement.." to "..block_name)

                        local times
                        if requirement == "snowball" then times = 4 else times = 1 end

                        for i = 1, times do
                            barrel.pushItems(
                                block_name,
                                BARREL_SLOT
                            )
                        end
                    end
                else
                    print("No barrel connected for "..requirement.."!")
                end
            end
        end
    end
end