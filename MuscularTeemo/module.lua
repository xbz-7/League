
if 1416929526 ~= Game.localPlayer.hash then
    return
end

--disable cpp champion script if need
Champions.CppScriptMaster(false)

-- Menu:
menu = Environment.LoadModule("menu")
local logic = Environment.LoadModule("logic")


local function init()

    --Manager Spell class pointer so we call use  Champions.Clean() when unload
    Champions.Q=(SDKSpell.Create(SpellSlot.Q,675,DamageType.Magical))
    Champions.W=(SDKSpell.Create(SpellSlot.W,0,DamageType.Magical))
    Champions.E=(SDKSpell.Create(SpellSlot.E,0,DamageType.Magical))
    Champions.R=(SDKSpell.Create (SpellSlot.R,585,DamageType.Magical))

    menu = menu();
    logic();

end

init()

print("<font color='#800080'>".."[Muscular Teemo]".."<font color='#FFD700'>".." - ".."<font color='#50C878'>".."loaded")

Callback.Bind(CallbackType.OnUnload,function ()
    Champions.Clean()--clean QWER Spell pointer , spell range dmobj
end)
