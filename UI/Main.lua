local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local DMW = DMW
local UI = DMW.UI
local RotationOrder = 1

local Options = {
    name = "WOW",
    handler = DMW,
    type = "group",
    childGroups = "tab",
    args = {
        RotationTab = {
            name = "Rotation",
            type = "group",
            order = 1,
            args = {}
        },
        GeneralTab = {
            name = "General",
            type = "group",
            order = 2,
            args = {
                GeneralHeader = {
                    type = "header",
                    order = 1,
                    name = "General"
                },
                HUDEnabled = {
                    type = "toggle",
                    order = 2,
                    name = "Show HUD",
                    desc = "Toggle to show/hide the HUD",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.HUD.Show
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.HUD.Show = value
                        if value then
                            DMW.UI.HUD.Frame:Show()
                        else
                            DMW.UI.HUD.Frame:Hide()
                        end
                    end
                },
                MMIconEnabled = {
                    type = "toggle",
                    order = 3,
                    name = "Show Minimap Icon",
                    desc = "Toggle to show/hide the minimap icon",
                    width = "full",
                    get = function()
                        return not DMW.Settings.profile.MinimapIcon.hide
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.MinimapIcon.hide = not value
                        if value then
                            UI.MinimapIcon:Show("MinimapIcon")
                        else
                            UI.MinimapIcon:Hide("MinimapIcon")
                        end
                    end
                },
                AutoLog = {
                    type = "toggle",
                    order = 3,
                    name = "自动登录",
                    width = 4,
                    get = function()
                        return DMW.Settings.profile.Navigation.AutoLog
                    end,
                    set = function(info, value)
                        if value then
                            DMW.Settings.profile.Navigation.AutoLog = true
                            if not IsHackEnabled("relog") and DMW.Settings.profile.Navigation.PassWord ~= "" then
                                RunMacroText(".login " .. DMW.Settings.profile.Navigation.PassWord)
                                SetHackEnabled("relog", true)
                                print("SetRelog successful")
                            end
                            if DMW.Settings.profile.Navigation.PassWord == "" then
                                print("password not set")
                            end
                        else
                            DMW.Settings.profile.Navigation.AutoLog = false
                            if IsHackEnabled("relog") then
                                SetHackEnabled("relog", false)
                                print("close relog")
                            end
                        end
                    end
                },
                PassWord = {
                    type = "input",
                    order = 4,
                    name = "password",
                    desc = "password",
                    width = 10,
                    get = function()
                        return tostring(DMW.Settings.profile.Navigation.PassWord)
                    end,
                    set = function(info, value)
                        if value then
                            DMW.Settings.profile.Navigation.PassWord = value
                        else
                            DMW.Settings.profile.Navigation.PassWord = ""
                        end
                    end
                },
                AntiAfk = {
                    type = "toggle",
                    order = 5,
                    name = "Anti Afk",
                    desc = "Enable/Disable EWT Anti Afk",
                    width = "full",
                    get = function()
                        return IsHackEnabled("antiafk")
                    end,
                    set = function(info, value)
                        SetHackEnabled("antiafk", value)
                    end
                },
                FilterMsg = {
                    type = "toggle",
                    order = 6,
                    name = "FilterMsg",
                    desc = "FilterMsg",
                    width = "full",
                    get = function()
                        return  DMW.Settings.profile.General.FilterMsg
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.General.FilterMsg = value
                        ReloadUI()
                    end
                },
            },
        },
        EnemyTab = {
            name = "Enemy",
            type = "group",
            order = 3,
            args = {
                InterruptHeader = {
                    type = "header",
                    order = 1,
                    name = "Interrupts"
                },
                InterruptPct = {
                    type = "range",
                    order = 2,
                    name = "Interrupt %",
                    desc = "Set desired % for interrupting enemy casts",
                    width = "full",
                    min = 0,
                    max = 100,
                    step = 1,
                    get = function()
                        return DMW.Settings.profile.Enemy.InterruptPct
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Enemy.InterruptPct = value
                    end
                },
                ChannelInterrupt = {
                    type = "range",
                    order = 3,
                    name = "Channel Interrupt",
                    desc = "Set seconds to wait before interrupting enemy channels",
                    width = "full",
                    min = 0.0,
                    max = 3.0,
                    step = 0.1,
                    get = function()
                        return DMW.Settings.profile.Enemy.ChannelInterrupt
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Enemy.ChannelInterrupt = value
                    end
                },
                InterruptTarget = {
                    type = "select",
                    order = 4,
                    name = "Interrupt Target",
                    desc = "Select desired target setting for interrupts",
                    width = "full",
                    values = { "Any", "Target", "Focus", "Mouseover" },
                    style = "dropdown",
                    get = function()
                        return DMW.Settings.profile.Enemy.InterruptTarget
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Enemy.InterruptTarget = value
                    end
                }
            }
        },
        FriendTab = {
            name = "Friend",
            type = "group",
            order = 4,
            args = {
                DispelDelay = {
                    type = "range",
                    order = 1,
                    name = "Dispel Delay",
                    desc = "Set seconds to wait before casting dispel",
                    width = "full",
                    min = 0.0,
                    max = 3.0,
                    step = 0.1,
                    get = function()
                        return DMW.Settings.profile.DispelDelay
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.DispelDelay = value
                    end
                }
            }
        },
        QueueTab = {
            name = "Queue",
            type = "group",
            order = 5,
            args = {
                QueueTime = {
                    type = "range",
                    order = 1,
                    name = "Queue Time",
                    desc = "Set maximum seconds to attempt casting queued spell",
                    width = "full",
                    min = 0,
                    max = 5,
                    step = 0.5,
                    get = function()
                        return DMW.Settings.profile.Queue.Wait
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Queue.Wait = value
                    end
                },
                QueueItems = {
                    type = "toggle",
                    order = 2,
                    name = "Items",
                    desc = "Enable item queue",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Queue.Items
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Queue.Items = value
                    end
                }
            }
        },
        TrackingOptionsTable = {
            name = "Tracking",
            type = "group",
            order = 6,
            args = {
                Herbs = {
                    type = "toggle",
                    order = 1,
                    name = "Herbs",
                    desc = "Mark herbs in the world",
                    width = 0.4,
                    get = function()
                        return DMW.Settings.profile.Tracker.Herbs
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.Herbs = value
                    end
                },
                HerbsLine = {
                    type = "range",
                    order = 2,
                    name = "Line",
                    desc = "Width of line to Herb",
                    width = 0.6,
                    min = 0,
                    max = 5,
                    step = 1,
                    get = function()
                        return DMW.Settings.profile.Tracker.HerbsLine
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.HerbsLine = value
                    end
                },
                HerbsAlert = {
                    type = "input",
                    order = 3,
                    name = "Alert",
                    desc = "Sound for Alert, 416 = Murlocs",
                    width = 0.4,
                    get = function()
                        return tostring(DMW.Settings.profile.Tracker.HerbsAlert)
                    end,
                    set = function(info, value)
                        if tonumber(value) then
                            DMW.Settings.profile.Tracker.HerbsAlert = tonumber(value)
                        else
                            DMW.Settings.profile.Tracker.HerbsAlert = 0
                        end
                    end
                },
                HerbsColor = {
                    type = "color",
                    order = 4,
                    name = "Color",
                    desc = "Color",
                    width = 0.4,
                    hasAlpha = true,
                    get = function()
                        return DMW.Settings.profile.Tracker.HerbsColor[1], DMW.Settings.profile.Tracker.HerbsColor[2], DMW.Settings.profile.Tracker.HerbsColor[3], DMW.Settings.profile.Tracker.HerbsColor[4]
                    end,
                    set = function(info, r, g, b, a)
                        DMW.Settings.profile.Tracker.HerbsColor = { r, g, b, a }
                    end
                },
                Ore = {
                    type = "toggle",
                    order = 5,
                    name = "Ores",
                    desc = "Mark ores in the world",
                    width = 0.4,
                    get = function()
                        return DMW.Settings.profile.Tracker.Ore
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.Ore = value
                    end
                },
                OreLine = {
                    type = "range",
                    order = 6,
                    name = "Line Width",
                    desc = "Width of line to Ore",
                    width = 0.6,
                    min = 0,
                    max = 5,
                    step = 1,
                    get = function()
                        return DMW.Settings.profile.Tracker.OreLine
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.OreLine = value
                    end
                },
                OreAlert = {
                    type = "input",
                    order = 7,
                    name = "Sound",
                    desc = "",
                    width = 0.4,
                    get = function()
                        return tostring(DMW.Settings.profile.Tracker.OreAlert)
                    end,
                    set = function(info, value)
                        if tonumber(value) then
                            DMW.Settings.profile.Tracker.OreAlert = tonumber(value)
                        else
                            DMW.Settings.profile.Tracker.OreAlert = 0
                        end
                    end
                },
                OreColor = {
                    type = "color",
                    order = 8,
                    name = "Color",
                    desc = "Color",
                    width = 0.4,
                    hasAlpha = true,
                    get = function()
                        return DMW.Settings.profile.Tracker.OreColor[1], DMW.Settings.profile.Tracker.OreColor[2], DMW.Settings.profile.Tracker.OreColor[3], DMW.Settings.profile.Tracker.OreColor[4]
                    end,
                    set = function(info, r, g, b, a)
                        DMW.Settings.profile.Tracker.OreColor = { r, g, b, a }
                    end
                },
                CheckLevel = {
                    type = "toggle",
                    order = 9,
                    name = "Check Skill Rank",
                    desc = "Check if you have high enough rank before tracking herbs/ore. Only english client support",
                    width = 0.9,
                    get = function()
                        return DMW.Settings.profile.Tracker.CheckRank
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.CheckRank = value
                    end
                },
                HideGrey = {
                    type = "toggle",
                    order = 10,
                    name = "Hide Grey",
                    desc = "Hide grey herbs/ore. Only english client support",
                    width = 0.9,
                    get = function()
                        return DMW.Settings.profile.Tracker.HideGrey
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.HideGrey = value
                    end
                },
                Trackable = {
                    type = "toggle",
                    order = 11,
                    name = "Track Special Objects",
                    desc = "Mark special objects in the world (chests, containers ect.)",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Tracker.Trackable
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.Trackable = value
                    end
                },
                TrackNPC = {
                    type = "toggle",
                    order = 12,
                    name = "Track NPCs",
                    desc = "Track important NPCs",
                    width = 0.7,
                    get = function()
                        return DMW.Settings.profile.Tracker.TrackNPC
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.TrackNPC = value
                    end
                },
                TrackNPCColor = {
                    type = "color",
                    order = 13,
                    name = "Color",
                    desc = "Color",
                    width = 0.5,
                    hasAlpha = true,
                    get = function()
                        return DMW.Settings.profile.Tracker.TrackNPCColor[1], DMW.Settings.profile.Tracker.TrackNPCColor[2], DMW.Settings.profile.Tracker.TrackNPCColor[3], DMW.Settings.profile.Tracker.TrackNPCColor[4]
                    end,
                    set = function(info, r, g, b, a)
                        DMW.Settings.profile.Tracker.TrackNPCColor = { r, g, b, a }
                    end
                },
                TrackPlayers = {
                    type = "input",
                    order = 14,
                    name = "Track Players By Name",
                    desc = "Mark Players by name or part of name, separated by comma",
                    width = "full",
                    multiline = true,
                    get = function()
                        return DMW.Settings.profile.Tracker.TrackPlayers
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.TrackPlayers = value
                    end
                },
                TrackPlayersLine = {
                    type = "range",
                    order = 15,
                    name = "Line",
                    desc = "Width of line to Player",
                    width = 0.6,
                    min = 0,
                    max = 5,
                    step = 1,
                    get = function()
                        return DMW.Settings.profile.Tracker.TrackPlayersLine
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.TrackPlayersLine = value
                    end
                },
                TrackPlayersAlert = {
                    type = "input",
                    order = 16,
                    name = "Alert",
                    desc = "Sound for Alert, 416 = Murlocs",
                    width = 0.4,
                    get = function()
                        return tostring(DMW.Settings.profile.Tracker.TrackPlayersAlert)
                    end,
                    set = function(info, value)
                        if tonumber(value) then
                            DMW.Settings.profile.Tracker.TrackPlayersAlert = tonumber(value)
                        else
                            DMW.Settings.profile.Tracker.TrackPlayersAlert = 0
                        end
                    end
                },
                TrackPlayersColor = {
                    type = "color",
                    order = 17,
                    name = "Color",
                    desc = "Color",
                    width = 0.4,
                    hasAlpha = true,
                    get = function()
                        return DMW.Settings.profile.Tracker.TrackPlayersColor[1], DMW.Settings.profile.Tracker.TrackPlayersColor[2], DMW.Settings.profile.Tracker.TrackPlayersColor[3], DMW.Settings.profile.Tracker.TrackPlayersColor[4]
                    end,
                    set = function(info, r, g, b, a)
                        DMW.Settings.profile.Tracker.TrackPlayersColor = { r, g, b, a }
                    end
                },
                Trackshit = {
                    type = "execute",
                    order = 18,
                    name = "Track Targeted Player",
                    desc = "Add targeted player name to list",
                    width = "full",
                    func = function()
                        if DMW.Player.Target and DMW.Player.Target.Player then
                            for k in string.gmatch(DMW.Settings.profile.Tracker.TrackPlayers, "([^,]+)") do
                                if strmatch(string.lower(DMW.Player.Target.Name), string.lower(string.trim(k))) then
                                    return
                                end
                            end
                            if DMW.Settings.profile.Tracker.TrackPlayers == nil or DMW.Settings.profile.Tracker.TrackPlayers == "" then
                                DMW.Settings.profile.Tracker.TrackPlayers = DMW.Player.Target.Name
                            else
                                DMW.Settings.profile.Tracker.TrackPlayers = DMW.Settings.profile.Tracker.TrackPlayers .. "," .. DMW.Player.Target.Name
                            end
                        end
                    end
                },
                TrackPlayersAny = {
                    type = "toggle",
                    order = 19,
                    name = "Track All Players",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Tracker.TrackPlayersAny
                    end,
                    set = function(info, value)
                        if value and DMW.Settings.profile.Tracker.TrackPlayersEnemy then
                            DMW.Settings.profile.Tracker.TrackPlayersEnemy = false
                        end
                        DMW.Settings.profile.Tracker.TrackPlayersAny = value
                    end
                },
                TrackPlayersEnemy = {
                    type = "toggle",
                    order = 20,
                    name = "Track All Enemy Players",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Tracker.TrackPlayersEnemy
                    end,
                    set = function(info, value)
                        if value and DMW.Settings.profile.Tracker.TrackPlayersAny then
                            DMW.Settings.profile.Tracker.TrackPlayersAny = false
                        end
                        DMW.Settings.profile.Tracker.TrackPlayersEnemy = value
                    end
                },
                TrackPlayersNameplates = {
                    type = "toggle",
                    order = 21,
                    name = "Track Enemy Players Nameplates",
                    desc = "Track enemy players outside nameplate range",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Tracker.TrackPlayersNamePlates
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.TrackPlayersNamePlates = value
                    end
                },
                DrawLine = {
                    type = "toggle",
                    order = 22,
                    name = "DrawLine",
                    desc = "",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Tracker.DrawLine
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Tracker.DrawLine = value
                    end
                }
            }
        },
        GathersTab = {
            name = "Loot",
            type = "group",
            order = 7,
            args = {
                AutoLoot = {
                    type = "toggle",
                    order = 1,
                    name = "AutoLoot",
                    desc = "",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Helpers.AutoLoot
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Helpers.AutoLoot = value
                    end
                },
                AutoSkinning = {
                    type = "toggle",
                    order = 2,
                    name = "AutoSkinning",
                    desc = "AutoSkinning",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Helpers.AutoSkinning
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Helpers.AutoSkinning = value
                    end
                },
                AutoGather = {
                    type = "toggle",
                    order = 2,
                    name = "AutoGather",
                    desc = "AutoGather",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Helpers.AutoGather
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Helpers.AutoGather = value
                    end
                },
                PickFlag = {
                    type = "toggle",
                    order = 3,
                    name = "PickFlag",
                    desc = "PickFlag",
                    width = "full",
                    get = function()
                        return DMW.Settings.profile.Helpers.PickFlag
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Helpers.PickFlag = value
                    end
                },

            }
        },
        BattleTable = {
            name = "Battle",
            type = "group",
            order = 8,
            args = {
                JoinRandomBG = {
                    type = "toggle",
                    order = 1,
                    name = "RandomBattle",
                    desc = "",
                    width = 0.8,
                    get = function()
                        return DMW.Settings.profile.Battle.JoinBattle
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Battle.JoinBattle = value
                    end
                },
                JoinRank = {
                    type = "toggle",
                    order = 2,
                    name = "JoinRank",
                    desc = "",
                    width = 0.8,
                    get = function()
                        return DMW.Settings.profile.Battle.JoinRank
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Battle.JoinRank = value
                    end
                },
                BattleKey = {
                    type = "input",
                    order = 2,
                    name = "战场界面热键",
                    desc = "战场界面热键",
                    width = 0.5,
                    get = function()
                        return DMW.Settings.profile.Battle.CommandKey
                    end,
                    set = function(info, value)
                        if value then
                            DMW.Settings.profile.Battle.CommandKey = value
                        else
                            DMW.Settings.profile.Battle.CommandKey = ""
                        end
                    end


                },
                BattleAlert = {
                    type = "input",
                    order = 3,
                    name = "JoinBattleAlert",
                    desc = "Sound for Alert, 416 = Murlocs",
                    width = "full",
                    get = function()
                        return tostring(DMW.Settings.profile.Battle.Alert)
                    end,
                    set = function(info, value)
                        if tonumber(value) then
                            DMW.Settings.profile.Battle.Alert = tonumber(value)
                        else
                            DMW.Settings.profile.Battle.Alert = 0
                        end
                    end
                },
            }
        },
        DungeonTable = {
            name = "Dungeon",
            type = "group",
            order = 9,
            args = {
                JoinRandomDungeon = {
                    type = "toggle",
                    order = 1,
                    name = "RandomDungeon",
                    desc = "",
                    width = 0.8,
                    get = function()
                        return DMW.Settings.profile.Dungeon.JoinRandomDungeon
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Dungeon.JoinRandomDungeon = value
                    end
                },
                Follow = {
                    type = "toggle",
                    order = 1,
                    name = "Follow",
                    desc = "",
                    width = 0.8,
                    get = function()
                        return DMW.Settings.profile.Dungeon.Follow
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Dungeon.Follow = value
                    end
                },
                FollowDistance = {
                    type = "range",
                    order = 2,
                    name = "FollowDistance",
                    desc = "",
                    width = 0.6,
                    min = 2,
                    max = 40,
                    step = 1,
                    get = function()
                        return DMW.Settings.profile.Dungeon.FollowDistance
                    end,
                    set = function(info, value)
                        DMW.Settings.profile.Dungeon.FollowDistance = value
                    end
                },
            }
        }
    }
}

