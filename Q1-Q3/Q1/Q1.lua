-- I'm going to make heavy use of Lua Language Server's Annotation system in order to provide a level of type-safety to the code.
-- I personally prefer making as much use of type safety as humanly possible.
-- I'm a sucker for using TypeScript over JavaScript, using type hints wherever possible in Python, and C# followed by C++ are my two most favorite languages.
-- Unfortunately, Annotations don't provide compile-time safety like TypeScript, C#, or C++ but, in my opinion, it is much better than no type-safety at all.
-- Lua's Annotations behave more like JavaScript's JSDocs or Python's type-hinting system. Not compile-time but again, better than nothing.

-- Documentation of Lua Language Server's Annotations: https://luals.github.io/wiki/annotations
-- VSCode Lua Language Server Extension: https://marketplace.visualstudio.com/items?itemName=sumneko.lua

-- My types for Q1-Q3 are specified under ./Types

local outcome = require("./Types/Outcome")

---@return Outcome
function InvalidPlayerResult()
    return outcome.Error("Specified player is not valid")
end

-- Because Lua is duck-typed, there is no definitive way of knowing if the type passed in really is a Player type for those not using Annotations so this will have to do for run-time checks
---@param player Player
---@return boolean
function IsValidPlayer(player)
    if  type(player) ~= "table"
        or type(player.setStorageValue) ~= "function" 
        or type(player.getStorageValue) ~= "function"
        or type(player.online) ~= "boolean" then
        return false
    end
    return true
end

-- I'm not quite sure what the purpose of this function is. What does item ID#1000 being equal to 1 or -1 represent?
-- Is it an unused item used to simply indicating if the player is online or not?
-- If so, why not simply set an online boolean on the player itself?
-- Furthermore, this function seems to not exist under https://github.com/otland/forgottenserver or https://github.com/edubart/otclient
---@param player Player
---@return Outcome
local function releaseStorage(player)
    -- The passed in player parameter could be invalid here. The annotation specified above will give a warning if anything other than a Player is passed in,
    -- but it's entirely possible that someone could be not using the Lua Language Server here so Annotations won't appear for them.
    if (IsValidPlayer(player) == false) then
        return InvalidPlayerResult()
    end
    player:setStorageValue(1000, -1)
    return outcome.Success()
end

-- To answer my questions above, these functions will do exactly that.
---@param player Player
---@return boolean
function IsOnline(player)
    return player.online
end

---@param player Player
---@param online boolean
function SetOnline(player, online)
    player.online = online
end

---@param player Player
---@return Outcome
-- I have read that the naming convention for Lua is to have global functions be PascalCase while having local functions be camelCase, but that's up to whatever the style guide establishes
function OnLogout(player)
    -- The passed in player parameter could be invalid here. The annotation specified above will give a warning if anything other than a Player is passed in,
    -- but it's entirely possible that someone could be not using the Lua Language Server here so Annotations won't appear for them.
    if IsValidPlayer(player) == false then
        return InvalidPlayerResult()
    end
    if IsOnline(player) then
        -- I'm assuming that addEvent will, in this example, call setOnline after 1000 milliseconds with player and false as its parameters.
        -- This is giving a warning in my Lua Language Server but I'm pretending that this function exists and behaves as described above
        addEvent(SetOnline, 1000, player, false)
    end
    return outcome.Success()
end