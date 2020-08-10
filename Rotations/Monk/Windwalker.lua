local DMW = DMW
local Monk = DMW.Rotations.MONK
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC, Player10Y, Player10YC
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

        UI.AddToggle("Vivify", nil, true)
        UI.AddRange("VivifyHP", nil, 0, 100, 1, 80)
        UI.AddToggle("Detox", nil, true)

        UI.AddToggle("SP1", nil, true)
        UI.AddRange("SP1Range", nil, 1, 100, 1, 60)
        UI.AddToggle("SP2", nil, true)
        UI.AddRange("SP2Range", nil, 1, 100, 1, 30)

        UI.AddHeader("DPS")

        UI.AddToggle("Attack", nil, false)
        UI.AddToggle("LegSweep", nil, true)
        UI.AddToggle("RisingSunKick", nil, true)
        UI.AddToggle("BlackoutKick", nil, true)
        UI.AddToggle("CracklingJadeLightning", nil, true)
        UI.AddToggle("TigerPalm", nil, true)
        UI.AddToggle("RingOfPeace", nil, true)
        UI.AddToggle("SpinningCraneKick", nil, true)
        UI.AddRange("SpinningCraneKickUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("FistOftheWhiteTiger", nil, true)
        UI.AddToggle("InvokeXuenTheWhiteTiger", nil, true)
        UI.AddRange("InvokeXuenTheWhiteTigerUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("ChiBurst", nil, true)
        UI.AddToggle("FlyingSerpentKick", nil, true)
        UI.AddToggle("TouchOfDeath", nil, true)
        UI.AddRange("TouchOfDeathHP", nil, 1, 100, 1, 30)
        UI.AddToggle("Disable", nil, true)
        UI.AddToggle("WhirlingDragonPunch", nil, true)
        UI.AddToggle("SpearHandStrike", nil, true)
        UI.AddToggle("FistsOfFury", nil, true)
        UI.AddToggle("StormEarthAndFire", nil, true)
        UI.AddHeader("Defensive")
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 40)
        UI.AddToggle("FortifyingBrew", nil, true)
        UI.AddRange("FortifyingBrewHP", nil, 0, 100, 1, 30)
        UI.AddToggle("Transcendence", nil, true)
        UI.AddRange("TranscendenceHP", nil, 1, 100, 1, 70)
        UI.AddToggle("GrappleWeapon", nil, true)
        UI.AddToggle("TouchOfKarma", nil, true)
        UI.AddRange("TouchOfKarmaHP", nil, 1, 100, 1, 70)
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
    Player10Y, Player10YC = Player:GetEnemies(10)
end

local function Dispel()
    for _, Friend in ipairs(Friends40Y) do
        --Dispel
        if HUD.Dispel == 1 and Spell.Detox:IsReady() and
                Friend:Dispel(Spell.Detox) and Spell.Detox:Cast(Friend) then
            return true
        end
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end

local function Heal()
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
    for _,Friend in ipairs(Player40Y) do
        if not Player.Moving and Player.HP <= Setting("VivifyHP") and Spell.Vivify:Cast(Friend) then
            return true
        end
    end
end

local function DPS()
    if Target and Target.ValidEnemy and not Target.Dead then
        if Setting("FlyingSerpentKick") and Target.Distance > 40 and Spell.FlyingSerpentKick:Cast(Target) then
            return true
        end
        --打断
        if Target.Distance <= 6 and Target:Interrupt() and Setting("SpearHandStrike") and Spell.SpearHandStrike:Cast(Target) then
            return true
        end
        if Target.Distance <= 6 and Target:Interrupt() and Setting("LegSweep") and Spell.LegSweep:Cast(Target) then
            return true
        end
        if Setting("GrappleWeapon") and Spell.GrappleWeapon:Cast(Target) then
            return true
        end
        if Setting("InvokeXuenTheWhiteTiger") and Player10YC >= Setting("InvokeXuenTheWhiteTigerUnits") and Spell.InvokeXuenTheWhiteTiger:Cast(Target) then
            return true
        end
        if Setting("Disable") and Target.Distance < 6 and Debuff.Disable:Remain(Target) < 1 and Spell.Disable:Cast(Target) then
            return true
        end

        if Setting("TouchOfDeath") and Target.Distance < 6 and Target.HP >= Setting("TouchOfDeathHP") and Spell.TouchOfDeath:Cast(Target) then
            return true
        end
        if Setting("TouchOfKarma") and Player.HP <= Setting("TouchOfKarmaHP") and Spell.TouchOfKarma:Cast(Target) then
            return true
        end
        if Setting("StormEarthAndFire") and Buff.StormEarthAndFire:Remain(Player) <= 0 and Spell.StormEarthAndFire:Cast(Target) then
            return true
        end
        if Setting("WhirlingDragonPunch") and Spell.WhirlingDragonPunch:Cast(Target) then
            return true
        end
        if Setting("FistsOfFury") and Spell.FistsOfFury:Cast(Target) then
            return true
        end
        if Setting("RisingSunKick") and Spell.RisingSunKick:Cast(Target) then
            return true
        end
        if Setting("ChiBurst") and Target.Distance < 40 and Spell.ChiBurst:Cast(Target) then
            return true
        end
        if Setting("SpinningCraneKick") and Player10YC >= Setting("SpinningCraneKickUnits") and Spell.SpinningCraneKick:Cast(Target) then
            return true
        end
        if Setting("BlackoutKick") and Spell.BlackoutKick:Cast(Target) then
            return true
        end
        if Setting("FistOftheWhiteTiger") and Spell.FistOftheWhiteTiger:Cast(Target) then
            return true
        end
        if Setting("TigerPalm") and Spell.TigerPalm:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Setting("FortifyingBrew") and Player.HP <= Setting("FortifyingBrewHP") and Spell.FortifyingBrew:Cast(Player) then
        return true
    end

    if Setting("Transcendence") and Player.Combat and Buff.Transcendence:Remain(Player) < 1 and Spell.Transcendence:Cast(Player) then
        return true
    end
    if Setting("Transcendence") and Buff.Transcendence:Remain(Player) > 0 and Player.HP <= Setting("TranscendenceHP") and Spell.Transfer:Cast(Player) then
        return true
    end
end

function Monk.Windwalker()

    Locals()
    CreateSettings()
    if Rotation.Active() then
        if Defensive() then
            return true
        end
        if Dispel() then
            return true
        end
        if Heal() then
            return true
        end
        Player:AutoTarget(40, true)
        if Setting("Attack") and Spell.GCD:CD() == 0  then
            if Target and Target.ValidEnemy and Target.Distance < 5 and Player.Combat and not IsCurrentSpell(6603) then
                StartAttack(Target.Pointer)
            end
            if DPS() then
                return true
            end
        end
    end
end
