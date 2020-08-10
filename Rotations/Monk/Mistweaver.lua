local DMW = DMW
local Monk = DMW.Rotations.MONK
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC
local UI = DMW.UI
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local _,_,_,beginTime,_,_,_,sid =  UnitChannelInfo("player")
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
                EssenceFontDuration = {
                    [1] = { Text = "EssenceFontDuration |cFF00FF001s", Tooltip = "" },
                    [2] = { Text = "EssenceFontDuration |cffff00002s", Tooltip = "" },
                    [3] = { Text = "EssenceFontDuration |cFF00FF003s", Tooltip = "" },
                    [4] = { Text = "EssenceFontDuration |cffff00004s", Tooltip = "" },
                    [5] = { Text = "EssenceFontDuration |cFF00FF005s", Tooltip = "" },
                    [6] = { Text = "EssenceFontDuration |cffff00006s", Tooltip = "" },
                }
            },

        }

        UI.AddHeader("Healing")

        UI.AddRange("SelfHP", nil, 1, 100, 1, 60)
        UI.AddToggle("ThunderFocusTea", nil, true)
        UI.AddRange("ThunderFocusTeaHP", nil, 0, 100, 1, 80)

        UI.AddRange("SoothingMistLowHP", nil, 0, 100, 1, 85)
        UI.AddRange("SoothingMistHighHP", nil, 0, 100, 1, 99)
        UI.AddToggle("EnvelopingMist", nil, true)
        UI.AddRange("EnvelopingMistHP", nil, 0, 100, 1, 90)

        UI.AddToggle("Vivify", nil, true)
        UI.AddRange("VivifyHP", nil, 0, 100, 1, 90)

        UI.AddToggle("RenewingMist", nil, true)
        UI.AddRange("RenewingMistHP", nil, 0, 100, 1, 85)

        UI.AddToggle("Revival", "Revival", true)
        UI.AddRange("RevivalUnits", nil, 0, 10, 1, 3)
        UI.AddRange("RevivalHP", nil, 1, 100, 1, 60)

        UI.AddToggle("SummonJadeSerpentStatue", nil, true)

        --精华泉
        UI.AddToggle("EssenceFont", nil, true)
        UI.AddRange("EssenceFontUnits", nil, 1, 20, 1, 3)
        UI.AddRange("EssenceFontHP", nil, 1, 100, 1, 70)

        UI.AddToggle("LifeCocoon", nil, true)
        UI.AddRange("LifeCocoonHP", nil, 0, 100, 1, 50)

        UI.AddToggle("RefreshingJadeWind", nil, true)
        UI.AddRange("RefreshingJadeWindUnits", nil, 0, 6, 1, 3)
        UI.AddRange("RefreshingJadeWindHP", nil, 1, 100, 1, 80)
        --清毒术
        UI.AddToggle("Detox", nil, true)

        UI.AddToggle("SP1", nil, true)
        UI.AddRange("SP1Range", nil, 1, 100, 1, 60)
        UI.AddToggle("SP2", nil, true)
        UI.AddRange("SP2Range", nil, 1, 100, 1, 30)
        --救世之魂
        UI.AddToggle("SpiritSalvation", nil, true)
        UI.AddRange("SpiritSalvationRange", nil, 1, 100, 1, 60)

        UI.AddToggle("TheRedCrane")
        UI.AddRange("TheRedCraneHP", nil, 1, 100, 1, 80)
        UI.AddRange("TheRedCraneUnits", nil, 1, 30, 1, 7)

        UI.AddHeader("DPS")

        UI.AddToggle("Attack", nil, false)
        UI.AddToggle("RisingSunKick", nil, true)
        UI.AddToggle("BlackoutKick", nil, true)
        UI.AddToggle("CracklingJadeLightning", nil, true)
        UI.AddToggle("TigerPalm", nil, true)
        UI.AddToggle("RingOfPeace", nil, true)
        UI.AddToggle("SpinningCraneKick", nil, true)
        UI.AddRange("SpinningCraneKickUnits", nil, 1, 10, 1, 3)

        UI.AddHeader("Defensive")
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 40)
        UI.AddToggle("FortifyingBrew", nil, true)
        UI.AddRange("FortifyingBrewHP", nil, 0, 100, 1, 30)
        UI.AddToggle("HealingElixir", nil, true)
        UI.AddRange("HealingElixirHP", nil, 0, 100, 1, 50)
        UI.AddToggle("Transcendence", nil, true)
        UI.AddRange("TranscendenceHP", nil, 1, 100, 1, 70)

    end
end

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Trait = Player.TraGits
    Item = Player.Items
    Target = Player.Target or false
    GCD = Player:GCD()
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs() and Target and Target.TTD > 5 and Target.Distance < 5
    Friends40Y, Friends40YC = Player:GetFriends(40)
    Player40Y, Player40YC = Player:GetEnemies(40)
    _,_,_,beginTime,_,_,_,sid =  UnitChannelInfo("player")
end

