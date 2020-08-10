local DMW = DMW
DMW.Tables.AuraCache = {}
DMW.Functions.AuraCache = {}
local AuraCache = DMW.Functions.AuraCache
local Buff = DMW.Classes.Buff
local Debuff = DMW.Classes.Debuff

function AuraCache.Refresh(Unit)
    if DMW.Tables.AuraCache[Unit] ~= nil then
        DMW.Tables.AuraCache[Unit] = nil
    end
    local AuraReturn, Name, Source

    for i = 1, 40 do
        AuraReturn = {UnitBuff(Unit, i)}
        Name, Source = GetSpellInfo(AuraReturn[10]), AuraReturn[7]
        if Name == nil then
            break
        end
        if DMW.Tables.AuraCache[Unit] == nil then
            DMW.Tables.AuraCache[Unit] = {}
        end
        if DMW.Tables.AuraCache[Unit][Name] == nil then
            DMW.Tables.AuraCache[Unit][Name] = {
                ["AuraReturn"] = AuraReturn,
                Type = "HELPFUL"
            }
        end        
        if Source ~= nil and Source == "player" then
            DMW.Tables.AuraCache[Unit][Name]["player"] = {
                ["AuraReturn"] = AuraReturn,
                Type = "HELPFUL"
            }
        end
    end

    for i = 1, 40 do
        AuraReturn = {UnitDebuff(Unit, i)}
        Name, Source = GetSpellInfo(AuraReturn[10]), AuraReturn[7]
        if Name == nil then
            break
        end
        if DMW.Tables.AuraCache[Unit] == nil then
            DMW.Tables.AuraCache[Unit] = {}
        end
        if DMW.Tables.AuraCache[Unit][Name] == nil then
            DMW.Tables.AuraCache[Unit][Name] = {
                ["AuraReturn"] = AuraReturn,
                Type = "HARMFUL"
            }
        end        
        if Source ~= nil and Source == "player" then
            DMW.Tables.AuraCache[Unit][Name]["player"] = {
                ["AuraReturn"] = AuraReturn,
                Type = "HARMFUL"
            }
        end
    end
end

function AuraCache.Event(...)

	local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags,
          sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
          
    local dest = GetObjectWithGUID(destGUID)
    if dest and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_REMOVED" or event == "SPELL_PERIODIC_AURA_REMOVED") then
        AuraCache.Refresh(dest)
    end
end

function Buff:Query(Unit, OnlyPlayer)
    OnlyPlayer = OnlyPlayer or false
    Unit = Unit.Pointer
    if DMW.Tables.AuraCache[Unit] ~= nil and DMW.Tables.AuraCache[Unit][self.SpellName] ~= nil and (not OnlyPlayer or DMW.Tables.AuraCache[Unit][self.SpellName]["player"] ~= nil) then
        local AuraReturn
        if OnlyPlayer then
            AuraReturn = DMW.Tables.AuraCache[Unit][self.SpellName]["player"].AuraReturn
        else
            AuraReturn = DMW.Tables.AuraCache[Unit][self.SpellName].AuraReturn
        end
        return unpack(AuraReturn)
    end
    return nil
end

function Debuff:Query(Unit, OnlyPlayer)
    OnlyPlayer = OnlyPlayer or false
    Unit = Unit.Pointer
    if DMW.Tables.AuraCache[Unit] ~= nil and DMW.Tables.AuraCache[Unit][self.SpellName] ~= nil and (not OnlyPlayer or DMW.Tables.AuraCache[Unit][self.SpellName]["player"] ~= nil) then
        local AuraReturn
        if OnlyPlayer then
            AuraReturn = DMW.Tables.AuraCache[Unit][self.SpellName]["player"].AuraReturn
        else
            AuraReturn = DMW.Tables.AuraCache[Unit][self.SpellName].AuraReturn
        end
        return unpack(AuraReturn)
    end
    return nil
end