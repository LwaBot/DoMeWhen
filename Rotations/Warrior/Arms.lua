local DMW = DMW
local Warrior = DMW.Rotations.WARRIOR
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
        }

        UI.AddHeader("DPS")
        UI.AddRange("RageReserve", nil, 1, 100, 1, 50)
        UI.AddToggle("VictoryRush", nil, false)
        UI.AddToggle("Charge", nil, true)
        UI.AddToggle("Bladestorm", nil, true)
        UI.AddToggle("Overpower", nil, true)
        UI.AddToggle("Avatar", nil, true)
        UI.AddRange("AvatarUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("DeadlyCalm", nil, true)
        UI.AddToggle("Warbreaker", nil, true)
        UI.AddRange("WarbreakerUnits", nil, 1, 10, 1, 3)
        UI.AddToggle("GiantAttack", nil, true)
        UI.AddToggle("Slam", nil, true)
        UI.AddToggle("MortalStrike", nil, true)
        UI.AddToggle("Skullsplitter", nil, true)
        UI.AddToggle("Rend", nil, true)
        UI.AddToggle("Cleave", nil, true)
        UI.AddToggle("Bladestorm", nil, true)
        UI.AddRange("BladestormUnits", nil, 1, 10, 1, 4)
        UI.AddToggle("Execute", nil, true)
        UI.AddToggle("Whirlwind", nil, true)
        UI.AddRange("WhirlwindUnits", nil, 3, 10, 1, 3)
        UI.AddToggle("BerserkerRage", "狂暴之怒", true)
        UI.AddToggle("ImpendingVictory", nil, true)
        UI.AddRange("ImpendingVictoryHP", nil, 1, 100, 1, 30)
        UI.AddToggle("FocusedAzeriteBeam", nil, false)
        UI.AddToggle("IntimidatingShout", nil, true)
        UI.AddToggle("Hamstring", nil, true)
        UI.AddToggle("SweepingStrikes", nil, true)
        UI.AddToggle("Ravager", nil, true)
        UI.AddToggle("Pummel", nil, true)
        UI.AddToggle("SP1", nil, true)
        UI.AddToggle("SP2", nil, true)
        --pvp
        UI.AddToggle("SharpenBlade", "打磨利刃", true)

        UI.AddHeader("Defensive")
        UI.AddToggle("Healthstone", nil, true)
        UI.AddRange("Healthstone HP", nil, 0, 100, 1, 60)
        UI.AddToggle("DiebytheSword", nil, true)
        UI.AddRange("DiebytheSwordHP", nil, 1, 100, 1, 50)
        UI.AddToggle("SpellReflection", nil, true)
        UI.AddRange("SpellReflectionHP", nil, 1, 100, 1, 60)
        UI.AddToggle("RallyingCry", nil, true)
        UI.AddRange("RallyingCryHP", nil, 1, 100, 1, 40)
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

local function Interrupt()
    if HUD.Interrupts == 1 then
        if Target and Target.ValidEnemy and not Target.Dead then

            if Spell.StormBolt:Cast(Target) then
                return true
            end
            if Spell.Pummel:Cast(Target) then
                return true
            end
            if Spell.IntimidatingShout:Cast(Target) then
                return true
            end
        end
        local Player8Y, Player8YC = Player:GetEnemies(8)
        if Player8YC > 0 then
            for _, Unit in pairs(Player8Y) do
                if Unit:Interrupt() then
                    if Spell.StormBolt:IsReady() and Spell.StormBolt:Cast(Unit) then
                        return true
                    end
                    if Spell.Pummel:IsReady() and Spell.Pummel:Cast(Unit) then
                        return true
                    end
                    if Spell.IntimidatingShout:IsReady() and Spell.IntimidatingShout:Cast(Target) then
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
        if Interrupt() then
            return true
        end
        local EnemyUnits, EnemyCount = Player:GetEnemies(8)
        if Setting("Hamstring") and not Debuff.Hamstring:Exist(Target) and Spell.Hamstring:Cast(Target) then
            return true
        end
        if Setting("SharpenBlade") and Spell.SharpenBlade:Cast(Player) then
            return true
        end
        if Setting("GiantAttack") and Spell.GiantAttack:Cast(Target) then
            return true
        end
        if Setting("DeadlyCalm") and Player.Combat and Spell.DeadlyCalm:IsReady() and Spell.DeadlyCalm:Cast(Target) then
            return true
        end
        if Setting("SweepingStrikes") and EnemyCount == 2 and Spell.SweepingStrikes:Cast(Player) then
            return true
        end
        if Setting("Cleave") and EnemyCount >= 3 and Spell.Cleave:IsReady() and Spell.Cleave:Cast(Target) then
            return true
        end
        if Setting("VictoryRush") and Spell.VictoryRush:IsReady() and Spell.VictoryRush:Cast(Target) then
            return true
        end
        if Setting("Avatar") and Player.Combat and (EnemyCount >= Setting("AvatarUnits") or Player:CDs()) and Spell.Avatar:Cast(Player) then
            return true
        end
        if Setting("Warbreaker") and EnemyCount >= Setting("WarbreakerUnits") and Spell.Warbreaker:Cast(Player) then
            return true
        end
        if Setting("Overpower") and Spell.Overpower:Cast(Target) then
            return true
        end
        if Setting("Execute") and Target.Distance <= 15 and Spell.Execute:IsReady() and Spell.Execute:Cast(Target) then
            return true
        end
        if Player.Combat and Setting("BerserkerRage") and Spell.BerserkerRage:Cast(Player) then
            return true
        end

        if Setting("MortalStrike") and Spell.MortalStrike:Cast(Target) then
            return true
        end

        if Setting("ImpendingVictory") and Target.Distance <= 8 and Target.HP <= Setting("ImpendingVictoryHP") and Spell.ImpendingVictory:Cast(Target) then
            return true
        end
        if Setting("Charge") and Target.Distance > 8 and Target.Distance < 25 and not Spell.Charge:LastCast() and Spell.Charge:Cast(Target) then
            return true
        end
        if Setting("Bladestorm") and Target.Distance <= 8 and EnemyCount >= Setting("BladestormUnits") and Spell.Bladestorm:Cast(Player) then
            return true
        end

        if Player.Combat and Setting("FocusedAzeriteBeam") and not Player.Moving and Spell.FocusedAzeriteBeam:Cast(Target) then
            return true
        end
        if Player.Combat and Target.Distance < 40 and Spell.NearDeath:Cast(Target) then
            return true
        end
        --火红烈焰
        if Player.Combat and Target.Distance < 40 and Spell.ConcentratedFlame:Cast(Target) then
            return true
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
        if Setting("Whirlwind") and EnemyCount >= Setting("WhirlwindUnits") and Target.Distance <= 8 and Spell.Whirlwind:Cast(Target) then
            return true
        end
        if Setting("Slam") and Player.PowerPct >= Setting("RageReserve") and Spell.Slam:Cast(Target) then
            return true
        end
    end
end

local function Defensive()
    if not Buff.BattleShout:Exist(Player) and Spell.BattleShout:Cast(Player) then
        return true
    end
    --HS
    if Setting("Healthstone") and Player.HP <= Setting("Healthstone HP") and Item.Healthstone:Use(Player) then
        return true
    end

    if Setting("DiebytheSword") and Player.HP <= Setting("DiebytheSwordHP") and Spell.DiebytheSword:Cast(Player) then
        return true
    end

    if Setting("SpellReflection") and Player.Combat and Player.HP <= Setting("SpellReflectionHP") and Spell.SpellReflection:Cast(Target) then
        return true
    end

    if Setting("RallyingCry") and Player.HP <= Setting("RallyingCryHP") and Spell.RallyingCry:Cast(Player) then
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
function Warrior.Arms()
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
        if Target and Target.ValidEnemy and Target.Distance < 5 and Player.Combat and not IsCurrentSpell(6603) then
            StartAttack(Target.Pointer)
        end
        if Spell.GCD:CD() == 0 and DPS() then
            return true
        end
    end
end
