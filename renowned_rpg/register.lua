
--local function caches
local math_random = math.random
local math_floor = math.floor
local math_abs = math.abs
local math_min = math.min
local math_max = math.max
local minetest_registered_craftitems = minetest.registered_craftitems
local minetest_registered_entities = minetest.registered_entities
local minetest_is_player = minetest.is_player
local minetest_get_player_by_name = minetest.get_player_by_name
local minetest_get_connected_players = minetest.get_connected_players
local minetest_get_timeofday = minetest.get_timeofday

-- renoened_rpg.players = {
--     prev_hps = {},
--     dead = {},
--     damaged = {},
--     suffocate = {},
--     exaustion = {},
--     hydration = {},
-- }

renowned_rpg.prev_hps = {}
renowned_rpg.player_dead = {}
renowned_rpg.player_damaged = {}
renowned_rpg.player_suffocate = {}
renowned_rpg.player_exaustion = {}
renowned_rpg.player_hydration = {}


minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()
    local stats = renowned_rpg:get_total_stats(player)
    
    renowned_rpg:set_hp(player, stats.hlth)
    renowned_rpg:set_breath(player, stats.breath)
    renowned_rpg:set_hunger(player, stats.hunger)
    renowned_rpg:set_sprint(player, stats.sprint)
    renowned_rpg:set_thirst(player, stats.thirst)
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local stats = renowned_rpg:get_total_stats(player)

    renowned_rpg.player_dead[name] = false
    renowned_rpg.player_damaged[name] = false
    renowned_rpg.player_exaustion[name] = 0
    renowned_rpg.player_hydration[name] = 0

    -- make sure the global tick hides/shows breath bar properly on join
    renowned_rpg.player_suffocate[name] = true

    --renowned_rpg:update_total_stats(player)

--debug
--renowned_rpg:set_hunger(player, 5)
renowned_rpg:set_thirst(player, stats.thirst/2)

    renowned_rpg:init_player_hud(player)
end)

minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    local stats = renowned_rpg:get_total_stats(player)
    renowned_rpg:set_hp(player, stats.hlth)
    player:set_hp(20)
    renowned_rpg:set_breath(player, stats.breath)
    renowned_rpg:set_hunger(player, stats.hunger)
    renowned_rpg:set_sprint(player, stats.sprint)
    renowned_rpg:set_thirst(player, stats.thirst)

    renowned_rpg.player_dead[name] = false
    renowned_rpg.player_damaged[name] = false
    renowned_rpg.player_suffocate[name] = false
    renowned_rpg.player_exaustion[name] = 0
    renowned_rpg.player_hydration[name] = 0

    renowned_rpg:update_all_huds(player)
end)

