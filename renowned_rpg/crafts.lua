
minetest.register_craftitem("renowned_rpg:health_potion", {
	description = "Health Potion",
	inventory_image = "renowned_rpg_health_potion.png",
	on_use = function(itemstack, player, pointed_thing)
  
        local stats = renowned_rpg.get_total_stats(player)
    
        if renowned_rpg.get_hp(player) >= stats.hlth then
            return itemstack
        else
            renowned_rpg.set_hp(player, stats.hlth)
            renowned_rpg.update_health_hud(player)
            itemstack:take_item()
            return itemstack
        end
	end
})

minetest.register_craft({
	output = "renowned_rpg:health_potion",
	recipe = {
		{"", "flowers:rose", ""},
		{"", "default:gold_ingot", ""},
		{"", "vessels:glass_bottle", ""},
	}
})


table.insert(armor.elements, "healing_item")

armor:register_armor("renowned_rpg:makeshift_bandage", {
	description = "Makeshift Bandage",
	inventory_image = "renowned_rpg_inv_makeshift_bandage.png",
	groups = {armor_healing_item=1, armor_use=10},
})

minetest.register_craft({
	output = "renowned_rpg:makeshift_bandage",
	recipe = {
		{"default:marram_grass_1"},
		{"group:sapling"},
	}
})



minetest.register_tool("renowned_rpg:leather_vessel", {
	description = "Leather Vessel",
    inventory_image = "renowned_rpg_leather_vessel.png",
    capacity = 20,
    stack_max = 1,
    liquids_pointable = true,
	on_use = function(itemstack, player, pointed_thing)
  
        local stats = renowned_rpg.get_total_stats(player)
        local meta = itemstack:get_meta()
        local def = itemstack:get_definition()
        local contents = meta:get_int("contents")
        local thirst = renowned_rpg.get_thirst(player)

        if contents == nil then
            contents = 0
        end

        if contents > 0 and thirst < stats.thirst then
            local diff = stats.thirst - thirst
            if contents <= diff then
                thirst = thirst + contents
                contents = 0 
                meta:set_int("contents", contents)
                itemstack:set_wear(0)
            elseif contents > diff then
                thirst = thirst + diff
                contents = contents-diff
                meta:set_int("contents", contents)
                itemstack:set_wear(65535-math.floor(contents/def.capacity*65535))
            end
            renowned_rpg.set_thirst(player, thirst)
            renowned_rpg.update_thirst_hud(player)
            local player_name = player:get_player_name()
            renowned_rpg.players[player_name].hydration = 0
        end

        return itemstack
    end,
    on_place = function(itemstack, player, pointed_thing)
        local meta = itemstack:get_meta()
        local def = itemstack:get_definition()
        local under_pos = pointed_thing.under
        local node = minetest.get_node_or_nil(under_pos)

        if node.name == "default:water_source" then
            itemstack:set_wear(1)
            meta:set_int("contents", def.capacity)
        end

        return itemstack
    end,
})

minetest.register_craft({
	output = "renowned_rpg:leather_vessel",
	recipe = {
		{"mobs:leather", "",             "mobs:leather"},
		{""            , "mobs:leather", ""            },
	}
})
