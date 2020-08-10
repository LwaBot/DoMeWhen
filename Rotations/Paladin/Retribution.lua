local DMW = DMW
local Paladin = DMW.Rotations.PALADIN
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC
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
            }
        }

        UI.AddHeader("Healing")

        UI.AddRange("SelfHP", nil, 1, 100, 1, 60)

        UI.AddToggle("GreaterBlessingOfWisdom", nil, true)
        UI.AddToggle("GreaterBlessingOfKings", nil, true)
        UI.AddToggle("FlashOfLight", nil, true)
        UI.AddRange("FlashOfLightHP", nil, 0, 100, 1, 50)
        --清毒术
        UI.AddToggle("CleanseToxins", nil, true)
        UI.AddToggle("LayOnHands", nil, true)
        UI.AddToggle("LayOnHandsHP", nil, 1, 100, 1, 30)
        UI.AddToggle("BlessingOfProtection", nil, true)
        UI.AddRange("BlessingOfProtectionHP", nil, 1, 100, 1, 30)
        --圣盾术
        UI.AddToggle("DivineShield", nil, true)
        UI.AddRange("DivineShieldHP", nil, 1, 100, 1, 30)
        UI.AddToggle("ShieldOfVengeance", nil, true)
        UI.AddRange("ShieldOfVengeanceHP", nil, 1, 100, 1, 60)
        UI.AddToggle("SP1", nil, true)
        UI.AddRange("SP1Range", nil, 1, 100, 1, 60)
        UI.AddToggle("SP2", nil, true)
        UI.AddRange("SP2Range", nil, 1, 100, 1, 30)

        UI.AddHeader("DPS")

        UI.AddToggle("HammerOfJustice", nil, true)
        UI.AddToggle("BladeOfJustice", nil, true)
        UI.AddToggle("CrusaderStrike", nil, true)
        UI.AddToggle("TemplarVerdict", nil, true)
        UI.AddToggle("HandOfHindrance", nil, true)
        UI.AddToggle("Judgment", nil, true)
        UI.AddToggle("Crusade", nil, true)
        UI.AddToggle("WakeOfAshes", nil, true)
        UI.AddRange("WakeOfAshesUnits", nil, 1, 10, 1, 3)
        --神圣风暴
        UI.AddToggle("DivineStorm", nil, true)
        UI.AddRange("DivineStormUnits", nil, 1, 10, 1, 3)

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
        if HUD.Dispel == 1 and Spell.CleanseToxins:IsReady() and
                Friend:Dispel(Spell.CleanseToxins) and Spell.CleanseToxins:Cast(Friend) then
            return true
        end
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end
local function Heal(Unit)
    --饰品1
    if not Player.Moving and Setting("FlashOfLight")  and Unit.HP <= Setting("FlashOfLightHP") and Spell.FlashOfLight:Cast(Unit) then
        return true
    end
end

local function DPS()

    if Target and not Target.Dead and (Target.ValidEnemy or Target.Attackable)  then
        --打断
        if Target.Distance <= 10 and Target:Interrupt() and HUD.Interrupts == 1 and Spell.HammerOfJustice:Cast(Target) then
            return true
        end
        if  Target.Distance <= 6  and Target:Interrupt() and HUD.Interrupts == 1 and Spell.Rebuke:Cast(Target) then
            return true
        end
        if Setting("HandOfHindrance") and Spell.HandOfHindrance:Cast(Target) then
            return true
        end
        if Setting("Crusade") and Spell.Crusade:Cast(Target) then
            return true
        end
        local EnemyUnits, EnemyCount = Player:GetEnemies(12)
        if Setting("WakeOfAshes") and EnemyCount >= Setting("WakeOfAshesUnits") and Spell.WakeOfAshes:Cast(Target) then
            return true
        end
        if Setting("DivineStorm") and HUD.Mode == 1 and EnemyCount >= Setting("DivineStormUnits") and Spell.DivineStorm:Cast(Target) then
            return true
        end
        if Setting("TemplarVerdict") and HUD.Mode == 2 and Spell.TemplarVerdict:Cast(Target) then
            return true
        end
        if Setting("Judgment") and Spell.Judgment:Cast(Target) then
            return true
        end
        if Setting("BladeOfJustice") and Spell.BladeOfJustice:Cast(Target) then
             return true
        end
        if Setting("CrusaderStrike") and Spell.CrusaderStrike:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    if Setting("GreaterBlessingOfWisdom") and not Buff.GreaterBlessingOfWisdom:Exist(Player) and Spell.GreaterBlessingOfWisdom:Cast(Player) then
        return true
    end
    if Setting("GreaterBlessingOfKings") and not Buff.GreaterBlessingOfKings:Exist(Player) and Spell.GreaterBlessingOfKings:Cast(Player) then
        return true
    end
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Setting("LayOnHands") and Player.HP <= Setting("LayOnHandsHP") and Spell.LayOnHands:Cast(Player) then
        return true
    end
    if Setting("BlessingOfProtection") and Player.HP <= Setting("BlessingOfProtectionHP") and Spell.BlessingOfProtection:Cast(Player) then
        return true
    end
    if Setting("DivineShield") and Player.HP <= Setting("DivineShieldHP") and Spell.DivineShield:Cast(Player) then
        return true
    end
    if Setting("ShieldOfVengeance") and Player.HP <= Setting("ShieldOfVengeanceHP") and Spell.ShieldOfVengeance:Cast(Player) then
        return true
    end
end

function Paladin.Retribution()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if Defensive() then
            return true
        end
        if  Dispel() then
            return true
        end
        if Player.HP <= Setting("SelfHP") and Heal(Player) then
            return true
        end
        Player:AutoTarget(40, true)
        if Target and Target.Distance < 5 and Player.Combat and not IsCurrentSpell(6603) then
            StartAttack(Target.Pointer)
        end
        if  DPS() then
            return true
        end
    end
end
