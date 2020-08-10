local DMW = DMW
local Unit = DMW.Classes.Unit

function Unit:New(Pointer)
    self.Pointer = Pointer
    self.Name = UnitName(Pointer)

    self.GUID = UnitGUID(Pointer)
    self.Player = UnitIsPlayer(Pointer)
    if self.Player then
        self.Class = select(2, UnitClass(Pointer)):gsub("%s+", "")
    end
    self.Friend = UnitIsFriend("player", self.Pointer)
    self.CombatReach = UnitCombatReach(Pointer)
    self.Level = UnitLevel(Pointer)
    self.PosX, self.PosY, self.PosZ = ObjectPosition(Pointer)
    self.ObjectID = ObjectID(Pointer)
    DMW.Functions.AuraCache.Refresh(Pointer)
end

function Unit:Update()
    self.NextUpdate = DMW.Time + (math.random(100, 400) / 1000)
    self.PosX, self.PosY, self.PosZ = ObjectPosition(self.Pointer)
    self.Distance = self:GetDistance()
    self.Dead = UnitIsDeadOrGhost(self.Pointer)
    self.Health = UnitHealth(self.Pointer)
    self.HealthMax = UnitHealthMax(self.Pointer)
    self.HP = self.Health / self.HealthMax * 100
    self.TTD = self:GetTTD()
    self.LoS = false
    if self.Distance < 50 and not self.Dead then
        self.LoS = self:LineOfSight()
    end
    self.Attackable = UnitCanAttack("player", self.Pointer) or false
    self.ValidEnemy = self.Attackable and self:IsEnemy() or false
    self.Target = UnitTarget(self.Pointer)
    self.Moving = GetUnitSpeed(self.Pointer) > 0
    self.Facing = ObjectIsFacing("Player", self.Pointer)
    self.Trackable = self:IsTrackable()
end

function Unit:UpdatePosition()
    self.PosX, self.PosY, self.PosZ = ObjectPosition(self.Pointer)
end

function Unit:GetDistance(OtherUnit)
    OtherUnit = OtherUnit or DMW.Player
    if OtherUnit == DMW.Player and DMW.Enums.MeleeSpell[DMW.Player.SpecID] and IsSpellInRange(GetSpellInfo(DMW.Enums.MeleeSpell[DMW.Player.SpecID]), self.Pointer) == 1 then
        return 0
    end
    return sqrt(((self.PosX - OtherUnit.PosX) ^ 2) + ((self.PosY - OtherUnit.PosY) ^ 2) + ((self.PosZ - OtherUnit.PosZ) ^ 2)) - ((self.CombatReach or 0) + (OtherUnit.CombatReach or 0))
end

function Unit:LineOfSight(OtherUnit)
    if DMW.Enums.LoS[self.ObjectID] then
        return true
    end
    OtherUnit = OtherUnit or DMW.Player
    return TraceLine(self.PosX, self.PosY, self.PosZ + 2, OtherUnit.PosX, OtherUnit.PosY, OtherUnit.PosZ + 2, 0x100010) == nil
end

function Unit:IsEnemy()
    return self.LoS and self.Attackable and self:HasThreat() and (not self.Friend or UnitIsUnit(self.Pointer, "target")) and not self:CCed()
end

function Unit:IsTrackable()
    if DMW.Settings.profile.Tracker.TrackUnits ~= nil and DMW.Settings.profile.Tracker.TrackUnits ~= "" and not self.Player then
        for k in string.gmatch(DMW.Settings.profile.Tracker.TrackUnits, "([^,]+)") do
            if strmatch(string.lower(self.Name), string.lower(string.trim(k))) then
                return true
            end
        end
    elseif self.Player and (DMW.Settings.profile.Tracker.TrackPlayersAny and DMW.Player.Pointer ~= self.Pointer) or (DMW.Settings.profile.Tracker.TrackPlayersEnemy and UnitCanAttack("player", self.Pointer)) then
        return true
    elseif self.Player and DMW.Settings.profile.Tracker.TrackPlayers ~= nil and DMW.Settings.profile.Tracker.TrackPlayers ~= "" then
        for k in string.gmatch(DMW.Settings.profile.Tracker.TrackPlayers, "([^,]+)") do
            if strmatch(string.lower(self.Name), string.lower(string.trim(k))) then
                return true
            end
        end
    end
    return false
end

function Unit:IsBoss()
    local Classification = UnitClassification(self.Pointer)
    if Classification == "worldboss" or Classification == "rareelite" then
        return true
    elseif DMW.Player.EID then
        for i = 1, 5 do
            if UnitIsUnit("boss" .. i, self.Pointer) then
                return true
            end
        end
    end
    return false
