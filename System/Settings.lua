local DMW = DMW
local AceGUI = LibStub("AceGUI-3.0")

local defaults = {
    profile = {
        MinimapIcon = {
            hide = false
        },
        HUDPosition = {
            point = "LEFT",
            relativePoint = "LEFT",
            xOfs = 40,
            yOfs = 100
        },
        HUDStatusPosition = {
            point = "LEFT",
            relativePoint = "LEFT",
            xOfs = 80,
            yOfs = 500
        },
        HUD = {
            Rotation = 1,
            Show = true
        },
        HUDStatus = {
            Show = true,
        },
        Enemy = {
            InterruptPct = 70,
            ChannelInterrupt = 1,
            InterruptTarget = 1
        },
        DispelDelay = 1,
        Rotation = {},
        Queue = {
            Wait = 2,
            Items = true
        },
        Tracker = {
            DrawLine = true,
            Herbs = true,
            Ore = true,
            CheckRank = true,
            HideGrey = false,
            TrackNPC = false,
            QuestieHelper = false,
            QuestieHelperColor = {0,0,0,1},
            HerbsColor = {255,0,0,1},
            OreColor = {0,255,0,1},
            TrackUnitsColor = {0,0,0,1},
            TrackObjectsColor = {0,0,0,1},
            TrackPlayersColor = {0,0,0,1},
            TrackNPCColor = {1,0.6,0,1},
            OreAlert = 0,
            HerbsAlert = 0,
            QuestieHelperAlert = 0,
            TrackUnitsAlert = 0,
            TrackObjectsAlert = 0,
            TrackPlayersAlert = 0,
            OreLine = 2,
            HerbsLine = 2,
            QuestieHelperLine = 0,
            TrackUnitsLine = 1,
            TrackObjectsLine = 1,
            TrackPlayersLine = 1,
            TrackPlayersEnemy = false,
            TrackPlayersAny = false,
            TrackObjectsMailbox = false,
            TrackFlag = false,
        },
        Navigation = {
            Manual = true,
            WorldMapHook = false,
            AttackDistance = 14,
            MaxDistance = 30,
            FoodHP = 60,
            PowerPct = 60,
            FoodID = 0,
            WaterID = 0,
            LevelRange = 3,
            GrindName = "",
            GrindRadius = 40,
            DropGrey = false,
            PassWord = "",
            DropWhite = false,
            Npc = false,
            AutoSaleGrey = false,
            AutoSaleWhite = false,
            AutoSaleGreen = false,
            AutoRepair = false,
            LogPoint = false,
            AutoGrind = false,
            Mode = 0,
            AttackPlayer = false,
            GatherMode = false,
            WMRouteIndex = 1,
            MountName = nil,
            DrawLine = true,
            AutoBg = false,
            FollowMaxRange = 10,
            FollowMinRange = 5,
            AutoSearch = false,
            BattlePlayer = nil,
            AutoFollow = false,
            AutoFlag = false,
            NoMove = true,
            NoLive = true,
            DrawLine = true
        },
        Helpers = {
            AutoLoot = true,
            AutoSkinning = false,
            AutoGather = true,
            PickFlag = true,
        },
        Battle = {
            JoinBattle = false,
            JoinRank = false,
            CommandKey = "9",
            Alert = 416,
        },
        Dungeon = {
            JoinRandomDungeon = false,
            Follow = true,
            FollowDistance = 5,
        },
        General  = {
            FilterMsg = false,
        }

    }
}

function DMW.Init()
    DMW.Settings = LibStub("AceDB-3.0"):New("DMWSettings", defaults, "Default")
    DMW.Settings:SetProfile(DMW.Enums.Specs[GetSpecializationInfo(GetSpecialization())])
    DMW.UI.Init()
end
