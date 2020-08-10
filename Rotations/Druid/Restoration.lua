local DMW = DMW
local Druid = DMW.Rotations.DRUID
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
            [6] = {
                TravelForm = {
                    [1] = { Text = "Travel |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Travel |cffff0000Disabled", Tooltip = "" }
                }
            },
            [7] = {
                ProwlForm = {
                    [1] = { Text = "Prowl |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "Prowl |cffff0000Disabled", Tooltip = "" }
                }
            },
        }

        UI.AddHeader("Healing")

        UI.AddToggle("Rejuvenation", nil, true)
        UI.AddRange("RejuvenationHP", nil, 1, 100, 1, 90)
        UI.AddRange("RejuvenationUnits", nil, 1, 40, 1, 3)

        UI.AddToggle("Regrowth", nil, true)
        UI.AddRange("RegrowthHP", nil, 1, 100, 1, 90)
        UI.AddRange("RegrowthLOWHP", nil, 1, 100, 1, 65)
        UI.AddRange("RegrowthUnits", nil, 1, 40, 1, 3)

        UI.AddToggle("Tranquility", "宁静", true)
        UI.AddRange("TranquilityHP", nil, 1, 100, 1, 70)
        UI.AddRange("TranquilityUnits", nil, 1, 40, 1, 3)

        UI.AddToggle("Innervate", "激活", true)
        UI.AddRange("InnervateHP", nil, 1, 100, 1, 60)
        UI.AddRange("InnervateUnits", nil, 1, 40, 1, 3)

        UI.AddToggle("Lifebloom", "绽放", true)
        UI.AddRange("LifebloomHP", nil, 1, 100, 1, 80)

        UI.AddToggle("Flowers", nil, true)
        UI.AddRange("FlowersHP", nil, 1, 100, 1, 94)
        UI.AddRange("FlowersUnits", nil, 1, 40, 1, 2)

        UI.AddToggle("Thriving", "繁盛", true)
        UI.AddRange("ThrivingHP", nil, 1, 100, 1, 80)
        UI.AddRange("ThrivingUnits", nil, 1, 40, 1, 3)

        UI.AddToggle("Swiftmend", "迅捷", true)
        UI.AddRange("SwiftmendHP", nil, 1, 100, 1, 70)

        UI.AddToggle("WildGrowth", "野性成长", true)
        UI.AddRange("WildGrowthHP", nil, 1, 100, 1, 80)
        UI.AddRange("WildGrowthUnits", nil, 1, 40, 1, 2)

        UI.AddToggle("Ironbark", "铁木树皮", true)
        UI.AddRange("IronbarkHP", nil, 1, 100, 1, 60)

        UI.AddToggle("TreantForm", nil, true)

        --清除腐蚀
        UI.AddToggle("RemoveCorruption", nil, true)

        UI.AddToggle("SP1", nil, true)
        UI.AddRange("SP1Range", nil, 1, 100, 1, 60)
        UI.AddToggle("SP2", nil, true)
        UI.AddRange("SP2Range", nil, 1, 100, 1, 30)

        --救世之魂
        UI.AddToggle("SpiritSalvation", nil, true)
        UI.AddRange("SpiritSalvationRange", nil, 1, 100, 1, 60)

        UI.AddHeader("DPS")
        UI.AddToggle("UrsolVortex", nil, true)

        UI.AddToggle("BirdForm", nil, true)
        UI.AddToggle("StarFall", nil, true)
        UI.AddToggle("MoonStrike", nil, true)

        UI.AddToggle("Moonfire", nil, true)
        UI.AddRange("MoonfireUnits", nil, 1, 15, 1, 3)

        UI.AddToggle("SolarWrath", nil, true)
        UI.AddRange("SolarWrathHP", nil, 1, 100, 1, 50)
        UI.AddToggle("Sunfire", "阳炎术", true)
        UI.AddRange("SunfireUnits", nil, 1, 15, 1, 3)

        UI.AddHeader("Defensive")

        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 40)
        UI.AddToggle("Thorns", nil, true)
        UI.AddRange("ThornsHP", nil, 1, 100, 1, 70)
        UI.AddToggle("Barkskin", nil, true)
        UI.AddRange("BarkskinHP", nil, 1, 100, 1, 60)
        UI.AddToggle("Renewal", nil, true)
        UI.AddRange("RenewalHP", nil, 1, 100, 1, 50)

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
        if HUD.Dispel == 1 and Friend:Dispel(Spell.NatureCure) and Spell.NatureCure:Cast(Friend) then
            return true
        end
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end

