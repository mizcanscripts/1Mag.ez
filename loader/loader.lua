-- 1Mag.ez
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("[1Mag.ez] booted")
print("[1Mag.ez] PlaceId = " .. tostring(game.PlaceId) .. "  GameId (universe) = " .. tostring(game.GameId))

local GameRegistry = {
    [17625359962] = {
        Name = "Rivals",
        Url = "https://raw.githubusercontent.com/mizcanscripts/1Mag.ez/refs/heads/main/src/Rivals/1mag%2520fixedcrimson.lua.obfuscated.lua.txt",
        UseUniverseId = true
    }
}

local function ExecuteRemoteScript(gameData)
    print("[1Mag.ez] fetching: " .. gameData.Url)
    local fetchSuccess, scriptContent = pcall(function()
        return game:HttpGet(gameData.Url)
    end)

    if not fetchSuccess then
        warn("[1Mag.ez] HTTP raised: " .. tostring(scriptContent))
        return
    end

    if type(scriptContent) ~= "string" then
        warn("[1Mag.ez] HTTP returned non-string: " .. typeof(scriptContent))
        return
    end

    if #scriptContent == 0 then
        warn("[1Mag.ez] HTTP returned empty body — check the URL in a browser")
        return
    end

    print("[1Mag.ez] fetched " .. #scriptContent .. " bytes")

    local compiledFunc, compileErr = loadstring(scriptContent)
    if not compiledFunc then
        warn("[1Mag.ez] compile error: " .. tostring(compileErr))
        return
    end

    print("[1Mag.ez] compiled OK, executing")

    task.spawn(function()
        local execSuccess, execErr = pcall(compiledFunc)
        if not execSuccess then
            warn("[1Mag.ez] runtime error: " .. tostring(execErr))
        else
            print("[1Mag.ez] executed clean")
        end
    end)
end

local function Init()
    local currentPlaceId = game.PlaceId
    local currentGameId = game.GameId
    local matchedGame = nil

    for id, data in pairs(GameRegistry) do
        if data.UseUniverseId and id == currentGameId then
            matchedGame = data
            break
        elseif not data.UseUniverseId and id == currentPlaceId then
            matchedGame = data
            break
        end
    end

    if matchedGame then
        print("[1Mag.ez] matched: " .. matchedGame.Name)
        ExecuteRemoteScript(matchedGame)
    else
        warn(string.format("[1Mag.ez] unsupported game | PlaceId: %d | GameId: %d", currentPlaceId, currentGameId))
    end
end

Init()
