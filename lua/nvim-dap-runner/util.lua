local M = {}

function M.table_len(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end

    return count
end

return M
