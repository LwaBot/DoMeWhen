local DMW = DMW
local Priest = DMW.Rotations.PRIEST
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC, FriendsDeadY, FriendsDeadYC
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
                Print = {
                    [1] = { Text = "Print |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Print |cffff0000Disabled", Tooltip = "" }
                }
            },
            [6] = {
                Attack = {
                    [1] = { Text = "Attack |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Attack |cffff0000Disabled", Tooltip = "" }
                }
            },
        }

        UI.AddHeader("Healing")
        UI.AddRange("SelfHP", nil, 1, 100, 1, 50)
        UI.AddToggle("MassResurrection", nil, true)
        UI.AddToggle("LeapOfFaith", nil, true)
        UI.AddRange("LeapOfFaithHP", nil, 0, 100, 1, 50)

        UI.AddToggle("DivineIncarnation", "神圣化身", true)
        UI.AddRange("DivineIncarnationHP", nil, 1, 100, 1, 80)
        UI.AddRange("DivineIncarnationUnits", nil, 1, 20, 1, 3)

        UI.AddToggle("DivineHymn", "神圣赞美诗", true)
        UI.AddRange("DivineHymnHP", nil, 1, 100, 1, 50)
        UI.AddRange("DivineHymnUnits", nil, 1, 40, 1, 3)

        UI.AddToggle("HolyWordSalvation", "圣言术赎", true)
        UI.AddRange("HolyWordSalvationHP", nil, 1, 100, 1, 60)
        UI.AddRange("HolyWordSalvationUnits", nil, 1, 40, 1, 4)

        UI.AddToggle("HolyWordSanctify", "圣言术灵", true)
        UI.AddRange("HolyWordSanctifyUnits", nil, 0, 10, 1, 3)
        UI.AddRange("HolyWordSanctifyHP", nil, 1, 100, 1, 70)

        UI.AddToggle("PrayerofMending", "愈合祷言", true)
        UI.AddRange("PrayerofMendingHP", nil, 1, 100, 1, 80)

        UI.AddToggle("PrayerofHealing", nil, true)
        UI.AddRange("PrayerofHealingHP", nil, 1, 100, 1, 60)
        UI.AddRange("PrayerofHealingUnits", nil, 1, 10, 1, 4)

        --BindingHeal
        UI.AddToggle("BindingHeal", nil, true)
        UI.AddRange("BindingHealHP", nil, 1, 100, 1, 90)
        UI.AddRange("BindingHealUnits", nil, 1, 10, 1, 2)

        --治疗之环 HealRing
        UI.AddToggle("HealRing", nil, true)
        UI.AddRange("HealRingHP", nil, 1, 100, 1, 90)
        UI.AddRange("HealRingUnits", nil, 1, 10, 1, 2)

        UI.AddToggle("HolyWordSerenity", "圣言术静", true)
        UI.AddRange("HolyWordSerenityHP", nil, 1, 100, 1, 75)

        UI.AddToggle("GuardianSpirit", nil, true)
        UI.AddRange("GuardianSpiritHP", nil, 1, 100, 1, 50)

        UI.AddToggle("GreaterHeal", nil, true)
        UI.AddRange("GreaterHealHP", nil, 1, 100, 1, 40)

        UI.AddToggle("Heal", nil, true)
        UI.AddRange("HealHP", nil, 1, 100, 1, 80)
        UI.AddRange("HealLowHP", nil, 1, 100, 1, 50)
        UI.AddRange("HealPowerPct", nil, 1, 100, 1, 40)

        UI.AddToggle("FlashHeal", nil, true)
        UI.AddRange("FlashHealHP", nil, 1, 100, 1, 80)

        UI.AddToggle("Renew", nil, true)
        UI.AddRange("RenewHP", nil, 1, 100, 1, 90)

        UI.AddToggle("SP1", nil, false)
        UI.AddRange("SP1Range", nil, 1, 100, 1, 60)
        UI.AddToggle("SP2", nil, false)
        UI.AddRange("SP2Range", nil, 1, 100, 1, 30)
        --救世之魂
        UI.AddToggle("SpiritSalvation", nil, true)
        UI.AddRange("SpiritSalvationHP", nil, 1, 100, 1, 70)

        UI.AddToggle("LightOfHope", nil, true)
        UI.AddRange("LightOfHopeHP", nil, 1, 100, 1, 30)

        UI.AddToggle("ShiningForce", nil, true)
        UI.AddRange("ShiningForceHP", nil, 1, 100, 1, 50)

        UI.AddToggle("PsychicScream", nil, true)
        UI.AddRange("PsychicScreamHP", nil, 1, 100, 1, 70)
        UI.AddRange("PsychicScreamUnits", nil, 1, 10, 1, 3)
        --光晕
        UI.AddToggle("Halo", nil, true)
        UI.AddRange("HaloUnits", nil, 1, 20, 1, 4)
        UI.AddRange("HaloHP", nil, 1, 100, 1, 60)

        UI.AddToggle("Fortitude", nil, true)
        --天堂之羽
        UI.AddToggle("AngelicFeather", nil, true)
        UI.AddRange("AngelicFeatherHP", nil, 1, 100, 1, 60)
        --神圣之星
        UI.AddRange("DivineStarHP", nil, 1, 100, 1, 70)

        UI.AddHeader("DPS")
        UI.AddToggle("HolyFire", nil, true)
        UI.AddToggle("Smite", nil, true)

        UI.AddHeader("Defensive")
        UI.AddToggle("MassResurrection", nil, true)
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("HealthstoneHP", nil, 0, 100, 1, 40)
        UI.AddToggle("Fade", nil, true)
        UI.AddRange("FadeHP", nil, 1, 100, 1, 60)

        UI.AddToggle("DesperatePrayer", nil, true)
        UI.AddRange("DesperatePrayerHP", nil, 0, 100, 1, 60)
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
    FriendsDeadY, FriendsDeadYC = Player:GetFriendsDead()
    Friends40Y, Friends40YC = Player:GetFriends(40)
    Player40Y, Player40YC = Player:GetEnemies(40)
