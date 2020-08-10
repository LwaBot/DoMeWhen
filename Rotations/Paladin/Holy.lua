local DMW = DMW
local Paladin = DMW.Rotations.PALADIN
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, HUD, Player5Y, Player5YC, Player10Y, Player10YC
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
            },
            [5] = {
                Attack = {
                    [1] = { Text = "Attack |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Attack |cffff0000Disabled", Tooltip = "" }
                }
            },
            [6] = {
                Print = {
                    [1] = { Text = "Print |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Print |cffff0000Disabled", Tooltip = "" }
                }
            }

        }

        UI.AddHeader("Healing")

        UI.AddToggle("AvengingWrath", nil, true)
        UI.AddRange("AvengingWrathHP", nil, 1, 100, 1, 60)
        UI.AddRange("AvengingWrathUnits", nil, 1, 40, 1, 3)

        UI.AddToggle("AuraMastery", nil, true)
        UI.AddRange("AuraMasteryHP", nil, 1, 100, 1, 60)
        UI.AddRange("AuraMasteryUnits", nil, 1, 40, 1, 3)

        UI.AddRange("SelfHP", nil, 1, 100, 1, 60)

        UI.AddToggle("LayOnHands", nil, true)
        UI.AddRange("LayOnHandsHP", nil, 1, 100, 1, 30)

        UI.AddToggle("HolyShock", nil, true)
        UI.AddRange("HolyShockHP", nil, 1, 100, 1, 60)

        UI.AddToggle("LightOfDawn", nil, true)
        UI.AddRange("LightOfDawnHP", nil, 1, 100, 1, 80)
        UI.AddRange("LightOfDawnUnits", nil, 1, 10, 1, 3)

        UI.AddToggle("HolyLight", nil, true)
        UI.AddRange("HolyLightHP", nil, 1, 100, 1, 85)

        UI.AddToggle("FlashOfLight", nil, true)
        UI.AddRange("FlashOfLightHP", nil, 1, 100, 1, 80)

        --赋予信仰
        UI.AddToggle("BestowFaith", nil, true)
        UI.AddRange("BestowFaithHP", nil, 1, 100, 1, 50)

        --殉道者
        UI.AddToggle("LightOftheMartyr", nil, true)
        UI.AddRange("LightOftheMartyrHP", nil, 1, 100, 1, 40)
        UI.AddRange("LightOftheMartyrSelfHP", nil, 1, 100, 1, 70)

        UI.AddToggle("BlessingOfSacrifice", nil, true)
        UI.AddRange("BlessingOfSacrificeHP", nil, 1, 100, 1, 20)
        UI.AddRange("BlessingOfSacrificeSelfHP", nil, 1, 100, 1, 60)

        UI.AddToggle("BlessingOfProtection", "保护祝福", true)
        UI.AddRange("BlessingOfProtectionHP", nil, 1, 100, 1, 40)

        UI.AddRange("DivineProtectionHP", nil, 1, 100, 1, 50)

        UI.AddHeader("Defensive")
        UI.AddToggle("Healthstone", "Use Healthstone", true)
        UI.AddRange("Healthstone HP", "HP to use Healthstone", 0, 100, 1, 60)
        UI.AddToggle("BeaconOfFaith", nil, true)
        UI.AddRange("BeaconOfFaithHP", nil, 1, 100, 1, 70)
        UI.AddToggle("BeaconOfLight", nil, true)
        UI.AddRange("BeaconOfLightHP", nil, 1, 100, 1, 80)

        UI.AddToggle("DivineShield", nil, true)
        UI.AddRange("DivineShieldHP", nil, 1, 100, 1, 20)

        UI.AddToggle("HolyAvenger", nil, true)
        UI.AddRange("HolyAvengerHP", nil, 1, 100, 1, 70)
        UI.AddRange("HolyAvengerUnits", nil, 1, 10, 1, 3)

        UI.AddToggle("BeaconOfVirtue", nil, true)
        UI.AddRange("BeaconOfVirtueHP", nil, 1, 100, 1, 80)

        UI.AddHeader("DPS")
        UI.AddToggle("Attack", nil, false)
        UI.AddToggle("Consecration", "Use Consecration", true)
        UI.AddToggle("Judgment", nil, true)
        UI.AddToggle("HammerOfJustice", nil, true)
        UI.AddToggle("CrusaderStrike", nil, true)

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
    Player5Y, Player5YC = Player:GetEnemies(5)
    Player10Y, Player10YC = Player:GetEnemies(10)
