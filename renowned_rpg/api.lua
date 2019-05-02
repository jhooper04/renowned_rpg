
-- **************************** Private Variables *********************************
-- ********************************************************************************

--local mod_storage = minetest.get_mod_storage()
local registered_food = {}

--local function caches
local minetest_serialize = minetest.serialize
local minetest_deserialize = minetest.deserialize
local minetest_get_player_by_name = minetest.get_player_by_name
local minetest_sound_play = minetest.sound_play
local minetest_get_color_escape_sequence = minetest.get_color_escape_sequence


local def_attk = renowned_rpg.settings.stat_defaults.attk
local def_def = renowned_rpg.settings.stat_defaults.def
local def_hlth = renowned_rpg.settings.stat_defaults.hlth
local def_stam = renowned_rpg.settings.stat_defaults.stam
local def_spd = renowned_rpg.settings.stat_defaults.spd
local def_sprint = renowned_rpg.settings.stamina_defaults.sprint
local def_thirst = renowned_rpg.settings.stamina_defaults.thirst
local def_breath = renowned_rpg.settings.stamina_defaults.breath
local def_hunger = renowned_rpg.settings.stamina_defaults.hunger


-- **************************** Private functions **********************************
-- *********************************************************************************



------------------------------ Data Storage/Retrieval ------------------------------
------------------------------------------------------------------------------------


------------------------- data helpers -----------------------------
local function data_get_string(player, prop, def)
    return player:get_attribute("renowned_rpg:" .. prop) or def
end 
local function data_set_string(player, prop, value)
    player:set_attribute("renowned_rpg:" .. prop, value)
end

local function data_get_number(player, prop, def)
    return tonumber(player:get_attribute("renowned_rpg:" .. prop) or def)
end 
local function data_set_number(player, prop, value)
    player:set_attribute("renowned_rpg:" .. prop, tostring(value))
end 

local function data_get_table(player, prop, def)
    return minetest_deserialize(player:get_attribute("renowned_rpg:" .. prop)) or def
end
local function data_set_table(player, prop, value)
    player:set_attribute("renowned_rpg:" .. prop, minetest_serialize(value))
end
--------------------------------------------------------------------------




local function data_get_hp(player)
    return data_get_number(player, "custom_hp", def_hlth)
end
local function data_set_hp(player, value)
    data_set_number(player, "custom_hp", value)
end

local function data_get_breath(player)
    return data_get_number(player, "custom_breath", def_breath)
end
local function data_set_breath(player, value)
    data_set_number(player, "custom_breath", value)
end

local function data_get_hunger(player)
    return data_get_number(player, "custom_hunger", def_hunger)
end
local function data_set_hunger(player, value)
    data_set_number(player, "custom_hunger", value)
end

local function data_get_sprint(player)
    return data_get_number(player, "custom_sprint", def_sprint)
end
local function data_set_sprint(player, value)
    data_set_number(player, "custom_sprint", value)
end

local function data_get_thirst(player)
    return data_get_number(player, "custom_thirst", def_thirst)
end
local function data_set_thirst(player, value)
    data_set_number(player, "custom_thirst", value)
end

local function data_get_total_xp(player)
    return data_get_number(player, "total_xp", 0)
end
local function data_set_total_xp(player, value)
    data_set_number(player, "total_xp", value)
end

local function data_get_level(player)
    return data_get_number(player, "level", 1)
end
local function data_set_level(player, value)
    data_set_number(player, "level", value)
end

local function data_get_upgrade_points(player)
    return data_get_number(player, "upgrade_points", 0)
end
local function data_set_upgrade_points(player, value)
    data_set_number(player, "upgrade_points", value)
end

local function data_get_pending_upgrades(player)
    return data_get_number(player, "pending_upgrades", 0)
end
local function data_set_pending_upgrades(player, value)
    data_set_number(player, "pending_upgrades", value)
end

local function data_get_applied_stats(player)
    return data_get_table(player, "applied_stats", {attk=0, def=0, hlth=0, stam=0, spd=0})
end
local function data_set_applied_stats(player, value)
    data_set_table(player, "applied_stats", value)
end

local function data_get_pending_stats(player)
    return data_get_table(player, "pending_stats", {attk=0, def=0, hlth=0, stam=0, spd=0})
end
local function data_set_pending_stats(player, value)
    data_set_table(player, "pending_stats", value)
