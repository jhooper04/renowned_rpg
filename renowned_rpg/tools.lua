

local minetest_get_color_escape_sequence = minetest.get_color_escape_sequence

function renowned_rpg.after_tool_use(itemstack, user, node, digparams)

    print("----------- tool data ---------------")

    print(dump(renowned_rpg.get_tool_stats(itemstack)))

    return itemstack
end

-- function renowned_rpg.on_tool_use(itemstack, user, pointed_thing)
--     local itemmeta  = itemstack:get_meta()
--     local itemdef   = itemstack:get_definition()
--     --local itemdesc  = itemdef.original_description
--     --local dugnodes  = tonumber(itemmeta:get_string("dug")) or 0 -- Number of nodes dug
--     --local lastlevel = tonumber(itemmeta:get_string("lastlevel")) or 1 -- Current Level

--     print("----------- tool data ---------------")
--     print(dump(itemmeta:to_table()))

--     if pointed_thing.type == "object" then
--         print("----------- pointed ---------------")
--         print(dump(pointed_thing.ref))

--         -- ItemStack punchitem = playersao->getWieldedItemOrHand();
--         -- ToolCapabilities toolcap =
--         --         punchitem.getToolCapabilities(m_itemdef);
--         -- v3f dir = (pointed_object->getBasePosition() -
--         --         (playersao->getBasePosition() + playersao->getEyeOffset())
--         --             ).normalize();
--         -- float time_from_last_punch =
--         --     playersao->resetTimeFromLastPunch();

--         -- u16 src_original_hp = pointed_object->getHP();
--         -- u16 dst_origin_hp = playersao->getHP();

--         -- pointed_object->punch(dir, &toolcap, playersao,
--         --         time_from_last_punch);
--     end
--     return nil
-- end

minetest.override_item("default:sword_diamond", {
    original_description = "Diamond Sword",
    description = renowned_rpg.create_tool_description("Diamond Sword", {}),
    after_use = renowned_rpg.after_tool_use,
})
