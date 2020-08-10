local DMW = DMW
local Shaman = DMW.Rotations.SHAMAN
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
            },
            [5] = {
                Attack = {
                    [1] = { Text = "Attack |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Attack |cffff0000Disabled", Tooltip = "" }
                }
            },
        }

        UI.AddHeader("Healing")

        UI.AddToggle("EarthShield", "大地之盾", true)
        UI.AddRange("EarthShieldHP", nil, 1, 100, 1, 50)

        UI.AddToggle("UnleashLife", "生命释放", true)
        UI.AddRange("UnleashLifeHP", nil, 1, 100, 1, 85)
        UI.AddToggle("Riptide", "激流", true)
        UI.AddRange("RiptideHP", nil, 1, 100, 1, 80)
        UI.AddToggle("HealingWave", "治疗波", true)
        UI.AddRange("HealingWaveHP", nil, 1, 100, 1, 70)
        UI.AddToggle("HealingSurge", "治疗之涌", true)
        UI.AddRange("HealingSurgeHP", nil, 1, 100, 1, 80)
        UI.AddToggle("HealingStreamTotem", nil, true)

        UI.AddToggle("ChainHeal", nil, true)
        UI.AddRange("ChainHealHP", nil, 1, 100, 1, 70)
        UI.AddRange("ChainHealUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("HealingRain", nil, true)
        UI.AddRange("HealingRainHP", nil, 1, 100, 1, 70)
        UI.AddRange("HealingRainUnits", nil, 1, 10, 1, 5)
        UI.AddToggle("SpiritLinkTotem", nil, true)
        UI.AddRange("SpiritLinkTotemHP", nil, 1, 100, 1, 60)
        UI.AddRange("SpiritLinkTotemUnits", nil, 1, 20, 1, 5)
        --救世之魂
        UI.AddToggle("SpiritSalvation", nil, true)
        UI.AddRange("SpiritSalvationRange", nil, 1, 100, 1, 60)

        UI.AddHeader("DPS")
        UI.AddToggle("EarthbindTotem", nil, true)
        UI.AddRange("EarthbindTotemUnits", nil, 1, 10, 1, 1)

        UI.AddHeader("Defensive")

        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 40)
        UI.AddToggle("EarthElemental", nil, true)
        UI.AddRange("EarthElementalHP", nil, 1, 100, 1, 50)
        UI.AddToggle("SpiritwalkerGrace", nil, true)
        UI.AddRange("SpiritwalkerGraceHP", nil, 1, 100, 1, 60)
        UI.AddToggle("AstralShift", nil, true)
        UI.AddRange("AstralShiftHP", nil, 1, 100, 1, 50)
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
    if Friends40YC > 0 then
        for _, Friend in ipairs(Friends40Y) do
            if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
                return true
            end
            if HUD.Dispel == 1 and Friend:Dispel(Spell.PurifySpirit) and Spell.PurifySpirit:Cast(Friend) then
                return true
            end
        end
    end
    if Player40YC > 0 then
        for _, Unit in pairs(Player40Y) do
            if Unit:Dispel(Spell.Purge) and Spell.Purge:Cast(Unit) then
                return true
            end
        end
    end
    return false
end

