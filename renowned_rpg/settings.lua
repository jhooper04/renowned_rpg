
renowned_rpg.settings = {}

renowned_rpg.settings.breath = {
  update_rate = 1
}

renowned_rpg.settings.hunger = {
  update_rate = 2,
  base_rate = 480,
  move_step = 6,
  dig_step = 8,
  place_step = 2,
}

renowned_rpg.settings.thirst = {
  update_rate = 2,
  base_rate = 240,
  move_step = 6,
  dig_step = 8,
  place_step = 2,
  hydrate_nodes = {
    "default:water_source"
  },
}

renowned_rpg.settings.sprint = {
  update_rate = 0.1,
  speed_multiplier = 0.2,
  jump_multiplier = 0.05,
}

renowned_rpg.settings.attk_def_stat = {
  update_rate = 4,
}

renowned_rpg.settings.class_bonuses = {
  soldier={
    attack=2,
    defense=2,
    health=1,
    stamina=1.25,
    speed=0.75,
    special="berserk",
  },
  assassin={
    attack=1.75,
    defense=0.75,
    health=1,
    stamina=1.5,
    speed=2,
    special="stealth",
  },
  hunter={
    attack=1.4,
    defense=1.4,
    health=1.4,
    stamina=1.4,
    speed=1.4,
    special="beast_spawn",
  },
  medic={
    attack=0.75,
    defense=1,
    health=2,
    stamina=1.25,
    speed=2,
    special="party_heal",
  },
}
renowned_rpg.settings.stat_multipliers={
  attk=1, def=1, hlth=5, stam=1, spd=1
}
renowned_rpg.settings.stat_defaults={
  attk=1, def=1, hlth=20, stam=0, spd=0
}
renowned_rpg.settings.stamina_defaults={
  sprint=5, thirst=10, breath=5, hunger=20
}

renowned_rpg.settings.max_level = 200
renowned_rpg.settings.levels = {}
local function build_levels_table()
  local points = 0
  local output = 0;
  local min_level = 2
  local max_level = renowned_rpg.settings.max_level

  renowned_rpg.settings.levels[1] = 0
  
  for lvl = 1, max_level do
    points = points + math.floor(lvl + 400 * math.pow(2, lvl / 5.0));
    if lvl >= min_level then
    renowned_rpg.settings.levels[lvl] = output
    end
    output = math.floor(points / 4);
  end
end
build_levels_table()