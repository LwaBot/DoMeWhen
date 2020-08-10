local DMW = DMW
DMW.Helpers.Rotation = {}
local Rotation = DMW.Helpers.Rotation

function Rotation.Active(CastingCheck)
    CastingCheck = CastingCheck or true
    local casting = DMW.Player.Casting
    if DMW.Settings.profile.HUD.Rotation == 1 and (not CastingCheck or not casting) and not IsMounted() and not DMW.Player.NoControl and
        (not DMW.Player.Spells.FocusedAzeriteBeam:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.2)) then
        return true
    end
    return false
end

function Rotation.GetSpellByID(SpellID)
    local SpellName = GetSpellInfo(SpellID)
    for _, Spell in pairs(DMW.Player.Spells) do
        if Spell.SpellName == SpellName then
            return Spell
        end
    end
end

function Rotation.RawDistance(X1, Y1, Z1, X2, Y2, Z2)
    return sqrt(((X1 - X2) ^ 2) + ((Y1 - Y2) ^ 2) + ((Z1 - Z2) ^ 2))
end

function Rotation.Setting(Setting)
    return DMW.Settings.profile.Rotation[Setting]
end