local MinimapIcon = LibStub("LibDataBroker-1.1"):NewDataObject(
        "MinimapIcon",
        {
            type = "data source",
            text = "DMW",
            icon = "Interface\\Icons\\Achievement_dungeon_utgardepinnacle_25man",
            OnClick = function(self, button)
                if button == "LeftButton" then
                    UI.Show()
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine("DoMeWhen", 1, 1, 1)
            end
        }
)

function UI.Show()
    if not UI.ConfigFrame then
        UI.ConfigFrame = AceGUI:Create("Frame")
        UI.ConfigFrame:Hide()
        _G["DMWConfigFrame"] = UI.ConfigFrame.frame
        table.insert(UISpecialFrames, "DMWConfigFrame")
    end
    if not UI.ConfigFrame:IsShown() then
        LibStub("AceConfigDialog-3.0"):Open("DMW", UI.ConfigFrame)
    else
        UI.ConfigFrame:Hide()
    end
end

function UI.Init()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("DMW", Options)
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("DMW", 400, 750)
    UI.MinimapIcon = LibStub("LibDBIcon-1.0")
    UI.MinimapIcon:Register("MinimapIcon", MinimapIcon, DMW.Settings.profile.MinimapIcon)
end

function UI.AddHeader(Text)
    local Setting = Text:gsub("%s+", "")
    Options.args.RotationTab.args[Setting .. "Header"] = {
        type = "header",
        order = RotationOrder,
        name = Text
    }
    RotationOrder = RotationOrder + 1
