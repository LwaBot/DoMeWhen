local DMW = DMW
local DeathKnight = DMW.Rotations.DEATHKNIGHT
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC, Friends8Y, Friends8YC, Player10Y, Player10YC
local UI = DMW.UI
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Charges

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

        UI.AddHeader("DPS")

        UI.AddToggle("Blooddrinker", nil, true)
        UI.AddToggle("Consumption", nil, true)
        UI.AddRange("ConsumptionHP", nil, 1, 100, 1, 90)
        UI.AddToggle("GorefiendGrap", nil, true)

        UI.AddToggle("DarkCommand", nil, true)

        UI.AddToggle("DancingRuneWeapon", nil, true)
        UI.AddRange("DancingRuneWeaponHP", nil, 1, 100, 1, 70)
        UI.AddRange("DancingRuneWeaponUnits", nil, 1, 10, 1, 3)

        UI.AddToggle("DeathStrike", nil, true)
        UI.AddRange("DeathStrikeHP", nil, 1, 100, 1, 75)

        UI.AddRange("BonestormPowerPct", nil, 1, 100, 1, 50)

        UI.AddRange("HeartStrikeCharges", nil, 1,6, 1, 4)
        UI.AddHeader("Defensive")

        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)

        UI.AddToggle("Tombstone", nil, true)
        UI.AddRange("TombstoneHP", nil, 1, 100, 1, 80)

        UI.AddToggle("RuenTap", nil, true)
        UI.AddRange("RuenTapHP", nil, 1, 100, 1, 80)

        UI.AddToggle("IceboundFortitude", nil, true)
        UI.AddRange("IceboundFortitudeHP", nil, 0, 100, 1, 60)

        UI.AddToggle("AntiMagicShell", nil, true)
        UI.AddRange("AntiMagicShellHP", nil, 0, 100, 1, 50)

        UI.AddToggle("VampiricBlood", nil, true)
        UI.AddRange("VampiricBloodHP", nil, 0, 100, 1, 55)
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
    Friends8Y, Friends8YC = Player:GetFriends(10)
    Player10Y, Player10YC = Player:GetEnemies(10)
    Player40Y, Player40YC = Player:GetEnemies(40)
    Charges = Player.ComboPoints
end

local function Interrupt()
    if HUD.Interrupts == 1 then

        for _, Unit in pairs(Player10Y) do
            if Unit:Interrupt() then
                if Spell.MindFreeze:Cast(Unit) then
                    return true
                end
                if Spell.DeathGrip:Cast(Unit) then
                    return true
                end
                if Spell.Asphyxiate:Cast(Unit) then
                    return true
                end
            end
        end
    end
    return false
end

local function DPS()

    if Setting("DarkCommand") then
        for _,Unit in ipairs(Player40Y) do
            if Unit.Distance < 30 and Unit.Target ~= nil and Unit.Target ~= Player.Pointer and Spell.DarkCommand:Cast(Unit) then
                return true
            end
        end
    end
    if Target and not Target.Dead and (Target.ValidEnemy or Target.Attackable) then
        if Target.Distance < 8 and Player.HP <= Setting("ConsumptionHP") and Spell.Consumption:Cast(Target) then
            return true
        end
        if Target.Distance > 8 and not Target:IsBoss() and Spell.DeathGrip:Cast(Target) then
            return true
        end
        if Setting("GorefiendGrap") and not Target:IsBoss() and Target.Distance > 8 and Spell.GorefiendGrap:Cast(Target) then
            return true
        end
        if Setting("DeathStrike") and (Player.HP <= Setting("DeathStrikeHP") or Player.PowerPct > 90) and Player.Combat and Spell.DeathStrike:Cast(Target) then
            return true
        end
        if Setting("DancingRuneWeapon") and Player.HP <= Setting("DancingRuneWeaponHP")  and Spell.DancingRuneWeapon:Cast(Target) then
            return true
        end
        if (Debuff.BloodIll:Count(Player40Y) == 0 or not Debuff.BloodIll:Exist(Target)) and Target.Distance < 10 and not Spell.BloodBoil:LastCast() and Spell.BloodBoil:Cast(Target)  then
            return true
        end
        if not Buff.Marrowrend:Exist(Player) and Spell.Marrowrend:Cast(Target) then
            return true
        end
        if not Debuff.DeathAndDecay:Exist(Target) and Target.Distance < 10 and Spell.DeathAndDecay:Cast(Target) then
            return true
        end

        if Player.PowerPct >= Setting("BonestormPowerPct") and Spell.Bonestorm:Cast(Target) then
            return true
        end
        if not Debuff.MarkOfBlood:Exist(Target) and Spell.MarkOfBlood:Cast(Target) then
            return true
        end
        if Player.Combat and Spell.NearDeath:Cast(Target) then
            return true
        end

        if Spell.ConcentratedFlame:Cast(Target) then
            return true
        end
        if Spell.Blooddrinker:Cast(Target) then
            return true
        end
        if Charges < 6 and Spell.RuneStrike:Cast(Target) then
            return true
        end
        if Charges >= Setting("HeartStrikeCharges") and Spell.HeartStrike:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end

    if Setting("IceboundFortitude") and Player.HP <= Setting("IceboundFortitudeHP")  and Spell.IceboundFortitude:Cast(Player) then
        return true
    end
    if Setting("AntiMagicShell") and Player.HP <= Setting("AntiMagicShellHP") and Player.Combat and Spell.AntiMagicShell:Cast(Player) then
        return true
    end
    if Setting("RuenTap") and Player.HP <= Setting("RuenTapHP") and not Buff.RuenTap:Exist(Player) and Spell.RuenTap:Cast(Player) then
        return true
    end
    if Setting("VampiricBlood") and Player.HP <= Setting("VampiricBloodHP") and Spell.VampiricBlood:Cast(Player) then
        return true
    end
    if Setting("Tombstone") and Player.HP <= Setting("TombstoneHP") and Spell.Tombstone:Cast(Player) then
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

function DeathKnight:Blood()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if Dispel() then
            return true
        end
        Player:AutoTarget(40, true)
        if Spell.GCD:CD() == 0 then
            if Defensive() then
                return true
            end
            if Interrupt() then
                return true
            end

            if Target and Target.ValidEnemy and Target.Distance < 5 and Player.Combat and not IsCurrentSpell(6603) then
                StartAttack(Target.Pointer)
            end
            if DPS() then
                return true
            end

        end
    end
end