end

local function data_get_total_stats(player)
    return data_get_table(player, "total_stats", {
        attk=def_attk, def=def_def, hlth=def_hlth, stam=def_stam, spd=def_spd,
        breath=def_breath, sprint=def_sprint, thirst=def_thirst, hunger=def_hunger
    })
end
local function data_set_total_stats(player, value)
    data_set_table(player, "total_stats", value)
end

local function data_get_class(player)
    return data_get_string(player, "class", "none")
end
local function data_set_class(player, value)
    data_set_string(player, "class", value)
end

local function data_get_stats_nodes_dug(player)
    return data_get_number(player, "stats_nodes_dug", 0)
end
local function data_set_stats_nodes_dug(player, value)
    data_set_number(player, "stats_nodes_dug", value)
end

local function data_get_stats_nodes_placed(player)
    return data_get_number(player, "stats_nodes_placed", 0)
end
local function data_set_stats_nodes_placed(player, value)
    data_set_number(player, "stats_nodes_placed", value)
end

local function data_get_stats_ores_mined(player)
    return data_get_number(player, "stats_ores_mined", 0)
end
local function data_set_stats_ores_mined(player, value)
    data_set_number(player, "stats_ores_mined", value)
end

local function data_get_stats_farm_harvests(player)
    return data_get_number(player, "stats_farm_harvests", 0)
end
local function data_set_stats_farm_harvests(player, value)
    data_set_number(player, "stats_farm_harvests", value)
end

local function data_get_stats_pvp_kills(player)
    return data_get_number(player, "stats_pvp_kills", 0)
end
local function data_set_stats_pvp_kills(player, value)
    data_set_number(player, "stats_pvp_kills", value)
end

local function data_get_stats_mob_kills(player)
    return data_get_number(player, "stats_mob_kills", 0)
end
local function data_set_stats_mob_kills(player, value)
    data_set_number(player, "stats_mob_kills", value)
end

local function data_get_stats_boss_kills(player)
    return data_get_number(player, "stats_boss_kills", 0)
end
local function data_set_stats_boss_kills(player, value)
    data_set_number(player, "stats_boss_kills", value)
end

local function data_get_stats_deaths(player)
    return data_get_number(player, "stats_deaths", 0)
end
local function data_set_stats_deaths(player, value)
    data_set_number(player, "stats_deaths", value)
end




---------------------------- Data Logic ----------------------------------
--------------------------------------------------------------------------


local function logic_xp_to_level(total_xp)
    local ret_level = 1
    
    for lvl, lvl_xp in pairs(renowned_rpg.settings.levels) do
        if total_xp >= lvl_xp then
            ret_level = lvl
        else
            break
        end
    end
    return ret_level
end

local function logic_add_upgrade_points(player, value)
    local points = data_get_upgrade_points(player)
    local pending = data_get_pending_upgrades(player)
    points = points + value
    pending = pending + value
    data_set_upgrade_points(player, points)
    data_set_pending_upgrades(player, pending)
end

local function logic_update_level(player)
    local total_xp = data_get_total_xp(player)
    local current_level = data_get_level(player)
    
    local new_level = logic_xp_to_level(total_xp)
    local level_diff = new_level - current_level
  
    if level_diff > 0 then
        --level increased
        
        local player_name = player:get_player_name()
        logic_add_upgrade_points(player, level_diff*3)
        data_set_level(player, new_level)
        
        minetest_sound_play({
            to_player = player_name,
            name = "renowned_rpg_snare",
            gain = 2,
        })
        --make sure stats page in unified inventory is updated
        --unified_inventory.get_formspec(player, "renowned_rpg_stats_form")
        if unified_inventory.current_page[player_name] == "renowned_rpg_stats_form" then
            unified_inventory.set_inventory_formspec(player, "renowned_rpg_stats_form")
        end
    elseif level_diff < 0 then
        --level decreased
        data_set_level(player, new_level)
    end
end