end

function UI.AddToggle(Name, Desc, Default)
    Options.args.RotationTab.args[Name] = {
        type = "toggle",
        order = RotationOrder,
        name = Name,
        desc = Desc,
        width = "full",
        get = function()
            return DMW.Settings.profile.Rotation[Name]
        end,
        set = function(info, value)
            DMW.Settings.profile.Rotation[Name] = value
        end
    }
    if Default and DMW.Settings.profile.Rotation[Name] == nil then
        DMW.Settings.profile.Rotation[Name] = Default
    end
    RotationOrder = RotationOrder + 1
end

function UI.AddRange(Name, Desc, Min, Max, Step, Default)
    Options.args.RotationTab.args[Name] = {
        type = "range",
        order = RotationOrder,
        name = Name,
        desc = Desc,
        width = "full",
        min = Min,
        max = Max,
        step = Step,
        get = function()
            return DMW.Settings.profile.Rotation[Name]
        end,
        set = function(info, value)
            DMW.Settings.profile.Rotation[Name] = value
        end
    }
    if Default and DMW.Settings.profile.Rotation[Name] == nil then
        DMW.Settings.profile.Rotation[Name] = Default
    end
    RotationOrder = RotationOrder + 1
end

function UI.AddDropdown(Name, Desc, Values, Default)
    Options.args.RotationTab.args[Name] = {
        type = "select",
        order = RotationOrder,
        name = Name,
        desc = Desc,
        width = "full",
        values = Values,
        style = "dropdown",
        get = function()
            return DMW.Settings.profile.Rotation[Name]
        end,
        set = function(info, value)
            DMW.Settings.profile.Rotation[Name] = value
        end
    }
    if Default and DMW.Settings.profile.Rotation[Name] == nil then
        DMW.Settings.profile.Rotation[Name] = Default
    end
    RotationOrder = RotationOrder + 1
