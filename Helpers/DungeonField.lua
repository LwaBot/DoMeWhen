local DMW = DMW
DMW.Helpers.DungeonField = {}
local Dungeon = DMW.Helpers.DungeonField
local Target
local Path = nil
local PathIndex = 1
local DestX, DestY, DestZ
local EndX, EndY, EndZ
local PathUpdated = false
local leaveBgBeginTime = 0
local lastQueryTime = GetTime()
local Player40Y, Player40YC, Friends200Y, Friends200YC
local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType,
instanceSubType, instanceName, averageWait, tankWait, healerWait, dpsWait, myWait, queuedTime, activeID = GetLFGQueueStats(1)
local proposalExists, id, typeID, subtypeID, name, texture, role, hasResponded, totalEncounters,
completedEncounters, numMembers, isLeader, isHoliday, proposalCategory = GetLFGProposal()
local Player, Debuff, Queued, Spell
local joinTime = 0
local lastCastFrame = CreateFrame("Frame")
local castIng = 0
local function GuidInviteRejct()
    if GuildInviteFrameDeclineButton:IsVisible() then
        GuildInviteFrameDeclineButton:Click()
    end
end

function Dungeon:Init()
    Player = DMW.Player
    Target = Player.Target or false
    Debuff = Player.Debuffs
    hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType,
    instanceSubType, instanceName, averageWait, tankWait, healerWait, dpsWait, myWait, queuedTime, activeID = GetLFGQueueStats(1)
    lastQueryTime = DMW.Time
    proposalExists, id, typeID, subtypeID, name, texture, role, hasResponded, totalEncounters,
    completedEncounters, numMembers, isLeader, isHoliday, proposalCategory = GetLFGProposal()
    Queued = hasData
    Spell = Player.Spells
    GuidInviteRejct()
    Friends200Y, Friends200YC = Player:GetFriends(2000)
    Player40Y, Player40YC = Player:GetEnemies(40)
end

function Dungeon:Join(time)
    --打开lfd
    if not PVEFrame:IsVisible() then
        LFDMicroButton:Click()
    end
    --打开pvptab
    if PVEFrameTab1:IsVisible() then
        PVEFrameTab1:Click()
    end
    --打开快速比赛tab
    if LFDQueueFrameRandom and not LFDQueueFrameRandom:IsVisible() and GroupFinderFrameGroupButton1:IsVisible() then
        GroupFinderFrameGroupButton1:Click()
    end
    --选择专精
    if LFDQueueFrameRandom and LFDQueueFrameRandom:IsVisible() and LFDQueueFrameRoleButtonHealer.checkButton:IsVisible() and LFDQueueFrameRoleButtonHealer.checkButton:GetChecked() == false then
        LFDQueueFrameRoleButtonHealer.checkButton:SetChecked(true)
    end
    if LFDQueueFrameRandom and LFDQueueFrameRandom:IsVisible() and LFDQueueFrameRoleButtonDPS.checkButton:IsVisible() and LFDQueueFrameRoleButtonDPS.checkButton:GetChecked() == false then
        LFDQueueFrameRoleButtonDPS.checkButton:SetChecked(true)
    end
    if LFDQueueFrameRandom and LFDQueueFrameRandom:IsVisible() and LFDQueueFrameRoleButtonTank.checkButton:IsVisible() and LFDQueueFrameRoleButtonTank.checkButton:GetChecked() == false then
        LFDQueueFrameRoleButtonTank.checkButton:SetChecked(true)
    end
    if DMW.Time - joinTime > 10 and joinTime ~= 0 then
        RunMacroText("/click LFDQueueFrameFindGroupButton")
        joinTime = DMW.Time
    end
    if time == 0 then
        RunMacroText("/click LFDQueueFrameFindGroupButton")
        joinTime = DMW.Time
    end
end

function Dungeon:Confirm()
    if PVPReadyDialogEnterDungeonButton:IsVisible() then
        PVPReadyDialogEnterDungeonButton:Click()
    end
end

function Dungeon:ClearPath()
    Path = nil
    PathIndex = 1
end

