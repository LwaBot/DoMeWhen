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
                    [1] = { Text = "C |cFF00FF00Auto", Tooltip = "" },
                    [2] = { Text = "C |cFFFFFF00Always On", Tooltip = "" },
                    [3] = { Text = "C |cffff0000Disabled", Tooltip = "" }
                }
            },
            [2] = {
                Mode = {
                    [1] = { Text = "Rotation |cFF00FF00Auto", Tooltip = "" },
                    [2] = { Text = "Rotation |cFFFFFF00Single", Tooltip = "" }
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
                    [1] = { Text = "TravelForm |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "TravelForm |cffff0000Disabled", Tooltip = "" }
                }
            },
            [7] = {
                ProwlForm = {
                    [1] = { Text = "PowlForm |cFF00FF00Enabled", Tooltip = "" },
                    [2] = { Text = "PowlForm |cffff0000Disabled", Tooltip = "" }
                }
            },
        }

        UI.AddHeader("Healing")

        UI.AddToggle("TreantForm", nil, true)

        --清除腐蚀
        UI.AddToggle("RemoveCorruption", nil, true)

        UI.AddToggle("SP1", nil, true)
        UI.AddToggle("SP2", nil, true)

        UI.AddHeader("DPS")

        UI.AddToggle("Berserk", nil, true)
        UI.AddToggle("TigerFury", nil, true)
        UI.AddToggle("Sweep", nil, true)
        UI.AddToggle("PrimalWrath", nil, true)
        UI.AddToggle("Shred", nil, true)
        UI.AddToggle("Thrash", nil, false)
        UI.AddToggle("Rake", nil, true)
        UI.AddToggle("FerociousBite", nil, true)
        UI.AddToggle("Regrowth", nil, true)
        UI.AddRange("RegrowthHP", nil, 1, 100, 1, 50)
        UI.AddToggle("BirdForm", nil, true)
        UI.AddToggle("StarFall", nil, true)
        UI.AddToggle("MoonStrike", nil, true)
        UI.AddToggle("Maim", nil, true)

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
        UI.AddToggle("SurvivalInstincts", nil, true)
        UI.AddRange("SurvivalInstinctsHP", nil, 1, 100, 1, 50)
        UI.AddToggle("Renewal", nil, true)
        UI.AddRange("RenewalHP", nil, 1, 100, 1, 70)
        UI.AddToggle("FrenziedRegeneration", nil, true)
        UI.AddRange("FrenziedRegenerationHP", nil, 1, 100, 1, 50)
        UI.AddToggle("Ironfur", nil, true)
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
        if not Player.Moving and HUD.Dispel == 1 and Friend:Dispel(Spell.RemoveCorruption) and Spell.RemoveCorruption:Cast(Friend) then
            return true
        end
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end

