local DMW = DMW
local LibDraw = LibStub("LibDraw-1.0")
DMW.Helpers.Navigation = {}
local Navigation = DMW.Helpers.Navigation
local Path = nil
local Reverse = false
local PathIndex = 1
local DestX, DestY, DestZ
local EndX, EndY, EndZ
local PathUpdated = false
local Pause = GetTime()
local move = GetTime()
Navigation.WMRoute = {}
Navigation.LogPointRoute = {}
Navigation.Npc = {}
Navigation.GoToNpc = false
Navigation.LastJump = GetTime()
local Settings

local lastX,lastY,lastZ
local stuckCount = 0
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
Navigation.Frame = AceGUI:Create("Window")
local Frame = Navigation.Frame
local AsPosX = -818.556641
local AsPosY =  -619.254883
local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

Frame:SetTitle("巡逻路线")
Frame:SetWidth(300)
Frame:Hide()

local Modes = {
    Disabled = 0,
    Grinding = 1,
    Transport = 2
}

Navigation.Mode = Modes.Disabled

Navigation.CombatRange = 18

function ToStringEx(value)
    if type(value)=='table' then
        return TableToStr(value)
    elseif type(value)=='string' then
        return "'"..value.."'"
    else
        return tostring(value)
    end
end


function TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
            signal = ""
        end

        if key == i then
            retstr = retstr..signal..ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..ToStringEx(key).."]="..ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..ToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..ToStringEx(value)
                end
            end
        end

        i = i+1
    end

    retstr = retstr.."}"
    return retstr
end


function StrToTable(str)
    if str == nil or type(str) ~= "string" then
        return {}
    end
    return loadstring("return " .. str)()
end
function Navigation:GetIndex()
    return DMW.Settings.profile.Navigation.WMRouteIndex
end
function Navigation:SetIndex(idx)
    DMW.Settings.profile.Navigation.WMRouteIndex  = idx
end

local function NextNodeRange()
    if IsMounted() then
        return 1
    end
    if PathIndex == #Path and DMW.Settings.profile.Helpers.AutoLoot and DMW.Player.Target and DMW.Player.Target.Dead and UnitCanBeLooted(DMW.Player.Target.Pointer) then
        return 0.7
    end
    return 1
end

function DrawRoute()
    if not DMW.Settings.profile.Navigation.DrawLine then
        return
    end
    LibDraw.SetWidth(3)
    LibDraw.SetColorRaw(100, 255, 0, 40)
    if not Path then
        return
    end
    for i = PathIndex, #Path do
        if i == PathIndex then
            LibDraw.Line(DMW.Player.PosX, DMW.Player.PosY, DMW.Player.PosZ, Path[i][1], Path[i][2], Path[i][3])
        end
        if Path[i + 1] then
            LibDraw.Line(Path[i][1], Path[i][2], Path[i][3], Path[i + 1][1], Path[i + 1][2], Path[i + 1][3])
        end
    end
end

function Navigation:DrawWRoute()
    if not DMW.Settings.profile.Navigation.DrawLine then
        return
    end
    LibDraw.SetWidth(3)
    LibDraw.SetColorRaw(0, 255, 0, 255)
    if not Navigation.WMRoute then
        return
    end
    if Navigation.WMRoute and #Navigation.WMRoute < 2 then
        return
    end
    local len = #Navigation.WMRoute - 1
    for i = 1, len do
        LibDraw.Line(Navigation.WMRoute[i][1],
                Navigation.WMRoute[i][2],
                Navigation.WMRoute[i][3],
                Navigation.WMRoute[i+1][1],
                Navigation.WMRoute[i+1][2],
                Navigation.WMRoute[i+1][3])
    end

    if Navigation.WMRoute[self:GetIndex()] then
        LibDraw.Circle(Navigation.WMRoute[self:GetIndex()][1], Navigation.WMRoute[self:GetIndex()][2], Navigation.WMRoute[self:GetIndex()][3], DMW.Settings.profile.Navigation.GrindRadius)
    end
end

