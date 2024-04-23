local outcome = {}

-- I originally called this Result but to avoid confusion with the result table used in Q2, I renamed this to Outcome. However, this is supposed to emulate the Result type in F# or Rust and is used to indicate a success or error
---@class Outcome
---@field ok boolean
---@field message string?

---@param ok boolean
---@param message string?
---@return Outcome
function outcome.Outcome(ok, message)
    return {
        ok = ok,
        message = message
    }
end

---@return Outcome
function outcome.Success()
    return outcome.Outcome(true)
end

---@param message string
---@return Outcome
function outcome.Error(message)
    return outcome.Outcome(false, message)
end

return outcome