local function DPS()
    if not Target or not Target.Attackable or Target.Dead then
        return false
    end
    if HUD.ProwlForm == 1 and not Buff.CatForm:Exist(Player) and not Buff.FrenziedRegeneration:Exist(Player) and Spell.CatForm:Cast(Player) then
        return true
    end
    if Setting("Rake") and Buff.Prowl:Exist(Player) and not Debuff.Rake:Exist(Target) and Spell.Rake:Cast(Target) then
        return true
    end
    --火红烈焰
    if Target.Distance < 40 and Spell.ConcentratedFlame:Cast(Target) then
        return true
    end
    if Target.Distance < 40 and (Target.HP > 80 or Target.HP <= 20) and Spell.NearDeath:Cast(Target) then
        return true
    end
    if Target.Distance < 16 and Target:Interrupt() and HUD.Interrupts == 1 and Spell.SkullBash:Cast(Target) then
        return true
    end
    if Target.Distance > 8 and Target.Distance < 28 and HUD.Interrupts == 1 and Spell.WildCharge:IsReady() and Spell.WildCharge:Cast(Target) then
        return true
    end
    if Target.Distance < 8 and Target:Interrupt() and Setting("Maim") and Spell.Maim:Cast(Target) then
        return true
    end
    --饰品1
    local sp1Begin, sp1Duration, sp1Enable = GetInventoryItemCooldown("player", 13)
    local sp2Begin, sp2Duration, sp2Enable = GetInventoryItemCooldown("player", 14)
    if Player.Combat and Setting("SP1") and Target.Distance < 6 and sp1Enable and sp1Begin == 0 then
        UseInventoryItem(13)
        return true
    end
    if Player.Combat and Setting("SP2") and Target.Distance < 6 and sp2Enable and sp2Begin == 0 then
        UseInventoryItem(14)
        return true
    end
    if Player.Combat and Target.ValidEnemy and Setting("Berserk") and Spell.Berserk:Cast(Player) then
        return true
    end
    if Player.Combat and Target.ValidEnemy and Setting("TigerFury") and Spell.TigerFury:Cast(Player) then
        return true
    end

    if Buff.Predator:Exist(Player) and Setting("Regrowth") and Spell.Regrowth:Cast(Player) then
        return true
    end
    if Setting("PrimalWrath") and ((not Debuff.Rip:Exist(Target)) or Buff.BloodClaw:Exist(Player)) and Spell.PrimalWrath:Cast(Target) then
        return true
    end
    if not Setting("PrimalWrath") and (not Debuff.Rip:Exist(Target) or Buff.BloodClaw:Exist(Player)) and Spell.Rip:Cast(Target) then
        return true
    end
    if (Player.ComboPoints >= 5 or (Player.ComboPoints >= 2 and Buff.BloodClaw:Exist(Player))) and Setting("FerociousBite") and Spell.FerociousBite:Cast(Target) then
        return true
    end
    if Setting("Rake") and not Buff.BloodClaw:Exist(Player) and not Debuff.Rake:Exist(Target) and Spell.Rake:Cast(Target) then
        return true
    end
    if Buff.EnergySave:Exist(Player) and Setting("Shred") and Debuff.Rake:Exist(Target) and Spell.Shred:Cast(Target) then
        return true
    end
    if (Buff.EnergySave:Exist(Player) or not Debuff.Thrash:Exist(Target)) and Setting("Thrash") and Spell.Thrash:Cast(Target) then
        return true
    end
    if Setting("Sweep") and Spell.Sweep:Cast(Target) then
        return true
    end

    local MFCount = Debuff.Moonfire:Count(Player40Y)
    local SFCount = Debuff.Sunfire:Count(Player40Y)
    for _, Unit in ipairs(Player40Y) do
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
        if Setting("MoonStrike") and Spell.MoonStrike:IsReady() then
            if Spell.MoonStrike:Cast(Unit) then
                return true
            end
        end
        if Setting("SolarWrath") and Spell.SolarWrath:IsReady() then
            if Spell.SolarWrath:Cast(Unit) then
                return true
            end
        end
    end
end

local function Defensive()
    if Player.Moving and Spell.Dash:IsReady() and Spell.Dash:Cast(Player) then
        return true
    end
    if Player.Combat and Setting("Thorns") and not Buff.Thorns:Exist(Player) and Spell.Thorns:Cast(Player) then
        return true
    end
    if Player.Combat and Setting("SurvivalInstincts") and Player.HP <= Setting("SurvivalInstinctsHP") and not Buff.SurvivalInstincts:Exist(Player) and Spell.SurvivalInstincts:Cast(Player) then
        return true
    end
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Setting("Renewal") and Spell.Renewal:IsReady() and Player.HP <= Setting("RenewalHP") and Spell.Renewal:Cast(Player) then
        return true
    end
    if Setting("FrenziedRegeneration") and Player.HP <= Setting("FrenziedRegenerationHP") and Spell.FrenziedRegeneration:CD() < 3 and not Buff.BearForm:Exist(Player) and
            Spell.BearForm:Cast(Player) then
        return true
    end
    if Setting("FrenziedRegeneration") and Player.HP <= Setting("FrenziedRegenerationHP") and Spell.FrenziedRegeneration:CD() < 3 and Buff.BearForm:Exist(Player) and
            not Buff.FrenziedRegeneration:Exist(Player) and
            Spell.FrenziedRegeneration:Cast(Player) then
        return true
    end
    if Setting("Ironfur") and Spell.Ironfur:CD() < 3 and not Buff.Ironfur:Exist(Player) and Buff.BearForm:Exist(Player) and
            Spell.Ironfur:Cast(Player) then
        return true
    end
    if Setting("Regrowth") and Player.HP <= Setting("RegrowthHP") and not Buff.FrenziedRegeneration:Exist(Player) and Spell.Regrowth:Cast(Player) then
        return true
    end
end

function Druid.Feral()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if (not Player.Combat or (Player.Moving and Player.HP <= 60)) and (not Target or not Target.ValidEnemy) and HUD.TravelForm == 1
                and not Buff.TravelForm:Exist(Player) and Spell.TravelForm:Cast(Player) then
            return true
        end
        if (not Player.Combat or (Player.Moving and Player.HP <= 60)) and HUD.TravelForm ~= 1 and HUD.ProwlForm == 1
                and not Buff.CatForm:Exist(Player) and Spell.CatForm:Cast(Player) then
            return true
        end
        if not Player.Combat and Buff.CatForm:Exist(Player) and not Buff.Prowl:Exist(Player) and Spell.Prowl:Cast(Player) then
            return true
        end
        if Defensive() then
            return true
        end
        if Dispel() then
            return true
        end
        if HUD.Attack == 1 and DPS() then
            return true
        end
    end
end