cmi.register_on_activatemob(function(entity, dtime)
  local mob_entity = entity:get_luaentity()
  if mob_entity.type == "monster" then
  
    local desc = minetest_registered_craftitems[mob_entity.name].description
    local level = math_random(1, 10)
    if mob_entity.mob_xp_level ~= nil then
      entity:set_properties({
        nametag = desc .. " [Level " .. mob_entity.mob_xp_level .. "]",
        nametag_color = "#00FF00",
      })
      return
    end
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
    mob_entity.health = mob_entity.hp_max
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

function cmi.damage_calculator(mob, puncher, tflp, caps, direction, attacker)
	local a_groups = mob:get_armor_groups() or {}
	local full_punch_interval = caps.full_punch_interval or 1.4
	local time_prorate = bound(tflp / full_punch_interval, 0, 1)
	local damage = 0
    local total_armor_rating = 0
  
	for group, damage_rating in pairs(caps.damage_groups or {}) do
		local armor_rating = a_groups[group] or 0
        damage = damage + damage_rating * (armor_rating / 100)
        total_armor_rating = total_armor_rating + armor_rating
	end
  
    if puncher:is_player() then
        local player_stats = renowned_rpg:get_total_stats(puncher)
        damage = damage + player_stats.attk * (total_armor_rating / 100)
    end
    --print('here ' .. math.floor(damage * time_prorate))
    --print(dump(puncher:get_player_control()))
    --print("mob: " .. mob:get_luaentity().name)
    --print(dump(puncher))
    --print("--------------------------------------------")
    --print("ret = " .. math.floor(damage * time_prorate))
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
                
                renowned_rpg:add_xp(cause.puncher, xp_reward)
                renowned_rpg:update_xp_hud(cause.puncher)
                
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
  local stats = renowned_rpg:get_total_stats(player)
  
  renowned_rpg:set_hp(player, stats.hlth)
  renowned_rpg:update_health_hud(player)
end
local function heal_players()
	for name, _ in pairs(beds.player) do
		local player = minetest_get_player_by_name(name)
        local stats = renowned_rpg:get_total_stats(player)
    
        renowned_rpg:set_hp(player, stats.hlth)
        renowned_rpg:update_health_hud(player)
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
local fast_timer = 0
local hunger_timer = 0
local hunger_base_rate = renowned_rpg.settings.hunger.base_rate
local hunger_move_step = renowned_rpg.settings.hunger.move_step
local hunger_dig_step = renowned_rpg.settings.hunger.dig_step
local hunger_place_step = renowned_rpg.settings.hunger.place_step
local thirst_base_rate = renowned_rpg.settings.thirst.base_rate
local thirst_move_step = renowned_rpg.settings.thirst.move_step
local thirst_dig_step = renowned_rpg.settings.thirst.dig_step
local thirst_place_step = renowned_rpg.settings.thirst.place_step

minetest.register_globalstep(function(dtime)

    timer = timer + dtime
    fast_timer = fast_timer + dtime
    hunger_timer = hunger_timer + dtime

    -- handle player damaged
    for name, damaged in pairs(renowned_rpg.player_damaged) do
        if damaged then
            local player = minetest_get_player_by_name(name)
            player:set_hp(20)
            renowned_rpg.player_damaged[name] = false
        end
    end

    --local players = nil --minetest_get_connected_players()

    --if fast_timer > 1 then
    --    players = minetest_get_connected_players()

    --    for n, player in ipairs(players) do

    --    end
    --end

    --handle breath
    if timer > 2 then
        
        --if players == nil then
        local players = minetest_get_connected_players()
        --end

        for n, player in ipairs(players) do
            local breath = player:get_breath()
            local player_name = player:get_player_name()
            local suffocating = false
            local hunger = renowned_rpg:get_hunger(player)
            local thirst = renowned_rpg:get_thirst(player)

            if breath < 11 then
                player:set_breath(10)
                suffocating = true
                renowned_rpg.player_suffocate[player_name] = true

                local real_breath = renowned_rpg:get_breath(player)-1

                if real_breath == -1 then
                    player:set_hp(player:get_hp()-10)
                end
                renowned_rpg:set_breath(player, math_max(real_breath, 0))
                renowned_rpg:update_breath_hud(player)
            end
            
            if suffocating == false and renowned_rpg.player_suffocate[player_name] then
                local stats = renowned_rpg:get_total_stats(player)
                local real_breath = renowned_rpg:get_breath(player)+3
                renowned_rpg:set_breath(player, math_min(real_breath, stats.breath))

                if real_breath >= stats.breath then
                    renowned_rpg.player_suffocate[player_name] = false
                end
                renowned_rpg:update_breath_hud(player)
            end

            local hunger_change = 0
            local exaustion = renowned_rpg.player_exaustion[player_name] + math_floor(dtime*100)
            local hydration = renowned_rpg.player_hydration[player_name] + math_floor(dtime*100)
            local keys = player:get_player_control()

            

            if keys.up or keys.down or keys.left or keys.right then
                --jump, right, left, LMB, RMB, sneak, aux1, down, up
                exaustion = exaustion + hunger_move_step
                hydration = hydration + thirst_move_step
                print("buttons pressed by " .. player_name .. ": " .. tostring(exaustion))
            end

            --if keys.LMB then
            --    exaustion = exaustion + hunger_dig_step
            --end

            if exaustion > hunger_base_rate then
                hunger = math_max(hunger-1, 0)
                renowned_rpg:set_hunger(player, hunger)
                renowned_rpg:update_hunger_hud(player)
                exaustion = 0
                print(player_name .. "is exausted: 1")
            end
            renowned_rpg.player_exaustion[player_name] = exaustion

            if hydration > thirst_base_rate then
                thirst = math_max(thirst-1, 0)
                renowned_rpg:set_thirst(player, thirst)
                renowned_rpg:update_thirst_hud(player)
                hydration = 0
                print(player_name .. "is thirstified: 1")
            end
            renowned_rpg.player_hydration[player_name] = hydration

            if hunger <= 0 then 
                player:set_hp(player:get_hp()-5)
            end
            if thirst <= 0 then 
                player:set_hp(player:get_hp()-5)
            end
        end -- for n, player in ipairs(players)

        timer = 0
    end -- timer > 2
end)

minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack, pointed_thing)
    if not player or not player:is_player() or player.is_fake_player == true then
		return
    end
    local player_name = player:get_player_name()

    local exaustion = renowned_rpg.player_exaustion[player_name]
    exaustion = exaustion + hunger_place_step
    renowned_rpg.player_exaustion[player_name] = exaustion

    local hydration = renowned_rpg.player_hydration[player_name]
    hydration = hydration + thirst_place_step
    renowned_rpg.player_hydration[player_name] = hydration

    renowned_rpg:inc_nodes_placed(player)