function Navigation:DrawLogPointRoute()
    if not DMW.Settings.profile.Navigation.DrawLine then
        return
    end
    LibDraw.SetWidth(3)
    LibDraw.SetColorRaw(0, 122, 122, 38)
    if not Navigation.LogPointRoute then
        return
    end
    if Navigation.LogPointRoute and #Navigation.LogPointRoute < 2 then
        return
    end
    local len = #Navigation.LogPointRoute - 1
    for i = 1, len do
        LibDraw.Line(Navigation.LogPointRoute[i][1],
                Navigation.LogPointRoute[i][2],
                Navigation.LogPointRoute[i][3],
                Navigation.LogPointRoute[i+1][1],
                Navigation.LogPointRoute[i+1][2],
                Navigation.LogPointRoute[i+1][3])
    end
end

function Navigation:InBg()
    return UnitInBattleground("player")
end

function Navigation:realyMove()
    if not (DMW.Settings.profile.Navigation.GatherMode and not self:InBg()) and DMW.Player.Combat or (not DMW.Settings.profile.Navigation.NoLive and self:InBg() and UnitIsDeadOrGhost("player")) then
        self:ClearPath()
        return
    end
    if not DMW.Player.Combat and not DMW.Player.Moving then
        DestX = Path[PathIndex][1]
        DestY = Path[PathIndex][2]
        DestZ = Path[PathIndex][3]
        if sqrt((abs(DestX - DMW.Player.PosX) ^ 2) + (abs(DestY - DMW.Player.PosY) ^ 2)) < NextNodeRange()  then
            PathIndex = PathIndex + 1
            if PathIndex > #Path then
                if Navigation.Mode == Modes.Transport then
                    Navigation.Mode = Modes.Disabled
                end
                self:ClearPath()
                return
            end
        elseif  (not DMW.Player.Moving or PathUpdated) then
            PathUpdated = false
            local PlayerX, PlayerY, PlayerZ = ObjectPosition("Player")
            if lastX == PlayerX and lastY == PlayerY and lastZ == PlayerZ then
                self:ClearPath()
                stuckCount = stuckCount + 1
                if stuckCount > 10 then
                    --这里是随机选择以自身20码为半径的园内选择一个点重新走路
                    MoveTo(PlayerX + math.random(-4, 4), PlayerY + math.random(-4, 4), DestZ )
                    stuckCount = 0
                    return
                end
            end
            MoveTo(DestX, DestY, DestZ, true)
            lastX = PlayerX
            lastY = PlayerY
            lastZ = PlayerZ
        end
        DrawRoute()
    end
    if DMW.Player.Combat then
        --self:ClearPath()
    end
end

--删除灰色、白色品质物品
function Navigation:dropItem()
    local dropWhite = DMW.Settings.profile.Navigation.DropWhite
    local dropGrey = DMW.Settings.profile.Navigation.DropGrey
    for i = 0,4 do
        for j = 1, 20 do
            local itemId =  GetContainerItemID(i, j)
            if itemId then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
                itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice,typeId = GetItemInfo(itemId)
                if itemName then
                    if dropGrey and itemRarity == 0 and itemSellPrice > 0 and itemId ~= 6948 then
                        PickupContainerItem(i,j)
                        DeleteCursorItem()
                    end
                    if dropWhite and itemRarity == 1 and itemSellPrice > 0 and itemId ~= 6948  and itemId ~= 7005 then
                        PickupContainerItem(i,j)
                        DeleteCursorItem()
                    end
                end
            end
        end
    end
end

--贩卖
function Navigation:saleItem()
    local saleGrey = DMW.Settings.profile.Navigation.SaleGrey
    local saleWhite = DMW.Settings.profile.Navigation.SaleWhite
    local saleGreen = DMW.Settings.profile.Navigation.SaleGreen
    Pause = DMW.Time + 30
    DMW.Player.Looting = true
    for i = 0,7 do
        for j = 1, 20 do
            local itemId =  GetContainerItemID(i, j)
            if itemId then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
                itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice,typeId = GetItemInfo(itemId)
                if itemName then
                    if saleGrey and itemRarity == 0 and itemSellPrice > 0  then
                        UseContainerItem(i,j)
                    end
                    if saleWhite and itemRarity == 1  and itemSellPrice > 0 and itemId ~= 7005 then
                        UseContainerItem(i,j)
                    end
                    if saleGreen and itemRarity == 2 and itemSellPrice > 0  then
                        UseContainerItem(i,j)
                    end
                end
            end
        end
    end
    DMW.Player.Looting = false
    DMW.Player.Target = nil
