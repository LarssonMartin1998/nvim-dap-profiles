local M = {}

function M.create(obj, custom_type)
    assert(obj ~= nil, "obj cannot be nil")
    assert(type(custom_type) == "string", "custom_type must be a string")
    assert(custom_type ~= "", "custom_type cannot be empty")

    local value = obj
    if type(obj) ~= "table" then
        obj = {}
    end

    setmetatable(obj, {
        __value = value,
        __type = custom_type,
        __index = function(self, _)
            return rawget(getmetatable(self), "__value")
        end,
        __newindex = function(self, _, new_value)
            getmetatable(self).__value = new_value
        end,
        __tostring = function(self)
            return tostring(rawget(getmetatable(self), "__value"))
        end,
        __concat = function(self, other)
            return tostring(self) .. tostring(other)
        end,
        __eq = function(self, other)
            local a = rawget(getmetatable(self), "__value")
            local b = other

            local other_mt = getmetatable(other)
            if type(other) == "table" and other_mt and rawget(other_mt, "__type") then
                b = rawget(other_mt, "__value")
            end

            return a == b
        end,
    })

    return obj
end

-- nil is a valid type, so we need to check for it
function M.get(obj)
    local mt = getmetatable(obj)
    if mt and mt.__type then
        return mt.__type
    else
        return type(obj)
    end
end

return M
