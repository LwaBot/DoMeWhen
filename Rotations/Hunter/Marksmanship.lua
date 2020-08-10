local DMW = DMW
local Hunter = DMW.Rotations.HUNTER
local Player, Buff, Debuff, Spell, Target, Pet, Trait, GCD, Pet5Y, Pet5YC, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC
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
            }},
            [2] = {
            Mode = {
                [1] = {Text = "Rotation Mode |cFF00FF00Auto", Tooltip = ""},
                [2] = {Text = "Rotation Mode |cFFFFFF00Single", Tooltip = ""}
            },},
            [3] = {
            Interrupts = {
                [1] = {Text = "Interrupts |cFF00FF00Enabled", Tooltip = ""},
                [2] = {Text = "Interrupts |cffff0000Disabled", Tooltip = ""}
            }},
        }

        UI.AddHeader("General")
        UI.AddToggle("Revive Pet", "Use Revive Pet", true)
        UI.AddToggle("BurstingShot", nil, true)
        UI.AddRange("BurstingShotHP", nil, 1, 100, 1, 60)
        UI.AddRange("BurstingShotDistance", nil, 1, 30, 1, 10)
        UI.AddToggle("TarTrap", nil, true)
        UI.AddToggle("CatchRougue", nil, true)

        UI.AddHeader("Defensive")
        UI.AddToggle("FreezingTrap", nil, true)
        UI.AddRange("FreezingTrapHP", nil, 1, 100, 1, 60)
        UI.AddToggle("Exhilaration", nil, true)
        UI.AddRange("ExhilarationHP", nil, 1, 100, 1, 50)
        UI.AddToggle("FeignDeath", nil, true)
        UI.AddRange("FeignDeathHP", nil, 1, 100, 1, 30)
        UI.AddToggle("Disengage", nil, true)
        UI.AddRange("DisengageHP", nil, 1, 100, 1, 70)
        UI.AddToggle("SurvivalOfTheFittest", nil, true)
        UI.AddRange("SurvivalOfTheFittestHP", nil, 1, 100, 1, 60)
    end
end

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Trait = Player.Traits
    Target = Player.Target or false
    Pet = Player.Pet or false
    GCD = Player:GCD()
    HUD = DMW.Settings.profile.HUD
    Friends40Y, Friends40YC = Player:GetFriends(40)
    Player40Y, Player40YC = Player:GetEnemies(40)
end