local function logic_update_total_stats(player)
    local applied = data_get_applied_stats(player)
    local multipliers = renowned_rpg.settings.stat_multipliers
    local defaults = renowned_rpg.settings.stat_defaults
    local stamina_defaults = renowned_rpg.settings.stamina_defaults
    
    local totals = { 
        attk=defaults.attk+( applied.attk*multipliers.attk ), 
        def=defaults.def+( applied.def*multipliers.def ), 
        hlth=defaults.hlth+( applied.hlth*multipliers.hlth ), 
        stam=defaults.stam+( applied.stam*multipliers.stam ), 
        spd=defaults.spd+( applied.spd*multipliers.spd ),
    }
    totals.sprint = stamina_defaults.sprint+totals.stam
    totals.thirst = stamina_defaults.thirst+totals.stam
    totals.breath = stamina_defaults.breath+totals.stam
    totals.hunger = stamina_defaults.hunger+totals.stam
    data_set_total_stats(player, totals)
    data_set_breath(player, totals.breath)
end





-- **************************** Public API functions **********************************
-- ************************************************************************************




-------------------------- player properties ---------------------------
------------------------------------------------------------------------

function renowned_rpg.get_hp(player)
    return data_get_hp(player)
end
function renowned_rpg.set_hp(player, value)
    data_set_hp(player, value)
end

function renowned_rpg.get_breath(player)
    return data_get_breath(player)
end
function renowned_rpg.set_breath(player, value)
    data_set_breath(player, value)
end

function renowned_rpg.get_hunger(player)
    return data_get_hunger(player)
end
function renowned_rpg.set_hunger(player, value)
    data_set_hunger(player, value)
end

function renowned_rpg.get_sprint(player)
    return data_get_sprint(player)
end
function renowned_rpg.set_sprint(player, value)
    data_set_sprint(player, value)
end

function renowned_rpg.get_thirst(player)
    return data_get_thirst(player)
end
function renowned_rpg.set_thirst(player, value)
    data_set_thirst(player, value)
end

function renowned_rpg.add_xp(player, amount)
    local total_xp = data_get_total_xp(player)
    total_xp = total_xp + amount
    data_set_total_xp(player, total_xp)
    logic_update_level(player)
    
    --print(dump(player:get_luaentity()))
end

function renowned_rpg.set_xp(player, amount)
    data_set_total_xp(player, amount)
    logic_update_level(player)
end

function renowned_rpg.get_xp(player)
    return data_get_total_xp(player)
end

function renowned_rpg.get_level(player)
    return data_get_level(player)
end

function renowned_rpg.get_upgrade_points(player)
    return data_get_upgrade_points(player)
end

function renowned_rpg.get_pending_upgrades(player)
    return data_get_pending_upgrades(player)
end

function renowned_rpg.get_applied_stats(player)
    return data_get_applied_stats(player)
end

function renowned_rpg.get_pending_stats(player)
    return data_get_pending_stats(player)
end

function renowned_rpg.get_total_stats(player)
    return data_get_total_stats(player)
end
function renowned_rpg.update_total_stats(player)
    logic_update_total_stats(player)
end

function renowned_rpg.plus_pending_stat(player, statname)
    local points = data_get_pending_upgrades(player)
    local stats = data_get_pending_stats(player)
    
    if points > 0 then
        stats[statname] = stats[statname] + 1
        data_set_pending_stats(player, stats)
        data_set_pending_upgrades(player, points-1)
    end
end
function renowned_rpg.minus_pending_stat(player, statname)
    local points = data_get_pending_upgrades(player)
    local stats = data_get_pending_stats(player)
    if stats[statname] > 0 then
        stats[statname] = stats[statname] - 1
        data_set_pending_stats(player, stats)
        data_set_pending_upgrades(player, points+1)
    end
end

function renowned_rpg.apply_stats(player)
    local applied = data_get_applied_stats(player)
    local pending = data_get_pending_stats(player)
    local upgrades = data_get_upgrade_points(player)
    local pending_upgrades = data_get_pending_upgrades(player)
    local point_diff = upgrades - pending_upgrades
    
    applied["attk"] = applied["attk"] + pending["attk"]
    applied["def"] = applied["def"] + pending["def"]
    applied["hlth"] = applied["hlth"] + pending["hlth"]
    applied["stam"] = applied["stam"] + pending["stam"]
    applied["spd"] = applied["spd"] + pending["spd"]
    
    pending = {attk=0, def=0, hlth=0, stam=0, spd=0}
    
    data_set_applied_stats(player, applied)
    data_set_pending_stats(player, pending)
    data_set_pending_upgrades(player, upgrades-point_diff)
    data_set_upgrade_points(player, upgrades-point_diff)
    logic_update_total_stats(player)
    renowned_rpg.update_all_huds(player)
