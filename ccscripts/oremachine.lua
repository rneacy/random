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
    redstone = peripheral.wrap("yabba:item_barrel_0"),
    cinnabar_ore = peripheral.wrap("yabba:item_barrel_1"),
    cinnabar = peripheral.wrap("yabba:item_barrel_2"),
}


-- What each thing we have to moderate needs
local inventories = {
    {
        name = "pyro crafter",
        block = peripheral.wrap("rftools:crafter1_0"),
        requirements = {
            "redstone",
            "blaze_rod",
            "sulfur",
        }
    },
    {
        name = "cryo crafter",
        block = peripheral.wrap("rftools:crafter1_1"),
        requirements = {
            "redstone",
            "snowball",
        }
    },
}


while true do
    for _, inv in pairs(inventories) do
        local inv_siz = inv.size()
        local slots_taken = inv.list()
        local inv_contents = {}

        -- Determine what is in inventory now
        for i, slot in pairs(slots_taken) do
            local stored_item = inv.getItemMeta(i)
            local si_name = stored_item.rawName
            local si_count = stored_item.count
            inv_contents[si_name] = (inv_contents[si_name] or 0) + si_count
        end

        -- Two stacks of a particular item allowed at one time
        for _, requirement in inv.requirements do
            if inv_contents[itemdefs[requirement]] < 64 then
                local barrel = barrels[requirement]

                if barrel then
                    if not barrel.list() then
                        print(requirement.." barrel is empty!")
                        goto continue
                    end

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
                else
                    print("No barrel connected for "..requirement.."!")
                end
            end

            ::continue::
        end
    end
end