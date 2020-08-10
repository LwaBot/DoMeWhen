local DMW = DMW
local Warlock = DMW.Rotations.WARLOCK
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC, Charges, Pet
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

        UI.AddHeader("DPS")
        UI.AddToggle("Agony", "痛楚", true)
        UI.AddRange("AgonyUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("UnstableAffliction", "痛苦无常", true)
        UI.AddToggle("ShadowBolt", "暗影箭", true)
        UI.AddToggle("SummonDarkglare", "召唤黑眼", true)
        UI.AddToggle("HealthFunnel", "生命通道", true)
        UI.AddRange("HealthFunnelHP", nil, 1, 100, 1, 30)
        UI.AddToggle("CommandDemon", "恶魔掌控", true)
        UI.AddToggle("VileTaint", "邪恶污染", nil, true)
        UI.AddToggle("Shadowfury", "暗影之怒", true)
        UI.AddToggle("Haunt", nil, true)
        UI.AddToggle("DrainSoul", nil, true)
        UI.AddToggle("DarkSoulMisery", nil, true)
        UI.AddToggle("MortalCoil", "死亡缠绕", true)
        UI.AddRange("MortalCoilHP", nil, 1, 100, 1, 80)

        UI.AddToggle("SP1", nil, true)
        UI.AddRange("SP1Range", nil, 1, 100, 1, 60)
        UI.AddToggle("SP2", nil, true)
        UI.AddRange("SP2Range", nil, 1, 100, 1, 30)
        UI.AddToggle("Fear", "恐惧", true)
        UI.AddToggle("LanguageCurse", nil, true)
        UI.AddHeader("Defensive")
        UI.AddToggle("CreateHealthstone", "制造灵魂石", true)

        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("UnendingResolve", nil, true)
        UI.AddRange("UnendingResolveHP", nil, 1, 100, 1, 60)
        UI.AddToggle("DrainLife", nil, true)
        UI.AddRange("DrainLifeHP", nil, 1, 100, 1, 30)
        UI.AddToggle("SummonImp", nil, true)
        UI.AddToggle("SummonVoidwalker", nil, false)
        UI.AddToggle("SummonFelhunter", nil, false)
        UI.AddToggle("SummonSuccubus", nil, false)
        UI.AddToggle("SummonDarkglare", nil, false)
        UI.AddToggle("NetherWard", nil, true)
        UI.AddRange("NetherWardHP", nil, 1, 100, 1, 80)
    end
end

local function Locals()
    Charges = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
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
    Pet = Player.Pet or false
    CDs = Player:CDs() and Target and Target.TTD > 5 and Target.Distance < 5
    Friends40Y, Friends40YC = Player:GetFriends(40)
    Player40Y, Player40YC = Player:GetEnemies(40)
end

local function Interrupt()
    if HUD.Interrupts == 1 then
        if Target and Target.ValidEnemy and not Target.Dead and Target:Interrupt() then
            if Spell.MortalCoil:Cast(Target) then
                return true
            end
            if Target.Distance < 8 and Spell.Shadowfury:Cast(Target) then
                return true
            end
            if not Pet.Dead and (Pet.ObjectID == 1863 or Pet.ObjectID == 417) and Spell.DevilCommand:Cast(Target) then
                return true
            end
        end
        local Player8Y, Player8YC = Player:GetEnemies(8)
        if Player8YC > 0 then
            for _, Unit in pairs(Player8Y) do
                if Unit:Interrupt() then
                    if Setting("MortalCoil") and Player.HP <= Setting("MortalCoilHP") and Spell.MortalCoil:Cast(Unit) then
                        return true
                    end
                    if Unit.Distance < 8 and Spell.Shadowfury:Cast(Unit) then
                        return true
                    end
                    if not Pet.Dead and (Pet.ObjectID == 1863 or Pet.ObjectID == 417) and Spell.DevilCommand:Cast(Target) then
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
        if Pet and not Pet.Dead and not UnitIsUnit("pettarget", Target.Pointer) then
            PetAttack()
        end
        if Setting("ShadowBolt") and Buff.Darkness:Exist(Player) and not Player.Moving and Spell.ShadowBolt:Cast(Target) then
            return true
        end
        if HUD.Mode == 1 and not Debuff.AfflictionBean:Exist(Target) and not Debuff.Corruption:Exist(Target) and Spell.AfflictionBean:Cast(Target) then
            return true
        end

        if Setting("VileTaint") and not Debuff.Haunt:Exist(Target) and Spell.VileTaint:Cast(Target) then
            return true
        end
        if Target.Distance < 20 and Player.Combat and Setting("SummonDarkglare") and Spell.SummonDarkglare:Cast(Player) then
            return true
        end
        if Setting("Agony") and Spell.Agony:CD() == 0 and Debuff.Agony:Refresh(Target) and Debuff.Agony:Remain(Target) < 5 and not Spell.Agony:LastCast() and Spell.Agony:Cast(Target) then
            return true
        end
        if Setting("DarkSoulMisery") and Player.Combat and Spell.DarkSoulMisery:Cast(Player) then
            return true
        end
        if Setting("Haunt") and not Debuff.Haunt:Exist(Target) and Spell.Haunt:Cast(Target) then
            return true
        end
        if Setting("UnstableAffliction") and Spell.UnstableAffliction:Cast(Target) then
            return true
        end

        if HUD.Mode == 2 and Debuff.Corruption:Remain(Target) < 5 and Spell.Corruption:Cast(Target) then
            return true
        end
        local AgonyCount = Debuff.Agony:Count(Player40Y)
        if Setting("Agony") and Player40YC > 0 and AgonyCount < Setting("AgonyUnits") and HUD.Mode == 1 then
            for _, Unit in ipairs(Player40Y) do
                if not Debuff.Agony:Exist(Unit) or Debuff.Agony:Remain(Unit) < 3 then

                    if Unit.Attackable and not Unit.Dead and Spell.Agony:Cast(Unit) then
                        return true
                    end

                end
            end
        end
        --饰品1
        local sp1Begin, sp1Duration, sp1Enable = GetInventoryItemCooldown("player", 13)
        local sp2Begin, sp2Duration, sp2Enable = GetInventoryItemCooldown("player", 14)
        if Setting("SP1") and Target.Distance < 4 and sp1Enable and sp1Begin == 0 then
            UseInventoryItem(13)
            return true
        end
        if Setting("SP2") and Target.Distance < 6 and sp2Enable and sp2Begin == 0 then
            UseInventoryItem(14)
            return true
        end

        if Setting("DrainSoul") and Spell.DrainSoul:Cast(Target) then
            return true
        end
        if Setting("ShadowBolt") and not Player.Moving and Spell.ShadowBolt:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end

    if Setting("UnendingResolve") and Player.HP <= Setting("UnendingResolveHP") and Spell.UnendingResolve:Cast(Player) then
        return true
    end

    if Setting("DrainLife") and Player.HP <= Setting("DrainLifeHP") and not Spell.DrainLife:LastCast() and Spell.DrainLife:Cast(Target) then
        return true
    end
    if Pet and not Pet.Dead and Player.HP <= 30 and Pet.ObjectID == 1860 and Spell.DevilCommand:Cast(Player) then
        return true
    end

end

local function PetStuff()
    if not Pet then
        if not Player.Combat and not UnitIsVisible("pet") and Setting("SummonImp") and Spell.SummonImp:Cast(Player) then
            return true
        end
        if not Player.Combat and not UnitIsVisible("pet") and Setting("SummonFelhunter") and Spell.SummonFelhunter:Cast(Player) then
            return true
        end
        if not Player.Combat and not UnitIsVisible("pet") and Setting("SummonVoidwalker") and Spell.SummonVoidwalker:Cast(Player) then
            return true
        end
        if not Player.Combat and not UnitIsVisible("pet") and Setting("SummonSuccubus") and Spell.SummonSuccubus:Cast(Player) then
            return true
        end
        if not Player.Combat and not UnitIsVisible("pet") and Setting("SummonDarkglare") and Spell.SummonDarkglare:Cast(Player) then
            return true
        end
    end
    if Setting("HealthFunnel") and Pet and not Pet.Dead and Pet.HP <= Setting("HealthFunnelHP") then
        if Spell.HealthFunnel:Cast(Player) then
            return true
        end
    end
end

local function Dispel()
    for _, Friend in ipairs(Friends40Y) do
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end

function Warlock.Affliction()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if Dispel() then
            return true
        end
        if PetStuff() then
            return true
        end
        if Interrupt() then
            return true
        end

        if Defensive() then
            return true
        end
        Player:AutoTarget(40, true)

        if Spell.GCD:CD() == 0 and DPS() then
            return true
        end
    end
end
