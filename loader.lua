local Scripts = {
    [3101667897] = "https://raw.githubusercontent.com/Coallly2/vitalityloader/Loader/3101667897.lua",
    [136107936984073] = "https://raw.githubusercontent.com/Coallly2/vitalityloader/Loader/136107936984073.lua"
}

local url = Scripts[game.GameId]

if not url then
    warn(("No script available for GameId %d"):format(game.GameId))
    return
end

local success, source = pcall(function()
    return game:HttpGet(url)
end)

if not success then
    warn("Failed to download script:", source)
    return
end

local func, err = loadstring(source)
if not func then
    warn("Failed to compile script:", err)
    return
end

func()
