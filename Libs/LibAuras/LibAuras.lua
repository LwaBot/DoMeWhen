local lib = LibStub:NewLibrary("LibAuras", 803)

if not lib then return end

if not lib.frame then
    lib.frame = CreateFrame("Frame")
end

lib.AURAS = lib.AURAS or {}

local FILTERS, getGuidAndCheckAuras, getBuff, getDebuff, getAura, nameToSpellId, getAurasForUnit, addBuff, addDebuff, addAura

lib.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
lib.frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then lib.AURAS = {} end
end)

function lib:ResetCache()
    for k,v in pairs(lib.AURAS) do
        v.updated = false
        for k2,v2 in pairs(v["BUFF"]) do
            if(v2.updated ~= nil) then
                v2.updated = false
            end
        end
        for k2,v2 in pairs(v["DEBUFF"]) do
            if(v2.updated ~= nil) then
                v2.updated = false
            end
        end
    end
    return
end

function lib:UnitBuff(unitId, spellIdOrName, filter)
    local guid = getGuidAndCheckAuras(unitId)
    if not guid then return end

    return getBuff(guid, spellIdOrName, filter or "")
end

function lib:UnitDebuff(unitId, spellIdOrName, filter)
    local guid = getGuidAndCheckAuras(unitId)
    if not guid then return end

    return getDebuff(guid, spellIdOrName, filter or "")
end

function lib:UnitAura(unitId, spellIdOrName, filter)
    local guid = getGuidAndCheckAuras(unitId)
    if not guid then return end

    local result = {getBuff(guid, spellIdOrName, filter or "")}
    if #result < 2 then
        return getDebuff(guid, spellIdOrName, filter or "")
    end
    return unpack(result)
end

local FILTERS = {
    HELPFUL = false,
    HARMFUL = false,
    PLAYER = false,
    RAID = false,
    CANCELABLE = false,
    NOTCANCELABLE = false
}

getGuidAndCheckAuras = function(unitId)
    local guid = UnitGUID(unitId)
    if not guid then return nil end
    if (not lib.AURAS[guid] or lib.AURAS[guid].updated == false)  then
        getAurasForUnit(unitId, guid)
    end
    return guid
end

getBuff = function(guid, spellIdOrName, filter)
    return getAura(guid, spellIdOrName, "HELPFUL")
end

getDebuff = function(guid, spellIdOrName, filter)
    return getAura(guid, spellIdOrName, "HARMFUL")
end

getAura = function(guid, spellIdOrName, filter)
    local auraType = "BUFF"
    if filter == "HARMFUL" then
        auraType = "DEBUFF"
    end
    local spellId = nameToSpellId(spellIdOrName, guid, auraType)
    local aura = lib.AURAS[guid][auraType][spellId]
    if (not aura or not aura.updated) then
        return
    end
    return aura.name, aura.icon, aura.count, aura.debuffType, aura.duration, aura.expirationTime, aura.unitCaster, aura.canStealOrPurge, aura.nameplateShowPersonal, spellId, aura.canApplyAura, aura.isBossDebuff, aura.isCastByPlayer, aura.nameplateShowAll, aura.timeMod, aura.value1, aura.value2, aura.value3
end

nameToSpellId = function(spellIdOrName, guid, auraType)
    if type(spellIdOrName) == "number" then
        return spellIdOrName
    elseif type(spellIdOrName) == "string" then
        if(lib.AURAS[guid][auraType][spellIdOrName]) then
            local spellId = lib.AURAS[guid][auraType][spellIdOrName].spellId
            if not spellId then return nil end
            return spellId
        end
    end
    return nil
end

getAurasForUnit = function(unitId, guid)
    if(not lib.AURAS[guid]) then
        lib.AURAS[guid] = {}
        lib.AURAS[guid]["BUFF"] = {}
        lib.AURAS[guid]["DEBUFF"] = {}
        lib.AURAS[guid]["updated"] = false
    end

    for i = 1, 40 do
        if not addBuff(unitId, guid, i) then break end
    end
    for i = 1, 40 do
        if not addDebuff(unitId, guid, i) then break end
    end

    lib.AURAS[guid].updated = true
end

addBuff = function(unitId, guid, index)
    return addAura(unitId, guid, index, "BUFF")
end

addDebuff = function(unitId, guid, index)
    return addAura(unitId, guid, index, "DEBUFF")
end

addAura = function(unitId, guid, index, type)
    local filter = nil
    if type == "BUFF" then filter = "HELPFUL" end
    if type == "DEBUFF" then filter = "HARMFUL" end
    if not filter then return end
    local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, value1, value2, value3 = UnitAura(unitId, index, filter)
    if (not name) then
        return false
    end
    if(not lib.AURAS[guid][type][spellId]) then
        lib.AURAS[guid][type][spellId] = {}
    end
    if(not lib.AURAS[guid][type][name]) then
        lib.AURAS[guid][type][name] = {}
    end
    if(not lib.AURAS[guid][type][spellId].updated) then
        lib.AURAS[guid][type][spellId].name = name
        lib.AURAS[guid][type][spellId].icon = icon
        lib.AURAS[guid][type][spellId].count = count
        lib.AURAS[guid][type][spellId].debuffType = debuffType
        lib.AURAS[guid][type][spellId].duration = duration
        lib.AURAS[guid][type][spellId].expirationTime = expirationTime
        lib.AURAS[guid][type][spellId].unitCaster = unitCaster
        lib.AURAS[guid][type][spellId].canStealOrPurge = canStealOrPurge
        lib.AURAS[guid][type][spellId].nameplateShowPersonal = nameplateShowPersonal
        lib.AURAS[guid][type][spellId].canApplyAura = canApplyAura
        lib.AURAS[guid][type][spellId].isBossDebuff = isBossDebuff
        lib.AURAS[guid][type][spellId].isCastByPlayer = isCastByPlayer
        lib.AURAS[guid][type][spellId].nameplateShowAll = nameplateShowAll
        lib.AURAS[guid][type][spellId].timeMod = timeMod
        lib.AURAS[guid][type][spellId].value1 = value1
        lib.AURAS[guid][type][spellId].value2 = value2
        lib.AURAS[guid][type][spellId].value3 = value3
        lib.AURAS[guid][type][spellId].updated = true
        if(not lib.AURAS[guid][type][name].updated or unitCaster == "player") then
            lib.AURAS[guid][type][name].spellId = spellId
            lib.AURAS[guid][type][name].updated = true
        end
    end
    return true
end