local function Heals()
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

    --激活
    if Setting("Innervate") and Spell.Innervate:IsReady() then
        local ITUnits, ITCount = Player:GetFriends(40, Setting("InnervateHP"))
        if ITCount >= Setting("InnervateUnits") then
            if Spell.Innervate:Cast(Player) then
                return true
            end
        end
    end

    if Setting("Innervate") and Player.PowerPct < 5 and Player.Combat and Spell.Innervate:Cast(Player) then
        return true
    end

    --繁盛
    if Setting("Thriving") and Spell.Thriving:IsReady() then
        local TVUnits, TVCount = Player:GetFriends(40, Setting("ThrivingHP"))
        if TVCount >= Setting("ThrivingUnits") then
            if Spell.Thriving:Cast(Player) then
                return true
            end
        end
    end

    --宁静
    if Setting("Tranquility") and Spell.Tranquility:IsReady() then
        local TLUnits, TLCount = Player:GetFriends(40, Setting("TranquilityHP"))
        if TLCount >= Setting("TranquilityUnits") then
            if Spell.Tranquility:Cast(Player) then
                return true
            end
        end
    end

    for _, Friend in ipairs(Friends40Y) do
        --百花
        if Setting("Flowers") then
            local FWUnits, FWCount = Friend:GetFriends(40, Setting("FlowersHP"))
            if FWCount >= Setting("FlowersUnits") and Friend.HP <= Setting("FlowersHP") and (DMW.Time - Spell.Flowers.LastCastTime > 10) and Player.Combat then
                if Spell.Flowers:Cast(Friend) then
                    return true
                end
            end
        end

        --野性成长
        if Setting("WildGrowth") and Spell.WildGrowth:IsReady() and Spell.WildGrowth:IsReady() then
                local WGUnits, WGCount = Friend:GetFriends(40, Setting("WildGrowthHP"))
                if WGCount >= Setting("WildGrowthUnits") and Friend.HP <= Setting("WildGrowthHP") then
                    if Spell.WildGrowth:Cast(Friend) then
                        return true
                    end
                end
        end

        if Player.Combat and Friend.HP <= Setting("IronbarkHP") and Spell.Ironbark:Cast(Friend) then
            return true
        end

        if not Player.Moving and Spell.SpiritSalvation:IsReady() and Setting("SpiritSalvation") then
            if Friend.HP < Setting("SpiritSalvationRange") and Spell.SpiritSalvation:Cast(Friend) then
                return true
            end
        end

        --迅捷治愈
        if Setting("Swiftmend") and Spell.Swiftmend:IsReady() then
            if Friend.HP < Setting("SwiftmendHP") and Spell.Swiftmend:Cast(Friend) then
                return true
            end
        end

        if Friend.HP < Setting("RegrowthLOWHP") and Spell.Regrowth:Cast(Friend) then
            return true
        end

        --回春
        if Buff.Rejuvenation:Count(Friends40Y) < Setting("RejuvenationUnits") and Setting("Rejuvenation") then
            if Friend.HP <= Setting("RejuvenationHP") and Buff.Rejuvenation:Remain(Friend) < 5 and Spell.Rejuvenation:Cast(Friend) then
                return true
            end
        end

        if Buff.Regrowth:Count(Friends40Y) < Setting("RegrowthUnits") and Setting("Regrowth") then
            if Friend.HP <= Setting("RegrowthHP") and Buff.Regrowth:Remain(Friend) < 1 and Spell.Regrowth:Cast(Friend) then
                return true
            end
        end

        --生命绽放
        if Setting("Lifebloom") then
            if Friend.HP < Setting("LifebloomHP") and Spell.Lifebloom:Cast(Friend) then
                return true
            end
        end

    end
end

local function DPS()
    Player:AutoTarget(40, true)
    if (Player.Combat and not Player.Moving) and Setting("BirdForm") and not Buff.BirdForm:Exist(Player) and Spell.BirdForm:Cast(Player) then
        return true
    end
    local MFCount = Debuff.Moonfire:Count(Player40Y)
    local SFCount = Debuff.Sunfire:Count(Player40Y)
    for _, Unit in ipairs(Player40Y) do
        if Setting("UrsolVortex") and Unit.HP <= 30 and Spell.UrsolVortex:Cast(Unit) then
            return true
        end
        if Setting("StarFall") and Spell.StarFall:Cast(Unit) then
            return true
        end
        if Setting("Sunfire") and SFCount <= Setting("SunfireUnits") then
            if Debuff.Sunfire:Refresh(Unit) and not Debuff.Sunfire:Exist(Unit) then
                if Spell.Sunfire:Cast(Unit) then
                    return true
                end
            end
        end
        if Setting("Moonfire") and MFCount <= Setting("MoonfireUnits") then
            if Debuff.Moonfire:Refresh(Unit) and not Debuff.Moonfire:Exist(Unit) then
                if Spell.Moonfire:Cast(Unit) then
                    return true
                end
            end
        end
        if Setting("MoonStrike") and Spell.MoonStrike:Cast(Target) then
            return true
        end
        if Setting("SolarWrath") and Unit.HP <= Setting("SolarWrathHP") and Spell.SolarWrath:Cast(Unit) then
            return true
        end
    end
end

local function Defensive()
    if Player.Combat and Setting("Thorns") and Player.HP <= Setting("ThornsHP") and not Buff.Thorns:Exist(Player) and Spell.Thorns:Cast(Player) then
        return true
    end
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    --DP
    if Player.Combat and Setting("Barkskin") and Player.HP <= Setting("BarkskinHP") and Spell.Barkskin:Cast(Player) then
        return true
    end
    if Setting("Renewal") and Player.HP <= Setting("RenewalHP") and Spell.Renewal:Cast(Player) then
        return true
    end
end

function Druid.Restoration()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if (not Player.Combat or (Player.Moving and Player.HP <= 60)) and HUD.TravelForm == 1 and not Buff.TravelForm:Exist(Player) and DMW.Time - Spell.TravelForm.LastCastTime > 5 and Spell.TravelForm:Cast(Player) then
            return true
        end
        if (not Player.Combat or (Player.Moving and Player.HP <= 60)) and HUD.TravelForm ~= 1 and HUD.ProwlForm == 1 and not Buff.Prowl:Exist(Player) and Spell.Prowl:Cast(Player) then
            return true
        end
        if Spell.GCD:CD() == 0 then
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
