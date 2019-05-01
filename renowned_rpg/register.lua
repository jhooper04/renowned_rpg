
--local function caches
local math_random = math.random
local math_floor = math.floor
local math_abs = math.abs
local math_min = math.min
local math_max = math.max
local minetest_get_node = minetest.get_node
local minetest_registered_craftitems = minetest.registered_craftitems
local minetest_registered_entities = minetest.registered_entities
local minetest_is_player = minetest.is_player
local minetest_get_player_by_name = minetest.get_player_by_name
local minetest_get_connected_players = minetest.get_connected_players
local minetest_get_timeofday = minetest.get_timeofday

renowned_rpg.players = {}

minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()
    local stats = renowned_rpg.get_total_stats(player)
    
    renowned_rpg.set_hp(player, stats.hlth)
    renowned_rpg.set_breath(player, stats.breath)
    renowned_rpg.set_hunger(player, stats.hunger)
    renowned_rpg.set_sprint(player, stats.sprint)
    renowned_rpg.set_thirst(player, stats.thirst)
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local stats = renowned_rpg.get_total_stats(player)

    renowned_rpg.players[name] = {
        damaged = false,
        suffocate = true,
        sprinting = false,
        exaustion = 0,
        hydration = 0,
    }

    --debug
    --renowned_rpg.set_hunger(player, 5)
    --renowned_rpg.set_thirst(player, stats.thirst/2)
    --renowned_rpg.update_total_stats(player)

    renowned_rpg.init_player_hud(player)
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    renowned_rpg.players[name] = nil
end)

minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    local stats = renowned_rpg.get_total_stats(player)

    renowned_rpg.set_hp(player, stats.hlth)
    player:set_hp(20)
    renowned_rpg.set_breath(player, stats.breath)
    renowned_rpg.set_hunger(player, stats.hunger)
    renowned_rpg.set_sprint(player, stats.sprint)
    renowned_rpg.set_thirst(player, stats.thirst)

    renowned_rpg.players[name].damaged = false
    renowned_rpg.players[name].suffocate = true
    renowned_rpg.players[name].sprinting = false
    renowned_rpg.players[name].exaustion = 0
    renowned_rpg.players[name].hydration = 0

    renowned_rpg.update_all_huds(player)
end)

local function get_closest_player(pos)
    local players = minetest_get_connected_players()
    local min_dist = 99999
    local ret_player = nil
    for n, player in ipairs(players) do
        local player_pos = player:get_pos()
        local dist = vector.distance(pos, player_pos)
        if dist < min_dist then
            min_dist = dist
            ret_player = player
        end
    end
    return ret_player
end

cmi.register_on_activatemob(function(entity, dtime)
  local mob_entity = entity:get_luaentity()
  if mob_entity.type == "monster" or mob_entity.type == "npc" then

    local desc = minetest_registered_craftitems[mob_entity.name].description

    if mob_entity.mob_xp_level ~= nil then
      entity:set_properties({
        nametag = desc .. " [Level " .. mob_entity.mob_xp_level .. "]",
        nametag_color = "#00FF00",
      })
      return
    end

    --find the nearest player so mob level depends on player's level
    local pos = entity:get_pos()
    local near_player = get_closest_player(pos)
    local near_level = 1
    if near_player ~= nil then
        near_level = renowned_rpg.get_level(near_player)
    end

    local level = math_random(math_max(near_level-10, 1), near_level+10)
    local attk_bal = math_random(3, 7)*0.1
    local def_bal = math_random(3, 7)*0.1
    local max_hp = minetest_registered_entities[mob_entity.name].hp_max
    local damage = minetest_registered_entities[mob_entity.name].damage
    local nametag = desc .. " [Level " .. level .. "]"
    entity:set_properties({
      nametag = nametag,
      nametag_color = "#00FF00",
    })
    mob_entity.nametag = nametag
    mob_entity.mob_xp_level = level
    mob_entity.hp_max = math_floor(level * (max_hp * 0.45))
    mob_entity.damage = math_floor(level * (damage * 0.5))
    mob_entity.renowned_attk = math_floor(level * (damage * attk_bal))
    mob_entity.renowned_def = math_floor(level * (damage * def_bal))
    mob_entity.health = mob_entity.hp_max
    --print("attk_bal: "..tostring(attk_bal))
    --print("def_bal: "..tostring(def_bal))
    --print(dump(mob_entity))
  end
end)

