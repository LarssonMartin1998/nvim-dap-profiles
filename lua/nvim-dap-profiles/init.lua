local M = {}

local function run()
    require("nvim-dap-profiles.app").run()
end

function M.setup(_)
    require("plenary.async").run(run)
end

return setmetatable(M, {
    __index = function(_, key)
        return require("nvim-dap-profiles.api")[key]
    end
})
