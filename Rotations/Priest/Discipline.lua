local DMW = DMW
local Priest = DMW.Rotations.PRIEST
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC
local UI = DMW.UI
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local lastTime = 0
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
        }

        UI.AddHeader("Healing")
        UI.AddRange("PenanceHP", nil, 0, 100, 1, 70)
        UI.AddToggle("LeapOfFaith", nil, true)
        UI.AddRange("LeapOfFaithHP", nil, 0, 100, 1, 50)
        UI.AddRange("ShadowMendHP", nil, 0, 100, 1, 80)
        UI.AddRange("Atonement HP", "HP to use Power Word: Shield or Power Word: Radiance to apply Atonement", 0, 100, 1, 90)
        UI.AddToggle("Power Word: Shield", nil, true)
        UI.AddRange("Power Word: Shield HP", "HP to use Power Word: Shield", 0, 100, 1, 80)
        UI.AddToggle("Power Word: Radiance", "耀", true)
        UI.AddRange("Power Word: Radiance Units", "低于救赎效果的个体数量超过此限制的数量>=", 0, 10, 1, 3)
        UI.AddToggle("Rapture", "全身贯注", true)
        UI.AddRange("Rapture Units", nil, 0, 10, 1, 3)
        UI.AddRange("Rapture HP", nil, 1, 100, 1, 60)
        UI.AddToggle("Archangel", "天使长", true)
        UI.AddRange("ArchangelUnits", nil, 1, 10, 1, 3)
        UI.AddRange("ArchangelHP", nil, 1, 100, 1, 70)
        UI.AddToggle("Pain Suppression", nil, true)
        UI.AddRange("Pain Suppression HP", nil, 0, 100, 1, 20)
        UI.AddToggle("SP1", nil, true)
        UI.AddRange("SP1Range", nil, 1, 100, 1, 60)
        UI.AddToggle("SP2", nil, true)
        UI.AddRange("SP2Range", nil, 1, 100, 1, 30)
        --救世之魂
        UI.AddToggle("SpiritSalvation", nil, true)
        UI.AddRange("SpiritSalvationHP", nil, 1, 100, 1, 70)
        UI.AddToggle("ShiningForce", nil, true)
        UI.AddRange("ShiningForceHP", nil, 1, 100, 1, 50)
        UI.AddToggle("PowerWordBarrier", nil, true)
        UI.AddRange("PowerWordBarrierUnits", nil, 1, 10, 1, 3)
        UI.AddRange("PowerWordBarrierHP", nil, 1, 100, 1, 60)
        UI.AddToggle("PsychicScream", nil, true)
        UI.AddRange("PsychicScreamHP", nil, 1, 100, 1, 70)
        UI.AddRange("PsychicScreamUnits", nil, 1, 10, 1, 3)
        --光晕
        UI.AddToggle("Halo", nil, true)
        UI.AddRange("HaloUnits", nil, 1, 20, 1, 4)
        UI.AddRange("HaloHP", nil, 1, 100, 1, 60)
        --激光屏障
        UI.AddToggle("LuminousBarrier", nil, true)
        UI.AddRange("LuminousBarrierUnits", nil, 1, 20, 1, 4)
        UI.AddRange("LuminousBarrierHP", nil, 1, 100, 1, 60)
        UI.AddToggle("Fortitude", nil, true)
        --辐照
        UI.AddToggle("Evangelism", nil, true)
        UI.AddRange("EvangelismUnits", nil, 1, 20, 1, 4)
        UI.AddRange("EvangelismHP", nil, 1, 100, 1, 60)
        --天堂之羽
        UI.AddToggle("AngelicFeather", nil, true)
        UI.AddRange("AngelicFeatherHP", nil, 1, 100, 1, 60)
        --神圣之星
        UI.AddRange("DivineStarHP", nil, 1, 100, 1, 70)
        UI.AddHeader("DPS")
        --催心魔
        UI.AddRange("MindbenderPowerPct", nil, 1, 100, 1, 80)
        UI.AddRange("Shadow Word: Pain Units", "Max active Shadow Word: Pain dots active", 0, 10, 1, 3)
        UI.AddToggle("PurgeTheWicked", nil, true)
        UI.AddRange("PurgeTheWickedUnits", nil, 0, 10, 1, 3)
        UI.AddHeader("Defensive")
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("HealthstoneHP", nil, 0, 100, 1, 40)
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
    if Dispel() then
        return true
    end

    --Rapture
    if Setting("Rapture") then
        if Spell.Rapture:IsReady() then
            local RaptureUnits, RaptureCount = Player:GetFriends(40, Setting("Rapture HP"))
            if RaptureCount >= Setting("Rapture Units") then
                if Spell.Rapture:Cast(Player) then
                    return true
                end
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
    --福兆
    if Setting("Evangelism") and Spell.Evangelism:IsReady() and not Player.Moving then
        local ElUnits, ElCount = Player:GetFriends(40, Setting("EvangelismHP"))
        if ElCount >= Setting("EvangelismUnits") then
            if Spell.Evangelism:Cast(Player) then
                return true
            end
        end
    end
    --激光屏障LuminousBarrier
    if Setting("LuminousBarrier") and Spell.LuminousBarrier:IsReady() then
        local LBUnits, LBCount = Player:GetFriends(40, Setting("LuminousBarrierHP"))
        if LBCount >= Setting("LuminousBarrierUnits") then
            if Spell.LuminousBarrier:Cast(Player) then
                return true
            end
        end
    end
    if Talent.Archangel.Active and Setting("Archangel") then
        if Spell.Archangel:IsReady() then
            local ArchangelUnits, ArchangelCount = Player:GetFriends(40, Setting("ArchangelHP"))
            if ArchangelCount >= Setting("ArchangelUnits") then
                if Spell.Archangel:Cast(Player) then
                    return true
                end
            end
        end
    end
    for _, Friend in ipairs(Friends40Y) do

        if Buff.Rapture:Exist(Player) and Friend.HP < Setting("Power Word: Shield HP") and not Buff.PowerWordShield:Exist(Friend) and Spell.PowerWordShield:Cast(Friend) then
            return true
        end
        if Setting("PowerWordBarrier") and Spell.PowerWordBarrier:IsReady() then
            local PBUnits, PBCount = Friend:GetFriends(20, Setting("PowerWordBarrierHP"))
            if PBCount >= Setting("PowerWordBarrierUnits") and Friend.HP <= Setting("PowerWordBarrierHP") and Player.Combat then
                if Spell.PowerWordBarrier:Cast(Friend) then
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
        --天堂飞羽
        if Friend.Moving and Friend.HP <= Setting("AngelicFeatherHP") and not Buff.AngelicFeather:Exist(Friend) and not Spell.AngelicFeather:LastCast() and Setting("AngelicFeather") and Spell.AngelicFeather:Cast(Friend) then
            return true
        end
        if Friend.Distance < 24 and Friend.HP <= Setting("DivineStarHP") and Spell.DivineStar:Cast(Friend) then
            return true
        end
        if not Player.Moving and Player.Combat and Friend.HP <= Setting("SpiritSalvationHP") and Spell.SpiritSalvation:Cast(Friend) then
            return true
        end
        if Setting("LeapOfFaith") and Friend.Distance < 40 and Friend.Player and Player.Pointer ~= Friend.Pointer and Friend.HP <= Setting("LeapOfFaithHP") and Spell.LeapOfFaith:Cast(Friend) then
            return true
        end
        if Player.Combat and Setting("Pain Suppression") and Friend.HP <= Setting("Pain Suppression HP") and Spell.PainSuppression:Cast(Friend) then
            return true
        end
        if Player.Combat and Spell.Penance:IsReady() and Friend.HP < Setting("PenanceHP") and Spell.Penance:Cast(Friend) then
            return true
        end
        if Friend.Distance < 40 and Friend.HP < Setting("PenanceHP") and Spell.ConcentratedFlame:Cast(Friend) then
            return true
        end
        if Setting("Fortitude") and not Buff.Fortitude:Exist(Friend) and Spell.Fortitude:Cast(Player) then
            return true
        end
        if not Player.Moving and Friend.HP < Setting("ShadowMendHP") and Spell.ShadowMend:Cast(Friend) then
            return true
        end
        if Friend.HP <= Setting("Power Word: Shield HP") then
            if not Buff.PowerWordShield:Exist(Friend) and (not Debuff.WeakenedSoul:Exist(Friend) or Buff.Rapture:Exist(Player)) then
                if Spell.PowerWordShield:Cast(Friend) then
                    return true
                end
            end
        end
        if not Player.Moving and Spell.PowerWordRadiance:IsReady() and not Spell.PowerWordRadiance:LastCast() and Friend.HP <= Setting("Atonement HP") and not Buff.Rapture:Exist(Player) then
            local RadianceTable, RadianceC = Friend:GetFriends(30, Setting("Atonement HP"))
            if RadianceC >= Setting("Power Word: Radiance Units") and Buff.Atonement:Count(RadianceTable) <= (math.max(RadianceC - 1, 0)) and
                    Spell.PowerWordRadiance:Cast(Friend) then
                return true
            end
        end
    end
