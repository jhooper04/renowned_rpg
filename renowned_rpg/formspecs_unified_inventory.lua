

local function generate_number_image(x, y, size, value)
    local ret_string = ""
    local val_string = tostring(value)
    local width = size * 0.875
    local total_width = #val_string * width
    local offset_x = x - total_width / 2
    local offset_y = y

    for i = 1, #val_string do
        local num_str = string.sub(val_string, i, i)
        ret_string = ret_string .. string.format("image[%f,%f;%f,%f;ui_renowned_rpg_%s.png]", 
                offset_x, offset_y, width, size, num_str)
        offset_x = offset_x + width
    end

    return ret_string
end

unified_inventory.register_page("renowned_rpg_stats_form", {
    get_formspec = function(player)
        local player_name = player:get_player_name()
        local applied_stats = renowned_rpg.get_applied_stats(player)
        local pending_stats = renowned_rpg.get_pending_stats(player)
        local formspec = "background[0.06,0.06;13.9,7.52;ui_renowned_rpg_stats_form.png]"
  
        formspec = formspec .. "label[1,0.2;STATISTICS AND UPGRADES]"
        
        --Level
        formspec = formspec .. "label[9.5,0.2;LEVEL]"
        formspec = formspec .. generate_number_image(11.9, 0.25, 0.5, renowned_rpg.get_level(player))
        
        formspec = formspec .. "label[3.95,1.15;Current]"
        formspec = formspec .. "label[6.45,1.15;Upgrades]"
        
        --Attack class bonus number
        formspec = formspec .. "label[2.0,2.1;Attack]"
        formspec = formspec .. generate_number_image(4.2, 2.1, 0.4, applied_stats["attk"])
        
        formspec = formspec .. "image_button[6,2.1;0.5,0.5;ui_renowned_rpg_minus.png;minus_attk;]"
        formspec = formspec .. generate_number_image(6.75, 2.1, 0.4, pending_stats["attk"])
        formspec = formspec .. "image_button[7.1,2.1;0.5,0.5;ui_renowned_rpg_plus.png;plus_attk;]"
        
        --Defense
        formspec = formspec .. "label[2.0,2.7;Defense]"
        formspec = formspec .. generate_number_image(4.2, 2.7, 0.4, applied_stats["def"])
        
        formspec = formspec .. "image_button[6,2.7;0.5,0.5;ui_renowned_rpg_minus.png;minus_def;]"
        formspec = formspec .. generate_number_image(6.75, 2.7, 0.4, pending_stats["def"])
        formspec = formspec .. "image_button[7.1,2.7;0.5,0.5;ui_renowned_rpg_plus.png;plus_def;]"
        
        --Health
        formspec = formspec .. "label[2.0,3.295;Health]"
        formspec = formspec .. generate_number_image(4.2, 3.295, 0.4, applied_stats["hlth"])
        
        formspec = formspec .. "image_button[6,3.295;0.5,0.5;ui_renowned_rpg_minus.png;minus_hlth;]"
        formspec = formspec .. generate_number_image(6.75, 3.295, 0.4, pending_stats["hlth"])
        formspec = formspec .. "image_button[7.1,3.295;0.5,0.5;ui_renowned_rpg_plus.png;plus_hlth;]"
        
        --Stamina
        formspec = formspec .. "label[2.0,3.85;Stamina]"
        formspec = formspec .. generate_number_image(4.2, 3.85, 0.4, applied_stats["stam"])
        
        formspec = formspec .. "image_button[6,3.85;0.5,0.5;ui_renowned_rpg_minus.png;minus_stam;]"
        formspec = formspec .. generate_number_image(6.75, 3.85, 0.4, pending_stats["stam"])
        formspec = formspec .. "image_button[7.1,3.85;0.5,0.5;ui_renowned_rpg_plus.png;plus_stam;]"
        
        --Speed
        formspec = formspec .. "label[2.0,4.42;Speed]"
        formspec = formspec .. generate_number_image(4.2, 4.42, 0.4, applied_stats["spd"])
        
        formspec = formspec .. "image_button[6,4.42;0.5,0.5;ui_renowned_rpg_minus.png;minus_spd;]"
        formspec = formspec .. generate_number_image(6.75, 4.42, 0.4, pending_stats["spd"])
        formspec = formspec .. "image_button[7.1,4.42;0.5,0.5;ui_renowned_rpg_plus.png;plus_spd;]"
        
        formspec = formspec .. "label[3.35,5.4;" .. renowned_rpg.get_pending_upgrades(player) .. " Upgrades Remaining]"
        formspec = formspec .. "button[5.975,5.4;1.7,0.5;apply_btn;Apply]"
  
        return {formspec=formspec, draw_inventory = false, draw_item_list=false}
    end,
})

unified_inventory.register_button("renowned_rpg_stats_form", {
    type = "image",
    image = "ui_renowned_rpg_stats_icon.png",
    tooltip = "View Your Stats, Apply Upgrade Points",
})

unified_inventory.register_page("renowned_rpg_quest_form", {
    get_formspec = function(player)
        local player_name = player:get_player_name()
        local formspec = "background[0.06,0.99;7.92,7.52;ui_renowned_rpg_main_form.png]"
        formspec = formspec.."label[0,0;Quests and Party Management]"
        return {formspec=formspec, draw_inventory = false, draw_item_list=false}
    end,
})

unified_inventory.register_button("renowned_rpg_quest_form", {
    type = "image",
    image = "ui_renowned_rpg_quest_icon.png",
    tooltip = "View Your Current Quest, and Manage Party",
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "" then
        return
    end
    --print(dump(fields))

    local action_happenned = false

    if fields["minus_attk"] then
        renowned_rpg.minus_pending_stat(player, "attk")
        action_happenned = true
    elseif fields["plus_attk"] then
        renowned_rpg.plus_pending_stat(player, "attk")
        action_happenned = true
    elseif fields["minus_def"] then
        renowned_rpg.minus_pending_stat(player, "def")
        action_happenned = true
    elseif fields["plus_def"] then
        renowned_rpg.plus_pending_stat(player, "def")
        action_happenned = true
    elseif fields["minus_hlth"] then
        renowned_rpg.minus_pending_stat(player, "hlth")
        action_happenned = true
    elseif fields["plus_hlth"] then
        renowned_rpg.plus_pending_stat(player, "hlth")
        action_happenned = true
    elseif fields["minus_stam"] then
        renowned_rpg.minus_pending_stat(player, "stam")
        action_happenned = true
    elseif fields["plus_stam"] then
        renowned_rpg.plus_pending_stat(player, "stam")
        action_happenned = true
    elseif fields["minus_spd"] then
        renowned_rpg.minus_pending_stat(player, "spd")
        action_happenned = true
    elseif fields["plus_spd"] then
        renowned_rpg.plus_pending_stat(player, "spd")
        action_happenned = true
    elseif fields["apply_btn"] then
        renowned_rpg.apply_stats(player)
        renowned_rpg.update_all_huds(player)
        action_happenned = true
    end

    if action_happenned == true then
        unified_inventory.set_inventory_formspec(player, "renowned_rpg_stats_form")
    end
    return
end)