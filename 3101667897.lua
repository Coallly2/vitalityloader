local scriptGameId = "3101667897"
local currentGameId = tostring(game.PlaceId)

if currentGameId ~= scriptGameId then
    local loader, err = loadfile(currentGameId .. ".lua")
    if loader then
        local success, result = pcall(loader)
        if not success then
            warn("Script error: " .. result)
        end
    else
        warn("No script for game " .. currentGameId)
    end
    return
end

-- === SCRIPT PAYLOAD FOR GAME 3101667897 ===
-- (add your script here)