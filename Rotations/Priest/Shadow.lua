local DMW = DMW
local Priest = DMW.Rotations.PRIEST
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC
local UI = DMW.UI
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting

local function CreateSettings()
    if not UI.HUD.Options then
        UI.HUD.Options = {
            [1] = {
                CDs = {
                    [1] = { Text = "Cooldowns |cFF00FF00Auto", Tooltip = "" },
                    [2] = { Text = "Cooldowns |cFFFFFF00Always On", Tooltip = "" },
                    [3] = { Text = "Cooldowns |cffff0000Disabled", Tooltip = "" }
                }
            },
            [2] = {
                Mode = {
                    [1] = { Text = "Rotation Mode |cFF00FF00Auto", Tooltip = "" },
                    [2] = { Text = "Rotation Mode |cFFFFFF00Single", Tooltip = "" }
                }
            },
            [3] = {
                Interrupts = {
                    [1] = { Text = "Interrupts |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Interrupts |cffff0000Disabled", Tooltip = "" }
                }
            },
            [4] = {
                Dispel = {
                    [1] = { Text = "Dispel |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Dispel |cffff0000Disabled", Tooltip = "" }
                }
            }
        }

        UI.AddHeader("Healing")
        UI.AddToggle("Shadow Mend", nil, true)
        UI.AddRange("Shadow Mend HP", nil, 0, 100, 1, 60)
        UI.AddToggle("Power Word: Shield", nil, true)
        UI.AddRange("Power Word: Shield HP", "HP to use Power Word: Shield", 0, 100, 1, 80)
        UI.AddToggle("SP1", nil, true)
        UI.AddRange("SP1Range", nil, 1, 100, 1, 60)
        UI.AddToggle("SP2", nil, true)
        UI.AddRange("SP2Range", nil, 1, 100, 1, 30)
        --救世之魂
        UI.AddRange("Atonement HP", "HP to use Power Word: Shield or Power Word: Radiance to apply Atonement", 0, 100, 1, 90)

        UI.AddHeader("DPS")
        UI.AddToggle("MindBlast", nil, true)
        UI.AddToggle("VampiricTouch", nil, true)
        UI.AddToggle("VoidEruption", nil, true)
        UI.AddToggle("VoidBolt", nil, true)
        UI.AddToggle("MindFlay", nil, true)
        UI.AddToggle("MindBender", nil, true)
        UI.AddToggle("MindBomb", nil, true)
        UI.AddToggle("Silence", nil, true)
        UI.AddToggle("DarkAscension", nil, true)
        UI.AddRange("Shadow Word: Pain Units", "Max active Shadow Word: Pain dots active", 0, 10, 1, 3)

        UI.AddHeader("Defensive")
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 40)
        UI.AddToggle("Dispersion")
        UI.AddRange("DispersionRange", nil, 1, 100, 1, 20)
    end
end

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Trait = Player.Traits
    Item = Player.Items
    Target = Player.Target or false
    GCD = Player:GCD()
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs() and Target and Target.TTD > 5 and Target.Distance < 5
    Friends40Y, Friends40YC = Player:GetFriends(40)
    Player40Y, Player40YC = Player:GetEnemies(40)
end

local function Dispel()
    for _, Friend in ipairs(Friends40Y) do
        if HUD.Dispel == 1 and Friend:Dispel(Spell.PurifyDisease) and Spell.PurifyDisease:Cast(Friend) then
            return true
        end
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end
local function Heals()
    if Dispel() then
        return true
    end
    --SM
    if Setting("Shadow Mend") and not Player.Moving then
        for _, Friend in ipairs(Friends40Y) do
            if Friend.HP < Setting("Shadow Mend HP") then
                if Spell.ShadowMend:Cast(Friend) then
                    return true
                end
            else
                break
            end
        end
    end
    --Dispel 进攻驱散
    if HUD.Dispel == 1 and Spell.DispelMagic:IsReady() then
        for _, Enemy in pairs(Player40Y) do
            if Enemy:Dispel(Spell.DispelMagic) and Spell.DispelMagic:Cast(Enemy) then
                return true
            end
        end
    end
    --PWS
    if Setting("Power Word: Shield") then
        for _, Friend in ipairs(Friends40Y) do
            if Friend.HP < Setting("Power Word: Shield HP") or (Player.Instance ~= "none" and Friend.Role == "TANK") or Friend.HP < Setting("Atonement HP") then
                if not Buff.PowerWordShield:Exist(Friend) and (not Debuff.WeakenedSoul:Exist(Friend)) then
                    if Spell.PowerWordShield:Cast(Friend) then
                        return true
                    end
                end
            end
        end
    end