local function bound(x, minb, maxb)
	if x < minb then
		return minb
	elseif x > maxb then
		return maxb
	else
		return x
	end
end

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
  if minetest_is_player(hitter) == false then
    local mob_entity = hitter:get_luaentity()
    local stats = renowned_rpg.get_total_stats(player)

    local offender_attk = mob_entity.renowned_attk
    --local offender_def = mob_entity.renowned_def

    --local defender_attk = stats.attk
    local defender_def = stats.def

    local damage = renowned_rpg.calc_damage(offender_attk, defender_def) -- offender_attk * offender_attk / (offender_attk + defender_def) 

    print("--------player hit---------")
    print("offender attk: "..tostring(offender_attk))
    print("defender def: "..tostring(defender_def))
    print("damage: "..tostring(damage))
    --print(dump(mob_entity))

    player:set_hp(player:get_hp()-damage)
    return true
  end
end)

function cmi.damage_calculator(mob, puncher, tflp, caps, direction, attacker)
	local a_groups = mob:get_armor_groups() or {}
	local full_punch_interval = caps.full_punch_interval or 1.4
	local time_prorate = bound(tflp / full_punch_interval, 0, 1)
	local damage = 0
    local mob_entity = mob:get_luaentity()

    local offender_attk = 0
    local defender_def = 0

    if mob_entity.renowned_def ~= nil then
        defender_def = mob_entity.renowned_def
    end

    print("------------cmi.damage_calculator---------------")
    print("               tflp: "..tostring(tflp))
    print("full_punch_interval: "..tostring(full_punch_interval))
    print("       time_prorate: "..tostring(time_prorate))

    if puncher:is_player() then
        local player_stats = renowned_rpg.get_total_stats(puncher)
        local weapon = puncher:get_wielded_item()
        local weapon_stats = renowned_rpg.get_tool_stats(weapon)

        offender_attk = player_stats.attk + weapon_stats.attk

        renowned_rpg.after_tool_use(weapon, puncher, nil)
    end

    damage = renowned_rpg.calc_damage(offender_attk, defender_def)
    print("             damage: "..tostring(damage))
    print("    damage prorated: "..tostring(math_floor(damage * time_prorate)))
	return math.floor(damage * time_prorate)
end

cmi.register_on_diemob(function(entity, cause)
    -- {type="punch", puncher=<userdata>}
    if cause.type == "punch" then
        if minetest_is_player(cause.puncher) then
            local mob_entity = entity:get_luaentity()
            if mob_entity.type == "monster" then
                --mob_entity.name
                local xp_reward = mob_entity.hp_max
                
                renowned_rpg.add_xp(cause.puncher, xp_reward)
                renowned_rpg.update_xp_hud(cause.puncher)
                
                print(cause.puncher:get_player_name() .. ' killed ' .. mob_entity.name .. " lvl=" .. mob_entity.mob_xp_level .. ' got ' .. 
                    xp_reward .. ' XP')
                --print(dump(minetest.registered_entities[mob_entity.name]))
                --print(dump(mob_entity))
                --print(dump(entity))
            end
        end
    end
end)

local function heal_player(player)
    local stats = renowned_rpg.get_total_stats(player)
  
    renowned_rpg.set_hp(player, stats.hlth)
    renowned_rpg.update_health_hud(player)
end
local function heal_players()
	for name, _ in pairs(beds.player) do
		local player = minetest_get_player_by_name(name)
        local stats = renowned_rpg.get_total_stats(player)
    
        renowned_rpg.set_hp(player, stats.hlth)
        renowned_rpg.update_health_hud(player)
	end
end
local function is_night_skip_enabled()
	local enable_night_skip = minetest.settings:get_bool("enable_bed_night_skip")
	if enable_night_skip == nil then
		enable_night_skip = true
	end
	return enable_night_skip
