local db = {}

---@param value string
---@return string
function db.escapeString(value)
    -- Pretend that some validation goes on here
    return value
end

---@param query string
---@return string
function db.storeQuery(query)
    return query
end

return db