end

local function Heal()

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

    if Setting("AvengingWrath") and Spell.AvengingWrath:IsReady() then
        local AWUnits, AWCount = Player:GetFriends(40, Setting("AvengingWrathHP"))
        if AWCount >= Setting("AvengingWrathUnits") then
            if Spell.AvengingWrath:Cast(Player) then
                return true
            end
        end
    end

    if Setting("AuraMastery") and Spell.AuraMastery:IsReady() then
        local AMUnits, AMCount = Player:GetFriends(40, Setting("AuraMasteryHP"))
        if AMCount >= Setting("AuraMasteryUnits") then
            if Spell.AuraMastery:Cast(Player) then
                return true
            end
        end
    end

    if Setting("HolyAvenger") and Spell.HolyAvenger:IsReady() then
        local AMUnits, HACount = Player:GetFriends(40, Setting("HolyAvengerHP"))
        if HACount >= Setting("HolyAvengerUnits") then
            if Spell.HolyAvenger:Cast(Player) then
                return true
            end
        end
    end

    if Setting("LightOfDawn") then
        if Spell.LightOfDawn:IsReady() then
            local RaptureUnits, EFCount = Player:GetFriends(40, Setting("LightOfDawnHP"))
            if EFCount and EFCount >= Setting("LightOfDawnUnits") then
                if Spell.LightOfDawn:Cast(Player) then
                    return true
                end
            end
        end
    end
    for _, Unit in ipairs(Friends40Y) do
        if Setting("BlessingOfProtection") and Unit.HP <= Setting("BlessingOfProtectionHP") and Player.Combat and Spell.BlessingOfProtection:Cast(Unit) then
            return true
        end
        if Player.Combat and Setting("LayOnHands") and Unit.HP <= Setting("LayOnHandsHP") and
                Spell.LayOnHands:Cast(Unit) then
            return true
        end
        if Setting("HolyShock") and Unit.HP < Setting("HolyShockHP") and Spell.HolyShock:Cast(Unit) then
            return true
        end
        if Setting("BestowFaith") and Unit.HP <= Setting("BestowFaithHP") and Spell.BestowFaith:Cast(Unit) then
            return true
        end
        --pvp天赋
        --神恩术
        if Talent.DivineFavor.Active and Spell.DivineFavor:IsReady() and Spell.DivineFavor:Cast(Player) then
            return true
        end
        if Buff.InfusionOfLight:Exist(Player) and not Player.Moving and Setting("HolyLight") and Unit.HP <= Setting("HolyLightHP") and Spell.HolyLight:Cast(Unit) then
            return true
        end
        if Setting("LightOftheMartyr") and Unit.HP <= Setting("LightOftheMartyrHP") and Player.HP >= Setting("LightOftheMartyrSelfHP") and
                Spell.LightOftheMartyr:Cast(Unit) then
            return true
        end
        if Setting("BlessingOfSacrifice") and Unit.HP <= Setting("BlessingOfSacrificeHP") and Player.HP >= Setting("BlessingOfSacrificeSelfHP") and
                Spell.BlessingOfSacrifice:Cast(Unit) then
            return true
        end
        --救赎之魂
        if not Player.Moving and Setting("SpiritSalvation") and Unit.HP < Setting("SpiritSalvationRange") and Spell.SpiritSalvation:Cast(Unit) then
            return true
        end
        if Unit.HP <= Setting("FlashOfLightHP") and Spell.ConcentratedFlame:Cast(Unit) then
            return true
        end
        if not Player.Moving and Setting("HolyLight") and Unit.HP <= Setting("HolyLightHP") and Spell.HolyLight:Cast(Unit) then
            return true
        end
        if not Player.Moving and Setting("FlashOfLight") and Unit.HP <= Setting("FlashOfLightHP") and Spell.FlashOfLight:Cast(Unit) then
            return true
        end

    end