end
local function check_in_beds(players)
	local in_bed = beds.player
	if not players then
		players = minetest_get_connected_players()
	end

	for n, player in ipairs(players) do
		local name = player:get_player_name()
		if not in_bed[name] then
			return false
		end
	end

	return #players > 0
end


local beds_on_rightclick_original = beds.on_rightclick


function beds_on_rightclick_override(pos, player)

    local name = player:get_player_name()
	local ppos = player:getpos()
	local tod = minetest_get_timeofday()

	if tod > 0.2 and tod < 0.805 then
		return
	end

	-- move to bed
	if not beds.player[name] then
        --Is Sleeping
        heal_player(player)
	end

	-- skip the night and let all players stand up
	if check_in_beds() then
		minetest.after(2, function()
			if is_night_skip_enabled() then
				heal_players()
			end
		end)
	end
  
    beds_on_rightclick_original(pos, player)
end
beds.on_rightclick = beds_on_rightclick_override


local timer = 0
local breath_timer = 0
local breath_update_rate = renowned_rpg.settings.breath.update_rate

local hunger_timer = 0
local hunger_update_rate = renowned_rpg.settings.hunger.update_rate
local hunger_base_rate = renowned_rpg.settings.hunger.base_rate
local hunger_move_step = renowned_rpg.settings.hunger.move_step
local hunger_dig_step = renowned_rpg.settings.hunger.dig_step
local hunger_place_step = renowned_rpg.settings.hunger.place_step

local thirst_timer = 0
local thirst_update_rate = renowned_rpg.settings.thirst.update_rate
local thirst_base_rate = renowned_rpg.settings.thirst.base_rate
local thirst_move_step = renowned_rpg.settings.thirst.move_step
local thirst_dig_step = renowned_rpg.settings.thirst.dig_step
local thirst_place_step = renowned_rpg.settings.thirst.place_step
local thirst_hydrate_nodes = renowned_rpg.settings.thirst.hydrate_nodes

local sprint_timer = 0
local sprint_update_rate = renowned_rpg.settings.sprint.update_rate
local sprint_speed = renowned_rpg.settings.sprint.speed_multiplier
local sprint_jump = renowned_rpg.settings.sprint.jump_multiplier