local function Cleave()
    local BSTarget = Debuff.BarbedShot:Lowest(Pet5Y) or Target
    -- actions.cleave=barbed_shot,target_if=min:dot.barbed_shot.remains,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
    if Buff.Frenzy:Exist(Pet) and Buff.Frenzy:Remain(Pet) < Player:GCDMax() then
        if Spell.BarbedShot:Cast(BSTarget) or (Spell.BarbedShot:Charges() == 0 and Spell.BarbedShot:RechargeTime() < Buff.Frenzy:Remain(Pet)) then
            return true
        end
    end
    -- actions.cleave+=/multishot,if=gcd.max-pet.cat.buff.beast_cleave.remains>0.25
    if (Player:GCDMax() - Buff.BeastCleave:Remain(Pet)) > 0.25 then
        if Spell.Multishot:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/barbed_shot,target_if=min:dot.barbed_shot.remains,if=full_recharge_time<gcd.max&cooldown.bestial_wrath.remains
    if Spell.BestialWrath:CD() > 0 and Spell.BarbedShot:FullRechargeTime() < GCD then
        if Spell.BarbedShot:Cast(BSTarget) then
            return true
        end
    end
    -- actions.cleave+=/aspect_of_the_wild
    if Player:CDs() then
        if Player.Combat and Spell.AspectOfTheWild:Cast(Player) then
            return true
        end
    end
    -- actions.cleave+=/stampede,if=buff.aspect_of_the_wild.up&buff.bestial_wrath.up|target.time_to_die<15
    -- actions.cleave+=/bestial_wrath,if=cooldown.aspect_of_the_wild.remains_guess>20|talent.one_with_the_pack.enabled|target.time_to_die<15
    if Player.Combat and Pet and not Pet.Dead and Target.TTD > 4 then
        if Spell.BestialWrath:Cast(Player) then
            return true
        end
    end
    -- actions.cleave+=/chimaera_shot
    if Spell.ChimaeraShot:Cast(Target) then
        return true
    end
    -- actions.cleave+=/a_murder_of_crows
    if Spell.BestialWrath:CD() > 0 then
        if Spell.AMurderOfCrows:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/barrage
    -- actions.cleave+=/kill_command,if=active_enemies<4|!azerite.rapid_reload.enabled
    if Pet and not Pet.Dead and (Pet5YC < 4 or Trait.RapidReload.Active) and Pet:GetDistance(Target) < 50 then
        if Spell.KillCommand:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/dire_beast
    if Spell.DireBeast:Cast(Target) then
        return true
    end
    -- actions.cleave+=/barbed_shot,target_if=min:dot.barbed_shot.remains,if=pet.cat.buff.frenzy.down&(charges_fractional>1.8|buff.bestial_wrath.up)|cooldown.aspect_of_the_wild.remains<pet.cat.buff.frenzy.duration-gcd&azerite.primal_instincts.enabled|charges_fractional>1.4|target.time_to_die<9
    if (not Buff.Frenzy:Exist(Pet) and (Spell.BarbedShot:ChargesFrac() > 1.8 or Buff.BestialWrath:Exist())) or (Spell.AspectOfTheWild:CD() < (Buff.Frenzy:Duration() - GCD) and Trait.PrimalInstincts.Active) or (Trait.DanceOfDeath.Rank > 1 and not Buff.DanceOfDeath:Exist() and Player:CritPct() > 40) or Target.TTD < 9 then
        if Spell.BarbedShot:Cast(BSTarget) then
            return true
        end
    end
    -- actions.cleave+=/focused_azerite_beam
    -- actions.cleave+=/purifying_blast
    -- actions.cleave+=/concentrated_flame
    if Spell.ConcentratedFlame:Cast(Target) then
        return true
    end
    -- actions.cleave+=/blood_of_the_enemy
    -- actions.cleave+=/the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<10
    -- actions.cleave+=/multishot,if=azerite.rapid_reload.enabled&active_enemies>2
    if Pet5YC > 2 and Trait.RapidReload.Active then
        if Spell.Multishot:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/cobra_shot,if=cooldown.kill_command.remains>focus.time_to_max&(active_enemies<3|!azerite.rapid_reload.enabled)
    if Spell.BestialWrath:CD() > Player:TTM() and (Pet5YC < 3 or not Trait.RapidReload.Active) then
        if Spell.CobraShot:Cast(Target) then
            return true
        end
    end
    -- actions.cleave+=/spitting_cobra
    if Spell.SpittingCobra:Cast(Target) then
        return true
    end
end

