local DMW = DMW
local DemonHunter = DMW.Rotations.DEMONHUNTER
local Player, Buff, Debuff, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC, Player8Y, Player8YC
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
            },
            [5] = {
                Meta = {
                    [1] = {Text = "Meta |cFF00FF00Enabled", Tooltip = ""},
                    [2] = {Text = "Meta |cffff0000Disabled", Tooltip = ""}
                }
            }
        }

        UI.AddHeader("DPS")

        UI.AddToggle("ImmolationAura", nil, true)
        UI.AddToggle("FelRush", nil, true)
        UI.AddToggle("DemonBite", nil, true)
        UI.AddToggle("EyeBeam", nil, true)
        UI.AddToggle("Nemsis", nil, false)
        UI.AddToggle("BladeDance", nil, true)
        UI.AddToggle("ThrowGlaive", nil, true)
        UI.AddToggle("ChaosStrike", nil, true)
        UI.AddToggle("ChaosNova", nil, true)
        UI.AddToggle("Disrupt", nil, true)
        UI.AddToggle("ConsumeMagic", nil, true)
        UI.AddToggle("EvilBlade", nil, true)
        UI.AddToggle("EvilOutbreak", nil, true)
        UI.AddToggle("BulletComments", nil, true)
        UI.AddToggle("DarkLash", nil, true)
        UI.AddToggle("ManaBurn", nil, true)
        UI.AddToggle("RevengeJump", nil, true)
        UI.AddToggle("FocusedAzeriteBeam", nil, false)

        UI.AddHeader("Defensive")

        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("QuickShadow", nil, true)
        UI.AddRange("QuickShadowRange", nil, 1, 100, 1, 50)
        UI.AddToggle("PhantomStrike", nil, true)
        UI.AddRange("PhantomStrikeRange", nil, 1, 100, 1, 30)
        UI.AddToggle("Netherwalk", nil, true)
        UI.AddRange("NetherwalkRange", nil, 1, 100, 1, 20)
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
    Player8Y, Player8YC = Player:GetEnemies(8)
end

local function Interrupt()
    if HUD.Interrupts == 1 and Player40YC > 0 then
            for _, Unit in pairs(Player8Y) do
                if Unit:Interrupt() then
                    if Unit.Distance <= 10 and Unit:Interrupt()  and Spell.Disrupt:Cast(Unit) then
                        return true
                    end
                    --混乱新星
                    if Unit.Distance < 8  and Unit:Interrupt()  and Spell.ChaosNova:Cast(Unit) then
                        return true
                    end
                    --邪能爆发,控制
                    if Unit.Distance < 15  and Spell.EvilOutbreak:Cast(Unit) then
                        return true
                    end
                end
        end
    end
    return false
end

local function DPS()
    if Target and  (Target.ValidEnemy or Target.Attackable) and not Target.Dead then
        --献祭光环
        if  Spell.ImmolationAura:Cast(Player) then
            return true
        end
        --邪能之刃 冲刺
        if Target.Distance < 15 and Target.Distance > 3 and Setting("EvilBlade") and Spell.EvilBlade:Cast(Target) then
            return true
        end
        --恶魔变身
        if Target.Distance < 6 and HUD.Meta == 1 and Spell.Metamorphosis:Cast(Player) then
            return true
        end
        --涅墨西斯
        if Target.Distance < 6 and Setting("Nemsis") and Spell.Nemsis:Cast(Target) then
            return true
        end

        --饰品1
        local sp1Begin,sp1Duration,sp1Enable = GetInventoryItemCooldown("player",13)
        local sp2Begin,sp2Duration,sp2Enable = GetInventoryItemCooldown("player",14)
        if Target.Distance < 4 and sp1Enable and sp1Begin == 0 then
            UseInventoryItem(13)
            return true
        end
        if Target.Distance < 6 and sp2Enable and sp2Begin == 0 then
            UseInventoryItem(14)
            return true
        end
        --邪能弹幕
        if Target.Distance < 8 and Setting("BulletComments") and Spell.BulletComments:Cast(Target) then
            return true
        end


        if Target.Distance < 40 and ( Target.HP > 80 or Target.HP < 20) and Spell.NearDeath:Cast(Target) then
            return true
        end

        --眼棱
        if Target.Distance < 8 and Setting("EyeBeam") and Spell.EyeBeam:Cast(Target) then
            return true
        end
        if Target.Distance < 8 and Setting("BladeDance") and Spell.BladeDance:Cast(Target) then
            return true
        end
        if  Setting("FocusedAzeriteBeam") and not Player.Moving and Spell.FocusedAzeriteBeam:Cast(Target) then
            return true
        end

        --黑暗鞭笞 易伤
        if Target.Distance < 8 and Setting("DarkLash") and Spell.DarkLash:Cast(Target) then
            return true
        end

        if Target.Distance < 8 and Setting("ChaosStrike") and Spell.ChaosStrike:Cast(Target) then
            return true
        end

        --火红烈焰
        if Target.Distance < 40 and Spell.ConcentratedFlame:Cast(Target) then
            return true
        end

        --法力燃烧
        if Target.Distance < 8 and Setting("ManaBurn") and Spell.ManaBurn:Cast(Target) then
            return true
        end
        --吸取魔法
        if Target.Distance < 30 and Target.Dispel(Spell.ConsumeMagic) and Setting("ConsumeMagic") and Spell.ConsumeMagic:Cast(Target) then
            return true
        end

        --复仇回避
        if Target.Distance < 5 and Setting("RevengeJump") and Spell.RevengeJump:IsReady() and Spell.RevengeJump:Cast(Player) then
            return true
        end

        if Target.Distance > 6  and Setting("FelRush") and Spell.FelRush:Cast(Player) then
            return true
        end

        if Setting("ThrowGlaive") and Spell.ThrowGlaive:Cast(Target) then
            return true
        end

        if Target.Distance < 8 and Setting("DemonBite") and Spell.DemonBite:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end

    if Setting("QuickShadow") and Player.Combat and Player.HP <= Setting("QuickShadowRange") and Spell.QuickShadow:Cast(Player) then
        return true
    end

    if Setting("PhantomStrike") and Player.Combat and Player.HP <= Setting("PhantomStrikeRange") and Spell.PhantomStrike:Cast(Player) then
        return true
    end

    if Setting("Netherwalk") and Player.Combat and Player.HP <= Setting("NetherwalkRange") and Spell.Netherwalk:Cast(Player) then
        return true
    end
end

local function Dispel()
    for _, Friend in ipairs(Friends40Y) do
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end

function DemonHunter.Havoc()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if Dispel() then
            return true
        end
        if Defensive() then
            return true
        end
        Player:AutoTarget(40, true)
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
