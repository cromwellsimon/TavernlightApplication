local outcome = require("./Types/Outcome")
require("./Types/Player")

--- https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/src/player.h#L135 tells me that the Player's IDs are numeric, so these can be numbers, not strings
---@param playerId number
---@param memberId number
---@return Outcome
-- Renamed 'do_sth_with_PlayerParty' to 'RemoveMemberFromPlayerParty' and 'membername' to 'memberId' for reasons that I'll explain later
function RemoveMemberFromPlayerParty(playerId, memberId)
    -- Setting the player as a global variable is very dangerous, the potential for errors being caused by that are incredibly high, equivalent to JavaScript's var keyword
    -- Leave this as a local, equivalent to JavaScript's let keyword. Better yet, make it const
    ---@type Player?
    local player <const> = Player(playerId)
    if player == nil then
        return outcome.Error("Player with specified playerId cannot be found")
    end

    local party <const> = player:getParty()
    if party == nil then
        return outcome.Error("Player's party cannot be found (maybe the player is not in a party?)")
    end

    ---@type Player?
    local foundMember = nil

    -- Looking at https://github.com/otland/forgottenserver/blob/1fcb5c27e62ff767c969d8eb028380f9f5d3325f/data/lib/core/party.lua#L4 , it seems that the keys for getMembers is purely an index. I would typically prefer to make the keys the Id itself unless if order needed to be maintained
    -- However, the values are definitely the different Player tables for each of the members as shown later
    for index, member in pairs(party:getMembers()) do
        -- As mentioned previously, the player's ID exists directly on the player itself. Therefore, there isn't a need to try re-getting the Member, just compare the GUIDs
        if member.getGUID() == memberId then
            -- Again, no need to re-get the Member, just pass in the Member that we have already used
            foundMember = member
            -- I have moved the party:removeMember to be outside of this for loop. I don't think this is a requirement in Lua, but in C#, modifying an enumerable as you're enumerating through it is completely not allowed.
            -- Furthermore, it is also very error-prone so it's considered better practice to just not it at all. So, I'm seeing if the member is in the party and if it is, setting it to the foundMember, then breaking out, and only removing that member if it was able to be found. This removes the former version's self-modifying nature.
            break
        end
    end

    if foundMember == nil then
        return outcome.Error("The specified member could not be found in the player's party")
    else
        party:removeMember(foundMember)
        return outcome.Success()
    end
end