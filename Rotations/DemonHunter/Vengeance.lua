local DMW = DMW
local DemonHunter = DMW.Rotations.DEMONHUNTER
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC, Friends8Y, Friends8YC, Player8Y, Player8YC
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
            },--Torment
            [5] = {
                Torment = {
                    [1] = { Text = "Torment |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Torment |cffff0000Disabled", Tooltip = "" }
                }
            },--Torment
        }

        UI.AddHeader("DPS")
        UI.AddToggle("Imprison", nil, false)
        UI.AddToggle("ImmolationAura", nil, true)

        UI.AddToggle("ThrowGlaive", nil, true)
        UI.AddToggle("Disrupt", nil, true)
        UI.AddToggle("ConsumeMagic", nil, true)
        UI.AddToggle("FieryBrand", nil, true)
        UI.AddToggle("Fracture", nil, true)
        UI.AddToggle("InfernalStrike", nil, true)

        UI.AddToggle("SigilOfChains", nil, true)
        UI.AddRange("SigilOfChainsHP", nil, 1, 100, 1, 40)
        UI.AddRange("SigilOfChainsUnits", nil, 1, 20, 1, 3)

        UI.AddToggle("SigilOfFlame", nil, true)
        UI.AddRange("SigilOfFlameUnits", nil, 1, 20, 1, 3)

        UI.AddToggle("SigilOfMisery", nil, true)
        UI.AddRange("SigilOfMiseryHP", nil, 1, 100, 1, 50)
        UI.AddToggle("SigilOfMiseryUnits", nil, 1, 20, 1, 3)

        UI.AddToggle("SigilOfSilence", nil, true)
        UI.AddRange("SigilOfSilenceHP", nil, 1, 100, 1, 60)
        UI.AddToggle("SigilOfSilenceUnits", nil, 1, 20, 1, 3)

        UI.AddToggle("SoulBarrier", nil, true)

        UI.AddToggle("Torment", nil, true)

        UI.AddHeader("Defensive")
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("SpiritBomb", nil, true)
        UI.AddRange("SpiritBombHP", nil, 1, 100, 1, 60)
        UI.AddRange("SpiritBombUnits", nil, 1, 20, 1, 3)
        UI.AddToggle("DemonSpikes", nil, true)
        UI.AddRange("DemonSpikesHP", nil, 1, 100, 1, 90)
        UI.AddToggle("SoulBarrier", nil, true)
        UI.AddRange("SoulBarrierRange", nil, 1, 100, 1, 70)
        UI.AddToggle("Metamorphosis", nil, true)
        UI.AddRange("MetamorphosisRange", nil, 1, 100, 1, 60)
        UI.AddToggle("SoulCleave", nil, true)
        UI.AddRange("SoulCleaveHP", nil, 70, 100, 1, 85)
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
    Friends8Y, Friends8YC = Player:GetFriends(8)
    Player8Y, Player8YC = Player:GetEnemies(8)
    Player40Y, Player40YC = Player:GetEnemies(40)
end

local function Interrupt()
    if HUD.Interrupts == 1 then

        if Player8YC == 0 then
            return false
        end
        for _, Unit in pairs(Player8Y) do
            if Unit:Interrupt() then
                if Spell.Disrupt:Cast(Unit) then
                    return true
                end
                if Spell.SigilOfSilence:Cast(Unit) then
                    return true
                end
            end
        end
    end
    return false
end

local function DPS()
    if HUD.Torment == 1 then
        for _,Unit in ipairs(Player40Y) do
            if Unit.Target ~= nil and Unit.Target ~= Player.Pointer and Spell.Torment:Cast(Unit) then
                return true
            end
        end
    end
    if Target and not Target.Dead and (Target.ValidEnemy or Target.Attackable) then

        if Setting("ImmolationAura") and Spell.ImmolationAura:Cast(Player) then
            return true
        end
        if Setting("FieryBrand") and Spell.FieryBrand:Cast(Target) then
            return true
        end
        if Setting("ThrowGlaive") and Target.Distance < 30 and Spell.ThrowGlaive:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Setting("InfernalStrike") and Spell.InfernalStrike:Cast(Target) then
            return true
        end
        --饰品1
        local sp1Begin, sp1Duration, sp1Enable = GetInventoryItemCooldown("player", 13)
        local sp2Begin, sp2Duration, sp2Enable = GetInventoryItemCooldown("player", 14)
        if Target.Distance < 4 and sp1Enable and sp1Begin == 0 then
            UseInventoryItem(13)
            return true
        end
        if Target.Distance < 4 and sp2Enable and sp2Begin == 0 then
            UseInventoryItem(14)
            return true
        end

        if Player.Combat and Spell.NearDeath:Cast(Target) then
            return true
        end

        if Spell.ConcentratedFlame:Cast(Target) then
            return true
        end

        if Setting("SpiritBomb") and Player.Combat
                and (
                (Player.HP < Setting("SpiritBombHP") and Player8YC > 0)
                        or
                        (Player.HP >= Setting("SpiritBombHP") and Player8YC >= Setting("SpiritBombUnits"))
        )
                and not Debuff.Fragile:Exist(Target)
                and Buff.SoulFragment:Stacks() == 5
                and Spell.SpiritBomb:Cast(Player) then
            return true
        end

        if Setting("SoulCleave") and Player.Combat and (Player.HP <= Setting("SoulCleaveHP") or Buff.SoulFragment:Stacks() == 5) and
                Spell.SoulCleave:Cast(Target) then
            return true
        end

        if Target.Distance < 30 and Setting("SigilOfChains") and Player8YC >= Setting("SigilOfChainsUnits")
                and Player.HP < Setting("SigilOfChainsHP") and Spell.SigilOfChains:Cast(Target) then
            return true
        end

        if Target.Distance < 30 and Setting("SigilOfFlame") and Player8YC >= Setting("SigilOfFlameUnits") and Spell.SigilOfFlame:Cast(Target) then
            return true
        end

        if Target.Distance < 30 and Setting("SigilOfMisery") and Player8YC >= Setting("SigilOfMiseryUnits")
                and Player.HP < Setting("SigilOfMiseryHP") and Spell.SigilOfMisery:Cast(Target) then
            return true
        end

        if Target.Distance < 30 and Setting("SigilOfSilence") and Player8YC >= Setting("SigilOfSilenceUnits")
                and Player.HP < Setting("SigilOfSilenceHP") and Spell.SigilOfSilence:Cast(Target) then
            return true
        end

        if Setting("Fracture") and Spell.Fracture:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    --恶魔皮肤
    if Setting("DemonSpikes") and Player.HP <= Setting("DemonSpikesHP") and not Buff.DemonSpikes:Exist(Player) and Spell.DemonSpikes:Cast(Player) then
        return true
    end

    if Setting("SoulBarrier") and Player.HP <= Setting("SoulBarrierRange") and Spell.SoulBarrier:Cast(Player) then
        return true
    end
    if Setting("Metamorphosis") and Player.HP <= Setting("MetamorphosisRange") and Spell.Metamorphosis:Cast(Player) then
        return true
    end
end

local function Dispel()
    for _, Friend in ipairs(Friends40Y) do
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
    for _, Unit in ipairs(Player40Y) do
        if HUD.Dispel == 1 and Unit:Dispel(Spell.ConsumeMagic) and Spell.ConsumeMagic:Cast(Unit) then
            return true
        end
    end
end

function DemonHunter.Vengeance()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if Target and Target.ValidEnemy and Target.Player and Setting("Imprison") then
            if Spell.Imprison:Cast(Target) then
                return true
            end
        end
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
