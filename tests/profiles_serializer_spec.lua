package.path = package.path .. ";lua/?.lua"

describe("Profiles Serializer", function()
    local function clone(source)
        local orig_type = type(source)
        local copy
        if orig_type == "table" then
            copy = {}
            for orig_key, orig_value in next, source, nil do
                copy[clone(orig_key)] = clone(orig_value)
            end
            setmetatable(copy, clone(getmetatable(source)))
        else
            copy = source
        end
        return copy
    end

    local serializer = require("nvim-dap-profiles.profiles_serializer")
    local profiles = require("nvim-dap-profiles.profiles")
    local path_to_test_file = "tests/toml_profiles.toml"

    local names = { "test1", "test2", "test3" }
    local binary_paths = { "path1", "path2", "path3" }
    local run_dir_paths = { "", nil, "run_dir3" }
    it("De/Serialize", function()
        profiles.delete_all_profiles()

        profiles.create_profiles(names, binary_paths, run_dir_paths, "test2")
        local profiles_from_code = clone(profiles.get_all_profiles())
        serializer.serialize_profiles(path_to_test_file)

        profiles.delete_all_profiles()
        serializer.deserialize_profiles(path_to_test_file)
        local profiles_from_file = profiles.get_all_profiles()

        assert.truthy(profiles_from_code)
        assert.truthy(profiles_from_file)
        assert.same(profiles_from_code, profiles_from_file)
    end)
end)