end

function Unit:HasThreat()
    if DMW.Enums.Threat[self.ObjectID] then
        return true
    elseif DMW.Enums.EnemyBlacklist[self.ObjectID] then
        return false
    elseif DMW.Player.Instance ~= "none" and UnitAffectingCombat(self.Pointer) then
        return true
    elseif DMW.Player.Instance == "none" and (DMW.Enums.Dummy[self.ObjectID] or UnitIsUnit(self.Pointer, "target")) then
        return true
    end
    if self.Target and (UnitIsUnit(self.Target, "player") or UnitIsUnit(self.Target, "pet") or UnitInParty(self.Target)) then
        return true
    end
    return false
end

function Unit:GetEnemies(Yards)
    local Table = {}
    local Count = 0
    for _, v in pairs(DMW.Enemies) do
        if self:GetDistance(v) <= Yards then
            table.insert(Table, v)
            Count = Count + 1
        end
    end
    return Table, Count
end

function Unit:GetFriends(Yards, HP)
    local Table = {}
    local Count = 0
    for _, v in pairs(DMW.Friends.Units) do
        if (not HP or v.HP < HP) and self:GetDistance(v) <= Yards then
            table.insert(Table, v)
            Count = Count + 1
        end
    end
    return Table, Count
end

function Unit:HardCC()
    if DMW.Enums.HardCCUnits[self.ObjectID] then
        return true
    end
    local CastingInfo = {UnitCastingInfo(self.Pointer)} --name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId
    local ChannelInfo = {UnitChannelInfo(self.Pointer)} --name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId
    local StartTime, SpellID
    if CastingInfo[4] then
        StartTime = CastingInfo[4] / 1000
        SpellID = CastingInfo[9]
    elseif ChannelInfo[4] then
        StartTime = ChannelInfo[4] / 1000
        SpellID = ChannelInfo[8]
    end
    if StartTime and SpellID and DMW.Enums.HardCCCasts[SpellID] and (DMW.Time - StartTime) > 0.4 and not self:InSanguine() then
        return true
    end
    return false
end

function Unit:Interrupt()
    local InterruptTarget = DMW.Settings.profile.Enemy.InterruptTarget
    if (InterruptTarget == 2 and not UnitIsUnit(self.Pointer, "target")) or (InterruptTarget == 3 and not UnitIsUnit(self.Pointer, "focus")) or (InterruptTarget == 4 and not UnitIsUnit(self.Pointer, "mouseover")) then
        return false
    end
    local Settings = DMW.Settings.profile
    local StartTime, EndTime, SpellID, Type
    local CastingInfo = {UnitCastingInfo(self.Pointer)} --name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId
    local ChannelInfo = {UnitChannelInfo(self.Pointer)} --name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId
    if CastingInfo[5] and not CastingInfo[8] then
        StartTime = CastingInfo[4] / 1000
        EndTime = CastingInfo[5] / 1000
        SpellID = CastingInfo[9]
        Type = "Cast"
    elseif ChannelInfo[5] and not ChannelInfo[7] then
        StartTime = ChannelInfo[4] / 1000
        SpellID = ChannelInfo[8]
        Type = "Channel"
    else
        return false
    end
    if not DMW.Enums.InterruptBlacklist[SpellID] then
        if Type == "Cast" then
            local Pct = (DMW.Time - StartTime) / (EndTime - StartTime) * 100
            if Pct >= Settings.Enemy.InterruptPct then
                return true
            end
        else
            local Delay = Settings.Enemy.ChannelInterrupt - 0.2 + (math.random(1, 4) / 10)
            if Delay < 0.1 then
                Delay = 0.1
            end
            if (DMW.Time - StartTime) > Delay then
                return true
            end
        end
    end
    return false
end

