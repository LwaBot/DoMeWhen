local DMW = DMW
DMW.Helpers.ChatFilter = {}
local keyWords = {}
local authors = {}
local inited = false
local authorHash = {}
local realmName = nil
local defaultWordDb = nil
local wordDbPath = nil
local authorDbPath = nil
local logPath = nil
local normalLogHash = {}
local normalLogPath = nil
local faction = UnitFactionGroup("player")
local date = date("%Y/%m/%d %H:%M:%S")
local playerName = nil

local function Init()
    defaultWordDb = {
        "金团",
    }
    realmName = GetRealmName()
    wordDbPath = "Interface/AddOns/DoMeWhen/KeyWords/WordDb.txt"
    authorDbPath = "Interface/AddOns/DoMeWhen/KeyWords/" .. realmName ..  "/" .. faction .. "AuthorDb.txt"
    logPath  = "Interface/AddOns/DoMeWhen/KeyWords/" .. realmName ..  "/" .. faction .. "LogDb.txt"
    normalLogPath = "Interface/AddOns/DoMeWhen/KeyWords/" .. realmName ..  "/" .. faction .. "NormalLogDb.txt"
    keyWords = StrToTable(ReadFile(wordDbPath))
    authors = StrToTable(ReadFile(authorDbPath))
    if not keyWords then
        keyWords = defaultWordDb
        WriteFile(wordDbPath, TableToStr(defaultWordDb), false, true)
    end
    if not authors then
        authors = {}
    end
    for idx, key in ipairs(authors) do
        authorHash[key] = "1"
    end
    playerName = UnitName("player")
end

local function removeRepeat(a)
    local b = {}
    for k, v in ipairs(a) do
        if (#b == 0) then
            b[1] = v;
        else
            local index = 0
            for i = 1, #b do
                if (v == b[i]) then
                    break
                end
                index = index + 1
            end
            if (index == #b) then
                b[#b + 1] = v;
            end
        end
    end
    return b
end

local function logNormal(event, msg, author, ...)
    local _,_,_,_,_,_,_,_,id = ...
    if not normalLogHash[id] then
        normalLogHash[id] = 1
        WriteFile(normalLogPath, date ..  " [" .. author  .."] "  .. msg   .. "\n", true)
    end
    return false,msg,author,...
end

local function updateAuthors(author)
    table.insert(authors, author)
    authors = removeRepeat(authors)
    if not authorHash[author] then
        WriteFile(authorDbPath, TableToStr(authors), false, true)
        authorHash[author] = "1"
    end
end

local function keyWordsFilter(self, event, msg, author, ...)
    if DMW.Settings.profile and not DMW.Settings.profile.General.FilterMsg then
        return false,msg,author,...
    end
    if not GetObjectWithGUID then
        return false,msg,author,...
    end
    if not inited then
        Init()
        inited = true
    end
    if author:find(playerName) then
        return logNormal(event, msg, author, ...)
    end
    if (not keyWords or #keyWords == 0) and (not authors or #authors == 0) then
        return logNormal(event, msg, author, ...)
    end
    if keyWords and #keyWords > 0 then
        for idx, key in ipairs(keyWords) do
            if msg:find(key) then
                updateAuthors(author)
                WriteFile(logPath, date .. " [" .. author  .."] "  .. msg .. "\n", true)
                return true
            end
        end
    end
    if authors and #authors > 0 then
        for idx, key in ipairs(authors) do
            if author:find(key) then
                return true
            end
        end
    end
    return logNormal(event, msg, author, ...)
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", keyWordsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", keyWordsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", keyWordsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", keyWordsFilter)
