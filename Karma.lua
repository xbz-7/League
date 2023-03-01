q_range = 950
q_speed = 1700
q_width = 280
--
w_range = 675
--
e_range = 670

-- TODO
--[[ 
 FIX E enemy dmg check for auto shield
 Add Q KS back (broken)
 Add mana checks

]]


local navigation = menu.get_main_window():push_navigation("Karma", 10000)
local nav = menu.get_main_window():find_navigation("Karma")
local q_section = nav:add_section("Q settings")
local w_section = nav:add_section("W settings")
local e_section = nav:add_section("E settings")
local r_section = nav:add_section("R settings")
local q_cfg = g_config:add_bool(true, "Use_Q")
local w_cfg = g_config:add_bool(true, "Use_W")
local e_cfg = g_config:add_bool(true, "Use_E")
--local e_cfg_dmg = g_config:add_bool(false, "Use_E_DMG")
local cfg_prefer_q = g_config:add_bool(true, "Prefer_RQ")
local cfg_prefer_w = g_config:add_bool(false, "Prefer_RW")
local cfg_force_w = g_config:add_bool(true, "Force_RW")
local draw_q = g_config:add_bool(true, "Draw_Q")
local draw_e = g_config:add_bool(true, "Draw_E")
local shield_cfg = g_config:add_int(0, "Shield")
local shield_cfg2 = g_config:add_int(0, "Shield2")
--local shield_cfg3 = g_config:add_int(0, "Shield3")

-- menu
local q_checkbox = q_section:checkbox("Use Q", q_cfg)
local w_checkbox = w_section:checkbox("Use W", w_cfg)
local e_checkbox = e_section:checkbox("Use E", e_cfg)
--local e_dmg_checkbox = e_section:checkbox("Use E only when DMG incoming", e_cfg_dmg)
local rq_checkbox = q_section:checkbox("Prefer R>Q Empower", cfg_prefer_q)
local rw_checkbox = w_section:checkbox("Prefer R>W Empower", cfg_prefer_w)
local rw_low_checkbox = w_section:checkbox("Force R>W Empower while LOW HP", cfg_force_w)
local w_slider = w_section:slider_int("%HP to use shield SELF", shield_cfg, 0, 100, 1)
local w_slider2 = w_section:slider_int("%HP to use shield ALLY", shield_cfg2, 0, 100, 1)
--local w_slider3 = w_section:slider_int("%MANA to use shield", shield_cfg3, 0, 100, 1)
local draw_q_checkbox = q_section:checkbox("Draw Q Range", draw_q)
local draw_e_checkbox = e_section:checkbox("Draw E Range", draw_e)
q_checkbox:set_value(true)
w_checkbox:set_value(true)
e_checkbox:set_value(true)
draw_q_checkbox:set_value(true)
draw_e_checkbox:set_value(true)


cheat.register_callback("render", function()
  if draw_q_checkbox:get_value() then
    pink = color:new(255, 155, 155)
    g_render:circle_3d(g_local.position, pink, q_range, 2, 100, 2)
  end
end)

cheat.register_callback("render", function()
  if draw_e_checkbox:get_value() then
    g_render:circle_3d(g_local.position, pink, e_range, 2, 100, 2)
  end
end)

