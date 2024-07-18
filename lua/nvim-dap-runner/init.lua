local M = {}

local function run()
    require("nvim-dap-runner.app").run()
end

function M.setup(_)
    require("plenary.async").run(run)
end

return setmetatable(M, {
    __index = function(_, key)
        return require("nvim-dap-runner.api")[key]
    end
})