end




---------------------------- player activity logging ------------------------------------
-----------------------------------------------------------------------------------------

function renowned_rpg.inc_nodes_dug(player, amount)
    if amount == nil then
        amount = 1
    end
    local nodes_dug = data_get_stats_nodes_dug(player)
    data_set_stats_nodes_dug(player, nodes_dug+amount)
end

function renowned_rpg.inc_nodes_placed(player, amount)
    if amount == nil then
        amount = 1
    end
    local nodes_placed = data_get_stats_nodes_placed(player)
    data_set_stats_nodes_placed(player, nodes_placed+amount)
end


--------------------------------- battle mechanics ----------------------------------------
-------------------------------------------------------------------------------------------

function renowned_rpg.calc_damage(attk, def)
    return attk * attk / (attk + def)
end

function renowned_rpg.calc_tool_attk_bonus(player_stats, tool_stats)
    local attk_mul = 1 + (tool_stats.attk*0.1)
    local attk_bonus = (player_stats.attk*attk_mul) - player_stats.attk
    if tool_stats.type ~= "other" and attk_bonus < tool_stats.attk then
        attk_bonus = tool_stats.attk
    end
    return attk_bonus
end

function renowned_rpg.calc_armor_def_bonus(player_stats, level)
    local def_mul = 1 + (level*0.1)
    local def_bonus = (player_stats.def*def_mul) - player_stats.def
    if def_bonus < level then
        def_bonus = level
    end
    return def_bonus
end


------------------------------- statbars --------------------------------------------------
-------------------------------------------------------------------------------------------

function renowned_rpg.get_xp_bar_state(player)
    local ret = {}
    local upgrades = data_get_upgrade_points(player)
    local total_xp = data_get_total_xp(player)
    local level = data_get_level(player)
    
    if level >= renowned_rpg.settings.max_level then
        ret = {
            text = string.format("Level: %d (Max)", level),
            value = 1,
            upgrades_text = (upgrades > 0) and string.format("%d Upgrades Available!", upgrades) or "",
        }
    else
        local xp_next_level_diff = renowned_rpg.settings.levels[level+1] - renowned_rpg.settings.levels[level]
        local xp_to_go = total_xp - renowned_rpg.settings.levels[level]
        --local number = math.floor((xp_to_go / xp_next_level_diff) * 160)
        ret = {
            text = string.format("Level: %d (%d/%d)", level, xp_to_go, xp_next_level_diff),
            value = xp_to_go / xp_next_level_diff,
            upgrades_text = (upgrades > 0) and string.format("%d Upgrades Available!", upgrades) or "",
        }
    end
    return ret
end

function renowned_rpg.get_health_bar_state(player)
    local ret = {}
    local stats = renowned_rpg.get_total_stats(player)
    
    local hp = renowned_rpg.get_hp(player)
    local hp_max = stats.hlth

    ret = {
        text = string.format("Health: %d/%d", hp, hp_max),
        value = hp / hp_max,
    }
    
    return ret
end

function renowned_rpg.get_attk_def_bar_state(player)
    local ret = {}
    local player_name = player:get_player_name()
    local stats = renowned_rpg.get_total_stats(player)
    local weapon = player:get_wielded_item()
    local weapon_stats = renowned_rpg.get_tool_stats(weapon)
    local attk_bonus = renowned_rpg.calc_tool_attk_bonus(stats, weapon_stats)
    local def_bonus = 0

    if armor.def[player_name] and armor.def[player_name].level ~= nil then
        def_bonus = renowned_rpg.calc_armor_def_bonus(stats, armor.def[player_name].level)
    end

    ret.text = string.format("AT %d+%d, DE %d+%d", stats.attk, attk_bonus, stats.def, def_bonus)
    ret.value = 1
    
    return ret
end

function renowned_rpg.get_breath_bar_state(player)
    local ret = {}
    local stats = renowned_rpg.get_total_stats(player)
    
    local breath = renowned_rpg.get_breath(player)
    local breath_max = stats.breath

    ret = {
        text = string.format("Breath: %d/%d", breath, breath_max),
        value = breath / breath_max,
    }
    
    return ret
end

