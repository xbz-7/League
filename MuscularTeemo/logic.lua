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

    local function ontick()
        if Champions.LagFree(0) then setMana(); end
        if Champions.LagFree(1) and W:Ready() then w_logic() end
        if Champions.LagFree(1) and R:Ready() then farm_flee_logic() end
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
end