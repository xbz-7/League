return function()
    local Player = Game.localPlayer;
    local Q = Champions.Q;
    local W = Champions.W;
    --local E = Champions.E;
    local R = Champions.R;
    local fleeRcooldown = false
    local Rcooldown = false
    local Rcooldown_close = false

    -- QWR
    -- W gapclose lowhp enemy
    -- W on evade
    -- W flee
    -- Jungle farming
    -- R flee under localplayer
    -- R on enemy / R under localplayer if enemy is close
    -- watermark with 2 style

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
                    print("<font color='#50C878'>".."Casted Q")
                end
            end

            if menu.Q.harassQ.value then 
                if (Champions.Harass and Player.mp > Champions.QMANA) then
                    Q:Cast(t);
                    print("<font color='#50C878'>".."Casted Q")
                end
            end
        end    
    end

    local function w_logic()
        local t = TargetSelector.GetTarget(Q.range, DamageType.Magical);

        if menu.W.autoW.value and Player.mp > Champions.WMANA then
            if (Champions.Combo or Champions.Harass) then
                if Player.position:CountEnemiesInRange(400) > 0  then
                    print("<font color='#50C878'>".."Cast W to anti-gapclose")
                    W:Cast();
                end

            if menu.W.gapcloseW.value then
                if t and t:IsValidTarget(1150) then
                    if t.totalHealth < 1000 then
                        print("<font color='#50C878'>".."Cast W to gapclose lowhp enemy")
                        W:Cast();
                    end
                end
            end
        end

            if Evade.IsEvading() then
                print("<font color='#50C878'>".."Cast W for (EVADE)")
                W:Cast();
            end

            if (Champions.Flee) then 
                if Player.position:CountEnemiesInRange(900) > 0 then
                    print("<font color='#50C878'>".."Cast W for (FLEE)")
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

                    if not fleeRcooldown then
                        R:Cast(Player.position);
                        fleeRcooldown = true
                        Common.DelayAction(function()
                        fleeRcooldown = false
                        print("<font color='#50C878'>".."shroom cast available again (FLEE)")
                    end, 5) -- 5 sec cooldown
                end
            end
        end

        if Champions.LaneClear then 
            if menu.R.farmR.value then

                for k, entity in ObjectManager.enemyLaneMinions:pairs() do
                    if entity:IsValidTarget(R.range) and entity.hp < health then
                        health = entity.hp;
                        bestTarget = entity;
                    end
                end -- still scuffed

                if (bestTarget) and R:GetDamage(bestTarget) > bestTarget.totalHealth then
                    if not Rcooldown then
                        R:Cast(bestTarget);
                        Rcooldown = true
                        Common.DelayAction(function()
                            Rcooldown = false
                            print("<font color='#50C878'>".."shroom cast available again (FARM)")
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
                if not Rcooldown then
                    if target and target.totalHealth > 350 then 
                        print("<font color='#50C878'>".."Casting shroom (JUNGLE)")
                        R:Cast(target);
                        Rcooldown = true
                        Common.DelayAction(function()
                            Rcooldown = false
                        end, 6) -- 6 sec cooldown
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

                    if enemy_close then -- cast shroom to localplayer position instead of enemy
                        if not Rcooldown_close then
                            R:Cast(Player.position);
                            Rcooldown_close = true
                            Common.DelayAction(function()
                                Rcooldown_close = false
                                print("<font color='#50C878'>".."shroom cast available again (COMBO CLOSE)")
                            end, 3) -- 3 sec cooldown
                        end
                    else -- enemy
                        if not Rcooldown then 
                            local cast_pos = R:GetPrediction(t).castPosition;
                            R:Cast(cast_pos);
                            Rcooldown = true
                            Common.DelayAction(function()
                                Rcooldown = false
                                print("<font color='#50C878'>".."shroom cast available again (COMBO)")
                            end, 5) -- 5 sec cooldown
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
                if Player.position:Distance(Math.Vector3(shroom.x, shroom.y, shroom.z)) < 200 then
                    place_shroom = Math.Vector3(shroom.x, shroom.y, shroom.z)
                    if R:Cast(place_shroom) then
                        table.remove(shroomtable, k)
                        table.insert(removed_spots, place_shroom)
                    end
                    --print("Near shroom at: ", shroom.x, shroom.y, shroom.z)
                end
            end

            if not shroom_cooldown and place_shroom ~= nil and Player.position:Distance(place_shroom) < 200 then
                R:Cast(place_shroom)
                shroom_cooldown = true
                Common.DelayAction(function()
                    shroom_cooldown = false
                end, 5)             -- 5 sec cooldown
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

    local function drawshrooms()
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
        if menu.Draw.Draw_watermark.value == 0 then
            Renderer.DrawRectFilled(Math.Vector2(1000, 8), Math.Vector2(898, 24), 0x8050C878, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(900, 9), Math.Vector2(1000, 23), 0xFF200060, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawText("Muscular Teemo", Math.Vector2(912, 9), 13, 0xCC50C878 )
        end

        if menu.Draw.Draw_watermark.value == 1 then
            Renderer.DrawRectFilled(Math.Vector2(941, 8), Math.Vector2(1001, 24), 0x99FFD700, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(898, 8), Math.Vector2(959, 24), 0x8050C878, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawRectFilled(Math.Vector2(900, 9), Math.Vector2(1000, 23), 0xFF200060, 10.0, Renderer.ImDrawFlags.None)
            Renderer.DrawText("Muscular Teemo", Math.Vector2(912, 9), 13, 0xCC50C878 )
        end
    end

    local function after_attack()
        if Q:Ready() then q_logic() end
    end

    Callback.Bind(CallbackType.OnTick, ontick)
    Callback.Bind(CallbackType.OnAfterAttack, after_attack)
    Callback.Bind(CallbackType.OnAfterAttack, shroom_combo)
    Callback.Bind(CallbackType.OnImguiDraw, draw)
    Callback.Bind(CallbackType.OnDraw, drawshrooms)

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

    local function close_enough(pos1, pos2, threshold)
        local dx = pos1.x - pos2.x
        local dy = pos1.y - pos2.y
        local dz = pos1.z - pos2.z
        return (dx * dx + dy * dy + dz * dz) <= (threshold * threshold) 
    end
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
                    --print("Removed shroom: ", existing_shroom.x, existing_shroom.y, existing_shroom.z)

                    for _, default_shroom in ipairs(removed_spots) do
                        if close_enough(shroom_position, default_shroom, threshold) then
                            table.insert(shroomtable, shroom_position)
                            --print("Inserted shroom at: ", shroom_position.x, shroom_position.y, shroom_position.z)
                            break 
                        else
                            --print("Not close enough to: ", default_shroom.x, default_shroom.y, default_shroom.z)
                        end
                    end
                    break
                end
            end
        end
    end)
end