local function Heal()
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

    if Setting("EssenceFont") and not Buff.EssenceFont:Exist(Player) then
        if Spell.EssenceFont:IsReady() then
            local RaptureUnits, EFCount = Player:GetFriends(40, Setting("EssenceFontHP"))
            if EFCount >= Setting("EssenceFontUnits") then
                if Spell.EssenceFont:Cast(Player) then
                    return true
                end
            end
        end
    end
    if Setting("Revival") and Spell.Revival:IsReady() then
        local RevivalUnits, RevivalCount = Player:GetFriends(40, Setting("RevivalHP"))
        if RevivalCount >= Setting("RevivalUnits") then
            if Spell.Revival:Cast(Player) then
                return true
            end
        end
    end
    if Setting("RefreshingJadeWind") and Spell.RefreshingJadeWind:IsReady() then
        local RaptureUnits, RJCount = Player:GetFriends(40, Setting("RefreshingJadeWindHP"))
        if RJCount >= Setting("RefreshingJadeWindUnits") then
            if Spell.RefreshingJadeWind:Cast(Player) then
                return true
            end
        end
    end
    if Setting("TheRedCrane") and Spell.TheRedCrane:IsReady() then
        local RaptureUnits, RedCount = Player:GetFriends(40, Setting("TheRedCraneHP"))
        if RedCount >= Setting("TheRedCraneUnits") then
            if Spell.TheRedCrane:Cast(Target) then
                return true
            end
        end
    end
    for _,Friend in ipairs(Friends40Y) do
        if Setting("EnvelopingMist") and not Player.Moving and not Buff.EnvelopingMist:Exist(Friend)
                and Friend.HP <= Setting("EnvelopingMistHP")
                and Buff.SoothingMist:Exist(Friend)
                and Spell.EnvelopingMist:Cast(Friend) then
            return true
        end
        if Setting("Vivify") and Friend.HP <= Setting("VivifyHP") and Buff.SoothingMist:Exist(Friend) and not Player.Moving and Spell.Vivify:Cast(Friend) then
            return true
        end
        if Setting("LifeCocoon") and Player.Combat and Friend.HP > 3 and Friend.HP < Setting("LifeCocoonHP")  and Spell.LifeCocoon:Cast(Friend) then
            return true
        end
        --救赎之魂
        if not Player.Moving and Setting("SpiritSalvation") and Friend.HP < Setting("SpiritSalvationRange") and Spell.SpiritSalvation:Cast(Friend) then
            return true
        end
        if Setting("ThunderFocusTea") and Friend.HP < Setting("ThunderFocusTeaHP") and Spell.ThunderFocusTea:Cast(Player) then
            return true
        end
        --复苏之雾
        if Setting("RenewingMistHP") and Friend.HP < Setting("RenewingMistHP") and  not Buff.RenewingMist:Exist(Friend)  and Spell.RenewingMist:Cast(Friend) then
            return true
        end
        if Buff.SoothingMist:Exist(Friend) and Friend.HP >= Setting("SoothingMistHighHP") then
            RunMacroText("/stopcasting")
        end
        local SoothMax = max(Setting("SoothingMistLowHP"), Setting("EnvelopingMistHP"), Setting("VivifyHP"))
        if Setting("SoothingMistHP") and  not Player.Moving and not Buff.SoothingMist:Exist(Friend)  and Friend.HP < SoothMax and
                Spell.SoothingMist:Cast(Friend) then
            return true
        end
    end

end

local function Interrupt()
    if HUD.Interrupts == 1 then
        for _, Unit in pairs(Player40Y) do
            if Unit:Interrupt() then
                if Spell.Paralysis:Cast(Unit) then
                    return true
                end
                if Unit.Distance < 5 and Spell.LegSweep:Cast(Player) then
                    return true
                end
                if Spell.RingOfPace:Cast(Unit) then
                    return true
                end
            end
        end
    end
    return false
end

local function DPS()
    if Target and Target.ValidEnemy and not Target.Dead then
        if Setting("RisingSunKick") and Spell.RisingSunKick:Cast(Target) then
            return true
        end
        if Setting("BlackoutKick") and Spell.BlackoutKick:Cast(Target) then
            return true
        end

        if Setting("SpinningCraneKick") and Target.Distance < 8 and Spell.SpinningCraneKick:Cast(Player) then
            return true
        end
        if Spell.TigerPalm:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    if Player.Combat and Spell.Tea:Cast(Player) then
        return true
    end
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end
    if Setting("FortifyingBrew") and Player.HP <= Setting("FortifyingBrewHP") and Spell.FortifyingBrew:Cast(Player) then
        return true
    end
    if Setting("HealingElixir") and Player.HP <= Setting("HealingElixirHP") and Spell.HealingElixir:Cast(Player) then
        return true
    end
    if Setting("Transcendence") and Player.Combat and Buff.Transcendence:Remain(Player) < 1 and Spell.Transcendence:Cast(Player) then
        return true
    end
    if Setting("Transcendence") and Buff.Transcendence:Remain(Player) > 0 and Player.HP <= Setting("TranscendenceHP") and Spell.Transfer:Cast(Player) then
        return true
    end
end

local function Dispel()
    for _, Friend in ipairs(Friends40Y) do
        if HUD.Dispel == 1 and Spell.Detox:IsReady() and
                Friend:Dispel(Spell.Detox) and Spell.Detox:Cast(Friend) then
            return true
        end
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end
function Monk.Mistweaver()
    Locals()
    CreateSettings()
    if Rotation.Active() or (sid == Spell.SoothingMist.SpellID or sid == Spell.EssenceFont.SpellID) then
        if Spell.GCD:CD() ==0 then
            --断精华泉
            if sid == Spell.EssenceFont.SpellID and (DMW.Time - beginTime/1000) >= HUD.EssenceFontDuration then
                print(DMW.Time - beginTime/1000)
                RunMacroText("/stopcasting")
            end
            if Defensive() then
                return true
            end
            if Dispel() then
                return true
            end
            if Interrupt() then
                return true
            end
            if Heal() then
                return true
            end
            if HUD.Attack ~= 1 then
                return false
            end
            Player:AutoTarget(8, true)
            if Target and Target.ValidEnemy and Target.Distance < 5 and Player.Combat and not IsCurrentSpell(6603) then
                StartAttack(Target.Pointer)
            end
            if DPS() then
                return true
            end
        end
    end
end