function Dungeon:realyMove()
    DestX = Path[PathIndex][1]
    DestY = Path[PathIndex][2]
    DestZ = Path[PathIndex][3]
    local distance = sqrt((DestX - Player.PosX) ^ 2 + (DestY - Player.PosY) ^ 2)
    if PathUpdated and Player.Moving then
        MoveForwardStop()
    end
    if distance < 1 then
        PathIndex = PathIndex + 1
        if PathIndex > #Path then
            self:ClearPath()
            return
        end
    elseif (not Player.Moving or PathUpdated) then
        PathUpdated = false
        local PlayerX, PlayerY, PlayerZ = ObjectPosition("Player")
        MoveTo(DestX, DestY, DestZ, true)
        lastX = PlayerX
        lastY = PlayerY
        lastZ = PlayerZ
    end
end

function Dungeon:CalculatePath(mapID, fromX, fromY, fromZ, toX, toY, toZ)
    return CalculatePath(mapID, fromX, fromY, fromZ, toX, toY, toZ, true, false, 1)
end

function Dungeon:MoveTo(toX, toY, toZ)
    if Path and #Path > 0 and PathIndex <= #Path then
      --  return
    end
    if not Path or PathIndex > 2 then
        PathIndex = 1
    end
    Path = self:CalculatePath(GetMapId(), Player.PosX, Player.PosY, Player.PosZ, toX, toY, toZ)
    if Path then
        EndX, EndY, EndZ = toX, toY, toZ
        PathUpdated = true
        return true
    end
    return false
end

function Dungeon:Activity()
    if  IsInLFGDungeon() then
        for i = 1, 40 do
            if  UnitIsDeadOrGhost("party" .. i) and Player.Combat then
                return  false
            end
        end
        if Target and Target.Player and not  Target.Dead and Target.Friend then
            if (Spell.GCD:CD() == 0 and not Player.Casting) then
                local distance = sqrt((Player.PosX - Target.PosX) ^ 2 + (Player.PosY - Target.PosY) ^ 2)
                if distance > DMW.Settings.profile.Dungeon.FollowDistance then
                    self:MoveTo(Target.PosX, Target.PosY, Target.PosZ)
                    self:realyMove()
                    return
                end
            end
            return
        end
        for i = 1, 5 do
            local name = UnitName("party" .. i)
            local x, y, z = ObjectPosition("party" .. i)
            Player:Update()
            if name ~= Player.Name and x and y and z and not UnitIsDeadOrGhost("party" .. i) and (Spell.GCD:CD() == 0 and not Player.Casting) then
                local distance = sqrt((Player.PosX - x) ^ 2 + (Player.PosY - y) ^ 2)
                if distance > DMW.Settings.profile.Dungeon.FollowDistance then
                    self:MoveTo(x, y, z)
                    self:realyMove()
                end
            end
            return
        end
    end
end

function Dungeon:Leave()
    if IsLFGComplete() then
        QueueStatusMinimapButton:Click()
        DropDownList1Button3:Click()
    end
end

function Dungeon:StatusCheck()
    if not DMW.Settings.profile.Dungeon.JoinRandomDungeon then
        return false
    end
    if leaveBgBeginTime == 0 then
        leaveBgBeginTime = GetTime()
    end
    return true
end

function Dungeon:Run(time)
    if not self:StatusCheck() then
        return
    end
    self:Init()
    if not IsInLFGDungeon() and proposalExists then
        AcceptProposal()
    end
    if not IsLFGComplete() and not IsInLFGDungeon() and not proposalExists and not Queued then
        self:Join(time)
    end
    if IsLFGComplete() then
        QueueStatusMinimapButton:Click()
        DropDownList1Button3:Click()
    end
    if castIng == 0 then
        self:Activity()
    end
    self:Leave()
end

local function EventTracker(self, event, ...)
    local SourceUnit = select(1, ...)
    local SpellID = select(3, ...)
    if SourceUnit == "player" and EWT and DMW.Player.Spells then
        if event == "UNIT_SPELLCAST_START" then
            castIng = DMW.Time
            MoveForwardStop()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            castIng = 0
        elseif event == "UNIT_SPELLCAST_STOP" then
        end
    end
end

lastCastFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
lastCastFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
lastCastFrame:RegisterEvent("UNIT_SPELLCAST_START")
lastCastFrame:SetScript("OnEvent", EventTracker)
