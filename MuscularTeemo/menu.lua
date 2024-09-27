
return function ()
    local charName = Game.localPlayer.charName;
    local displayName = "Muscular Teemo ALT"

    local menu = UI.Menu.CreateMenu(charName,displayName,2);

    Champions.CreateBaseMenu(menu,0);

    local QMenu = menu:AddMenu("Q", "Q");

    local comboQ = QMenu:AddCheckBox(("comboQ"), ("Combo Q"));
    local harassQ = QMenu:AddCheckBox(("harassQ"), ("Harass Q"));


    local WMenu = menu:AddMenu("W", "W");

    local autoW = WMenu:AddCheckBox(("autoW"), ("Use W"));
    local gapcloseW = WMenu:AddCheckBox(("gapcloseW"), ("Gapclose W low hp enemy "));


    local RMenu = menu:AddMenu("R", "R");
    local autoR = RMenu:AddCheckBox(("autoR"), ("Use R"));
    local fleeR = RMenu:AddCheckBox(("fleeR"), ("Flee R if enemy close (Z)"));
    local farmR = RMenu:AddCheckBox(("farmR"), ("Use R Farming"));
    local jungleR = RMenu:AddCheckBox(("jungleR"), ("Use R Jungling"));

    local table = {
        "Regular",
        "Secondary",
    }

    local Drawmenu = menu:AddMenu("Draw", "Draw")
    local Draw_Watermark = Drawmenu:AddList(("Draw_watermark"), ("Draw Watermark"), table, 0);

    Champions.CreateColorMenu(menu:AddMenu(("draw"), ("Drawing")),false);
    return menu;
end