end

local function Interrupt()
    if HUD.Interrupts == 1 then
        local Player8Y, Player8YC = Player:GetEnemies(10)
        if Player8YC > 0 then
            for _, Unit in pairs(Player8Y) do
                if Unit:Interrupt() then
                    if Spell.HammerOfJustice:IsReady() and Spell.HammerOfJustice:Cast(Unit) then
                        return true
                    end
                    if Spell.BlindingLight:IsReady() and Spell.BlindingLight:Cast(Player) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function DPS()
    if Target and Target.ValidEnemy and not Target.Dead then
        if not Player.Moving and Player5YC > 0 and (Paladin.ConsDistance() > 5 or Paladin.ConsRemain() < 2) then
            if Spell.Consecration:Cast(Player) then
                return true
            end
        end
        if Setting("Judgment") and Target.Distance <= 30 and Spell.Judgment:Cast(Target) then
            return true
        end
        if Setting("CrusaderStrike") and Target.Distance <= 6 and Spell.CrusaderStrike:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Player.HP <= Setting("DivineProtectionHP") and Player.Combat and Spell.DivineProtection:Cast(Player) then
        return true
    end
    if Setting("DivineShield") and Player.HP <= Setting("DivineShieldHP") and not Debuff.Forbearance:Exist(Player) and Spell.DivineShield:Cast(Player) then
        return true
    end

    local faith = Buff.BeaconOfFaith:Count(DMW.Friends.Tanks) > 0
    local light = Buff.BeaconOfLight:Count(DMW.Friends.Tanks) > 0
    for _, Tank in ipairs(DMW.Friends.Tanks) do
        if Player.Combat and Setting("BeaconOfVirtue") and Tank.HP <= Setting("BeaconOfVirtueHP") and Spell.BeaconOfVirtue:IsReady() and Spell.BeaconOfVirtue:Cast(Tank) then
            return true
        end
        if Setting("BeaconOfLight") and not light and not Buff.BeaconOfFaith:Exist(Tank) and not Buff.BeaconOfLight:Exist(Tank) and Spell.BeaconOfLight:Cast(Tank) then
            return true
        end
        if Setting("BeaconOfFaith") and not faith and Buff.BeaconOfLight:Remain(Tank) < 1 and Buff.BeaconOfFaith:Remain(Tank) < 1 and Spell.BeaconOfFaith:Cast(Tank) then
            return true
        end
    end
    for _, Unit in ipairs(Friends40Y) do
        if Player.Combat and Setting("BeaconOfVirtue") and Unit.HP <= Setting("BeaconOfVirtueHP") and Spell.BeaconOfVirtue:IsReady() and Spell.BeaconOfVirtue:Cast(Unit) then
            return true
        end
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
        if Spell.Cleanse:IsReady() and Friend:Dispel(Spell.Cleanse) and Spell.Cleanse:Cast(Friend) then
            return true
        end
    end
end

function Paladin.Holy()
    Locals()
    CreateSettings()
    if Rotation.Active() and Spell.GCD:CD() == 0 then
        if HUD.Print == 1 then
            Player:printTalentsInfo()
        end
        if Defensive() then
            return true
        end
        if Dispel() then
            return true
        end
        if Heal() then
            return true
        end
        if  Interrupt() then
            return true
        end
        if HUD.Attack ~= 1 then
            return false
        end
        Player:AutoTarget(8, true)
        if Target and Target.ValidEnemy and Target.Distance < 5 and Player.Combat and not IsCurrentSpell(6603) then
            StartAttack(Target.Pointer)
        end
        if  DPS() then
            return true
        end
    end
end
