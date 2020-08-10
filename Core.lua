DMW = LibStub("AceAddon-3.0"):NewAddon("DMW", "AceConsole-3.0")
local DMW = DMW
local join = 0
DMW.Tables = {}
DMW.Enums = {}
DMW.Functions = {}
DMW.Rotations = {}
DMW.Player = {}
DMW.UI = {}
DMW.Settings = {}
DMW.Helpers = {}
DMW.Pulses = 0
local Init = false
local initNavigation = false
local function FindRotation()
    if DMW.Rotations[DMW.Player.Class] and DMW.Rotations[DMW.Player.Class][DMW.Player.Spec] then
        DMW.Player.Rotation = DMW.Rotations[DMW.Player.Class][DMW.Player.Spec]
    end
end

local f = CreateFrame("Frame", "DoMeWhen", UIParent)
f:SetScript(
        "OnUpdate",
        function(self, elapsed)

            if GetObjectWithGUID then
                LibStub("LibDraw-1.0").clearCanvas()
                DMW.Time = GetTime()
                DMW.Pulses = DMW.Pulses + 1
                if EWT ~= nil then

                    if not Init then

                        DMW.Init()
                        DMW.UI.HUD.Init()
                        local mapId = GetMapId()
                        DMW.UI.InitNavigation()
                        if not initNavigation  then

                            if not IsMeshLoaded(mapId) then
                                DestroyNavigation()
                            end
                            InitializeNavigation(function(result)
                                if result then
                                    DMW.Helpers.Navigation:InitWorldMap()
                                end
                            end, "" .. mapId .. "")
                            initNavigation = true
                        end
                        Init = true
                    end
                    if not DMW.Player.Name then
                        DMW.Player = DMW.Classes.LocalPlayer(ObjectPointer("player"))
                    end
                    if GetSpecializationInfo(GetSpecialization()) ~= DMW.Player.SpecID then
                        ReloadUI()
                        return
                    end

                    DMW.UpdateOM()
                    DMW.Helpers.Trackers.Run()
                    DMW.Helpers.Gatherers.Run()
                    if not DMW.Player.Rotation then
                        FindRotation()
                    else
                        if DMW.Helpers.Queue.Run() then
                            return true
                        end
                        DMW.Player.Rotation()
                    end
                    DMW.Helpers.DungeonField:Run(join)
                    if not DMW.UI.HUD.Loaded then
                        DMW.UI.HUD.Load()
                    end

                    join = join + 1
                    if not DMW.Player.Casting then
                        DMW.Helpers.BattleField:Run()
                    end
                    if DMW.Helpers.Gatherers.SkinningTime < GetTime() and not DMW.Player.Combat then
                        DMW.Helpers.Navigation:Pulse()
                    end
                end
            end
        end
)