end

function Navigation:KeepCloseToRoute()
    if not DMW.Settings.profile.Navigation.GatherMode and not DMW.Player.Combat and not DMW.Player.Looting and not DMW.Player.Moving then
        if Navigation.WMRoute and  Navigation.WMRoute[self:GetIndex()] then
            local X = Navigation.WMRoute[self:GetIndex()][1]
            local Y = Navigation.WMRoute[self:GetIndex()][2]
            local Z = Navigation.WMRoute[self:GetIndex()][3]
            if sqrt(((X - DMW.Player.PosX) ^ 2) + ((Y - DMW.Player.PosY) ^ 2)) < DMW.Settings.profile.Navigation.GrindRadius and math.abs(Z - DMW.Player.PosZ) > DMW.Settings.profile.Navigation.GrindRadius then
                if self:MoveTo(DestX, DestY, DestZ) then
                end
            end
        end
    end
end

--自动贩卖修复
function Navigation:AutoSale()
    if not Settings then
        Settings = DMW.Settings.profile.Navigation
    end
    --计算装备耐久度
    local totalBroken = 0
    for i = 1,19 do
        if GetInventoryItemBroken("player", i) then
            totalBroken = totalBroken + 1
        end
    end
    if Navigation.Npc and  Navigation.Npc.Name and not DMW.Player.Combat and not DMW.Player.Looting  and
            (DMW.Player:GetFreeBagSlots() < 3 or totalBroken > 3) and Navigation.Npc and
            (DMW.Settings.profile.Navigation.SaleWhite or DMW.Settings.profile.Navigation.SaleGrey or DMW.Settings.profile.Navigation.SaleGreen)
    then
        --如果当前有
        local X = Navigation.Npc.PosX
        local Y = Navigation.Npc.PosY
        local Z = Navigation.Npc.PosZ
        Navigation.GoToNpc = true
        if DMW.Player.Target and not DMW.Player.Combat and DMW.Player.Target.Name ~= Navigation.Npc.Name then
            --ClearTarget()
        end
        if sqrt((X - DMW.Player.PosX) ^ 2 + ((Y - DMW.Player.PosY) ^ 2)) > 10 then
            if self:MoveTo(X, Y, Z) then
                self:realyMove()
            end
        else
            Dismount()
            for _,UNIT in pairs(DMW.Units) do
                if UNIT.Name == Navigation.Npc.Name then
                    InteractUnit(UNIT.Pointer)
                    if CanMerchantRepair() then
                        RepairAllItems()
                    end
                    self:saleItem()
                end
            end
        end
    else
        Navigation.GoToNpc = false
    end
end

