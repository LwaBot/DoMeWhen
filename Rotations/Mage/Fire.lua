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
                Combustion = {
                    [1] = { Text = "Combustion |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Combustion |cffff0000Disabled", Tooltip = "" }
                }
            },
        }

        UI.AddHeader("DPkS")
        UI.AddToggle("TimeWrap", nil, true)
        UI.AddToggle("MirrorImage", nil, true)
        UI.AddToggle("BlastWave", nil, true)
        UI.AddToggle("Combustion", "燃烧", true)
        UI.AddToggle("DragonBreath", "龙息术", true)
        UI.AddToggle("PhonenixFlames", "不死鸟之焰", true)
        UI.AddToggle("Meteor", "流星", true)
        UI.AddToggle("LivingBomb", "活动炸弹", true)
        UI.AddToggle("GreaterPyroblast", "强效炎爆术", true)
        UI.AddToggle("Counterspell", nil, true)
        UI.AddToggle("FireBlast", nil, true)
        UI.AddToggle("Fireball", nil, true)
        UI.AddToggle("Scorch", nil, true)
        UI.AddToggle("Pyroblast", nil, true)
        UI.AddToggle("Flamestrike", nil, true)
        UI.AddToggle("RingofFrost", nil, true)

        UI.AddToggle("FrostNova", nil, true)
        UI.AddToggle("RuneofPower", nil, true)
        UI.AddHeader("Defensive")
        UI.AddToggle("ArcaneIntellect", nil, true)
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("IceBlock", nil, true)
        UI.AddRange("IceBlockHP", nil, 1, 100, 1, 50)
        UI.AddToggle("TemporalShield", nil, true)
        UI.AddRange("TemporalShieldHP", nil, 1, 100, 1, 70)
        UI.AddToggle("BlazingBarrier", nil, true)
        UI.AddRange("BlazingBarrierHP", nil, 1, 100, 1, 70)
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

local function Interrupt()
    if HUD.Interrupts ~= 1 then
        return true
    end
    if HUD.Interrupts == 1 then
        if Target and Target.ValidEnemy and not Target.Dead then
            --打断
            if Target.Distance <= 40 and Target:Interrupt() and Setting("Counterspell") and Spell.Counterspell:Cast(Target) then
                return true
            end
        end
        if Player40YC == 0 then
            return
        end
        for _, Unit in pairs(Player40Y) do
            if Unit:Interrupt() then
                if Target.Distance <= 40 and Spell.Counterspell:Cast(Target) then
                    return true
                end
            end
        end
    end
    return false
end

local function DPS()
    if Interrupt() then
        return true
    end
    if Target and not Target.Dead and (Target.ValidEnemy or Target.Attackable) then
        if HUD.Combustion == 1 and Player.Combat and Buff.FireCombo:Exist(Player) and Target.Distance < 40 and Spell.Combustion:Cast(Player) then
            return true
        end
        if Setting("Pyroblast") and Target.Distance < 40 and Buff.FireCombo:Exist(Player) and Spell.Pyroblast:Cast(Target) then
            return true
        end
        if not Buff.Combustion:Exist() and not Player.Moving and Player.HP > 20 then
            if Spell.FocusedAzeriteBeam:Cast(Target) then
                return true
            end
        end
        if Setting("RingofFrost") and not Player.Moving and Target.Distance < 40 and Spell.RingofFrost:Cast(Target) then
            return true
        end
        if Setting("BlastWave") and Target.Distance < 8 and Spell.BlastWave:IsReady() and Spell.BlastWave:Cast(Player) then
            return true
        end
        if Setting("FrostNova") and Target.Distance <= 12 and Spell.FrostNova:Cast(Player) then
            return true
        end
        if Setting("DragonBreath") and Target.Distance < 8 and Spell.DragonBreath:IsReady() and Spell.DragonBreath:Cast(Player) then
            return true
        end
        if Setting("TimeWrap") and Player.Combat and Spell.TimeWrap:Cast(Player) then
            return true
        end
        if Setting("RuneofPower") and not Player.Moving and Player.Combat and (DMW.Time - Spell.RuneofPower.LastCastTime) > 10 and Spell.RuneofPower:Cast(Player) then
            return true
        end
        if Setting("MirrorImage") and Player.Combat and Spell.MirrorImage:Cast(Player) then
            return true
        end
        if Target.Distance < 40 and (Target.HP > 80 or Target.HP < 20) and Spell.NearDeath:Cast(Target) then
            return true
        end

        if Setting("FireBlast") and Target.Distance < 40 and Spell.FireBlast:IsReady() and Spell.FireBlast:Cast(Target) then
            return true
        end
        if Setting("PhonenixFlames") and Target.Distance < 40 and Spell.PhonenixFlames:IsReady() and Spell.PhonenixFlames:Cast(Target) then
            return true
        end
        if Setting("Meteor") and Target.Distance < 40 and not Target.Moving and Spell.Meteor:Cast(Target) then
            return true
        end

        if Setting("Scorch") and Target.Distance < 40 and Player.Moving and Spell.Scorch:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Spell.ConcentratedFlame:Cast(Target) then
            return true
        end
        if Setting("GreaterPyroblast") and Target.Distance < 40 and Spell.GreaterPyroblast:Cast(Target) then
            return true
        end
        if HUD.Mode == 2 and Target.Distance < 40 and not Target.Moving and Spell.Flamestrike:Cast(Target) then
            return true
        end
        if Setting("Fireball") and not Buff.FireCombo:Exist(Player) and Target.Distance < 40 and Spell.Fireball:Cast(Target) then
            return true
        end
        if Setting("Pyroblast") and not Buff.FireCombo:Exist(Player) and Target.Distance < 40 and Spell.Pyroblast:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
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
    if Setting("BlazingBarrier") and Player.HP <= Setting("BlazingBarrierHP") and Spell.BlazingBarrier:Cast(Player) then
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

function Mage.Fire()
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
