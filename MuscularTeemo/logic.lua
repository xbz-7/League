return function()
    local Player = Game.localPlayer;
    local Q = Champions.Q;
    local W = Champions.W;
    --local E = Champions.E;
    local R = Champions.R;
    local shroom_cooldown_flee = false
    local shroom_cooldown = false
    local shroom_cooldown_close = false

    -- QWR
    -- W gapclose lowhp enemy
    -- W on evade
    -- W flee
    -- Jungle farming
    -- Shroom farming to middle of the wave (3minion minimum)
    -- Shroom flee under localplayer
    -- Shroom on enemy / R under localplayer if enemy is close
    -- animated watermark with 3 styles
    -- Shroom locations
    -- Auto shroom on set locations holding X
    -- Shroom drawings including locations
    -- Shroom on CC
    -- dev debug

    -- changelog v1.2
    --[[

    Added new watermark style
    Fixed R trying to cast on shroomspot when R not ready
    Fixed shroomspot range
    Added dev debug drawings instead of annoying chat prints

    ]]
    local debug_text = "chilling"


    local shroomtable = {
        { x = 3316.20,  y = -74.06, z = 9334.85 },
        { x = 4288.76,  y = -71.71, z = 9902.76 },
        { x = 3981.86,  y = 39.54,  z = 11603.55 },
        { x = 6435.51,  y = 47.51,  z = 9076.02 },
        { x = 9577.91,  y = 45.97,  z = 6634.53 },
        { x = 7635.25,  y = 45.09,  z = 5126.81 },
        { x = 10731.51, y = -30.77, z = 5287.01 },
        { x = 9662.24,  y = -70.79, z = 4536.15 },
        { x = 10080.45, y = 44.48,  z = 2829.56 },
        --
        { x = 3283.18,  y = -69.64, z = 10975.15 },
        { x = 2595.85,  y = -74.00, z = 11044.66 },
        { x = 2524.10,  y = 23.36,  z = 11912.28 },
        { x = 4347.64,  y = 43.34,  z = 7796.28 },
        { x = 6093.20,  y = -67.90, z = 8067.45 },
        { x = 7960.99,  y = -73.41, z = 6233.09 },
        { x = 10652.57, y = -58.96, z = 3507.64 },
        { x = 11460.14, y = -63.94, z = 3544.83 },
        { x = 11401.81, y = -11.72, z = 2626.61 }
    }

    local shrooms_here = {}
    local removed_spots = {
        { x = 0,  y = 0, z = 0 },
    }

    
    local function setMana()
        if (Champions.Combo or Player.hpPercent < 20) then
            Champions.QMANA = (0);
            Champions.WMANA = (0);
            --Champions.EMANA = (0);
            Champions.RMANA = (0);
            return;
        end

        Champions.QMANA = (Q:ManaCost());
        Champions.WMANA = (W:ManaCost());
       -- Champions.EMANA = (E:ManaCost());
        Champions.RMANA = (R:ManaCost());
    end

    local function q_logic()

        local t = TargetSelector.GetTarget(Q.range, DamageType.Magical);

        if t and t:IsValidTarget(Q.range) then
            if menu.Q.comboQ.value then
                if (Champions.Combo and Player.mp > Champions.QMANA) then
                    Q:Cast(t);
                    debug_text = "casted Q"
                end
            end

            if menu.Q.harassQ.value then 
                if (Champions.Harass and Player.mp > Champions.QMANA) then
                    Q:Cast(t);
                    debug_text = "casted Q"
                end
            end
        end    
    end

    local function w_logic()
        local t = TargetSelector.GetTarget(Q.range, DamageType.Magical);

        if menu.W.autoW.value and Player.mp > Champions.WMANA then
            if (Champions.Combo or Champions.Harass) then
                if Player.position:CountEnemiesInRange(400) > 0  then
                    debug_text = "Cast W to anti-gapclose"
                    W:Cast();
                end

            if menu.W.gapcloseW.value then
                if t and t:IsValidTarget(1150) then
                    if t.totalHealth < 1000 then
                        debug_text = "Cast W to gapclose lowhp enemy"
                        W:Cast();
                    end
                end
            end
        end

            if Evade.IsEvading() then
                debug_text = "Cast W for (EVADE)"
                W:Cast();
            end

            if (Champions.Flee) then 
                if Player.position:CountEnemiesInRange(900) > 0 then
                    debug_text = "Cast W for (FLEE)"
                    W:Cast();
                end
            end
        end
    end
   --[[ local function e_logic()
        
    end--]] 
    local function farm_flee_logic()

        local bestTarget = nil;
        local health = math.huge

        if (Champions.Flee) then 
            if menu.R.fleeR.value and Player.position:CountEnemiesInRange(500) > 0 then

                    if not shroom_cooldown_flee then
                        R:Cast(Player.position);
                        shroom_cooldown_flee = true
                        Common.DelayAction(function()
                            shroom_cooldown_flee = false
                        debug_text = "shroom cast available again (FLEE)"
                    end, 5) -- 5 sec cooldown
                end
            end
        end

        if Champions.LaneClear then 
            if menu.R.farmR.value then
                local minion_count = 0
                local min_x, max_x, min_y, max_y, min_z, max_z = math.huge, -math.huge, math.huge, -math.huge, math.huge, -math.huge

                for k, entity in ObjectManager.enemyLaneMinions:pairs() do
                    if entity:IsValidTarget(R.range) then
                        minion_count = minion_count + 1
                        min_x = math.min(min_x, entity.position.x)
                        max_x = math.max(max_x, entity.position.x)
                        min_y = math.min(min_y, entity.position.y)
                        max_y = math.max(max_y, entity.position.y)
                        min_z = math.min(min_z, entity.position.z)
                        max_z = math.max(max_z, entity.position.z)
                    end
                end

                if minion_count > 3 then
                    local mid_x = (min_x + max_x) / 2 local mid_y = (min_y + max_y) / 2 local mid_z = (min_z + max_z) / 2
                    minions_middle = Math.Vector3(mid_x, mid_y, mid_z)

                    if not shroom_cooldown then
                        R:Cast(minions_middle);
                        debug_text = "casted shroom to middle of wave - counted: "..minion_count.." hittable"
                        shroom_cooldown = true
                        Common.DelayAction(function()
                            shroom_cooldown = false
                            debug_text = "shroom cast available again (FARM)"
                        end, 5) -- 5 sec cooldown
                    end
                end
            end
        end

        local target = nil;
        -- jungle 
        if Champions.LaneClear then 
            for k, jungle_entity in ObjectManager.jungleMinions:pairs() do 
                if jungle_entity:IsValidTarget(R.range) then
                    target = jungle_entity
                end
            end

            Q:Cast(target)
            if menu.R.jungleR.value then
                if not shroom_cooldown then
                    if target and target.totalHealth > 350 then
                        if R:Ready() then  
                            debug_text = "casted shroom (JUNGLE)"
                            R:Cast(target);
                            shroom_cooldown = true
                            Common.DelayAction(function()
                                shroom_cooldown = false
                            end, 6) -- 6 sec cooldown
                        end
                    end
                end
            end
        end
    end

    local function shroom_combo() 
        if menu.R.autoR.value then

            local t = TargetSelector.GetTarget(R.range, DamageType.Magical);

            if t and t:IsValidTarget(R.range) and R:Ready() then

                if (Champions.Combo and Player.mp > Champions.RMANA) then
                    local enemy_close = t.position:Distance(Player.position) < 300
                    local enemy_is_cc = t:HasBuffOfType(7) or t:HasBuffOfType(12) or t:HasBuffOfType(13) or t:HasBuffOfType(32) or t:HasBuffOfType(33) or t:HasBuffOfType(37)

                    if enemy_close then -- cast shroom to localplayer position instead of enemy
                        if not shroom_cooldown_close then
                            R:Cast(Player.position);
                            shroom_cooldown_close = true
                            Common.DelayAction(function()
                                shroom_cooldown_close = false
                                debug_text = "shroom cast available again (COMBO CLOSE)"
                            end, 3) -- 3 sec cooldown
                        end
                    elseif enemy_is_cc then -- enemy
                        if not shroom_cooldown then 
                            local cast_pos = R:GetPrediction(t).castPosition;
                            R:Cast(cast_pos);
                            shroom_cooldown = true
                            Common.DelayAction(function()
                                shroom_cooldown = false
                                debug_text = "shroom cast available again (COMBO)"
                            end, 5) -- 5 sec cooldown
                        end
                    else
                        if t.totalHealth < 1000 then
                            if not shroom_cooldown then
                                local cast_pos = R:GetPrediction(t).castPosition;
                                R:Cast(cast_pos);
                                shroom_cooldown = true
                                Common.DelayAction(function()
                                shroom_cooldown = false
                                debug_text = "shroom cast available again (COMBO)"
                            end, 5) -- 5 sec cooldown
                            end
                        end
                    end
                end
            end
        end
    end

    local shroom_cooldown = false
    local function auto_shroom()
        if Champions.LastHit then
            for k, shroom in ipairs(shroomtable) do
                if Player.position:Distance(Math.Vector3(shroom.x, shroom.y, shroom.z)) < 450 and R:Ready() then
                    place_shroom = Math.Vector3(shroom.x, shroom.y, shroom.z)
                    if R:Cast(place_shroom) then
                        debug_text = "casted shroom to preset location"
                        table.remove(shroomtable, k)
                        table.insert(removed_spots, place_shroom)
                    end
                end
            end

            if not shroom_cooldown and place_shroom ~= nil and Player.position:Distance(place_shroom) < 200 and R:Ready() then

                R:Cast(place_shroom)
                shroom_cooldown = true
                Common.DelayAction(function()
                    shroom_cooldown = false
                end, 5) -- 5 sec cooldown
            end

            if shroom_here == nil then
                shroom_here = Math.Vector3(0, 0, 0)
            end
        end
    end

    local function ontick()
        if Champions.LagFree(0) then setMana(); end
        if Champions.LagFree(1) and W:Ready() then w_logic() end
        if Champions.LagFree(1) and R:Ready() then farm_flee_logic() end
        if Champions.LagFree(1) then auto_shroom() end
    end

    local function draw_shrooms()
        for k, shroom in ipairs(shrooms_here) do 
            -- existing shrooms
            Renderer.DrawCircle3D(Math.Vector3(shroom.x, shroom.y, shroom.z), 150, 20, 2, 0x8050C878)
            Renderer.DrawWorldText("SHROOM", Math.Vector3(shroom.x, shroom.y, shroom.z), Math.Vector2(-20, 15), 13, 0x8050C878)
        end

        for k, shroom in ipairs(shroomtable) do
            -- where should shroom
            Renderer.DrawCircle3D(Math.Vector3(shroom.x, shroom.y, shroom.z), 150, 20, 2, 0xB2800080)
            Renderer.DrawWorldText("SHROOM SPOT", Math.Vector3(shroom.x, shroom.y, shroom.z), Math.Vector2(-33, -7), 13, 0x8050C878)
        end
    end

    local function draw()
        local animation_time = Game.GetTime()
        local animation_offset = math.sin(animation_time * 2) * 5
       
        local alpha = math.floor((math.sin(animation_time * 2) + 1) * 0.5 * 77)
        local color = alpha * 256^3 + 0x200060

        if menu.Draw.Draw_watermark.value == 0 then
            Renderer.DrawRectFilled(Math.Vector2(1000, 8), Math.Vector2(898, 24), 0x8050C878, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(900, 9), Math.Vector2(1000, 23), 0xFF200060, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawText("Muscular Teemo", Math.Vector2(912, 9), 13, color )
        end

        if menu.Draw.Draw_watermark.value == 1 then
            Renderer.DrawRectFilled(Math.Vector2(941 - animation_offset * 3 , 8), Math.Vector2(1001, 24), 0x99FFD700, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(898, 8), Math.Vector2(959 + animation_offset * 3, 24), 0x8050C878, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(900, 9), Math.Vector2(1000, 23), 0xFF200060, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawText("Muscular Teemo", Math.Vector2(912, 9), 13, color)
        end

        if menu.Draw.Draw_watermark.value == 2 then 
            --local screenres = Renderer.GetResolution()
          
            -- glow
            Renderer.DrawRectFilled(Math.Vector2(427 , 982), Math.Vector2(553, 1077), color, 5.0, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(426 , 981), Math.Vector2(554, 1078), color, 5.0, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(425 , 980), Math.Vector2(555, 1079), color, 5.0, Renderer.ImDrawFlags.None)
            --
            
            Renderer.DrawRectFilled(Math.Vector2(429 , 984), Math.Vector2(551, 1076), 0xFF200060, 0.9, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(430 , 985), Math.Vector2(550, 1075), 0xFF000000, 0.9, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(430 , 985), Math.Vector2(550, 1000), 0xFF200060, 0.9, Renderer.ImDrawFlags.None)

            -- horizontal
            -- underlayer
           -- Renderer.DrawLine2D(Math.Vector2(430, 1000), Math.Vector2(440, 1000), 0x4DFFD700 , 1)
           -- Renderer.DrawLine2D(Math.Vector2(550, 985), Math.Vector2(539, 985), 0x4DFFD700 , 1)

            -- layer
            Renderer.DrawLine2D(Math.Vector2(430, 1000), Math.Vector2(440 - animation_offset * 2, 1000), 0xB30066CC, 1)
            Renderer.DrawLine2D(Math.Vector2(550, 985), Math.Vector2(539 - animation_offset * 2, 985), 0xB30066CC, 1)
            
            --vertical
            -- underlayer 
            
            --Renderer.DrawLine2D(Math.Vector2(550, 985), Math.Vector2(550, 993), 0x4DFFD700 , 1)
           -- Renderer.DrawLine2D(Math.Vector2(430, 992), Math.Vector2(430, 1000), 0x4DFFD700 , 1)

            -- layer
            Renderer.DrawLine2D(Math.Vector2(550, 985), Math.Vector2(550, 993 - animation_offset * 1.6), 0xB30066CC, 1)
            Renderer.DrawLine2D(Math.Vector2(430, 992 - animation_offset * 1.6), Math.Vector2(430, 1000), 0xB30066CC, 1)

            Renderer.DrawText("wilency - Teemo", Math.Vector2(447, 985), 15, 0xFF000000)
            Renderer.DrawText("wilency - Teemo", Math.Vector2(446, 984), 15, 0xFFFFFFFF)

            Renderer.DrawText("keys:", Math.Vector2(433, 1000), 15, 0xB30066CC)
            Renderer.DrawText("use shroom spot:", Math.Vector2(433, 1015), 15, 0xB30066CC)
            Renderer.DrawText("flee and shroom:", Math.Vector2(433, 1030), 15, 0xB30066CC)

            local usagecolor = 0xFF200060
            local usagecolor2 = 0xFF200060
            if Champions.LastHit then usagecolor = 0xB30066CC end
            if Champions.Flee then usagecolor2 = 0xB30066CC end

            Renderer.DrawText("|  |", Math.Vector2(531, 1015), 15, usagecolor)
            Renderer.DrawText("|  |", Math.Vector2(531, 1030), 15, usagecolor2)

            Renderer.DrawText("X", Math.Vector2(536, 1015), 15, 0xB30066CC)
            Renderer.DrawText("Z", Math.Vector2(536, 1030), 15, 0xB30066CC)
            local username = client.GetUserName()
            
            if username == "altimor" then
                local tX, tY = Renderer.CalcTextSize("debug: "..debug_text, 15)
                Renderer.DrawRectFilled(Math.Vector2(429 , 949), Math.Vector2(429 + tX + 11, 971), 0xFF200060, 0.9, Renderer.ImDrawFlags.None)
                Renderer.DrawRectFilled(Math.Vector2(430 , 950), Math.Vector2(430 + tX + 10, 970), 0xFF000000, 0.9, Renderer.ImDrawFlags.None)
                Renderer.DrawText("debug:", Math.Vector2(433, 951), 15, 0xB30066CC)
                Renderer.DrawText(debug_text, Math.Vector2(475, 951), 15, 0xADFF2F00)
            end
        end
    end
    local function after_attack()
        if Q:Ready() then q_logic() end
    end

    local function close_enough(pos1, pos2, threshold)
        local dx = pos1.x - pos2.x
        local dy = pos1.y - pos2.y
        local dz = pos1.z - pos2.z
        return (dx * dx + dy * dy + dz * dz) <= (threshold * threshold) 
    end

    Callback.Bind(CallbackType.OnTick, ontick)
    Callback.Bind(CallbackType.OnAfterAttack, after_attack)
    Callback.Bind(CallbackType.OnAfterAttack, shroom_combo)
    Callback.Bind(CallbackType.OnImguiDraw, draw)
    Callback.Bind(CallbackType.OnDraw, draw_shrooms)

    Callback.Bind(CallbackType.OnObjectCreate, function(shroom_object)
        if shroom_object:IsValid() and (shroom_object:GetUniqueName():find("Noxious Trap")) then
            local shroom_here = {
                x = shroom_object.position.x,
                y = shroom_object.position.y,
                z = shroom_object.position.z
            }
            table.insert(shrooms_here, shroom_here)
        end
    end)

    Callback.Bind(CallbackType.OnObjectRemove, function(shroom_object)
        if shroom_object:IsValid() and (shroom_object:GetUniqueName():find("Noxious Trap")) then
            local shroom_position = {
                x = shroom_object.position.x,
                y = shroom_object.position.y,
                z = shroom_object.position.z
            }

            local threshold = 100

            for i = #shrooms_here, 1, -1 do
                local existing_shroom = shrooms_here[i]
                if close_enough(shroom_position, existing_shroom, threshold) then
                    table.remove(shrooms_here, i)

                    for _, default_shroom in ipairs(removed_spots) do
                        if close_enough(shroom_position, default_shroom, threshold) then
                            table.insert(shroomtable, shroom_position)
                            break 
                        end
                    end
                    break
                end
            end
        end
    end)
end