end

local function Dispel()
    for _, Friend in ipairs(Friends40Y) do
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
        if HUD.Dispel == 1 and Friend:Dispel(Spell.Purify) and Spell.Purify:Cast(Friend) then
            return true
        end

    end
end
local function Heals()

    if Setting("MassResurrection") and not Player.Combat and not Player.Dead and not Player.Moving and FriendsDeadYC > 0
            and DMW.Time - Spell.MassResurrection.LastCastTime > 60 and Spell.MassResurrection:Cast(Player) then
        return true
    end
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
    --神圣赞美诗
    if Setting("DivineHymn") and Spell.DivineHymn:IsReady() and not Player.Moving then
        local DHUnits, DHCount = Player:GetFriends(40, Setting("DivineHymnHP"))
        if DHCount >= Setting("DivineHymnUnits") then
            if Spell.DivineHymn:Cast(Player) then
                return true
            end
        end
    end

    --神圣化身
    if Setting("DivineIncarnation") and Spell.DivineIncarnation:IsReady() then
        local DIUnits, DICount = Player:GetFriends(40, Setting("DivineIncarnationHP"))
        if DICount >= Setting("DivineIncarnationUnits") then
            if Spell.DivineIncarnation:Cast(Player) then
                return true
            end
        end
    end

    --赎 HolyWordSalvation
    if Setting("HolyWordSalvation") and Spell.HolyWordSalvation:IsReady() then
        local HSUnits, HSCount = Player:GetFriends(40, Setting("HolyWordSalvationHP"))
        if HSCount >= Setting("HolyWordSalvationUnits") then
            if Spell.HolyWordSalvation:Cast(Player) then
                return true
            end
        end
    end

    if Setting("Halo") and Spell.Halo:IsReady() and not Player.Moving then
        local HaloUnits, HaloCount = Player:GetFriends(40, Setting("HaloHP"))
        if HaloCount >= Setting("HaloUnits") then
            if Spell.Halo:Cast(Player) then
                return true
            end
        end
    end

    for _, Unit in ipairs(Friends40Y) do
        local Friend = Unit
        if Player.HP <= Setting("SelfHP") then
           -- Friend = Player
        end
        if Setting("HolyWordSanctify") and Spell.HolyWordSanctify:IsReady() then
            local HSUnits, HSCount = Friend:GetFriends(10, Setting("HolyWordSanctifyHP"))
            if HSCount >= Setting("HolyWordSanctifyUnits") and Friend.HP <= Setting("HolyWordSanctifyHP") and Player.Combat then
                if Spell.HolyWordSanctify:Cast(Friend) then
                    return true
                end
            end
        end
        if Setting("ShiningForce") and Spell.ShiningForce:IsReady() and Friend.HP < Setting("ShiningForceHP") then
            local enemyUnits, enemyCount = Friend:GetEnemies(8)
            if enemyCount >= 3 and Spell.ShiningForce:Cast(Friend) then
                return true
            end
        end

        if Setting("LightOfHope") and Player.Combat and Friend.HP <= Setting("LightOfHopeHP") and
                Spell.LightOfHope:Cast(Friend) then
            return true
        end

        if Setting("GreaterHeal") and not Player.Moving and Friend.HP <= Setting("GreaterHealHP") and Spell.GreaterHeal:Cast(Friend) then
            return true
        end

        if Setting("GuardianSpirit") and Player.Combat and Friend.HP <= Setting("GuardianSpiritHP") and Spell.GuardianSpirit:Cast(Friend) then
            return true
        end

        --BindingHeal
        if Setting("BindingHeal") and not Player.Moving and Spell.BindingHeal:IsReady() and Friend.HP > 50 then
            local BHUnits, BHCount = Friend:GetFriends(40, Setting("BindingHealHP"))
            if BHCount >= Setting("BindingHealUnits") and Friend.HP <= Setting("BindingHealHP") and Friend.Pointer ~= Player.Pointer then
                if Spell.BindingHeal:Cast(Friend) then
                    return true
                end
            end
        end

        if Setting("HealRing") and Spell.HealRing:IsReady() then
            local HRUnits, HRCount = Friend:GetFriends(40, Setting("HealRingHP"))
            if HRCount >= Setting("HealRingUnits") and Friend.HP <= Setting("HealRingHP") then
                if Spell.HealRing:Cast(Friend) then
                    return true
                end
            end
        end
        if Friend.HP <= Setting("PrayerofMendingHP") and Spell.PrayerofMending:Cast(Friend) then
            return true
        end

        if Setting("PrayerofHealing") and not Player.Moving and Spell.PrayerofHealing:IsReady() then
            local PHUnits, PHCount = Friend:GetFriends(40, Setting("PrayerofHealingHP"))
            if PHCount >= Setting("PrayerofHealingUnits") and Friend.HP <= Setting("PrayerofHealingHP") then
                if Spell.PrayerofHealing:Cast(Friend) then
                    return true
                end
            end
        end

        if not Player.Moving and Player.Combat and Friend.HP <= Setting("SpiritSalvationHP") and Spell.SpiritSalvation:Cast(Friend) then
            return true
        end

        if Setting("HolyWordSerenity") and Friend.HP <= Setting("HolyWordSerenityHP") and Spell.HolyWordSerenity:Cast(Friend) then
            return true
        end

        if Setting("LeapOfFaith") and Friend.Distance < 40 and Friend.Player and Player.Pointer ~= Friend.Pointer and Friend.HP <= Setting("LeapOfFaithHP")
                and Spell.LeapOfFaith:Cast(Friend) then
            return true
        end

        --天堂飞羽
        --    if Friend.Moving and Friend.HP <= Setting("AngelicFeatherHP") and not Buff.AngelicFeather:Exist(Friend) and not Spell.AngelicFeather:LastCast() and Setting("AngelicFeather") and Spell.AngelicFeather:Cast(Friend) then
        --       return true
        --  end
        if Friend.Distance < 24 and Friend.HP <= Setting("DivineStarHP") and Spell.DivineStar:Cast(Friend) then
            return true
        end

        if Setting("Fortitude") and not Buff.Fortitude:Exist(Friend) and Spell.Fortitude:Cast(Player) then
            return true
        end
        if Setting("Renew") and Friend.HP <= Setting("RenewHP") and not Buff.Renew:Exist(Friend) and Spell.Renew:Cast(Friend) then
            return true
        end
        if Setting("Heal") and not Player.Moving and Friend.HP >= Setting("HealLowHP") and Friend.HP <= Setting("HealHP") and (Player.PowerPct <= Setting("HealPowerPct") and not Player.Bg)
                and Spell.Heal:Cast(Friend) then
            return true
        end

        if Setting("FlashHeal") and not Player.Moving and Friend.HP <= Setting("FlashHealHP") and Spell.FlashHeal:Cast(Friend) then
            return true
        end


    end
    if Player.PowerPct < 4 and Player.Combat and not Player.Moving and Spell.SymbolOfHope:Cast(Player) then
        return true
    end
    return false
