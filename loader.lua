local Scripts = {
    [1119466531] = "https://raw.githubusercontent.com/Coallly2/vitalityloader/Loader/1119466531.lua",
    [10256263771] = "https://raw.githubusercontent.com/Coallly2/vitalityloader/Loader/10256263771.lua"
}

local id = tonumber(game.GameId)

print("GameId:", id)

local url = Scripts[id]

if not url then
    warn("No script available for GameId "..id)
    return
end

local source = game:HttpGet(url)

local func, err = loadstring(source)

if not func then
    warn("Compile error:", err)
    return
end

func()