end

local function DPS()
    --饰品1
    local sp1Begin, sp1Duration, sp1Enable = GetInventoryItemCooldown("player", 13)
    local sp2Begin, sp2Duration, sp2Enable = GetInventoryItemCooldown("player", 14)
    if Player.Combat and Setting("SP1") and Player.PowerPct <= Setting("SP1Range") and sp1Enable and sp1Begin == 0 then
        UseInventoryItem(13)
        return true
    end
    if Player.Combat and Setting("SP2") and Player.PowerPct <= Setting("SP2Range") and sp2Enable and sp2Begin == 0 then
        UseInventoryItem(14)
        return true
    end
    local SWPCount = Debuff.ShadowWordPain:Count(Player40Y)
    if Friends40Y[1].HP > 50 and SWPCount <= Setting("Shadow Word: Pain Units") then
        for _, Unit in ipairs(Player40Y) do
            if Debuff.ShadowWordPain:Refresh(Unit) and (Unit.TTD - Debuff.ShadowWordPain:Remain(Unit)) > 4 and (SWPCount < Setting("Shadow Word: Pain Units") or Debuff.ShadowWordPain:Exist(Unit)) then
                if Spell.ShadowWordPain:Cast(Unit) then
                    return true
                end
            end
        end
    end
    if Target and Target.ValidEnemy then
        if Target.Distance < 30 and Target.Target ~= nil and Target.Target == Player.Pointer and Spell.Fade:Cast(Player) then
            return true
        end
        if Target.Distance < 40 and Setting("DarkAscension") and Spell.DarkAscension:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Setting("VoidEruption") and Spell.VoidEruption:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Setting("VoidBolt") and Buff.VoidForm:Remain(Player) > 0 and Spell.VoidBolt:IsReady() and Spell.VoidBolt:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Setting("MindBlast") and not Player.Moving and Spell.MindBlast:Cast(Target) then
            return true
        end
        if Target.Distance < 30 and Setting("MindBomb") and Spell.MindBomb:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Setting("MindBender") and Spell.MindBender:Cast(Target) then
            return true
        end
        if Target.Distance < 30 and Setting("Silence") and Spell.Silence:Cast(Target) then
            return true
        end

        if Debuff.VampiricTouch:Remain(Target) < 1 and Target.Distance < 40 and Setting("VampiricTouch") and Spell.VampiricTouch:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Setting("MindFlay") and Spell.MindFlay:Cast(Target) then
            return true
        end
        local LowestSWP = Debuff.ShadowWordPain:Lowest(Player40Y)
        if LowestSWP and Spell.ShadowWordPain:Cast(LowestSWP) then
            return true
        end
    end
end

local function Defensive()
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Setting("Dispersion") and Player.HP <= Setting("DispersionRange") and Spell.Dispersion:Cast(Player) then
        return true
    end

    --DP
end

function Priest.Shadow()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if not Player.Combat then
            -- if OOC() then
            --     return true
            -- end
            if Target and Target.ValidEnemy then
                if Spell.ShadowWordPain:Cast(Target) then
                    return true
                end
            end
        else
            Player:AutoTarget(40, true)
            if Defensive() then
                return true
            end
            if Spell.GCD:CD() == 0 then
                if Heals() then
                    return true
                end
                if DPS() then
                    return true
                end
            end
        end
    end
end
