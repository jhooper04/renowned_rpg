
local huds_table = {}
local STATBAR_WIDTH = 160

local function hide_builtin_statbars(player)
    local flags = player:hud_get_flags()
    flags.healthbar = false
    flags.breathbar = false
    player:hud_set_flags(flags)
end

-- {
--   position = {x,y},
--   alignment = {x=1,y=1},
--   width = 160,
--   icon = "icon_image.png",
--   fill = "fill_image.png"
--   label = "Stat Label",
--   color = 0xFFFFFF,
--   value = 0.5 (percentage)
-- }
local function create_statbar(player, stat_name, config)
    local player_name = player:get_player_name()

    -- convert fill percentage to pixels
    local number = math.floor(config.value*STATBAR_WIDTH)

    if huds_table[player_name] == nil then
        huds_table[player_name] = {}
    end

    huds_table[player_name][stat_name.."_bar_bg"] = player:hud_add({
        hud_elem_type = "image",
        position = config.position,
        scale = {x=1, y=1},
        text = "renowned_rpg_bar_background.png",
        alignment = config.alignment, 
        offset = { x = -162, y = 0 },
    })
    huds_table[player_name][stat_name.."_bar_icon"] = player:hud_add({
        hud_elem_type = "image",
        position = config.position,
        scale = {x=1, y=1},
        text = config.icon,
        alignment = config.alignment,
        offset = { x = -179, y = 0 },
    })
    huds_table[player_name][stat_name.."_bar_fill"] = player:hud_add({
        hud_elem_type = "statbar",
        position = config.position,
        text = config.fill,
        number = number,
        alignment = config.alignment, 
        offset = { x = -161, y = 1 },
        direction = 0,
    })
    huds_table[player_name][stat_name.."_bar_text"] = player:hud_add({
        hud_elem_type = "text",
        position = config.position,
        text = config.label,
        alignment = config.alignment, 
        number = config.color,
        direction = 0,
        offset = { x = -154,  y = 1},
    })
end

local function update_statbar(player, stat_name, text, value)
    local player_name = player:get_player_name()
    player:hud_change(huds_table[player_name][stat_name.."_bar_text"], "text", text)
    player:hud_change(huds_table[player_name][stat_name.."_bar_fill"], "number", math.floor(value*STATBAR_WIDTH))
end

local function hide_statbar(player, stat_name)
    local player_name = player:get_player_name()
    player:hud_change(huds_table[player_name][stat_name.."_bar_bg"], "scale", {x=0,y=0})
    player:hud_change(huds_table[player_name][stat_name.."_bar_icon"], "scale", {x=0,y=0})
    player:hud_change(huds_table[player_name][stat_name.."_bar_fill"], "number", 0)
    player:hud_change(huds_table[player_name][stat_name.."_bar_text"], "text", "")
end

local function unhide_statbar(player, stat_name, text, value)
    local player_name = player:get_player_name()
    player:hud_change(huds_table[player_name][stat_name.."_bar_bg"], "scale", {x=1,y=1})
    player:hud_change(huds_table[player_name][stat_name.."_bar_icon"], "scale", {x=1,y=1})
    player:hud_change(huds_table[player_name][stat_name.."_bar_text"], "text", text)
    player:hud_change(huds_table[player_name][stat_name.."_bar_fill"], "number", math.floor(value*STATBAR_WIDTH))
end

function renowned_rpg.init_player_hud(player)
    local player_name = player:get_player_name()
    local xp_state = renowned_rpg.get_xp_bar_state(player)
    local attk_def_state = renowned_rpg.get_attk_def_bar_state(player)
    local health_state = renowned_rpg.get_health_bar_state(player)
    local hunger_state = renowned_rpg.get_hunger_bar_state(player)
    local breath_state = renowned_rpg.get_breath_bar_state(player)
    local sprint_state = renowned_rpg.get_sprint_bar_state(player)
    local thirst_state = renowned_rpg.get_thirst_bar_state(player)

    hide_builtin_statbars(player)

    create_statbar(player, "health", {
        position = {x=0.49, y=0.93},
        alignment = {x=1, y=1},
        icon = "heart.png",
        fill = "renowned_rpg_bar_red_fill.png",
        label = health_state.text,
        color = 0xFFFFFF,
        value = health_state.value
    })

    create_statbar(player, "attk_def", {
        position = {x=0.49, y=0.91},
        alignment = {x=1, y=1},
        icon = "renowned_rpg_attack_icon.png",
        fill = "renowned_rpg_bar_grey_fill.png",
        label = attk_def_state.text,
        color = 0xFFFFFF,
        value = attk_def_state.value
    })

    create_statbar(player, "hunger", {
        position = {x=0.59, y=0.93},
        alignment = {x=1, y=1},
        icon = "farming_bread.png",
        fill = "renowned_rpg_bar_tan_fill.png",
        label = hunger_state.text,
        color = 0xFFFFFF,
        value = hunger_state.value
    })

    create_statbar(player, "thirst", {
        position = {x=0.59, y=0.91},
        alignment = {x=1, y=1},
        icon = "renowned_rpg_thirst_icon.png",
        fill = "renowned_rpg_bar_blue_fill.png",
        label = thirst_state.text,
        color = 0xFFFFFF,
        value = thirst_state.value
    })

    create_statbar(player, "sprint", {
        position = {x=0.49, y=0.89},
        alignment = {x=1, y=1},
        icon = "renowned_rpg_sprint_icon_2.png",
        fill = "renowned_rpg_bar_green_fill.png",
        label = sprint_state.text,
        color = 0xFFFFFF,
        value = sprint_state.value
    })
    renowned_rpg.update_sprint_hud(player)

    create_statbar(player, "breath", {
        position = {x=0.59, y=0.89},
        alignment = {x=1, y=1},
        icon = "bubble.png",
        fill = "renowned_rpg_bar_blue_fill.png",
        label = breath_state.text,
        color = 0xFFFFFF,
        value = breath_state.value
    })
    renowned_rpg.update_breath_hud(player)

    create_statbar(player, "xp", {
        position = {x=0.98, y=0.3},
        alignment = {x=1, y=1},
        icon = "renowned_rpg_bar_xp_icon.png",
        fill = "renowned_rpg_bar_blue_fill.png",
        label = xp_state.text,
        color = 0xFFFFFF,
        value = xp_state.value
    })
    
    huds_table[player_name].xp_bar_upgrade_text = player:hud_add({
        hud_elem_type = "text",
        position = {x=0.98, y=0.3},
        text = xp_state.upgrades_text,
        alignment = {x=1,y=1},
        number = 0xFFFFFF,
        direction = 0,
        offset = { x = -162,  y = 25},
    })
  
