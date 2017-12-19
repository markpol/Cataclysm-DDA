local MOD = {}

mods["No_Cure"] = MOD

local no_cure_effect = efftype_id("infected")

local no_cure_effect = {

 level_start = { "0 hours", nil, nil, "You have been <color_green>infected</color> and will <color_red>die</color> in <color_yellow>72 hours</color>!" },
 level1 = { "24 hours", nil, nil, "You have been <color_green>infected</color> earlier and will <color_red>die</color> in <color_yellow>48 hours</color>!"},
 level2 = { "48 hours", nil, nil, "You have been <color_green>infected</color> earlier and will <color_red>die</color> in <color_yellow>24 hours</color>!" },
 level3 = { "71 hours", nil, nil, "You have been <color_green>infected</color> earlier and will <color_red>die</color> in <color_yellow>1 hour</color>!" },
 level_end = { "72 hours", "bp_torso", 666, "You have <color_red>died</color> due to being <color_green>infected</color> earlier." }

}

function string.split(input_string, string_separator)

  if string_separator == nil then
    string_separator = "%s"
  end
  local t={} ; i=1
  for input_string in string.gmatch(inputstr, "([^"..string_separator.."]+)") do
    t[i] = input_string
    i = i + 1
  end
  return t

end

function string_to_turns(time_string)

  local return_value = tonumber(string.split(time_string, " ")[1])
  local time_type = string.split(time_string, " ")[2]

  if time_type = "days" then
    return_value = return_value * 24 * 60 * 60 / 10
  else if time_type = "hours" then
    return_value = return_value * 60 * 60 / 10
  else if time_type = "minutes" then
    return_value = return_value * 60 / 10
  else if time_type = "seconds" then
    return_value = return_value / 10
  end

  return return_value

end

local no_cure_effect_duration_level1 = 24*60*60/10 --24 hours
local no_cure_effect_duration_level2 = 48*60*60/10 --48 hours
local no_cure_effect_duration_level3 = 72*60*60/10 --72 hours

function MOD.on_new_player_created()

  game.add_msg("Starting new game with <color_red>No Cure!</color> mod.  You will <color_red>die</color> in <color_yellow>72 hours</color> after getting <color_green>infected</color>.")

  no_cure_process()

end

function MOD.on_minute_passed()

  no_cure_process()

end

function no_cure_process()

  local calendar = game.get_calendar_turn()
  local current_turn = calendar:get_turn()
  local expected_death_turn = tonumber(player:get_value("No_Cure_DeathTurn"))

  if expected_death_turn == nil and player:has_effect(no_cure_effect) then
    game.add_msg(NO_CURE_MESSAGE_EFFECT_START)
    player:set_value("No_Cure_DeathTurn", tostring(current_turn + no_cure_effect_duration_level3))
  else
    if current_turn >= expected_death_turn then
      game.add_msg(NO_CURE_MESSAGE_EFFECT_END)
      player:apply_damage(player, no_cure_effect_body_part, no_cure_effect_body_part_damage) -- player:die() is not working, so we apply high damage to selected player body part.
    end
  end

end
