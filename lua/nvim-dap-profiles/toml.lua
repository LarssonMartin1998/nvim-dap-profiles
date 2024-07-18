local toml = require("toml")

local M = {}

function M.decode_from_file(file_path)
    assert(file_path and file_path ~= "", "Must provide a valid file_path")

    local result, table = pcall(toml.decodeFromFile, file_path)
    if not result then
        print("Failed to decode toml file: " .. file_path)
        return nil
    end

    return table
end

function M.encode_to_file(file_path, table)
    assert(file_path and file_path ~= "", "Must provide a valid file_path")

    local result, document_or_err = pcall(toml.encodeToFile, table, { file = file_path, overwrite = true })
    if not result then
        error(document_or_err)
    end
end

return M
