local Scripts = {
    [1119466531] = "https://raw.githubusercontent.com/Coallly2/vitalityloader/Loader/1119466531.lua", -- Legend's of Speed
    [10256263771] = "https://raw.githubusercontent.com/Coallly2/vitalityloader/Loader/10256263771.lua" -- Push Boulder
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