end

function renowned_rpg.update_all_huds(player)
    local player_name = player:get_player_name()
    local xp_state = renowned_rpg.get_xp_bar_state(player)
    local health_state = renowned_rpg.get_health_bar_state(player)
    local hunger_state = renowned_rpg.get_hunger_bar_state(player)
    local attk_def_state = renowned_rpg.get_attk_def_bar_state(player)

    update_statbar(player, "health", health_state.text, health_state.value)
    update_statbar(player, "xp", xp_state.text, xp_state.value)
    update_statbar(player, "hunger", hunger_state.text, hunger_state.value)
    update_statbar(player, "attk_def", attk_def_state.text, attk_def_state.value)

    renowned_rpg.update_breath_hud(player)
    renowned_rpg.update_sprint_hud(player)
    renowned_rpg.update_thirst_hud(player)

    player:hud_change(huds_table[player_name].xp_bar_upgrade_text, "text", 
        xp_state.upgrades_text)
end

function renowned_rpg.update_attk_def_hud(player)
    local attk_def_state = renowned_rpg.get_attk_def_bar_state(player)

    update_statbar(player, "attk_def", attk_def_state.text, attk_def_state.value)
end

function renowned_rpg.update_health_hud(player)
    local health_state = renowned_rpg.get_health_bar_state(player)

    update_statbar(player, "health", health_state.text, health_state.value)
end

function renowned_rpg.update_hunger_hud(player)
    local hunger_state = renowned_rpg.get_hunger_bar_state(player)

    update_statbar(player, "hunger", hunger_state.text, hunger_state.value)
end

function renowned_rpg.update_breath_hud(player)
    --local sprint_state = renowned_rpg.get_sprint_bar_state(player)
    local breath_state = renowned_rpg.get_breath_bar_state(player)

    if breath_state.value ~= 1 then
        -- if sprint_state.value ~= 1 then
        --     update_statbar_pos(player, "sprint", {x=0.59, y=0.87})
        -- else
        --     update_statbar_pos(player, "sprint", {x=0.59, y=0.89})
        -- end
        unhide_statbar(player, "breath", breath_state.text, breath_state.value)
    else
        hide_statbar(player, "breath")
    end
end

function renowned_rpg.update_sprint_hud(player)
    local sprint_state = renowned_rpg.get_sprint_bar_state(player)
    --local breath_state = renowned_rpg.get_breath_bar_state(player)

    if sprint_state.value ~= 1 then
        -- if breath_state.value ~= 1 then
        --     update_statbar_pos(player, "sprint", {x=0.59, y=0.87})
        -- else
        --     update_statbar_pos(player, "sprint", {x=0.59, y=0.89})
        -- end
        unhide_statbar(player, "sprint", sprint_state.text, sprint_state.value)
    else
        hide_statbar(player, "sprint")
    end
end

function renowned_rpg.update_thirst_hud(player)
    local thirst_state = renowned_rpg.get_thirst_bar_state(player)

    --if sprint_state.value ~= 1 then
        unhide_statbar(player, "thirst", thirst_state.text, thirst_state.value)
    --else
    --    hide_statbar(player, "thirst")
    --end
end

function renowned_rpg.update_xp_hud(player)
    local player_name = player:get_player_name()
    local xp_state = renowned_rpg.get_xp_bar_state(player)

    update_statbar(player, "xp", xp_state.text, xp_state.value)
    player:hud_change(huds_table[player_name].xp_bar_upgrade_text, "text", 
        xp_state.upgrades_text)
end
