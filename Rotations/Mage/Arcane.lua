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
                    [1] = {Text = "Cooldowns |cFF00FF00Auto", Tooltip = ""},
                    [2] = {Text = "Cooldowns |cFFFFFF00Always On", Tooltip = ""},
                    [3] = {Text = "Cooldowns |cffff0000Disabled", Tooltip = ""}
                }
            },
            [2] = {
                Mode = {
                    [1] = {Text = "Rotation Mode |cFF00FF00Auto", Tooltip = ""},
                    [2] = {Text = "Rotation Mode |cFFFFFF00Single", Tooltip = ""}
                }
            },
            [3] = {
                Interrupts = {
                    [1] = {Text = "Interrupts |cFF00FF00Enabled", Tooltip = ""},
                    [2] = {Text = "Interrupts |cffff0000Disabled", Tooltip = ""}
                }
            },
            [4] = {
                Dispel = {
                    [1] = {Text = "Dispel |cFF00FF00Enabled", Tooltip = ""},
                    [2] = {Text = "Dispel |cffff0000Disabled", Tooltip = ""}
                }
            },
        }

        UI.AddHeader("DPS")
        UI.AddToggle("TimeWrap", nil, true)
        UI.AddToggle("MirrorImage", nil, true)
        UI.AddToggle("ArcanePower", nil, true)
        UI.AddRange("ArcanePowerPct", nil, 1, 100, 1, 40)
        UI.AddToggle("Counterspell", nil, true)
        UI.AddToggle("ArcaneOrb", nil, true)
        UI.AddToggle("ArcaneBlast", nil, true)
        UI.AddToggle("ArcaneBarrage", nil, true)
        UI.AddToggle("ArcaneMissiles", nil, true)
        UI.AddToggle("ArcaneExplosion", nil, true)
        UI.AddRange("ArcaneExplosionUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("PresenceofMind", nil, true)
        UI.AddToggle("ChargedUp", nil, true)
        UI.AddToggle("RuneofPower", nil, true)
        UI.AddToggle("SuperNova", nil, true)
        UI.AddToggle("NetherTempest", nil, true)

        UI.AddHeader("Defensive")
        UI.AddToggle("ArcaneFamiliar", nil, true)
        UI.AddToggle("ArcaneIntellect", nil, true)
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("IceBlock", nil, true)
        UI.AddRange("IceBlockHP", nil, 1, 100, 1, 50)
        UI.AddToggle("TemporalShield", nil, true)
        UI.AddRange("TemporalShieldHP", nil, 1, 100, 1, 70)
        UI.AddToggle("PrismaticBarrier", nil, true)
        UI.AddRange("PrismaticBarrierHP", nil, 1, 100, 1, 80)
        UI.AddToggle("Evocation", nil, true)
        UI.AddRange("EvocationPct", nil, 1, 100, 1, 10)
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

    if Target and  (Target.ValidEnemy or Target.Attackable)  and not Target.Dead then
        local EnemyUnits, EnemyCount = Player:GetEnemies(10)

        if Target.Distance < 40 and ( Target.HP > 80 or Target.HP < 20) and Spell.NearDeath:Cast(Target) then
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
        if Setting("TimeWrap") and Player.PowerPct >= Setting("ArcanePowerPct") and Player.Combat and Spell.TimeWrap:Cast(Player) then
            return true
        end
        if Setting("RuneofPower") and not Player.Moving and Player.Combat and (DMW.Time - Spell.RuneofPower.LastCastTime) > 10 and Spell.RuneofPower:Cast(Player) then
            return true
        end
        if Setting("MirrorImage") and Player.Combat and Spell.MirrorImage:Cast(Player) then
            return true
        end
        if Setting("ArcanePower") and Player.PowerPct >= Setting("ArcanePowerPct") and Player.Combat and Spell.ArcanePower:Cast(Player) then
            return true
        end
        if Setting("NetherTempest") and not Debuff.NetherTempest:Exist(Target) and Charges == 4 and Spell.NetherTempest:Cast(Target) then
            return true
        end
        if Setting("ChargedUp") and Player.Combat and Charges == 0 and Spell.ChargedUp:Cast(Player) then
            return true
        end
        if Setting("SuperNova") and Spell.SuperNova:Cast(Target) then
            return true
        end
        if not Player.Moving and Setting("ArcaneMissiles")  and Buff.EnergySave:Exist(Player) and Spell.ArcaneMissiles:Cast(Target) then
            return true
        end
        if Setting("ArcaneExplosion") and Target.HP < 35 and Buff.EnergySave:Exist(Player) and Spell.ArcaneExplosion:Cast(Player) then
            return  true
        end
        if Setting("ArcaneBarrage") and ((Spell.ArcaneOrb:IsReady() and Charges >= 1 ) or Charges == 4) and Spell.ArcaneBarrage:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Setting("ArcaneOrb") and Spell.ArcaneOrb:Cast(Target) then
            return true
        end
        if Setting("PresenceofMind") and Spell.PresenceofMind:Cast(Player) then
            return true
        end

        if Setting("ArcaneExplosion") and EnemyCount >= Setting("ArcaneExplosionUnits") and Spell.ArcaneExplosion:Cast(Player) then
            return true
        end
        if not Player.Moving and Setting("ArcaneBlast") and Spell.ArcaneBlast:Cast(Target) then
            return true
        end
        if not Player.Moving and Setting("ArcaneMissiles") and Target.Distance < 40  and Spell.ArcaneMissiles:Cast(Target) then
            return true
        end
        if Setting("ArcaneBarrage") and Target.Distance < 40 and Spell.ArcaneBarrage:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    if Setting("ArcaneIntellect") and not Buff.ArcaneIntellect:Exist(Player) and Spell.ArcaneIntellect:Cast(Player) then
        return true
    end
    if Setting("ArcaneFamiliar") and not Buff.ArcaneFamiliar:Exist(Player) and Spell.ArcaneFamiliar:Cast(Player) then
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
    if Setting("PrismaticBarrier") and Player.HP <= Setting("PrismaticBarrierHP") and Spell.PrismaticBarrier:Cast(Player) then
        return true
    end
    if Setting("Evocation") and Player.PowerPct <= Setting("EvocationPct") and Spell.Evocation:Cast(Player) then
        return true
    end
end
local function Dispel()
    for _, Friend in ipairs(Friends40Y) do
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end
function Mage.Arcane()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if   Dispel() then
            return true
        end
        Player:AutoTarget(40, true)
        if Defensive() then
            return true
        end
        if DPS() then
            return true
        end
    end
end