cheat.register_module({

  champion_name = "Karma",

  spell_r = function()

  end,

  spell_q = function()
    local target = features.target_selector:get_default_target()

    if (target == nil or features.evade:is_active()) then 
      return false 
    end

    local q_predict = features.prediction:predict(target.index, q_range, q_speed, q_width, 0.25, g_local.position)
    local bad_target = features.target_selector:is_bad_target(target.index)
    local minion_block = features.prediction:minion_in_line(g_local.position, q_predict.position, 45, -1)
    local spell_q = g_local:get_spell_book():get_spell_slot(0)
    local spell_r = g_local:get_spell_book():get_spell_slot(3) local low_hp = g_local.health <= 500

    if (spell_q:is_ready() and bad_target ~= true and minion_block == false and q_predict.hitchance > 2 and (features.orbwalker:get_mode() == 1) and q_checkbox:get_value()) then 
      
      if rq_checkbox:get_value() and not rw_checkbox:get_value() and not low_hp then 
        if spell_r:is_ready() then 
          g_input:cast_spell(e_spell_slot.r, q_predict.position)
          return features.orbwalker:set_cast_time(0.25)
        end
        g_input:cast_spell(e_spell_slot.q, q_predict.position)
      else
        g_input:cast_spell(e_spell_slot.q, q_predict.position)
        return features.orbwalker:set_cast_time(0.25)
      end
    end
    return false
  end,

  spell_e = function()

    --local e_cost = 50  + (5 * e_level())
    local threshold = w_slider:get_value() / 100
    local threshold2 = w_slider2:get_value() / 100
    --local mana_threshold = w_slider3:get_value() / 100
    if (g_local:get_spell_book():get_spell_slot(e_spell_slot.e):is_ready() and (features.orbwalker:get_mode() == 1 or features.orbwalker:get_mode() == 4) and e_checkbox:get_value())  then
      
      
      if g_local.health <= (g_local.max_health * threshold) then 
        g_input:cast_spell(e_spell_slot.e, g_local.position)
        return true
      end
      
      for _,ally in pairs(features.entity_list:get_allies()) do 
        if ally ~= nil and ally:is_alive() and ally.position:dist_to(g_local.position) <= e_range  then
          if g_local.index ~= ally.index and ally.health <= (ally.max_health * threshold2) then
            --if not e_dmg_checkbox:get_value() then
              g_input:cast_spell(e_spell_slot.e, ally)
              return true
            --else
              --[[print("trying to get enemies") --not working??
              for _,enemy in pairs(features.entity_list:get_enemies()) do 
                if enemy.position:dist_to(ally.position) <= 1500 then 
                  if enemy:get_spell_book():get_spell_cast_info():get_target_index() == ally.index or enemy:get_spell_book():get_spell_cast_info():get_target_index() ~= nil or features.evade:is_position_safe(ally.position, false) == false then
                    g_input:cast_spell(e_spell_slot.e, ally)
                    print("lol got hit lololol")
                  end
                end
              end --]]
            --end
          end
        end
      end
    return false
  end
end,

  spell_w = function()
    local target = features.target_selector:get_default_target()

    if (target == nil or features.evade:is_active()) then 
      return false 
    end

    local bad_target = features.target_selector:is_bad_target(target.index)
    local spell_w = g_local:get_spell_book():get_spell_slot(1)
    local spell_r = g_local:get_spell_book():get_spell_slot(3)
    local low_hp = g_local.health <= 500
    print(tostring(g_local.health))
    
    if (spell_w:is_ready() and bad_target ~= true and (features.orbwalker:get_mode() == 1) and w_checkbox:get_value() and target:dist_to_local() <= w_range ) then 
      if low_hp and rw_low_checkbox:get_value() then 
        if spell_r:is_ready() then 
          g_input:cast_spell(e_spell_slot.r, g_local.position)
          return features.orbwalker:set_cast_time(0.25)
        end
        g_input:cast_spell(e_spell_slot.w, target.network_id)
        return features.orbwalker:set_cast_time(0.25)
      else
        if not rw_checkbox:get_value() then 
          g_input:cast_spell(e_spell_slot.w, target.network_id)
          return features.orbwalker:set_cast_time(0.25)
        else
          if spell_r:is_ready() then 
            g_input:cast_spell(e_spell_slot.r, g_local.position)
            return features.orbwalker:set_cast_time(0.25)
          end
          g_input:cast_spell(e_spell_slot.w, target.network_id)
          return features.orbwalker:set_cast_time(0.25)
        end
      end
    end
    return false
  end,
      
initialize = function()
  print("Karma Loading")

end,
get_priorities = function()
return{
  "spell_r",
  "spell_q",
  "spell_e",
  "spell_w"
}
end
})