function renowned_rpg.get_hunger_bar_state(player)
    local ret = {}
    local stats = renowned_rpg.get_total_stats(player)
    
    local hunger = renowned_rpg.get_hunger(player)
    local hunger_max = stats.hunger

    ret = {
        text = string.format("Hunger: %d/%d", hunger, hunger_max),
        value = hunger / hunger_max,
    }
    
    return ret
end

function renowned_rpg.get_sprint_bar_state(player)
    local ret = {}
    local stats = renowned_rpg.get_total_stats(player)
    
    local sprint = renowned_rpg.get_sprint(player)
    local sprint_max = stats.sprint

    ret = {
        text = string.format("Sprint: %d/%d", sprint, sprint_max),
        value = sprint / sprint_max,
    }
    
    return ret
end

function renowned_rpg.get_thirst_bar_state(player)
    local ret = {}
    local stats = renowned_rpg.get_total_stats(player)
    
    local thirst = renowned_rpg.get_thirst(player)
    local thirst_max = stats.thirst

    ret = {
        text = string.format("Thirst: %d/%d", thirst, thirst_max),
        value = thirst / thirst_max,
    }
    
    return ret
end

-------------------------- food ---------------------------------------
-----------------------------------------------------------------------

function renowned_rpg.register_food(itemstring, satiation, replace_with, poison, heal, sound)
    registered_food[itemstring] = {}
    registered_food[itemstring].satiation = satiation
    registered_food[itemstring].replace_with = replace_with
    registered_food[itemstring].poison = poison
    registered_food[itemstring].heal = heal 
    registered_food[itemstring].sound = sound
end

function renowned_rpg.get_registered_food(itemstring)
    if registered_food[itemstring] then
        return registered_food[itemstring]
    else
        return nil
    end
end


-------------------------------- tools ---------------------------------------
------------------------------------------------------------------------------

local desc_colors = {
    title = minetest.get_color_escape_sequence("#1eff00"),
    highlight = minetest.get_color_escape_sequence("#ffdf00"),
    default = minetest.get_color_escape_sequence("#ffffff"),
}

function renowned_rpg.get_tool_type(description)
    if string.find(description, "Pickaxe") then
        return "pickaxe"
    elseif string.find(description, "Axe") then
        return "axe"
    elseif string.find(description, "Shovel") then
        return "shovel"
    elseif string.find(description, "Hoe") then
        return "hoe"
    elseif string.find(description, "Sword") then
        return "sword"
    else
        return "other"
    end
  end

 function renowned_rpg.get_tool_stats(itemstack)
    local itemmeta  = itemstack:get_meta()
    local fields = itemmeta:to_table().fields

    if fields.type == nil then
        local itemdef   = itemstack:get_definition()

        if itemdef.original_description ~= nil then
            fields.type = renowned_rpg.get_tool_type(itemdef.original_description)
        else
            fields.type = renowned_rpg.get_tool_type(itemdef.description)
        end
        if fields.upgrade1 == nil then
            fields.upgrade1 = "none"
        end
        if fields.upgrade2 == nil then
            fields.upgrade2 = "none"
        end
        if fields.upgrade3 == nil then
            fields.upgrade3 = "none"
        end
        if fields.uses == nil then
            fields.uses = 0
        end
        if fields.level == nil then
            fields.level = 1
        end

        local attk = 0
        if itemdef.tool_capabilities ~= nil then
            for group, damage_rating in pairs(itemdef.tool_capabilities.damage_groups or {}) do
                attk = attk + damage_rating
            end
        end
        fields.attk = attk
    end
    return fields
end

function renowned_rpg.create_tool_description(description, tool_stats)
    local upgrades = 0
    if tool_stats.level == nil then
        tool_stats.level = 1
    end
    if tool_stats.type == nil then
        tool_stats.type = renowned_rpg.get_tool_type(description)
    end
    if tool_stats.upgrade1 and tool_stats.upgrade1 ~= "none" then
        upgrades = upgrades + 1
    end
    if tool_stats.upgrade2 and tool_stats.upgrade2 ~= "none" then
        upgrades = upgrades + 1
    end
    if tool_stats.upgrade3 and tool_stats.upgrade3 ~= "none" then
        upgrades = upgrades + 1
    end
    local desc = desc_colors.title .. description .. "\n" ..
        desc_colors.highlight .. "Level " .. (tool_stats.level) .. " " .. tool_stats.type .. "\n" ..
        desc_colors.default .. "Upgrades: " .. tostring(upgrades) .. "/3"
    return desc
end
