local scriptGameId = "136107936984073"
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

-- === SCRIPT PAYLOAD FOR GAME 136107936984073 ===
-- (add your script here)