end

local function DPS()
    Player:AutoTarget(40, true)
    local SWPCount = Debuff.ShadowWordPain:Count(Player40Y)
    local PTWCount = Debuff.PurgeTheWicked:Count(Player40Y)
    for _, Unit in ipairs(Player40Y) do
        if HUD.Dispel == 1 and Unit:Dispel(Spell.DispelMagic) and Spell.DispelMagic:Cast(Unit) then
            return true
        end
        if not Talent.PurgeTheWicked.Active and SWPCount <= Setting("Shadow Word: Pain Units") and
                Debuff.ShadowWordPain:Refresh(Unit) and not Debuff.ShadowWordPain:Exist(Unit) and
                Spell.ShadowWordPain:Cast(Unit) then
            return true
        end
        if Talent.PurgeTheWicked.Active and PTWCount <= Setting("PurgeTheWickedUnits") and not Debuff.PurgeTheWicked:Exist(Unit) and
                Spell.PurgeTheWicked:Cast(Unit) then
            return true
        end
    end
    if Target and not Target.Dead and Target.ValidEnemy then
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
        if Talent.DarkArchangel.Active and
                Spell.DarkArchangel:IsReady() and
                Spell.DarkArchangel:Cast(Player) then
            return true
        end
        if not Player.Moving and Spell.Schism:Cast(Target) then
            return true
        end
        if (Player.Moving or Buff.PowerOfTheDarkSide:Exist()) and Spell.Penance:Cast(Target) then
            return true
        end
        if Talent.Mindbender.Active and Player.PowerPct <= Setting("MindbenderPowerPct") and Spell.Mindbender:Cast(Target) then
            return true
        end
        if not Talent.Mindbender.Active and Spell.SunSon:Cast(Target) then
            return true
        end
        if Target.Distance < 40 and Spell.ConcentratedFlame:Cast(Target) then
            return true
        end
        if Spell.PowerWordSolace:Cast(Target) then
            return true
        end
        if not Player.Moving and Spell.Smite:Cast(Target) then
            return true
        end
        if Talent.PurgeTheWicked.Active and Spell.PurgeTheWicked:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    if Player.Moving and not Buff.AngelicFeather:Exist(Player) and (not Spell.AngelicFeather:LastCast() or not Player.Combat) and Setting("AngelicFeather")
            and Spell.AngelicFeather:Cast(Player) then
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
    if Setting("PsychicScream") and Player.HP <= Setting("PsychicScreamHP") and enemyCount >= Setting("PsychicScreamUnits") and
            Spell.PsychicScream:Cast(Player) then
        return true
    end

end

function Priest.Discipline()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if HUD.Print == 1 then
            Player:printTalentsInfo()
        end
        if Player.Combat and Defensive() then
            return true
        elseif Heals() then
            return true
        end
        DPS()
    end
end