--记录路径
function Navigation:LogPoint()
    local canLog = DMW.Settings.profile.Navigation.LogPoint
    if not Navigation.LogPointRoute then
        Navigation.LogPointRoute = {}
    end
    if canLog then
        if #Navigation.LogPointRoute == 0 then
            Navigation.LogPointRoute[1] = {DMW.Player.PosX, DMW.Player.PosY, DMW.Player.PosZ}
        else
            local lastPoint = Navigation.LogPointRoute[#Navigation.LogPointRoute]
            --20 一个节点距离
            if sqrt((lastPoint[1] - DMW.Player.PosX) ^ 2 + (lastPoint[2] - DMW.Player.PosY) ^ 2) > 10 then
                Navigation.LogPointRoute[#Navigation.LogPointRoute + 1] =  {DMW.Player.PosX, DMW.Player.PosY, DMW.Player.PosZ}
                self:DrawLogPointRoute()
            end
        end
    elseif #Navigation.LogPointRoute > 2 then
        Navigation.WMRoute = Navigation.LogPointRoute
        Navigation.LogPointRoute = {}
        self:SaveGrindData()
    end
end

function Navigation:CheckFriendsCombat()
    local Friends40Y = DMW.Player:GetFriends(40)
    if #Friends40Y == 1 then
        return false
    end
    for _,Unit in ipairs(Friends40Y) do
        if UnitAffectingCombat(Unit.Pointer) then
            return true
        end
    end
    return false
end

function Navigation:Pulse()
    if not Settings then
        Settings = DMW.Settings.profile.Navigation
    end
    Navigation.Mode = Settings.Mode
    if Settings.Manual then
        return
    end
        --设置自动grind
    if Settings.AutoGrind and Settings.Mode == Modes.Disabled then
        Navigation.Mode =  Modes.Grinding
        Settings.Mode = Modes.Grinding
    end


    if DMW.Player.Combat and DMW.Player.Moving and Navigation.Mode == Modes.Grinding then
        self:ClearPath()
        MoveForwardStop()
    end
    self:DrawWRoute()
    self:DrawLogPointRoute()
    self:dropItem()
    self:LogPoint()
    if DMW.Time > Pause and DMW.Player.Target and DMW.Player.Target.Name == Navigation.Npc.Name then
        Pause = DMW.Time + 10
        ClearTarget()
    end
    if DMW.Player.Target and DMW.Player.Target.Dead and DMW.Player.Combat then
        ClearTarget()
    end
    if  DMW.Player.Target and not Settings.Manual  and DMW.Player.Target.Distance > Settings.AttackDistance and self:InBg() then
        ClearTarget()
    end
    self:AutoSale()
    if not DMW.Helpers.Gatherers:CheckLoot() then
        self:KeepCloseToRoute()
    end
    if not DMW.Player.Moving  and DMW.Player.Target and DMW.Player.Target.ValidEnemy  and Navigation.Mode == Modes.Grinding then
        FaceDirection(DMW.Player.Target.Pointer)
    end
    if Navigation.Mode ~= Modes.Disabled and not DMW.Player.Casting and DMW.Time > Pause then

        if Navigation.Mode == Modes.Grinding then
            self:Grinding()
        end
        self:realyMove()
    end
end

function Navigation:CalculatePath(mapID, fromX, fromY, fromZ, toX, toY, toZ)
    return CalculatePath(mapID, fromX, fromY, fromZ, toX, toY, toZ, true, false, 3)
end

function Navigation:MoveTo(toX, toY, toZ)
    if Path and #Path > 0 and PathIndex < #Path then
        return
    end
    PathIndex = 1
    Path = self:CalculatePath(GetMapId(), DMW.Player.PosX, DMW.Player.PosY, DMW.Player.PosZ, toX, toY, toZ)
    if Path then
        EndX, EndY, EndZ = toX, toY, toZ
        PathUpdated = true
        return true
    end
    return false
end

function Navigation:ClearPath()
    Path = nil
    PathIndex = 1
end

function Navigation:MoveToCursor()
    local x, y = GetMousePosition()
    local PosX, PosY, PosZ = ScreenToWorld(x, y)
    self:MoveTo(PosX, PosY, PosZ)
end

function Navigation:MoveToCorpse()
    if StaticPopup1 and StaticPopup1:IsVisible() and (StaticPopup1.which == "DEATH" or StaticPopup1.which == "RECOVER_CORPSE") and StaticPopup1Button1 and StaticPopup1Button1:IsEnabled() then
        StaticPopup1Button1:Click()
        self:ClearPath()
        self:SetIndex(1)
        Pause = DMW.Time + 1
        return
    end
    local PosX, PosY, PosZ = GetCorpsePosition()
    if not Path or (PosX ~= EndX or PosY ~= EndY) then
        self:MoveTo(PosX, PosY, PosZ)
    end
end

function Navigation:SearchNext()
    --寻找友方目标: 优先级 该目标为中心的友方数量最多，该目标距离玩家距离最近
    local Table = {}
    local GameTable = {}
    local distance = 0
    local Friends40Y =  DMW.Player:GetFriends(40)
    local maxFriendPlayer = 0
    local maxFriends = 0
    local length = 200
    for _, Unit in pairs(DMW.Attackable) do
        table.insert(Table, Unit)
    end
    for _, gobject in pairs(DMW.GameObjects) do
        table.insert(GameTable,  gobject)
    end
    if #Table > 1 then
        table.sort(
                Table,
                function(x, y)
                    return x.Distance < y.Distance
                end
        )
    end
    if #GameTable > 1 then
        table.sort(
                GameTable,
                function(x, y)
                    return x.Distance < y.Distance
                end
        )
    end
    if #Friends40Y > 1 then
        table.sort(
                Friends40Y,
                function(x, y)
                    return x.Distance < y.Distance
                end
        )
    end
    if DMW.Settings.profile.Navigation.GatherMode and #Friends40Y > 1 then

        for idx,Unit in ipairs(Friends40Y) do
            local AsLength = sqrt(abs(AsPosX - Unit.PosX) ^ 2 + abs(AsPosY - Unit.PosY) ^ 2)
            if  AsLength > 200 and Unit.Name ~= "LocalPlayer"   and Unit.Class ~= "ROGUE" and Unit.Class ~= "WARRIOR" and Unit.Class ~= "DRUID" then

                local curLength = sqrt(abs(Unit.PosX - DMW.Player.PosX) ^ 2 + abs(Unit.PosY - DMW.Player.PosY) ^ 2)
                if length > curLength then
                    length = curLength
                    maxFriendPlayer = idx
                    DMW.Settings.profile.Navigation.BattlePlayer = Unit
                end
                local frs = Unit:GetFriends(200)
                if maxFriends < #frs then
                    maxFriends = #frs
                    maxFriendPlayer = idx
                    DMW.Settings.profile.Navigation.BattlePlayer = Unit
                end
            end
        end
        if DMW.Settings.profile.Navigation.AutoFollow and not DMW.Player.Combat and Friends40Y[maxFriendPlayer] and Friends40Y[maxFriendPlayer].Distance > DMW.Settings.profile.Navigation.FollowMaxRange  then
            self:MoveTo(Friends40Y[maxFriendPlayer].PosX + DMW.Settings.profile.Navigation.FollowMinRange,
                    Friends40Y[maxFriendPlayer].PosY + DMW.Settings.profile.Navigation.FollowMinRange, Friends40Y[maxFriendPlayer].PosZ)
            move = DMW.Time
        end
        --战场以外就返回,如果没有找到队友则往下运行寻找敌人或找下一个节点
        if not self:InBg() then
            return
        end
    end
    --战场或非采集模式下寻找攻击目标
    if DMW.Settings.profile.Navigation.AutoSearch and ((not DMW.Settings.profile.Navigation.GatherMode) or self:InBg()) then
        for _, Unit in ipairs(Table) do
            if self:GetIndex() > 0 and Navigation.WMRoute and #Navigation.WMRoute > 1  then
                distance = GetDistanceBetweenPositions (Unit.PosX, Unit.PosY, Unit.PosZ,  Navigation.WMRoute[self:GetIndex()][1],  Navigation.WMRoute[self:GetIndex()][2],  Navigation.WMRoute[self:GetIndex()][3])
            end
            --战场模式下无视节点距离现在

            if self:InBg() then
                Unit.Level = DMW.Player.Level
            end
            if Unit.Distance <= DMW.Settings.profile.Navigation.GrindRadius and distance < DMW.Settings.profile.Navigation.GrindRadius  - 5 and not Unit.Dead and
                    ((DMW.Settings.profile.Navigation.AttackPlayer and Unit.Player)  or (not DMW.Settings.profile.Navigation.AttackPlayer and not Unit.Player and not UnitPlayerControlled(Unit.Pointer))) and
                    math.abs(DMW.Player.Level - Unit.Level) <= Settings.LevelRange and UnitCanAttack("player", Unit.Pointer)
                    and not UnitIsTapDenied(Unit.Pointer)
            then
                TargetUnit(Unit.Pointer)
                if self:MoveTo(Unit.PosX, Unit.PosY, Unit.PosZ) then
                    self:realyMove()
                    return true
                end
            end
        end
    end

    local x, y, z = unpack(Navigation.WMRoute[self:GetIndex()])
    if sqrt((abs(x - DMW.Player.PosX) ^ 2) + (abs(y - DMW.Player.PosY) ^ 2)) > 20 then
        if #Navigation.WMRoute > 2 then
            local minLength  = sqrt((abs(Navigation.WMRoute[1][1] - DMW.Player.PosX) ^ 2) + (abs(Navigation.WMRoute[1][2] - DMW.Player.PosY) ^ 2))
            local idx = 1
            for i = 1,#Navigation.WMRoute do
                local x = Navigation.WMRoute[i][1]
                local y = Navigation.WMRoute[i][2]
                if sqrt((abs(x - DMW.Player.PosX) ^ 2) + (abs(y - DMW.Player.PosY) ^ 2)) < minLength then
                    minLength = sqrt((abs(x - DMW.Player.PosX) ^ 2) + (abs(y - DMW.Player.PosY) ^ 2))
                    idx = i
                end
            end
            self:SetIndex(idx)
        end
    end
    --战场模式下定期检测是否有队友，没有寻找下个节点
    if DMW.Settings.profile.Navigation.AutoFollow and self:InBg()  and  DMW.Settings.profile.Navigation.BattlePlayer  and #Navigation.WMRoute and self:GetIndex() >2 * #Navigation.WMRoute/3 then
        if not UnitIsDeadOrGhost(DMW.Settings.profile.Navigation.BattlePlayer.Pointer) and DMW.Settings.profile.Navigation.BattlePlayer.Distance < 40 then
            self:MoveTo(DMW.Settings.profile.Navigation.BattlePlayer.PosX,
                    DMW.Settings.profile.Navigation.BattlePlayer.PosY,
                    DMW.Settings.profile.Navigation.BattlePlayer.PosZ)
            return
        end
    end
    if not Path and #Navigation.WMRoute > 0 then
        x, y, z = unpack(Navigation.WMRoute[self:GetIndex()])
        if sqrt(((x - DMW.Player.PosX) ^ 2) + ((y - DMW.Player.PosY) ^ 2)) < 3 then
            if Reverse and self:GetIndex() >= 2 then
                self:SetIndex(self:GetIndex()-1)
            elseif Reverse and self:GetIndex() == 1 then
                Reverse = false
                self:SetIndex(self:GetIndex() + 1)
            elseif  not Reverse and self:GetIndex() < #Navigation.WMRoute then
                self:SetIndex(self:GetIndex() + 1)
            elseif not Reverse and self:GetIndex() == #Navigation.WMRoute then
                self:SetIndex(self:GetIndex() - 1)
                Reverse = true
            end
            x, y, z = unpack(Navigation.WMRoute[self:GetIndex()])
        end
        if self:MoveTo(x, y, z) then
            return true
        end
    end
end

function Navigation:SearchEnemy()
    local distance = 0
    local enemy = DMW.Enemies
    if #enemy > 1 then
        table.sort(
                enemy,
                function(x, y)
                    return x.Distance < y.Distance
                end
        )
    end
    for _, Unit in ipairs(enemy) do
        if self:GetIndex() > 0 and Navigation.WMRoute  then
            distance = GetDistanceBetweenPositions (Unit.PosX, Unit.PosY, Unit.PosZ,  Navigation.WMRoute[self:GetIndex()][1],  Navigation.WMRoute[self:GetIndex()][2],  Navigation.WMRoute[self:GetIndex()][3])
        end
        if Unit.Distance <=  DMW.Settings.profile.Navigation.GrindRadius and math.abs(DMW.Player.Level - Unit.Level) <= Settings.LevelRange and distance < DMW.Settings.profile.Navigation.GrindRadius - 5  then
            if self:MoveTo(Unit.PosX, Unit.PosY, Unit.PosZ) then
                self:realyMove()
                return true
            end
        else
        end
    end
end

function Navigation:SetPause(time)
    Pause = DMW.Time +  time
end

function Navigation:PowerPctGreatThan(powerPct)
    if DMW.Player.Class == "MAGE" or DMW.Player.Class == "DRUID" or DMW.Player.Class == "HUNTER" or DMW.Player.Class == "PALADIN" or DMW.Player.Class == "PRIEST" or DMW.Player.Class == "SHAMAN"
            or DMW.Player.Class == "WARLOCK" then
        return DMW.Player.PowerPct > powerPct
    end
    return true
end

function Navigation:PowerPctSmallThan(powerPct)
    if DMW.Player.Class == "MAGE" or DMW.Player.Class == "DRUID" or DMW.Player.Class == "HUNTER" or DMW.Player.Class == "PALADIN" or DMW.Player.Class == "PRIEST" or DMW.Player.Class == "SHAMAN"
            or DMW.Player.Class == "WARLOCK" then
        return DMW.Player.PowerPct <= powerPct
    end
    return true
end
function Navigation:Grinding()
    if not DMW.Settings.profile.Navigation.NoLive and UnitIsDeadOrGhost("player") then
        if not self:InBg() then
            return self:MoveToCorpse()
        elseif self:InBg() and StaticPopup1 and StaticPopup1:IsVisible() and (StaticPopup1.which == "DEATH" or StaticPopup1.which == "RECOVER_CORPSE") and StaticPopup1Button1 and StaticPopup1Button1:IsEnabled() then
            self:ClearPath()
            self:SetIndex(1)
            Pause = DMW.Time + 1
            local rd = math.random(1, 100)
            if rd > 89 then
                StaticPopup1Button1:Click()
            end
        end
        return
    end
    DMW.Player:Update()
        --正在拾取不搜寻， 没有正在拾取并且背包剩余栏小于3 则搜寻
    if not Navigation.GoToNpc and  DMW.Player.Standing() and (not DMW.Player.Looting or DMW.Player:GetFreeBagSlots() < 3) and
            (not DMW.Player.Target or
                    (DMW.Player.Target.Dead and
                            (not DMW.Settings.profile.Helpers.AutoLoot or
                                    DMW.Player:GetFreeBagSlots() == 0 or not (UnitCanBeLooted(DMW.Player.Target.Pointer) or UnitCanBeLooted(DMW.Player.Target.Pointer))
                            )
                    ) or DMW.Player.Combat or UnitIsTapDenied(DMW.Player.Target.Pointer)) and not DMW.Helpers.Gatherers:CheckLoot()
    then
        self:SearchNext()
    elseif (not DMW.Player.Target or not UnitAffectingCombat(DMW.Player.Target.Pointer) or DMW.Player.Combat ) and not DMW.Helpers.Gatherers:CheckLoot() then
        self:SearchEnemy()
    elseif not Navigation.GoToNpc   and not DMW.Player.Combat and DMW.Helpers.Gatherers.CheckLoot() then
        DMW.Helpers.Gatherers.Run()
    end
end

function Navigation:MapCursorPosition()
    if WorldMapFrame:IsVisible() then
        local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        local continentID, worldPosition = C_Map.GetWorldPosFromMapPos(WorldMapFrame:GetMapID(), CreateVector2D(x, y))
        local WX, WY = worldPosition:GetXY()
        local WZ = select(3, TraceLine(WX, WY, 10000, WX, WY, -10000, 0x110))
        if not WZ and WorldPreload(WX, WY, DMW.Player.PosZ) then
            WZ = select(3, TraceLine(WX, WY, 9999, WX, WY, -9999, 0x110))
        end
        if WZ then
            return WX, WY, WZ, WorldMapFrame:GetMapID(), x, y
        end
    end
    return nil
end

function Navigation:MoveToMapCursorPosition()
    local x, y, z = self:MapCursorPosition()
    if z and self:MoveTo(x, y, z) then
        Navigation.Mode = Modes.Transport
        return true
    end
    return false
end

function Frame:AddRoutePoint(Index, X, Y, Z)
    local Label = AceGUI:Create("Label")
    Label:SetFullWidth(true)
    Label.RouteIndex = Index
    Label:SetText(string.format("%s - %s - %s", Round(X, 2), Round(Y, 2), Round(Z, 2)))
    Frame:AddChild(Label)
end

--保存巡逻路径
function Navigation:SaveGrindData()
    WriteFile("Interface/AddOns/DoMeWhen/Grinds/gp_" .. DMW.Settings.profile.Navigation.GrindName .. ".lua", TableToStr(Navigation.WMRoute))
end

function Navigation:AddMapCursorPosition()
    local Pos = {self:MapCursorPosition()}
    if Pos[3] then
        if #Navigation.WMRoute == 0 then
            if self:CalculatePath(GetMapId(), DMW.Player.PosX, DMW.Player.PosY, DMW.Player.PosZ, Pos[1], Pos[2], Pos[3]) then
                table.insert(Navigation.WMRoute, Pos)
                Frame:AddRoutePoint(#Navigation.WMRoute, Pos[1], Pos[2], Pos[3])
            end
        else
            local LastWMIndex = Navigation.WMRoute[#Navigation.WMRoute]
            if self:CalculatePath(GetMapId(), LastWMIndex[1], LastWMIndex[2], LastWMIndex[3], Pos[1], Pos[2], Pos[3]) then
                table.insert(Navigation.WMRoute, Pos)
                Frame:AddRoutePoint(#Navigation.WMRoute, Pos[1], Pos[2], Pos[3])
            end
        end
        self:SaveGrindData()
        self:DrawWRoute()
    end
end


--保存修理npc
function Navigation:SaveNpc()
    if DMW.Player.Target then
        Navigation.Npc = {}
        Navigation.Npc["Name"] = DMW.Player.Target.Name
        Navigation.Npc["PosX"] = DMW.Player.Target.PosX
        Navigation.Npc["PosY"] = DMW.Player.Target.PosY
        Navigation.Npc["PosZ"] = DMW.Player.Target.PosZ
        if DMW.Settings.profile.Navigation.GrindName then
            WriteFile("Interface/AddOns/DoMeWhen/Grinds/np_" .. DMW.Settings.profile.Navigation.GrindName .. ".lua", TableToStr(Navigation.Npc), false)
        end
    end
end

function Navigation:InitWorldMap(mapName)
    if DMW.Settings.profile.Navigation.GrindName ~= "" then
        --载入巡逻路线
        if not mapName then
            mapName = DMW.Settings.profile.Navigation.GrindName
        end
        Navigation.WMRoute = StrToTable(ReadFile("Interface/AddOns/DoMeWhen/Grinds/gp_" .. mapName  .. ".lua"))
        if not Navigation.WMRoute then
            Navigation.WMRoute = {}
        end
        --计算当前最近的寻路点
        if #Navigation.WMRoute > 2 then
            local minLength  = sqrt((abs(Navigation.WMRoute[1][1] - DMW.Player.PosX) ^ 2) + (abs(Navigation.WMRoute[1][2] - DMW.Player.PosY) ^ 2))
            local idx = 1
            for i = 1,#Navigation.WMRoute do
                local x = Navigation.WMRoute[i][1]
                local y = Navigation.WMRoute[i][2]
                if sqrt((abs(x - DMW.Player.PosX) ^ 2) + (abs(y - DMW.Player.PosY) ^ 2)) < minLength then
                    minLength = sqrt((abs(x - DMW.Player.PosX) ^ 2) + (abs(y - DMW.Player.PosY) ^ 2))
                    idx = i
                end
            end
            self:SetIndex(idx)
        end
        --载入npc
        local tempNpc = StrToTable(ReadFile("Interface/AddOns/DoMeWhen/Grinds/np_" .. mapName .. ".lua"))
        if tempNpc then
            Navigation.Npc = tempNpc
        end
    end
    WorldMapFrame.ScrollContainer:HookScript(
            "OnMouseDown",
            function(self, button)
                if (button == "LeftButton") and IsLeftControlKeyDown() then
                    Navigation:MoveToMapCursorPosition()
                elseif (button == "LeftButton") and IsLeftShiftKeyDown() then
                    Navigation:AddMapCursorPosition()
                    if not Frame:IsShown() then
                        Frame:Show()
                    end
                end
            end
    )
end
