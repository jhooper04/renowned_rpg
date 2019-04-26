

local desc_colors = {
    title = minetest.get_color_escape_sequence("#1eff00"),
    highlight = minetest.get_color_escape_sequence("#ffdf00"),
    default = minetest.get_color_escape_sequence("#ffffff"),
}

function renowned_rpg.get_tool_stats()
    return {
        type = "sword",
        upgrade1 = "none",
        upgrade2 = "none",
        upgrade3 = "none",
        uses = 0,
        level = 1
    }
end


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
      return "tool"
    end
  end

function renowned_rpg.create_tool_description(description, stats)
    local upgrades = 0
    if stats.upgrade1 and stats.upgrade1 ~= "none" then
        upgrades = upgrades + 1
    end
    if stats.upgrade2 and stats.upgrade2 ~= "none" then
        upgrades = upgrades + 1
    end
    if stats.upgrade3 and stats.upgrade3 ~= "none" then
        upgrades = upgrades + 1
    end
    local desc = desc_colors.title .. description .. "\n" ..
        desc_colors.highlight .. "Level " .. (stats.level) .. " " .. stats.type .. "\n" ..
        desc_colors.default .. "Upgrades: " .. tostring(upgrades) .. "/3"
    return desc
end

function renowned_rpg.after_tool_use(itemstack, user, node, digparams)
    local itemmeta  = itemstack:get_meta()
    local itemdef   = itemstack:get_definition()
    local itemdesc  = itemdef.original_description
    local dugnodes  = tonumber(itemmeta:get_string("dug")) or 0 -- Number of nodes dug
    local lastlevel = tonumber(itemmeta:get_string("lastlevel")) or 1 -- Current Level
end

