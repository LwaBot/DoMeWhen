local DMW = DMW
DMW.Helpers.BattleField = {}
local Battle = DMW.Helpers.BattleField
local leaveBgBeginTime = 0
local lastQueryTime = GetTime()
local Player40Y, Player40YC, Friends200Y, Friends200YC
local status, mapName, teamSize, registeredMatch, suspendedQueue, queueType, gameType, role = GetBattlefieldStatus(1)
local Player, Debuff, Queued

local function GuidInviteRejct()
    if GuildInviteFrameDeclineButton:IsVisible() then
        GuildInviteFrameDeclineButton:Click()
    end
end

function  Battle:Init()
    Player = DMW.Player
    Debuff = Player.Debuffs
    Friends200Y, Friends200YC = Player:GetFriends(2000)
    Player40Y, Player40YC = Player:GetEnemies(40)
    if DMW.Time - lastQueryTime > 1 then
        status, mapName, teamSize, registeredMatch, suspendedQueue, queueType, gameType, role = GetBattlefieldStatus(1)
        lastQueryTime = DMW.Time
    end
    Queued = status == "queued"
    GuidInviteRejct()
end

function Battle:JoinBgQueue()
    --打开lfd
    if   not PVEFrame:IsVisible() then
        LFDMicroButton:Click()
    end
    --打开pvptab
    if PVEFrameTab2:IsVisible() then
        PVEFrameTab2:Click()
    end
    --打开快速比赛tab
    if  DMW.Settings.profile.Battle.JoinBattle and  HonorFrame and not HonorFrame:IsVisible() and PVPQueueFrameCategoryButton1:IsVisible() then
        PVPQueueFrameCategoryButton1:Click()
    end
    if  DMW.Settings.profile.Battle.JoinRank and  ConquestFrame and not ConquestFrame:IsVisible() and PVPQueueFrameCategoryButton2:IsVisible() then
        PVPQueueFrameCategoryButton2:Click()
    end
    --选择专精
    if DMW.Settings.profile.Battle.JoinBattle then
        if  HonorFrame and   HonorFrame:IsVisible() and HonorFrame.HealerIcon.checkButton:IsVisible() and HonorFrame.HealerIcon.checkButton:GetChecked() == false then
            HonorFrame.HealerIcon.checkButton:SetChecked(true)
        end
        if  HonorFrame and HonorFrame:IsVisible() and HonorFrame.TankIcon.checkButton:IsVisible() and HonorFrame.TankIcon.checkButton:GetChecked() == false then
            HonorFrame.TankIcon.checkButton:SetChecked(true)
        end
        if  HonorFrame and HonorFrame:IsVisible() and HonorFrame.DPSIcon.checkButton:IsVisible() and HonorFrame.DPSIcon.checkButton:GetChecked() == false then
            HonorFrame.DPSIcon.checkButton:SetChecked(true)
        end
        if  HonorFrameQueueButton  and HonorFrameQueueButton:IsVisible() then
            HonorFrameQueueButton:Click()
        end
    end
    if DMW.Settings.profile.Battle.JoinRank then
        if ConquestFrame and ConquestFrame:IsVisible() and ConquestFrame.HealerIcon.checkButton:IsVisible() and ConquestFrame.HealerIcon.checkButton:GetChecked() == false then
            ConquestFrame.HealerIcon.checkButton:SetChecked(true)
        end
        if ConquestFrame and ConquestFrame:IsVisible() and ConquestFrame.TankIcon.checkButton:IsVisible() and ConquestFrame.TankIcon.checkButton:GetChecked() == false then
            ConquestFrame.HealerIcon.checkButton:SetChecked(true)
        end
        if ConquestFrame and ConquestFrame:IsVisible() and ConquestFrame.DPSIcon.checkButton:IsVisible() and ConquestFrame.DPSIcon.checkButton:GetChecked() == false then
            ConquestFrame.HealerIcon.checkButton:SetChecked(true)
        end
        if ConquestFrame and ConquestFrame:IsVisible() and ConquestFrame.RatedBG:IsVisible() then
            ConquestFrame.RatedBG:Click()
        end
        if ConquestFrame and ConquestFrame:IsVisible() then
             --ConquestJoinButton
        end
    end

end

function Battle:ConfirmBg()
    if PVPReadyDialogEnterBattleButton:IsVisible() then
        PVPReadyDialogEnterBattleButton:Click()
    end
end
function Battle:PVPActivity()
    if Friends200YC  < 1 then
        return
    end
    for _,Friend in ipairs(Friends200Y) do
        if  Player.Bg and not Friend.Combat and not Friend.Dead then
         --   ReportPlayerIsPVPAFK(Friend.Name)
        end
        return
    end
end

function  Battle:LeaveBg()
    if leaveBgBeginTime == 0 and inBg and PVPMatchResults.buttonContainer.leaveButton:IsVisible()  then
        leaveBgBeginTime = GetTime()
    end
    if Player.Bg and PVPMatchResults.buttonContainer.leaveButton:IsVisible() and leaveBgBeginTime ~= 0 and
            DMW.Time - leaveBgBeginTime > 10 then
        leaveBgBeginTime = 0
        PVPMatchResults.buttonContainer.leaveButton:Click()
    end
end

 function Battle:StatusCheck()
    if (not  DMW.Settings.profile.Battle.JoinBattle and not DMW.Settings.profile.Battle.JoinRank) or Debuff.Escape:Exist(Player) then
        return false
    end
    return true
end

function Battle:Run()
    self:Init()
    if not self:StatusCheck() then
        return
    end
    if status == "none" then
        self:JoinBgQueue()
    elseif status == "confirm" then
        self:ConfirmBg()
    elseif status == "active" then
        self:PVPActivity()
        self:LeaveBg()
    end
end
