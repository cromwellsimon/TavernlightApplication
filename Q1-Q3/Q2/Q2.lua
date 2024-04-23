local db = require("./Types/Db")
local outcome = require("./Types/Outcome")

---@param memberCount number
---@return Outcome
function PrintSmallGuildNames(memberCount)
    -- I'm not sure if it'd even be possible to pass in something other than a number here, but it is certainly better to be safe than sorry with SQL queries
    if (type(memberCount) ~= "number") then
        return outcome.Error("memberCount invalid")
    end
    -- SQL injection is an incredibly dangerous thing. OTClient doesn't seem to contain any SQL queries which is very good,
    -- but based off of how SQL queries are done in ForgottenServer, it should look like this instead. The backticks imply this is specifically MySQL:
    local selectGuildQuery <const> = "SELECT `name` FROM `guilds` WHERE `max_members` < %d;"
    local resultId <const> = db.storeQuery(string.format(selectGuildQuery, memberCount))
    if not resultId then
        return outcome.Error("Query invalid")
    end
    -- This SQL query returns a table, not a scalar, so we need to enumerate through the table.
    -- 'DbResult' here acts like an ADO.NET driver, so we need to move its pointer through each row in the table and access the individual column
    -- Originally, this was just 'result' but I renamed it to 'DbResult' because it makes more sense to me, 'result' is too broad of a term to specifically refer to a database query, especially if it's a global value
    repeat
        local guildName <const> = DbResult.getString(resultId, "name")
        print(guildName)
    until not outcome.next(resultId)
    return outcome.Success()
end