local DMW = DMW
local GameObject = DMW.Classes.GameObject

function GameObject:New(Pointer)
    self.Pointer = Pointer
    self.Name = ObjectName(Pointer)
    self.ObjectID = ObjectID(Pointer)
end

function GameObject:Update()
    self.NextUpdate = DMW.Time + (math.random(100, 400) / 1000)
    self.PosX, self.PosY, self.PosZ = ObjectPosition(self.Pointer)
    self.Distance = self:GetDistance()
    if not self.Name or self.Name == "" then
        self.Name = ObjectName(self.Pointer)
    end
    self.Herb = self:IsHerb()
    self.Ore = self:IsOre()
    self.BgFlag  = self:IsBgFlag()
    self.Trackable = self:IsTrackable()
end

function GameObject:GetDistance(OtherUnit)
    OtherUnit = OtherUnit or DMW.Player
    return sqrt(((self.PosX - OtherUnit.PosX) ^ 2) + ((self.PosY - OtherUnit.PosY) ^ 2) + ((self.PosZ - OtherUnit.PosZ) ^ 2))
end


function GameObject:IsHerb()
    if DMW.Settings.profile.Tracker.Herbs and DMW.Enums.Herbs[self.ObjectID] and (not DMW.Settings.profile.Tracker.CheckRank or (DMW.Player.Professions.Herbalism and DMW.Enums.Herbs[self.ObjectID].SkillReq <= DMW.Player.Professions.Herbalism)) and (not DMW.Settings.profile.Tracker.HideGrey or (DMW.Player.Professions.Herbalism and DMW.Enums.Herbs[self.ObjectID].SkillReq > (DMW.Player.Professions.Herbalism - 100))) then
        return true
    end
    return false
end
--301091
function GameObject:IsBgFlag()
    if not  DMW.Settings.profile.Tracker.TrackFlag then
        return false
    end
    if  self.ObjectID == DMW.Enums.BgFlags.ControlPoint then
        return true
    end
    local faction = UnitFactionGroup("player")
    if  faction == "Horde" and self.ObjectID == DMW.Enums.BgFlags.ALLIANCE then
        return true
    end
    if faction == "Alliance" and self.ObjectID == DMW.Enums.BgFlags.HORDE then
        return true
    end
    return false
end

function GameObject:IsOre()
    if DMW.Settings.profile.Tracker.Ore and DMW.Enums.Ore[self.ObjectID] and (not DMW.Settings.profile.Tracker.CheckRank or (DMW.Player.Professions.Mining and DMW.Enums.Ore[self.ObjectID].SkillReq <= DMW.Player.Professions.Mining)) and (not DMW.Settings.profile.Tracker.HideGrey or (DMW.Player.Professions.Mining and DMW.Enums.Ore[self.ObjectID].SkillReq > (DMW.Player.Professions.Mining - 100))) then
        return true
    end
    return false
end

function GameObject:IsTrackable() --TODO: enums
    if DMW.Settings.profile.Tracker.Trackable and DMW.Enums.Trackable[self.ObjectID] then
        return true
    end
    if DMW.Settings.profile.Tracker.TrackObjects and DMW.Settings.profile.Tracker.TrackObjects ~= "" then
        for k in string.gmatch(DMW.Settings.profile.Tracker.TrackObjects, "([^,]+)") do
            if strmatch(string.lower(self.Name), string.lower(string.trim(k))) then
                return true
            end
        end
    end
    return false
end
