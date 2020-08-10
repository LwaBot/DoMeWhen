local DMW = DMW
local Rogue = DMW.Rotations.ROGUE
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player8Y, Player8YC, Friends40Y, Friends40YC, Stealth
local UI = DMW.UI
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local bonesCount = 0
local bonesBuff = false

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
        }

        UI.AddHeader("DPS")
        UI.AddDropdown("Auto Tricks", "Select Tricks of the Trade Option", {"Disabled", "Tank", "Focus"}, 2)
        UI.AddToggle("GhostlyStrike", nil, true)
        UI.AddToggle("MarkedForDeath", nil, true)
        UI.AddRange("RageReserve", nil, 1, 100, 1, 50)
        UI.AddToggle("BladeFlurry", nil, true)
        UI.AddRange("BladeFlurryUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("AdrenalingRush", nil, true)
        UI.AddRange("AdrenalingRushUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("GraplingHook", nil, true)
        UI.AddRange("NearDeathHP", nil, 1, 100, 1, 70)
        UI.AddToggle("SP1", nil, true)
        UI.AddToggle("SP2", nil, true)

        UI.AddHeader("Defensive")
        UI.AddDropdown("Auto Stealth", nil, {"Disabled", "Always", "20 Yards"}, 2)
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("CloakOfShadows", nil, true)
        UI.AddRange("CloakOfShadowsHP", nil, 1, 100, 1, 50)
        UI.AddToggle("CrimsonVial", nil, true)
        UI.AddRange("CrimsonVialHP", nil, 1, 100, 1, 70)
        UI.AddToggle("Sprint", nil, true)
        UI.AddRange("SprintHP", nil, 1, 100, 1, 70)
        UI.AddToggle("Riposte", nil, true)
        UI.AddRange("RiposteHP", nil, 1, 100, 1, 30)
    end
end

local function bonesInit()
    bonesCount = 0
    bonesBuff = false
    if Buff.RuthlessPrecison:Exist(Player) then
        bonesBuff = true
        bonesCount = bonesCount + 1
    end
    if Buff.Broadside:Exist(Player) then
        bonesBuff = true
        bonesCount = bonesCount + 1
    end
    if Buff.TrueBearing:Exist(Player) then
        bonesBuff = true
        bonesCount = bonesCount + 1
    end
    if Buff.SkullAndCrossbones:Exist(Player) then
        bonesBuff = true
        bonesCount = bonesCount + 1
    end
    if Buff.GrandMelee:Exist(Player) then
        bonesBuff = true
        bonesCount = bonesCount + 1
    end
    if Buff.BuriedTreasure:Exist(Player) then
        bonesBuff = true
        bonesCount = bonesCount + 1
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
    Stealth = Rogue.Stealth()
    GCD = Player:GCD()
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs() and Target and Target.TTD > 5 and Target.Distance < 5
    Friends40Y, Friends40YC = Player:GetFriends(40)
    Player8Y, Player8YC = Player:GetEnemies(8)
    bonesInit()
end

local function OOC()
    if Setting("Auto Stealth") ~= 1 and Spell.Stealth:Cast(Player) then
    return true
    end
end

local function Interrupt()
    if HUD.Interrupts == 1 then
        if Target and Target.ValidEnemy and Target:Interrupt() and not Target.Dead then

            if Spell.Kick:Cast(Target) then
                return true
            end
            if Spell.BetweenTheEyes:Cast(Target) then
                return true
            end
        end
        if Player8YC > 0 then
            for _, Unit in pairs(Player8Y) do
                if Unit:Interrupt() then
                    if Spell.Kick:IsReady() and Spell.Kick:Cast(Unit) then
                        return true
                    end
                    if Spell.BetweenTheEyes:IsReady() and Spell.BetweenTheEyes:Cast(Unit) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function DPS()
    if Target and not Target.Dead and (Target.ValidEnemy or Target.Attackable) then

        if Setting("GraplingHook") and Target.Distance > 15 and Player.Combat and Target.Distance <= 40 and Spell.GraplingHook:Cast(Target) then
            return true
        end
        print(CDs,Player8YC)
        if CDs and Setting("AdrenalingRush") and Player.Combat  and ((Buff.BladeFlurry:Remain(Player) > 6 and Player8YC >= Setting("AdrenalingRushUnits")) or Player8YC == 1) and Spell.AdrenalingRush:Cast(Player) then
            return true
        end
        if CDs and Player.Combat and (Buff.BladeFlurry:Remain(Player) > 6) and Spell.BladeRush:Cast(Target) then
            return true
        end
        if CDs and Player.Combat and (Buff.BladeFlurry:Remain(Player) > 6 ) and Spell.KillingSpree:Cast(Target) then
            return true
        end
        if Player.Combat and Spell.Shiv:Cast(Target) then
            return true
        end
        if Player.Combat and Player.ComboPoints >= 5 and Spell.DeathFromAbove:Cast(Target) then
            return true
        end
        if Player.Combat and Spell.Dismantle:Cast(Target) then
            return true
        end
        if Player.Combat and Spell.PlunderArmor:Cast(Target) then
            return true
        end
        if Player.Combat and Target.Distance < 5 and Spell.SmokeBomb:Cast(Target) then
            return true
        end
     --单骰子
        --aoe
        if bonesCount == 1 and Player8YC >= Setting("BladeFlurryUnits") and Player.ComboPoints >= 4
                and not (Buff.RuthlessPrecison:Remain(Player) > 1 or Buff.TrueBearing:Remain(Player) > 1 or Buff.Broadside:Remain(Player) > 1)
                and not Buff.BladeFlurry:Exist(Player)
                and Player.ComboPoints >= 3 and Spell.RollTheBones:Cast(Player) then
            return true
        end
        --单体
        if bonesCount < 2 and Player8YC < Setting("BladeFlurryUnits") and not (Buff.RuthlessPrecison:Remain(Player) > 1 or Buff.TrueBearing:Remain(Player) > 1 and Buff.SkullAndCrossbones:Remain(Player) > 1 or Buff.Broadside:Remain(Player) > 1)
                and Player.ComboPoints >= 3 and Spell.RollTheBones:Cast(Player) then
            return true
        end
        --双骰子
        if bonesCount == 2 and (Buff.BuriedTreasure:Exist(Player) and Buff.TrueBearing:Exist(Player)) and not Buff.BladeFlurry:Exist(Player)
                and Player.ComboPoints >= 3 and Spell.RollTheBones:Cast(Player) then
            return true
        end
        if Buff.BladeFlurry:Remain(Player) >= 6 and not bonesBuff and Player.ComboPoints >= 3 and Spell.RollTheBones:Cast(Player) then
            return true
        end
        if Setting("BladeFlurry") and Player.Combat and Player8YC >= Setting("BladeFlurryUnits") and (Buff.BladeFlurry:Remain(Player) < 2) and Player.Power >= 30 and Spell.BladeFlurry:Cast(Player) then
            return true
        end

        if Rogue.Stealth() and Spell.CheapShot:Cast(Target) then
            return true
        end
        if Player.ComboPoints >= 5 and Spell.BetweenTheEyes:Cast(Target) then
            return true
        end
        if Player.ComboPoints >= 4 and Spell.BetweenTheEyes:CD() > 2 and Spell.Dispatch:Cast(Target) then
            return true
        end

        if Setting("GhostlyStrike") and Player.Combat and Spell.GhostlyStrike:Cast(Target) then
            return true
        end
        if Setting("MarkedForDeath") and Player.Combat and Spell.MarkedForDeath:Cast(Target) then
            return true
        end
        for _,Unit in ipairs(Player8Y) do
            if (Unit.HP < 20 or  Buff.BladeFlurry:Exist(Player)) and Player.Combat and Target.Distance < 6 and Spell.NearDeath:Cast(Unit) then
                return true
            end
        end
        if Player.Combat and Buff.BladeFlurry:Exist(Player) and Target.Distance < 40 and (Target.HP > 80 or Target.HP < Setting("NearDeathHP")) and Spell.NearDeath:Cast(Target) then
            return true
        end
        --火红烈焰
        if Player.Combat and Target.Distance < 40 and Spell.ConcentratedFlame:Cast(Target) then
            return true
        end
        if Buff.Opportunity:Exist(Player) and (Buff.Deadshot:Exist(Player) or Spell.BetweenTheEyes:CD() > 2) and Spell.PistolShot:Cast(Target) then
            return true
        end
        local sp1Begin, sp1Duration, sp1Enable = GetInventoryItemCooldown("player", 13)
        local sp2Begin, sp2Duration, sp2Enable = GetInventoryItemCooldown("player", 14)
        if Setting("SP1") and Player.Combat and Target.Distance < 4 and sp1Enable and sp1Begin == 0 then
            UseInventoryItem(13)
            return true
        end
        if Setting("SP2") and Target.Distance < 6 and Player.Combat and sp2Enable and sp2Begin == 0 then
            UseInventoryItem(14)
            return true
        end
        if Spell.SinisterStrike:Cast(Target) then
            return true
        end
    end
end
local function Tricks()
    if Setting("Auto Tricks") == 2 then
        if DMW.Friends.Tanks[1] and Target.Distance < 5 and UnitThreatSituation("player") and UnitThreatSituation("player") >= 2 then
            Spell.TricksOfTheTrade:Cast(DMW.Friends.Tanks[1])
        end
    elseif Setting("Auto Tricks") == 3 then
        if Player.Focus and Target.Distance < 5 and UnitThreatSituation("player") and UnitThreatSituation("player") >= 2 then
            Spell.TricksOfTheTrade:Cast(Player.Focus)
        end
    end
end
local function Defensive()
    if Player.Moving and Spell.Sprint:Cast(Player) then
        return true
    end
    if Setting("Riposte") and Player.Combat and Player.HP <= Setting("RiposteHP") and Spell.Riposte:Cast(Player) then
        return true
    end
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Setting("Sprint") and Player.Combat and Player.HP <= Setting("SprintHP") and Spell.Sprint:Cast(Player) then
        return true
    end
    if Setting("CloakOfShadows") and Player.Combat and Player.HP <= Setting("CloakOfShadowsHP") and Spell.CloakOfShadows:Cast(Player) then
        return true
    end
    if Setting("CrimsonVial") and Player.HP <= Setting("CrimsonVialHP") and Spell.CrimsonVial:Cast(Player) then
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
function Rogue.Outlaw()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if not Player.Combat and not Spell.Vanish:LastCast() then
            OOC()
        end
        if not Stealth and Player.Combat then
            Player:AutoTarget(5)
        end
        if Dispel() then
            return true
        end
        if Defensive() then
            return true
        end
        if Target and not Target.Dead and (Target.ValidEnemy  or Target.Attackable) then
            Target:Update()
            if not Stealth and Interrupt() then
                return true
            end
            Tricks()
            if Spell.GCD:CD() == 0 then
                if Target.Distance < 5 and Player.Combat and not IsCurrentSpell(6603) and not Stealth then
                    StartAttack(Target.Pointer)
                end
                if DPS() then
                    return true
                end
            end
        end
    end
end