end

function UI.AddQueue()
    for k, v in pairs(DMW.Player.Spells) do
        Options.args.QueueTab.args[k] = {
            type = "select",
            name = v.SpellName,
            --desc = Desc,
            width = "full",
            values = { "Disabled", "Normal", "Mouseover", "Cursor", "Cursor - No Cast" },
            style = "dropdown",
            get = function()
                return DMW.Settings.profile.Queue[v.SpellName]
            end,
            set = function(info, value)
                DMW.Settings.profile.Queue[v.SpellName] = value
            end
        }
        if DMW.Settings.profile.Queue[v.SpellName] == nil then
            DMW.Settings.profile.Queue[v.SpellName] = 1
        end
    end
end
function UI.InitNavigation()
    Options.args.NavigationTab = {
        name = "Navigation",
        type = "group",
        order = 6,
        args = {
            Manual = {
                type = "toggle",
                order = 0,
                name = "manual control",
                desc = "manual control",
                width = "full",
                get = function()
                    return DMW.Settings.profile.Navigation.Manual
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.Manual = true
                    else
                        DMW.Settings.profile.Navigation.Manual = false
                    end
                end
            },
            Enable = {
                type = "toggle",
                order = 1,
                name = "Enable Grinding",
                desc = "Check to enable grinding",
                width = "full",
                get = function()
                    return DMW.Settings.profile.Navigation.Mode == 1
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.Mode = 1
                    else
                        DMW.Settings.profile.Navigation.Mode = 0
                    end
                end
            },
            AutoGrind = {
                type = "toggle",
                order = 2,
                name = "Enable Auto Grinding",
                desc = "Check to enable auto grinding",
                width = "full",
                get = function()
                    return DMW.Settings.profile.Navigation.AutoGrind
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.AutoGrind = true
                    else
                        DMW.Settings.profile.Navigation.AutoGrind = false
                    end
                end
            },
            AttackDistance = {
                type = "range",
                order = 3,
                name = "Attack Distance",
                desc = "Set distance to stop moving towards target",
                width = "full",
                min = 0.0,
                max = 40.0,
                step = 0.2,
                get = function()
                    return DMW.Settings.profile.Navigation.AttackDistance
                end,
                set = function(info, value)
                    DMW.Settings.profile.Navigation.AttackDistance = value
                end
            },
            MaxDistance = {
                type = "range",
                order = 4,
                name = "Max Attack Distance",
                desc = "Set distance to start moving towards target again",
                width = "full",
                min = 0.0,
                max = 40.0,
                step = 0.2,
                get = function()
                    return DMW.Settings.profile.Navigation.MaxDistance
                end,
                set = function(info, value)
                    DMW.Settings.profile.Navigation.MaxDistance = value
                end
            },
            LevelRange = {
                type = "range",
                order = 5,
                name = "Max level difference",
                desc = "Set max level difference of mobs",
                width = "full",
                min = 0,
                max = 130,
                step = 1,
                get = function()
                    return DMW.Settings.profile.Navigation.LevelRange
                end,
                set = function(info, value)
                    DMW.Settings.profile.Navigation.LevelRange = value
                end
            },
            GrindName = {
                type = "input",
                order = 6,
                name = "巡逻路径",
                desc = "巡逻路径文件名称",
                width = 10,
                get = function()
                    return tostring(DMW.Settings.profile.Navigation.GrindName)
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.GrindName = value
                        ReloadUI()
                    else
                        DMW.Settings.profile.Navigation.GrindName = ""
                    end
                end
            },
            GrindRadius = {
                type = "range",
                order = 7,
                name = "循环距离",
                desc = "怪物到grind节点的最远距离",
                width = "2",
                min = 1,
                max = 3000,
                step = 1,
                get = function()
                    return DMW.Settings.profile.Navigation.GrindRadius
                end,
                set = function(info, value)
                    DMW.Settings.profile.Navigation.GrindRadius = value
                end
            },
            Npc = {
                type = "toggle",
                order = 8,
                name = "设置修理贩卖npc",
                desc = "设置修理贩卖",
                width = 5,
                get = function()
                    return DMW.Settings.profile.Navigation.Npc
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.Npc = true
                        DMW.Helpers.Navigation:SaveNpc()
                    else
                        DMW.Settings.profile.Navigation.Npc = false
                    end
                end
            },
            DropGrey = {
                type = "toggle",
                order = 9,
                name = "丢弃灰色品质物品",
                desc = "drop grey quality thing",
                width = 5,
                get = function()
                    return DMW.Settings.profile.Navigation.DropGrey
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.DropGrey = true
                    else
                        DMW.Settings.profile.Navigation.DropGrey = false
                    end
                end
            },
            DropWhite = {
                type = "toggle",
                order = 10,
                name = "丢弃白色品质物品",
                desc = "drop white quality thing",
                width = 5,
                get = function()
                    return DMW.Settings.profile.Navigation.DropWhite
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.DropWhite = true
                    else
                        DMW.Settings.profile.Navigation.DropWhite = false
                    end
                end
            },
            SaleGrey = {
                type = "toggle",
                order = 11,
                name = "自动售卖灰色物品",
                desc = "自动售卖灰色物品",
                width = 5,
                get = function()
                    return DMW.Settings.profile.Navigation.SaleGrey
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.SaleGrey = true
                    else
                        DMW.Settings.profile.Navigation.SaleGrey = false
                    end
                end
            },
            SaleWhite = {
                type = "toggle",
                order = 12,
                name = "自动售卖白色物品",
                desc = "自动售卖白色物品",
                width = 5,
                get = function()
                    return DMW.Settings.profile.Navigation.SaleWhite
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.SaleWhite = true
                    else
                        DMW.Settings.profile.Navigation.SaleWhite = false
                    end
                end
            },
            SaleGreen = {
                type = "toggle",
                order = 13,
                name = "自动售卖绿色物品",
                desc = "自动售卖绿色物品",
                width = 5,
                get = function()
                    return DMW.Settings.profile.Navigation.SaleGreen
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.SaleGreen = true
                    else
                        DMW.Settings.profile.Navigation.SaleGreen = false
                    end
                end
            },
            LogPoint = {
                type = "toggle",
                order = 14,
                name = "记录路径",
                width = 5,
                get = function()
                    return DMW.Settings.profile.Navigation.LogPoint
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.LogPoint = true
                    else
                        DMW.Settings.profile.Navigation.LogPoint = false
                    end
                end
            },
            JoinAS = {
                type = "toggle",
                order = 15,
                name = "加入战场",
                desc = "加入战场",
                width = 5,
                get = function()
                    return DMW.Settings.profile.Navigation.JoinAS
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.JoinAS = true
                    else
                        DMW.Settings.profile.Navigation.JoinAS = false
                    end
                end
            },

            AttackPlayer = {
                type = "toggle",
                order = 17,
                name = "攻击玩家",
                desc = "攻击玩家",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.AttackPlayer
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.AttackPlayer = true
                    else
                        DMW.Settings.profile.Navigation.AttackPlayer = false
                    end
                end
            },
            GatherMode = {
                type = "toggle",
                order = 18,
                name = "采集模式",
                desc = "采集模式",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.GatherMode
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.GatherMode = true
                    else
                        DMW.Settings.profile.Navigation.GatherMode = false
                    end
                end
            },
            MountName = {
                type = "input",
                order = 19,
                name = "坐骑名称",
                desc = "坐骑名称",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.MountName
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.MountName = value
                    else
                        DMW.Settings.profile.Navigation.MountName = nil
                    end
                end
            },
            AutoFollow = {
                type = "toggle",
                order = 20,
                name = "自动跟随",
                desc = "自动跟随",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.AutoFollow
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.AutoFollow = true
                    else
                        DMW.Settings.profile.Navigation.AutoFollow = false
                    end
                end
            },
            FollowMaxRange = {
                type = "range",
                order = 21,
                name = "最大跟随距离",
                desc = "最大跟随距离，必须大于最小跟随距离",
                min = 1,
                max = 300,
                step = 1,
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.FollowMaxRange
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.FollowMaxRange = value
                    else
                        DMW.Settings.profile.Navigation.FollowMaxRange = 10
                    end
                end
            },
            FollowMinRange = {
                type = "range",
                order = 22,
                name = "最小跟随距离",
                desc = "最小跟随距离",
                min = 1,
                max = 300,
                step = 1,
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.FollowMinRange
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.FollowMinRange = value
                    else
                        DMW.Settings.profile.Navigation.FollowMinRange = 10
                    end
                end
            },
            AutoSearch = {
                type = "toggle",
                order = 23,
                name = "自动选择敌人",
                desc = "自动选择敌人",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.AutoSearch
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.AutoSearch = true
                    else
                        DMW.Settings.profile.Navigation.AutoSearch = false
                    end
                end
            },
            AutoFlag = {
                type = "toggle",
                order = 24,
                name = "自动抗旗",
                desc = "自动抗旗",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.AutoFlag
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.AutoFlag = true
                    else
                        DMW.Settings.profile.Navigation.AutoFlag = false
                    end
                end
            },
            NoMove = {
                type = "toggle",
                order = 25,
                name = "挂机",
                desc = "挂机",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.NoMove
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.NoMove = true
                    else
                        DMW.Settings.profile.Navigation.NoMove = false
                    end
                end
            },
            NoLive = {
                type = "toggle",
                order = 26,
                name = "不复活",
                desc = "不复活",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.NoLive
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.NoLive = true
                    else
                        DMW.Settings.profile.Navigation.NoLive = false
                    end
                end
            },
            DrawLine = {
                type = "toggle",
                order = 27,
                name = "绘制",
                desc = "绘制",
                width = 28,
                get = function()
                    return DMW.Settings.profile.Navigation.DrawLine
                end,
                set = function(info, value)
                    if value then
                        DMW.Settings.profile.Navigation.DrawLine = true
                    else
                        DMW.Settings.profile.Navigation.DrawLine = false
                    end
                end
            },
        }
    }
end
