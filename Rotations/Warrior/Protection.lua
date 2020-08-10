local DMW = DMW
local Warrior = DMW.Rotations.WARRIOR
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC,  Player8Y, Player8YC
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
                Taunt = {
                    [1] = { Text = "Taunt |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Taunt |cffff0000Disabled", Tooltip = "" }
                }
            },--Torment
        }

        UI.AddHeader("DPS")
        UI.AddToggle("Avatar", nil, true)
        UI.AddRange("RageReserve", nil, 1, 100, 1, 50)
        UI.AddRange("AvatarUnits", nil, 1, 10, 1, 4)
        UI.AddToggle("BerserkerRage", nil, true)
        UI.AddToggle("DemoralizingShout", nil, true)
        UI.AddToggle("Devastate", nil, true)

        UI.AddToggle("Intercept", nil, true)
        UI.AddToggle("HeroicLeap", nil, true)
        UI.AddToggle("IntimidatingShout", nil, true)
        UI.AddToggle("Revenge", nil, true)

        UI.AddToggle("ShieldSlam", nil, true)
        UI.AddToggle("Shockwave", nil, true)
        UI.AddToggle("SpellReflection", nil, true)
        UI.AddRange("SpellReflectionHP", nil, 1, 100, 1, 60)
        UI.AddToggle("Taunt", nil, true)
        UI.AddToggle("ThunderClap", nil, true)
        UI.AddToggle("VictoryRush", nil, true)
        UI.AddToggle("DragonRoar", nil, true)
        UI.AddToggle("Devastator", nil, true)
        UI.AddToggle("Ravager", nil, true)
        UI.AddToggle("Pummel", nil, true)
        UI.AddToggle("Ravager", nil, true)

        UI.AddHeader("Defensive")
        UI.AddToggle("Healthstone", nil, false)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("IgnorePain", nil, true)
        UI.AddRange("IgnorePainHP", nil, 1, 100, 1, 60)
        UI.AddToggle("ShieldBlock", nil, true)
        UI.AddRange("ShieldBlockHP", nil, 1, 100, 1, 70)
        UI.AddToggle("LastStand", nil, true)
        UI.AddRange("LastStandHP", nil, 1, 100, 1, 40)
        UI.AddToggle("ShieldWall", nil, true)
        UI.AddRange("ShieldWallHP", nil, 1, 100, 1, 30)
        UI.AddToggle("RallyingCry", nil, true)
        UI.AddRange("RallyingCryHP", nil, 1, 100, 1, 40)

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
    Player8Y, Player8YC = Player:GetEnemies(8)
end

local function Interrupt()
    if HUD.Interrupts == 1 then
            for _, Unit in pairs(Player8Y) do
                if Unit:Interrupt() then
                    if  Spell.StormBolt:Cast(Unit) then
                        return true
                    end
                    if  Spell.Pummel:Cast(Unit) then
                        return true
                    end
                    if  Spell.IntimidatingShout:Cast(Unit) then
                        return true
                    end
                    if  Spell.Shockwave:Cast(Unit) then
                        return true
                    end
                end
            end
    end
    return false
end