local function Heals()

    for _, Friend in ipairs(Friends40Y) do
        if Setting("SpiritLinkTotem") and Spell.SpiritLinkTotem:IsReady() then
            local SLTUnits, SLTCount = Friend:GetFriends(20, Setting("SpiritLinkTotemHP"))
            if SLTCount >= Setting("SpiritLinkTotemUnits") and Friend.HP <= Setting("SpiritLinkTotemHP") then
                if Spell.SpiritLinkTotem:Cast(Friend) then
                    return true
                end
            end
        end

        if Setting("HealingRain") and not Player.Moving and Spell.HealingRain:IsReady() then
            local HRUnits, HRCount = Friend:GetFriends(10, Setting("HealingRainHP"))
            if HRCount >= Setting("HealingRainUnits") and Friend.HP <= Setting("HealingRainHP") then
                if Spell.HealingRain:Cast(Friend) then
                    return true
                end
            end
        end

        if Setting("ChainHeal") and not Player.Moving and Spell.ChainHeal:IsReady() then
            local ChainUnits, ChainCount = Friend:GetFriends(10, Setting("ChainHealHP"))
            if ChainCount >= Setting("ChainHealUnits") and Friend.HP <= Setting("ChainHealHP") then
                if Spell.ChainHeal:Cast(Friend) then
                    return true
                end
            end
        end

        if Setting("EarthShield") and Friend.HP <= Setting("EarthShieldHP") and Buff.EarthShield:Count(Friends40Y) == 0 and Spell.EarthShield:Cast(Friend) then
            return true
        end

        if Setting("UnleashLife") and Friend.HP <= Setting("UnleashLifeHP") and not Player.Moving and not Buff.GhostWolf:Exist(Player) and Spell.UnleashLife:Cast(Friend) then
            return true
        end

        if Setting("Riptide") and Friend.HP <= Setting("RiptideHP") and Spell.Riptide:Cast(Friend) then
            return true
        end

        if Setting("HealingWave") and Friend.HP <= Setting("HealingWaveHP") and not Player.Moving and Spell.HealingWave:Cast(Friend) then
            return true
        end

        if Setting("HealingSurge") and Friend.HP <= Setting("HealingSurgeHP") and not Player.Moving and Spell.HealingSurge:Cast(Friend) then
            return true
        end

    end
    return false
end

local function Interrupt()
    if HUD.Interrupts == 1 then
        if Target and Target.ValidEnemy and not Target.Dead and Target:Interrupt() then

            if Spell.WindShear:Cast(Target) then
                return true
            end
        end
        if Player40YC > 0 then
            for _, Unit in pairs(Player40Y) do
                if Unit:Interrupt() then
                    if Spell.WindShear:IsReady() and Spell.WindShear:Cast(Unit) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function DPS()
    if Player40YC == 0 then
        return false
    end
    for _, Unit in ipairs(Player40Y) do
        if not Unit.Facing then
            FaceDirection(Unit.Pointer)
        end
        if Spell.CapacitorTotem:Cast(Unit) then
            return true
        end
        if not Spell.EarthbindTotem:LastCast() and Spell.EarthbindTotem:Cast(Unit) then
            return true
        end
        if Spell.FlameShock:Cast(Unit) then
            return true
        end
        if Debuff.FlameShock:Exist(Unit) and not Player.Moving and Spell.LavaBurst:Cast(Unit) then
            return true
        end
        local eU,ec = Unit:GetEnemies(14)
        if ec == 1 and Spell.LightningBolt:Cast(Unit) then
            return true
        end
        if ec > 1 and Spell.ChaninLightning:Cast(Unit) then
            return true
        end
    end
    return false
end

local function Defensive()
    if Player.Moving and not Buff.SpiritwalkerGrace:Exist(Player) and not Buff.GhostWolf:Exist(Player) and Spell.GhostWolf:Cast(Player) then
        return true
    end
    if not Player.Combat then
        return false
    end
    if Player.Combat and Player40YC > 0 and not Spell.HealingStreamTotem:LastCast() and Spell.HealingStreamTotem:Cast(Player) then
        return true
    end
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Setting("EarthElemental") and Player.HP <= Setting("EarthElementalHP") and Spell.EarthElemental:Cast(Player) then
        return true
    end
    if Setting("SpiritwalkerGrace") and Player.HP <= Setting("SpiritwalkerGraceHP") and Spell.SpiritwalkerGrace:Cast(Player) then
        return true
    end
    if Setting("AstralShift") and Player.HP <= Setting("AstralShiftHP") and Spell.AstralShift:Cast(Player) then
        return true
    end
end

function Shaman:Restoration()
    Locals()
    CreateSettings()
    if Rotation.Active() and Spell.GCD:CD() == 0 then
        if Defensive() then
            return true
        end
        if Player.Moving and Buff.GhostWolf:Exist(Player) then
            return false
        end
        if Interrupt() then
            return true
        end
        if Dispel() then
            return true
        end
        if Heals() then
            return true
        end
        if HUD.Attack == 1  then
            if DPS() then
                return true
            end
        end
    end
end