function Unit:Dispel(Spell)
    local AuraCache = DMW.Tables.AuraCache[self.Pointer]
    if not AuraCache or not Spell then
        return false
    end
    local DispelTypes = {}
    for k, v in pairs(DMW.Enums.DispelSpells[Spell.SpellID]) do
        DispelTypes[v] = true
    end
    local Elapsed
    local Delay = DMW.Settings.profile.DispelDelay - 0.2 + (math.random(1, 4) / 10)
    local ReturnValue = false
    --name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId
    local AuraReturn
    for _, Aura in pairs(AuraCache) do
        if (self.Friend and Aura.Type == "HARMFUL") or (not self.Friend and Aura.Type == "HELPFUL") then
            AuraReturn = Aura.AuraReturn 
            Elapsed = AuraReturn[5] - (AuraReturn[6] - DMW.Time)
            if AuraReturn[4] and DispelTypes[AuraReturn[4]] and Elapsed > Delay then
                if DMW.Enums.NoDispel[AuraReturn[10]] then
                    ReturnValue = false
                    break                
                elseif DMW.Enums.SpecialDispel[AuraReturn[10]] and DMW.Enums.SpecialDispel[AuraReturn[10]].Stacks then 
                    if AuraReturn[3] >= DMW.Enums.SpecialDispel[AuraReturn[10]].Stacks then
                        ReturnValue = true
                    else
                        ReturnValue = false
                        break
                    end
                elseif DMW.Enums.SpecialDispel[AuraReturn[10]] and DMW.Enums.SpecialDispel[AuraReturn[10]].Range then
                    if select(2, self:GetFriends(DMW.Enums.SpecialDispel[AuraReturn[10]].Range)) < 2 then
                        ReturnValue = true
                    else
                        ReturnValue = false
                        break
                    end
                else
                    ReturnValue = true
                end
            end
        end
    end
    return ReturnValue
end
function Unit:ControlDispel(Spell)
    local AuraCache = DMW.Tables.AuraCache[self.Pointer]
    if not AuraCache or not Spell then
        return false
    end
    local DispelSpellList = {}
    for k, v in pairs(DMW.Enums.ControlDispel) do
        DispelSpellList[k] = true
    end
    local Elapsed
    local Delay = DMW.Settings.profile.DispelDelay - 0.2 + (math.random(1, 4) / 10)
    local ReturnValue = false
    --name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId
    local AuraReturn
    for _, Aura in pairs(AuraCache) do
        if (self.Friend and Aura.Type == "HARMFUL") then
            AuraReturn = Aura.AuraReturn
            Elapsed = AuraReturn[5] - (AuraReturn[6] - DMW.Time)
            if  DispelSpellList[AuraReturn[10]] and Elapsed > Delay then
                ReturnValue = true
            end
        end
    end
    return ReturnValue
end

function Unit:PredictPosition(Time)
    local MoveDistance = GetUnitSpeed(self.Pointer) * Time
    if MoveDistance > 0 then
        local X, Y, Z = self.PosX, self.PosY, self.PosZ
        local Angle = ObjectFacing(self.Pointer)
        local UnitTargetDist = 0
        if self.Target then
            local TX, TY, TZ = ObjectPosition(self.Target)
            local TSpeed = GetUnitSpeed(self.Target)
            if TSpeed > 0 then
                local TMoveDistance = TSpeed * Time
                local TAngle = ObjectFacing(self.Target)
                TX = TX + cos(TAngle) * TMoveDistance
                TY = TY + sin(TAngle) * TMoveDistance
            end
            UnitTargetDist = sqrt(((TX - X) ^ 2) + ((TY - Y) ^ 2) + ((TZ - Z) ^ 2)) - ((self.CombatReach or 0) + (UnitCombatReach(self.Target) or 0))
            if UnitTargetDist < MoveDistance then
                MoveDistance = UnitTargetDist
            end
            Angle = rad(atan2(TY - Y, TX - X))
            if Angle < 0 then
                Angle = rad(360 + atan2(TY - Y, TX - X))
            end
        end
        X = X + cos(Angle) * MoveDistance
        Y = Y + cos(Angle) * MoveDistance
        return X, Y, Z
    end
    return self.X, self.Y, self.Z
end

function Unit:InSanguine()
    for _, v in pairs(DMW.Tables.Sanguine) do
        if sqrt(((self.PosX - v.PosX) ^ 2) + ((self.PosY - v.PosY) ^ 2) + ((self.PosZ - v.PosZ) ^ 2)) < 5 then
            return true
        end
    end
    return false
end

function Unit:AuraByID(SpellID, OnlyPlayer)
    OnlyPlayer = OnlyPlayer or false
    local SpellName = GetSpellInfo(SpellID)
    Unit = self.Pointer
    if DMW.Tables.AuraCache[Unit] ~= nil and DMW.Tables.AuraCache[Unit][SpellName] ~= nil and (not OnlyPlayer or DMW.Tables.AuraCache[Unit][SpellName]["player"] ~= nil) then
        local AuraReturn
        if OnlyPlayer then
            AuraReturn = DMW.Tables.AuraCache[Unit][SpellName]["player"].AuraReturn
        else
            AuraReturn = DMW.Tables.AuraCache[Unit][SpellName].AuraReturn
        end
        return unpack(AuraReturn)
    end
    return nil
end

function Unit:CCed()
    for SpellID, _ in pairs(DMW.Enums.CCBuffs) do
        if self:AuraByID(SpellID) then
            return true
        end
    end
    return false
end