end

local function Interrupt()
    if HUD.Interrupts == 1 then
        local Player30Y, Player30YC = Player:GetEnemies(30)
        if Player30YC > 0 then
            for _, Unit in pairs(Player30Y) do
                if Unit:Interrupt() then
                    if Spell.HolyWordChastise:IsReady() and Spell.HolyWordChastise:Cast(Unit) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function DPS()
    Player:AutoTarget(40, true)
    for _, Unit in ipairs(Player40Y) do
        if HUD.Dispel == 1 and Unit:Dispel(Spell.DispelMagic) and Spell.DispelMagic:Cast(Unit) then
            return true
        end

    end
    if Target and not Target.Dead and Target.ValidEnemy then

        if Target.Distance < 40 and Spell.ConcentratedFlame:Cast(Target) then
            return true
        end
        if Setting("HolyFire") and Spell.HolyFire:Cast(Target) then
            return true
        end
        if Setting("Smite") and not Player.Moving and Spell.Smite:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    for _, Friend in ipairs(Friends40Y) do
        if not Player.Moving and not Player.Combat and Friends40YC > 0 and Setting("MassResurrection") then
            if Friend.Dead and Spell.MassResurrection:Cast(Player) then
                return true
            end
        end
    end
    for _,Unit in ipairs(Player40Y) do
        if Unit.Target and Unit.Target == Player.Pointer and Spell.Fade:Cast(Player) then
            return true
        end
    end
    if Player.Moving and not Buff.AngelicFeather:Exist(Player)
            and Setting("AngelicFeather")
            and Spell.AngelicFeather:Cast(Player) then
        return true
    end
    if not Player.Moving and Player.Combat and Player40YC >= 1 and Spell.HolyGet:Cast(Player) then
        return true
    end
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("HealthstoneHP") and Item.Healthstone:Use(Player) then
        return true
    end
    --DP
    if Setting("DesperatePrayer") and Player.HP <= Setting("DesperatePrayerHP") and Spell.DesperatePrayer:Cast(Player) then
        return true
    end
    local enemyUnits, enemyCount = Player:GetEnemies(10)
    if Setting("PsychicScream") and Player.HP <= Setting("PsychicScreamHP") and Player.Combat and enemyCount >= Setting("PsychicScreamUnits") and
            Spell.PsychicScream:Cast(Player) then
        return true
    end

end

function Priest.Holy()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if HUD.Print == 1 then
            Player:printTalentsInfo()
        end
        if Spell.GCD:CD() == 0 then
            if Interrupt() then
                return true
            end
            if Defensive() then
                return true
            end
            if Dispel() then
                return true
            end
            if Heals() then
                return true
            end
            if HUD.Attack == 1 and DPS() then
                return true
            end
        end
    end
end