minetest.register_globalstep(function(dtime)

    timer = timer + dtime
    breath_timer = breath_timer + dtime
    hunger_timer = hunger_timer + dtime
    thirst_timer = thirst_timer + dtime
    sprint_timer = sprint_timer + dtime
    

    local players = minetest_get_connected_players()
    for n, player in ipairs(players) do

        local player_name = player:get_player_name()
        local keys = player:get_player_control()
        local is_moving = keys.up or keys.down or keys.left or keys.right



        -- refill player's hp after doing damage animations
        if renowned_rpg.players[player_name].damaged then
            player:set_hp(20, {damage_sim=true})
            renowned_rpg.players[player_name].damaged = false
        end

        if keys.aux1 then 

            if renowned_rpg.get_sprint(player) > 0 then
                if renowned_rpg.players[player_name].sprinting == false then
                    local stats = renowned_rpg.get_total_stats(player)
                    local speed = 1.1 + sprint_speed * stats.spd
                    local jump = 1 + sprint_jump * stats.spd
                    player:set_physics_override({speed=speed,jump=jump})
                    print("overriden: spd "..tostring(speed).." jmp "..tostring(jump))
                end
                renowned_rpg.players[player_name].sprinting = true
            else
                if renowned_rpg.players[player_name].sprinting == true then
                    player:set_physics_override({speed=1.0,jump=1.0})
                end
                renowned_rpg.players[player_name].sprinting = false
            end
        else
            if renowned_rpg.players[player_name].sprinting == true then
                player:set_physics_override({speed=1.0,jump=1.0})
            end
            renowned_rpg.players[player_name].sprinting = false
        end



        if sprint_timer > sprint_update_rate then
            if renowned_rpg.players[player_name].sprinting then
                local sprint = math_max(renowned_rpg.get_sprint(player)-sprint_timer, 0)
                renowned_rpg.set_sprint(player, sprint)
            else
                local stats = renowned_rpg.get_total_stats(player)
                local sprint = math_min(renowned_rpg.get_sprint(player)+sprint_timer, stats.sprint)
                renowned_rpg.set_sprint(player, sprint)
            end
            renowned_rpg.update_sprint_hud(player)
            sprint_timer = 0
        end

        if breath_timer > breath_update_rate then
            local breath = player:get_breath()
            local suffocating = false

            if breath < 11 then
                player:set_breath(10)
                suffocating = true
                renowned_rpg.players[player_name].suffocate = true

                local real_breath = renowned_rpg.get_breath(player)-1

                if real_breath == -1 then
                    player:set_hp(player:get_hp()-10)
                end
                renowned_rpg.set_breath(player, math_max(real_breath, 0))
                renowned_rpg.update_breath_hud(player)
            end
            
            if suffocating == false and renowned_rpg.players[player_name].suffocate then
                local stats = renowned_rpg.get_total_stats(player)
                local real_breath = renowned_rpg.get_breath(player)+3
                renowned_rpg.set_breath(player, math_min(real_breath, stats.breath))

                if real_breath >= stats.breath then
                    renowned_rpg.players[player_name].suffocate = false
                end
                renowned_rpg.update_breath_hud(player)
            end
            breath_timer = 0
        end

        if hunger_timer > hunger_update_rate then
            local hunger = renowned_rpg.get_hunger(player)
            local exaustion = renowned_rpg.players[player_name].exaustion + math_floor(dtime*100)

            if is_moving then
                exaustion = exaustion + hunger_move_step
            end

            if exaustion > hunger_base_rate then
                hunger = math_max(hunger-1, 0)
                renowned_rpg.set_hunger(player, hunger)
                renowned_rpg.update_hunger_hud(player)
                exaustion = 0
            end
            renowned_rpg.players[player_name].exaustion = exaustion

            if hunger <= 0 then
                player:set_hp(player:get_hp()-5)
            end

            hunger_timer = 0
        end

        if thirst_timer > thirst_update_rate then
            local thirst = renowned_rpg.get_thirst(player)
            local hydration = renowned_rpg.players[player_name].hydration + math_floor(dtime*100)
            local drinking = false

            if is_moving then
                hydration = hydration + thirst_move_step
            else
                local node = minetest_get_node(player:get_pos())
                for ni, hydrate_node in ipairs(thirst_hydrate_nodes) do
                    if node.name == hydrate_node then
                        drinking = true
                    end
                end
            end

            if drinking then
                local stats = renowned_rpg.get_total_stats(player)
                thirst = math_min(thirst+thirst_update_rate, stats.thirst)
                renowned_rpg.set_thirst(player, thirst)
                renowned_rpg.update_thirst_hud(player)
                hydration = 0
            end
            if hydration > thirst_base_rate then
                thirst = math_max(thirst-1, 0)
                renowned_rpg.set_thirst(player, thirst)
                renowned_rpg.update_thirst_hud(player)
                hydration = 0
            end
            renowned_rpg.players[player_name].hydration = hydration

            if thirst <= 0 then 
                player:set_hp(player:get_hp()-5)
            end

            thirst_timer = 0
        end
    end
end)

minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack, pointed_thing)
    if not player or not player:is_player() or player.is_fake_player == true then
		return
    end
    local player_name = player:get_player_name()

    local exaustion = renowned_rpg.players[player_name].exaustion
    exaustion = exaustion + hunger_place_step
    renowned_rpg.players[player_name].exaustion = exaustion

    local hydration = renowned_rpg.players[player_name].hydration
    hydration = hydration + thirst_place_step
    renowned_rpg.players[player_name].hydration = hydration

    renowned_rpg.inc_nodes_placed(player)

    local ppos = player:get_pos()
    local biome = minetest.get_biome_data(ppos)
    local xi = math_floor(ppos.x)%128
    local zi = math_floor(ppos.z)%128
    print(minetest.get_biome_name(biome.biome))
    print("x: "..tostring(xi).." z: "..tostring(zi))
    print("x: "..tostring(xi*128).." z: "..tostring(zi*128))
    print(dump(biome))
