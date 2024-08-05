local profiles = require("nvim-dap-profiles.profiles")

local M = {}

function M.is_profile_name_invalid(name)
    if name == nil or name == "" then
        print("Profile name is nil or empty")
        return true
    end

    if not profiles.profile_exists(name) then
        print("Profile does not exist: " .. name)
        return true
    end

    return false
end

function M.xpcallargs(fn, ...)
    local args = { ... }
    local result, err = pcall(fn, unpack(args))
    if not result then
        print(err .. "\n" .. debug.traceback())
    end

    return result
end

return M
