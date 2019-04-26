

mobs:register_mob("renowned_rpg:npc", {
	type = "npc",
	passive = false,
	attack_type = "dogfight",
	attack_animals = true,
	--specific_attack = {"player", "mobs_animal:chicken"},
	reach = 2,
	damage = 2,
	hp_min = 7,
	hp_max = 33,
	armor = 100,
    collisionbox = {-0.3, 0, -0.3, 0.3, 1.7, 0.3},
    selectionbox = {-0.3, 0, -0.3, 0.3, 1.7, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {
		armor.default_skin..".png",
		"3d_armor_trans.png",
		"3d_armor_trans.png",
	},
	--blood_texture = "default_wood.png",
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_treemonster",
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	view_range = 15,
	drops = {
		{name = "default:apple", chance = 2, min = 1, max=3},
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	fall_damage = 0,
--	immune_to = {
--		{"default:axe_diamond", 5},
--		{"default:sapling", -5}, -- saplings heal
--		{"all", 0},
--	},
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 189,
		punch_end = 198,
	},
})


mobs:spawn({
	name = "renowned_rpg:npc",
	nodes = {"default:dirt_with_grass"},
	min_light = 14,
	chance = 7000,
	min_height = 0,
	day_toggle = false,
})


mobs:register_egg("renowned_rpg:npc", "NPC Villager", "renowned_rpg_sprint_icon_2.png", 1)