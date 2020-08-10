local DMW = DMW
local Mage = DMW.Rotations.MAGE
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC, Charges
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
                    [1] = { Text = "Rotation Mode |cFF00FF00Single", Tooltip = "" },
                    [2] = { Text = "Rotation Mode |cFFFFFF00Aoe", Tooltip = "" }
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
            },
            [5] = {
                ColdBlood = {
                    [1] = { Text = "ColdBlood |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "ColdBlood |cffff0000Disabled", Tooltip = "" }
                }
            },
        }

        UI.AddHeader("DPkS")
        UI.AddToggle("TimeWrap", nil, true)
        UI.AddToggle("MirrorImage", nil, true)
        UI.AddToggle("ColdBlood", nil, true)
        UI.AddToggle("ConeofCold", nil, true)
        UI.AddToggle("Counterspell", nil, true)
        UI.AddToggle("GlacialSpike", nil, true)
        UI.AddToggle("IceLance", nil, true)
        UI.AddToggle("FrostNova", nil, true)
        UI.AddToggle("Flurry", nil, true)
        UI.AddToggle("FrozenOrb", nil, true)
        UI.AddToggle("Frostbolt", nil, true)
        UI.AddToggle("Blizzard", nil, true)
        UI.AddRange("BlizzardUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("Ebonbolt", nil, true)
        UI.AddToggle("RuneofPower", nil, true)
        UI.AddToggle("CometStorm", nil, true)
        UI.AddToggle("FrostSp", nil, true)
        UI.AddToggle("ColdSnap", nil, true)
        UI.AddToggle("SP1", nil, true)
        UI.AddToggle("SP2", nil, true)

        UI.AddHeader("Defensive")
        UI.AddToggle("SummonWater", nil, true)
        UI.AddToggle("ArcaneIntellect", nil, true)
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("IceBlock", nil, true)
        UI.AddRange("IceBlockHP", nil, 1, 100, 1, 50)
        UI.AddToggle("TemporalShield", nil, true)
        UI.AddRange("TemporalShieldHP", nil, 1, 100, 1, 70)
        UI.AddToggle("Evocation", nil, true)
        UI.AddRange("EvocationPct", nil, 1, 100, 1, 10)
        UI.AddToggle("IceBarrier", nil, true)
        UI.AddRange("IceBarrierHP", nil, 1, 100, 1, 40)
    end
end

local function Locals()
    Charges = UnitPower("player", SPELL_POWER_ARCANE_CHARGES)
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

local function DPS()
    if Target and not Target.Dead and (Target.ValidEnemy or Target.Attackable) then

        if Target.Distance < 40 and (Target.HP > 80 or Target.HP < 20) and Spell.NearDeath:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Spell.RayOfFros:Cast(Target) then
            return true
        end
        --打断
        if Target.Distance <= 40 and Target:Interrupt() and HUD.Interrupts == 1 and Setting("Counterspell") and Spell.Counterspell:Cast(Target) then
            return true
        end
        if not Player.Moving and Setting("FocusedAzeriteBeam") and not Player.Moving and Spell.FocusedAzeriteBeam:Cast(Target) then
            return true
        end

        if Target.Distance < 40 and Spell.ConcentratedFlame:Cast(Target) then
            return true
        end
        if Setting("IceLance") and (Debuff.FrostSp:Exist(Target) or Buff.IceFinger:Exist(Player) or Debuff.WinterCold:Exist(Target)) and Spell.IceLance:Cast(Target) then
            return true
        end
        if Setting("Blizzard") and HUD.Mode == 2 and not Buff.IceIntel:Exist(Player) and Spell.Blizzard:Cast(Target) then
            return true
        end
        if Setting("TimeWrap") and Player.PowerPct >= Setting("ArcanePowerPct") and Player.Combat and Spell.TimeWrap:Cast(Player) then
            return true
        end
        if Setting("RuneofPower") and not Player.Moving and Player.Combat and (DMW.Time - Spell.RuneofPower.LastCastTime) > 10 and Spell.RuneofPower:Cast(Player) then
            return true
        end
        if Setting("MirrorImage") and Player.Combat and Spell.MirrorImage:Cast(Player) then
            return true
        end
        --饰品1
        local sp1Begin, sp1Duration, sp1Enable = GetInventoryItemCooldown("player", 13)
        local sp2Begin, sp2Duration, sp2Enable = GetInventoryItemCooldown("player", 14)
        if Player.Combat and Setting("SP1") and sp1Enable and sp1Begin == 0 then
            UseInventoryItem(13)
            return true
        end
        if Player.Combat and Setting("SP2") and sp2Enable and sp2Begin == 0 then
            UseInventoryItem(14)
            return true
        end
        if Setting("ColdBlood") and HUD.ColdBlood == 1 and Player.Combat and Spell.ColdBlood:Cast(Player) then
            return true
        end
        if Setting("FrozenOrb") and Spell.FrozenOrb:Cast(Target) then
            return true
        end
        if Setting("ColdSnap") and Spell.ColdSnap:IsReady() and not Spell.FrostNova:IsReady() and not Spell.FrostNova:LastCast() and Spell.ColdSnap:Cast(Player) then
            return true
        end
        if Setting("FrostNova") and Target.Distance <= 12 and Spell.FrostNova:Cast(Player) then
            return true
        end
        if Setting("FrostSp") and Talent.SummonWater.Active and Spell.FrostSp:IsReady() and Spell.FrostSp:Cast(Target) then
            return true
        end
        if Setting("ConeofCold") and ((Setting("FrostSp") and Debuff.FrostSp:Exist(Target)) or Debuff.FrostNova:Exist(Target)) and Spell.ConeofCold:Cast(Player) then
            return true
        end

        if Setting("Ebonbolt") and Spell.Ebonbolt:IsReady() and not Buff.IceIntel:Exist(Player) and Spell.Ebonbolt:Cast(Target) then
            return true
        end
        if Setting("Flurry") and Buff.IceIntel:Exist(Player) and Spell.Flurry:Cast(Target) then
            return true
        end
        if Setting("GlacialSpike") and Spell.GlacialSpike:IsReady() and Spell.GlacialSpike:Cast(Target) then
            return true
        end
        if Setting("CometStorm") and Spell.CometStorm:IsReady() and Spell.CometStorm:Cast(Target) then
            return true
        end

        if Setting("Frostbolt") and Spell.Frostbolt:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    if Talent.SummonWater.Active and Setting("SummonWater") and Spell.SummonWater:IsReady() and not UnitIsVisible("pet") and Spell.SummonWater:Cast(Player) then
        return true
    end
    if Setting("ArcaneIntellect") and not Buff.ArcaneIntellect:Exist(Player) and Spell.ArcaneIntellect:Cast(Player) then
        return true
    end
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Setting("IceBlock") and not Buff.IceBlock:Exist(Player) and Player.HP <= Setting("IceBlockHP") and Spell.IceBlock:Cast(Player) then
        return true
    end
    if Setting("TemporalShield") and not Buff.TemporalShield:Exist(Player) and Player.HP <= Setting("TemporalShieldHP") and Spell.TemporalShield:Cast(Player) then
        return true
    end
    if Setting("IceBarrier") and Player.HP <= Setting("IceBarrierHP") and Spell.IceBarrier:Cast(Player) then
        return true
    end
    if Setting("Evocation") and Player.PowerPct <= Setting("EvocationPct") and Spell.Evocation:Cast(Player) then
        return true
    end
end

local function Dispel()
    if HUD.Dispel ~= 1 then
        return false
    end
    for _, Friend in ipairs(Friends40Y) do
        if Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
        if Friend:Dispel(Spell.RemoveCurse) and Spell.RemoveCurse:Cast(Friend) then
            return true
        end
    end
end

function Mage.Frost()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if Dispel() then
            return true
        end

        if Defensive() then
            return true
        end
        Player:AutoTarget(40, true)
        if DPS() then
            return true
        end
    end
end