end)
minetest.register_on_dignode(function(pos, oldnode, player)
    local player_name = player:get_player_name()
    
    local exaustion = renowned_rpg.players[player_name].exaustion
    exaustion = exaustion + hunger_dig_step
    renowned_rpg.players[player_name].exaustion = exaustion

    local hydration = renowned_rpg.players[player_name].hydration
    hydration = hydration + thirst_dig_step
    renowned_rpg.players[player_name].hydration = hydration

    renowned_rpg.inc_nodes_dug(player)
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)

    local name = player:get_player_name()

    --if the call to player:set_hp is passed the damage_sim flag in the reason,
    --then the player's normal hp value is being set back to 20 so they don't die
    --after damage simulations and shouldn't effect player's actual health value
    if reason.damage_sim then
        return hp_change
    end

    local hp = renowned_rpg.get_hp(player)
    hp = hp + hp_change
    if hp <= 0 then
        --hp is less than or zero so kill the player
        renowned_rpg.set_hp(player, 0)
        return -20
    else
        if hp_change < 0 then
            --player is damaged, so hp change is -1 to show damage animation
            --while actual player health stat is reduced by damage amount
            renowned_rpg.set_hp(player, hp)
            renowned_rpg.update_health_hud(player)
            renowned_rpg.players[name].damaged = true
            print("----------hurt--------------------")
            print(name .. ", hp change: " .. tostring(hp_change).." reason: ")
            print(dump(reason))
            return -1
        elseif hp_change > 0 then
            --player has been healed, no need for damage animation
            local stats = renowned_rpg.get_total_stats(player)
            renowned_rpg.set_hp(player, math_min(hp, stats.hlth))
            renowned_rpg.update_health_hud(player)
            print("----------healed--------------------")
            print(name .. ", hp change: " .. tostring(hp_change).." reason: ")
            print(dump(reason))
            return 20
        else
            return 0
        end
    end
end, true)

local function eat_food(def, itemstack, player, pointed_thing)
    if player ~= nil and itemstack:take_item() ~= nil then
        local player_name = player:get_player_name()
        local stats = renowned_rpg.get_total_stats(player)
        local hunger = renowned_rpg.get_hunger(player)
        local hp = renowned_rpg.get_hp(player)

        --todo: play eat sound

        if def.satiation ~= nil and hunger < stats.hunger then 
            hunger = math_min(hunger+def.satiation, stats.hunger)
            renowned_rpg.set_hunger(player, hunger)
            renowned_rpg.update_hunger_hud(player)
            renowned_rpg.players[player_name].exaustion = 0
        end
        if def.heal ~= nil and hp < stats.hlth then 
            hp = math_min(hp+def.heal, stats.hlth)
            renowned_rpg.set_hp(player, hp)
            renowned_rpg.update_health_hud(player)
        elseif def.poison ~= nil then 
            --use regular player:set_hp to get the damage animation and sound
            player:set_hp(player:get_hp()-def.poison)
        end
        if itemstack:get_count() == 0 then
            itemstack:add_item(def.replace)
        else
            local inv = player:get_inventory()
            if inv:room_for_item("main", def.replace) then
                inv:add_item("main", def.replace)
            else
                minetest.add_item(player:getpos(), def.replace)
            end
        end
    end
    return itemstack
end

local function item_eat(hp_change, replace_with_item, itemstack, player, pointed_thing)
    local item = itemstack:get_name()
    local def = renowned_rpg.get_registered_food(item)
    
    if def == nil then
        if type(hp_change) ~= "number" then
            hp_change = 1
            core.log("error", "Invalid on_use() definition for item '" .. item .. "' using hp_change of 1")
        end
        def = {}
        def.satiation = math_abs(hp_change)
        if hp_change < 0 then
            def.poison = math_abs(hp_change)
        end
        def.replace = replace_with_item
    end
    return eat_food(def, itemstack, player, pointed_thing)
end


local do_item_eat_original = core.do_item_eat
core.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local original_itemstack = itemstack
	itemstack = item_eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	for _, callback in pairs(core.registered_on_item_eats) do
		local result = callback(hp_change, replace_with_item, itemstack, user, pointed_thing, original_itemstack)
		if result then
			return result
		end
	end
	return itemstack
end