local function AttackUnit(Unit)
    if Unit.Distance < 8 and Spell.Shockwave:Cast(Unit) then
        return true
    end
    if Setting("DemoralizingShout") and not Debuff.DemoralizingShout:Exist(Unit) and Spell.DemoralizingShout:Cast(Unit) then
        return true
    end
    if Setting("Avatar") and (Player8YC >= Setting("AvatarUnits") or Unit:IsBoss()) and Spell.Avatar:Cast(Player) then
        return true
    end
    if Setting("Ravager") and Player8YC >= Setting("AvatarUnits") and Spell.Ravager:Cast(Unit) then
        return true
    end

    if Setting("ShieldSlam") and Spell.ShieldSlam:Cast(Unit) then
        return true
    end
    --30 4638
    if Setting("Revenge") and Player.PowerPct >= Setting("RageReserve") and Spell.Revenge:Cast(Unit) then
        return true
    end
    if Setting("Intercept") and not Unit:IsBoss() and Unit.Distance >= 8 and Unit.Distance <= 25 and Spell.Intercept:Cast(Unit) then
        return true
    end
    if Setting("HeroicLeap") and not Unit:IsBoss()   and Unit.Distance > 10 and Spell.HeroicLeap:Cast(Unit) then
        return true
    end
    if Setting("IntimidatingShout") and Unit.Distance <= 8 and Unit:Interrupt() and HUD.Interrupts == 1 and
            Spell.IntimidatingShout:Cast(Unit) then
        return true
    end
    if Player.Combat and Setting("BerserkerRage") and Spell.BerserkerRage:Cast(Player) then
        return true
    end
    --乘胜追击
    if Setting("VictoryRush") and Spell.VictoryRush:IsReady() and Spell.VictoryRush:Cast(Unit) then
        return true
    end
    if Player.Combat and Player8YC > 2 and Spell.AnimaOfDeath:Cast(Unit) then
        return true
    end
    if Setting("ThunderClap") and Player.Combat and Unit.Distance < 12 and Player8YC >= 1 and not Debuff.ThunderClap:Exist(Unit) and Spell.ThunderClap:Cast(Unit) then
        return true
    end


    if Setting("DragonRoar") and Unit.Distance < 13 and Spell.DragonRoar:Cast(Unit) then
        return true
    end

    if Player.Combat and Setting("FocusedAzeriteBeam") and not Player.Moving and Spell.FocusedAzeriteBeam:Cast(Unit) then
        return true
    end
    if Player.Combat and Unit.Distance < 40 and Spell.ConcentratedFlame:Cast(Unit) then
        return true
    end
    if Setting("Devastate") and Unit.Distance < 8 and Spell.Devastate:Cast(Unit) then
        return true
    end
    if Setting("HeroicThrow") and Spell.HeroicThrow:Cast(Unit) then
        return true
    end
end

local function DPS()
    if HUD.Taunt == 1 then
        for _,Unit in ipairs(Player40Y) do
            if Unit.Target ~= nil and Unit.Target ~= Player.Pointer then
                if Spell.Taunt:Cast(Unit) then
                    return true
                end
                if  Spell.StormBolt:Cast(Unit) then
                    return true
                end
                if Unit.Distance < 8 and  Spell.IntimidatingShout:Cast(Unit) then
                    return true
                end
            end
        end
    end

    for _,Unit in ipairs(Player40Y) do
        if Unit.HP > 0 and  ( Unit.Name:find("球") or Unit.Name:find("燃") or Unit.Name:find("爆")) then
           return AttackUnit(Unit)
        end
    end
    for _,Unit in ipairs(Player40Y) do
        if Unit.HP >0 then
            return  AttackUnit(Unit)
        end
    end
end

local function Defensive()
    if not Buff.BattleShout:Exist(Player) and Spell.BattleShout:Cast(Player) then
        return true
    end
    if Setting("IgnorePain") and Player.HP <= Setting("IgnorePainHP") and Spell.IgnorePain:Cast(Player) then
        return true
    end
    if Setting("SpellReflection") and Player.Combat and Player.HP <= Setting("SpellReflectionHP") and Spell.SpellReflection:Cast(Target) then
        return true
    end
    if Setting("ShieldWall") and Player.Combat and Player.HP <= Setting("ShieldWallHP") and Spell.ShieldWall:Cast(Player) then
        return true
    end
    if Setting("LastStand") and Player.Combat and Player.HP <= Setting("LastStandHP") and Spell.LastStand:Cast(Player) then
        return true
    end
    if Setting("ShieldBlock") and Player.Combat and Player.HP <= Setting("ShieldBlockHP") and Spell.ShieldBlock:Cast(Player) then
        return true
    end
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end

    if Setting("RallyingCry") and Player.HP <= Setting("RallyingCryHP") and Spell.RallyingCry:Cast(Player) then
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

function Warrior.Protection()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if Dispel() then
            return true
        end
        if Defensive() then
            return true
        end
        if Interrupt() then
            return true
        end
        Player:AutoTarget(40, true)
        if Target and Target.ValidEnemy and Target.Distance < 5 and Player.Combat and not IsCurrentSpell(6603) then
            StartAttack(Target.Pointer)
        end
        if Spell.GCD:CD() == 0 and DPS() then
            return true
        end
    end
end