end)
minetest.register_on_dignode(function(pos, oldnode, player)
    local player_name = player:get_player_name()
    
    local exaustion = renowned_rpg.player_exaustion[player_name]
    exaustion = exaustion + hunger_dig_step
    renowned_rpg.player_exaustion[player_name] = exaustion

    local hydration = renowned_rpg.player_hydration[player_name]
    hydration = hydration + thirst_dig_step
    renowned_rpg.player_hydration[player_name] = hydration

    renowned_rpg:inc_nodes_dug(player)
end)

minetest.register_on_player_hpchange(function(player, hp_change)

    local name = player:get_player_name()

    if renowned_rpg.player_dead[name] or renowned_rpg.player_damaged[name] then
        return hp_change
    end  

    local hp = renowned_rpg:get_hp(player)
    hp = hp + hp_change
    if hp <= 0 then
        renowned_rpg:set_hp(player, 0)
        renowned_rpg.player_dead[name] = true
        return -20
    else
        if hp_change < 0 then
            renowned_rpg:set_hp(player, hp)
            renowned_rpg:update_health_hud(player)
            renowned_rpg.player_damaged[name] = true
            return -1
        else
            local stats = renowned_rpg:get_total_stats(player)
            renowned_rpg:set_hp(player, math_min(hp, stats.hlth))
            renowned_rpg:update_health_hud(player)
        end
    end
    return 0
end, true)

--minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
  --if minetest_is_player(hitter) == false then
    --local mob_entity = hitter:get_luaentity()
    --local stats = renowned_rpg:get_total_stats(player)
    
    --local name = player:get_player_name()
  
    --if renowned_rpg:get_hp(player)-damage <= 0 then
    --  renowned_rpg.player_dead[name] = true
    --  print('should be dead')
    --  player:set_hp(0)
    --end
    
    --if damage > 0 then
      
    --end
    --print("-------------------------------------------------")
    --print(player:get_player_name() .. " hitter: " .. mob_entity.name .. " damage=" .. damage)
    --print(dump(stats))
    --print(damage * (20 / stats.hlth))
    --damage = damage * (20 / stats.hlth)
    --armor:punch(player, hitter, time_from_last_punch, tool_capabilities)
    --return damage
  --end
--end)

local function eat_food(def, itemstack, player, pointed_thing)
    if player ~= nil and itemstack:take_item() ~= nil then
        local player_name = player:get_player_name()
        local stats = renowned_rpg:get_total_stats(player)
        local hunger = renowned_rpg:get_hunger(player)
        local hp = renowned_rpg:get_hp(player)

        --todo: play eat sound

        if def.satiation ~= nil and hunger < stats.hunger then 
            hunger = math_min(hunger+def.satiation, stats.hunger)
            renowned_rpg:set_hunger(player, hunger)
            renowned_rpg:update_hunger_hud(player)
        end
        if def.heal ~= nil and hp < stats.hlth then 
            hp = math_min(hp+def.heal, stats.hlth)
            renowned_rpg:set_hp(player, hp)
            renowned_rpg:update_health_hud(player)
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
    local def = renowned_rpg:get_registered_food(item)
    
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




