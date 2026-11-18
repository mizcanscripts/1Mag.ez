-- 1Mag.ez
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local GameRegistry = {
    [17625359962] = {
        Name = "Rivals",
        Url = "https://raw.githubusercontent.com/mizcanscripts/1Mag.ez/refs/heads/main/src/Rivals/1mag%2520fixedcrimson.lua.obfuscated.lua.txt",
        UseUniverseId = false
    }
}

local function ExecuteRemoteScript(gameData)
    local fetchSuccess, scriptContent = pcall(function()
        return game:HttpGet(gameData.Url)
    end)

    if not fetchSuccess or type(scriptContent) ~= "string" or #scriptContent == 0 then
        warn("[1Mag.ez] HTTP Fetch Failed for " .. gameData.Name .. ": " .. tostring(scriptContent))
        return
    end

    local compiledFunc, compileErr = loadstring(scriptContent)
    if not compiledFunc then
        warn("[1Mag.ez] Syntax/Compile Error in " .. gameData.Name .. ": " .. tostring(compileErr))
        return
    end

    task.spawn(function()
        local execSuccess, execErr = pcall(compiledFunc)
        if not execSuccess then
            warn("[1Mag.ez] Runtime Error in " .. gameData.Name .. ": " .. tostring(execErr))
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
        ExecuteRemoteScript(matchedGame)
    else
        warn(string.format("[1Mag.ez] Unsupported Game | PlaceId: %d | GameId: %d", currentPlaceId, currentGameId))
    end
end

Init()
