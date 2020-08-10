local DMW = DMW
DMW.Helpers.Gatherers = {}
DMW.Helpers.Gatherers.SkinningTime = 0
local Gatherers = DMW.Helpers.Gatherers
Gatherers.SkinningTime = 0
Gatherers.DisMount = false

local Looting = false
local Skinning = false
local Player = DMW.Player
local InteractLength = 5

function Gatherers:CheckLoot()
    local HelpersSettings = DMW.Settings.profile.Helpers
    if Player.Combat or (not HelpersSettings.AutoLoot and not HelpersSettings.AutoSkinning and not HelpersSettings.AutoGather) then
        return false
    end
    for _, Unit in pairs(DMW.Units) do
        if HelpersSettings.AutoLoot and Unit.Dead and UnitCanBeLooted(Unit.Pointer) then
            if Unit.Distance > InteractLength then
                DMW.Helpers.Navigation:MoveTo(Unit.PosX, Unit.PosY, Unit.PosZ)
                DMW.Helpers.Navigation:realyMove()
            end
            return true
        end
        if HelpersSettings.AutoSkinning and Unit.Dead and UnitCanBeSkinned(Unit.Pointer) then
            if Unit.Distance > InteractLength then
                DMW.Helpers.Navigation:MoveTo(Unit.PosX, Unit.PosY, Unit.PosZ)
                DMW.Helpers.Navigation:realyMove()
            end
            return true
        end
    end
    if HelpersSettings.AutoGather then
        for _, Object in pairs(DMW.GameObjects) do
            if Object.Herb then
                DMW.Helpers.Navigation:MoveTo(Object.PosX, Object.PosY, Object.PosZ)
                DMW.Helpers.Navigation:realyMove()
                return true
            elseif Object.Ore then
                if Object.Distance > InteractLength then
                    DMW.Helpers.Navigation:MoveTo(Object.PosX, Object.PosY, Object.PosZ)
                    DMW.Helpers.Navigation:realyMove()
                    return true
                end
            elseif Object.BgFlag then
                if Object.Distance > InteractLength then

                    return false
                end
            elseif Object.Trackable then
                return false
            end
        end
    end
    return false
end

function Gatherers:Run()
    local Player = DMW.Player
    if Player.Dead or Player.Casting then
        return false
    end
    local HelpersSettings = DMW.Settings.profile.Helpers
    if Looting and (DMW.Time - Looting) > 0 and not Player.Looting then
        Looting = false
    end
    if HelpersSettings.AutoSkinning and Skinning and (DMW.Time - Skinning) > 0 then
        Skinning = false
    end
    for _, Unit in pairs(DMW.Units) do
        if HelpersSettings.AutoLoot and not Looting then
            if Unit.Dead and Unit.Distance < InteractLength and UnitCanBeLooted(Unit.Pointer) then
                if IsMounted() then
                    Dismount()
                end
                InteractUnit(Unit.Pointer)
                DMW.Helpers.Gatherers.SkinningTime = DMW.Time + 2
                Looting = DMW.Time + 1.2
                return
            end
        end
        if HelpersSettings.AutoSkinning and not Skinning and not Player.Combat then
            if Unit.Dead and Unit.Distance < InteractLength and UnitCanBeSkinned(Unit.Pointer) then
                if IsMounted() then
                    Dismount()
                end
                InteractUnit(Unit.Pointer)
                DMW.Helpers.Gatherers.SkinningTime = DMW.Time + 2
                return
            end
        end
    end
    if HelpersSettings.PickFlag then
        for _, Object in pairs(DMW.GameObjects) do
            if Object.BgFlag and Object.Distance < InteractLength + 3 then
                if IsMounted() then
                    Dismount()
                end
                ObjectInteract(Object.Pointer)
                DMW.Helpers.Gatherers.SkinningTime = DMW.Time + 2
                Looting = DMW.Time + 1.2
                return
            end
        end
    end
    if HelpersSettings.AutoGather and not Looting then
        for _, Object in pairs(DMW.GameObjects) do
            if Object.Herb and Object.Distance < InteractLength + 3
                    and (not DMW.Player.Spells.HerbGathering:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 2)) then
                if IsMounted() then
                    Dismount()
                end
                ObjectInteract(Object.Pointer)
                DMW.Helpers.Gatherers.SkinningTime = DMW.Time + 2
                Looting = DMW.Time + 1.2
                return
            elseif Object.Ore and Object.Distance < InteractLength + 3 and
                    (not DMW.Player.Spells.Mining:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 2)) then
                if IsMounted() then
                    Dismount()
                end
                ObjectInteract(Object.Pointer)
                DMW.Helpers.Gatherers.SkinningTime = DMW.Time + 2
                Looting = DMW.Time + 1.2
                return
            elseif Object.Trackable and Object.Distance < InteractLength + 3 then
                if IsMounted() then
                    Dismount()
                end
                ObjectInteract(Object.Pointer)
                DMW.Helpers.Gatherers.SkinningTime = DMW.Time + 2
                Looting = DMW.Time + 1.2
                return
            end
        end
    end
end