local function SingleTarget()
    --FreezingTrap
    if Setting("FreezingTrap") and Player.HP <= Setting("FreezingTrapHP") and  Spell.FreezingTrap:Cast(Target) then
        return true
    end
    if Setting("TarTrap") and Spell.TarTrap:Cast(Target) then
        return true
    end
    if Spell.PiercingShot:IsReady() and Spell.PiercingShot:Cast(Target) then
        return true
    end
    --pvp
    if Spell.ViperSting:IsReady() and Spell.ViperSting:Cast(Target) then
        return true
    end
    if Spell.SniperShot:IsReady() and Spell.SniperShot:Cast(Target) then
        return true
    end
    if Spell.ScorpidSting:IsReady() and Spell.ScorpidSting:Cast(Target) then
        return true
    end
    if Spell.SpiderSting:IsReady() and Spell.SpiderSting:Cast(Target) then
        return true
    end
    if Spell.ScatterShot:IsReady() and Spell.ScatterShot:Cast(Target) then
        return true
    end
    if Spell.HiExplosiveTrap:IsReady() and Spell.HiExplosiveTrap:Cast(Target) then
        return true
    end
    if Buff.MasterMarksman:Exist(Player) and (HUD.Mode == 2 or Player40YC < 3) and Spell.ArcaneShot:Cast(Target) then
        return true
    end
    if Buff.MasterMarksman:Exist(Player) and (HUD.Mode == 1 and Player40YC > 2 ) and Spell.MultiShot:Cast(Target) then
        return true
    end

    if not Debuff.HunterMark:Exist(Target) and Spell.HunterMark:Cast(Target) then
        return true
    end
    if not Debuff.SerpentSting:Exist(Target) and Spell.SerpentSting:Cast(Target) then
        return true
    end

    if not Player.Moving and not Spell.AimedShot:LastCast() and Spell.AimedShot:Cast(Target) then
        return true
    end

    if Spell.RapidFire:Cast(Target) then
        return true
    end
    if Target.Distance < 40 and Spell.DoubleTap:Cast(Player) then
        return true
    end
    if Player.Combat and Target.Distance < 40 and Spell.TrueShot:Cast(Player) then
        return true
    end
    if Setting("BurstingShot") and Player.HP <= Setting("BurstingShotHP") and Target.Distance <= Setting("BurstingShotDistance") and
        Spell.BurstingShot:Cast(Target) then
        return true
    end
    if (Buff.PreciseShots:Exist(Player) or Player.PowerPct >30)  and (HUD.Mode == 2 or Player40YC < 3) and Spell.ArcaneShot:Cast(Target) then
        return true
    end
    if (Buff.PreciseShots:Exist(Player) or Player.PowerPct > 30) and (HUD.Mode == 1 and Player40YC > 2 ) and Spell.MultiShot:Cast(Target) then
        return true
    end
    if Spell.SteadyShot:Cast(Target) then
        return true
    end
end

local function Defense()
    if Setting("Disengage") and Player.HP <= Setting("DisengageHP") and  Player.Combat and not Player.Moving  and Spell.Disengage:Cast(Player) then
        return true
    end
    if Setting("Exhilaration") and Player.HP <= Setting("ExhilarationHP") and Spell.Exhilaration:Cast(Player) then
        return true
    end
    if Setting("SurvivalOfTheFittest") and Player.HP <= Setting("SurvivalOfTheFittestHP") and Spell.SurvivalOfTheFittest:Cast(Player) then
        return true
    end
    if Setting("FeignDeath") and Player.HP <= Setting("FeignDeathHP") and Spell.FeignDeath:Cast(Player) then
        return true
    end

end


local function PetStuff()
    if not Pet then
        if Spell.CallPet2:Cast(Player) then
            return true
        end
    end
    if Pet and Pet.Dead then
        if Spell.RevivePet:Cast(Player) then
            return true
        end
    end
    if Pet and Pet.HP < 70 then
        if Spell.MendPet:Cast(Player) then
            return true
        end
    end
end

local function Interrupt()
    if HUD.Interrupts == 1 then
        if Target and Target.ValidEnemy and not Target.Dead and Spell.CounterShot:Cast(Target) then
            return true
        end
        if Target and Target.ValidEnemy and not Target.Dead and Spell.ConcussiveShot:Cast(Target) then
            return true
        end
        Player40Y, Player40YC = Player:GetEnemies(40)
        if Player40YC > 0 then
            for _, Unit in pairs(Player40Y) do
                if Unit:Interrupt() then
                    if Spell.CounterShot:Cast(Unit) then
                        return true
                    end
                    if Spell.ConcussiveShot:Cast(Unit) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function Dispel()
    if Friends40YC == 0 then
        return false
    end
    for _, Friend in ipairs(Friends40Y) do
        if HUD.Dispel == 1 and Friend:ControlDispel(Spell.ControlDispel) and Spell.ControlDispel:Cast(Player) then
            return true
        end
    end
end
function Hunter.Marksmanship()
    Locals()
    CreateSettings()
    if Rotation.Active() then
        if   Dispel() then
            return true
        end
        if Defense() then
            return true
        end
        Player:AutoTarget(40)
        if Target and not Target.Dead and (Target.ValidEnemy or Target.Attackable) then
            if not IsCurrentSpell(6603) then
                StartAttack(Target.Pointer)
            end
            if Interrupt() then
                return true
            end
                if SingleTarget() then
                    return true
                end
        end
    end
end
