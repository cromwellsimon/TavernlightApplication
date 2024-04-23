-- This is inexhaustive for what all exists on the Player
---@class Player
-- As far as I can tell, there isn't a way to define function arguments if the function is being used as a type
---@field setStorageValue function
---@field getStorageValue function
---@field getParty function
---@field online boolean

--- https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/src/player.h#L135 tells me that the Player's IDs are numeric, so these can be numbers, not strings
---@param id number
---@return Player?
function Player(id)
    if (type(id) ~= "number") then
        return nil
    end
    return {}
end