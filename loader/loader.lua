-- 1Mag.ez
local MAG = {}
MAG.P = "[1Mag.ez]"

local KICK_ON_FAIL  = true
local KICK_ON_RERUN = false
local KICK_MESSAGE = "1Mag.ez\n\nThis game is not supported or the loader failed to start."

if getgenv().__1MAG_BOOTED then
    if KICK_ON_RERUN then
        game:GetService("Players").LocalPlayer:Kick(KICK_MESSAGE)
        return
    end
    warn(MAG.P .. " already booted this session — skipping")
    return
end
getgenv().__1MAG_BOOTED = true

local GameRegistry = {
    [6035872082] = {
        Name          = "Rivals",
        Url           = "https://api.jnkie.com/api/v1/luascripts/public/0598fe85aebe3417c0a2b26d2888153f47c073c97a3cc404a6fbc357ef64e2b0/download",
        UseUniverseId = true,
    },
}

local function kick(reason)
    if KICK_ON_FAIL then
        warn(MAG.P .. " kicking: " .. tostring(reason))
        game:GetService("Players").LocalPlayer:Kick(KICK_MESSAGE .. "\n\n" .. tostring(reason))
    else
        warn(MAG.P .. " failed: " .. tostring(reason))
    end
end

local function findEntry(placeId, gameId)
    for id, entry in pairs(GameRegistry) do
        if entry.UseUniverseId and id == gameId then
            return entry
        elseif not entry.UseUniverseId and id == placeId then
            return entry
        end
    end
    return nil
end

local function executePayload(entry)
    print(string.format("%s matched   -> %s", MAG.P, entry.Name))

    local ok, body = pcall(function() return game:HttpGet(entry.Url) end)
    if not ok then
        kick("fetch failed: " .. tostring(body))
        return
    end

    if type(body) ~= "string" or #body == 0 then
        kick("empty body for " .. entry.Name)
        return
    end

    print(string.format("%s fetched   -> %d bytes", MAG.P, #body))

    getgenv().__1MAG_LOADER = {
        Version  = "1.0",
        BootedAt = tick(),
        GameName = entry.Name,
        GameId   = game.GameId,
        PlaceId  = game.PlaceId,
    }

    local fn, err = loadstring(body)
    if not fn then
        kick("compile failed: " .. tostring(err))
        return
    end

    print(string.format("%s running   -> %s", MAG.P, entry.Name))

    task.spawn(function()
        local ok2, err2 = pcall(fn)
        if not ok2 then
            kick("runtime error: " .. tostring(err2))
        else
            print(string.format("%s done      -> %s", MAG.P, entry.Name))
        end
    end)
end

print(MAG.P .. " booting")

local entry = findEntry(game.PlaceId, game.GameId)
if not entry then
    kick(string.format("unsupported | PlaceId: %s | GameId: %s", tostring(game.PlaceId), tostring(game.GameId)))
    return
end

executePayload(entry)
