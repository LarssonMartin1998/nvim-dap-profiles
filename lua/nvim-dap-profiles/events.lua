local type = require("nvim-dap-profiles.type")

local M = {
    PRE_DAP_RUN = "PRE_DAP_RUN",
    POST_DAP_RUN = "POST_DAP_RUN",
}

for _, event in pairs(M) do
    type.create(event, "event")
end

return M
