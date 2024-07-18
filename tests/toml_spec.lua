package.path = package.path .. ";lua/?.lua"

describe("Toml", function()
    local toml = require("nvim-dap-profiles.toml")

    it("Decode toml into lua tables", function()
        local toml_table = toml.decode_from_file("tests/toml_file.toml")
        assert.truthy(toml_table ~= nil)

        assert.same({
            profile = "test1",
            test1 = {
                foo = "bar",
                numbers = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
            },
            test2 = {
                hello = "world"
            }
        }, toml_table)

        assert.same(toml_table[toml_table.profile].foo, "bar")
    end)
    it("Encode lua table to toml", function()
        local table_to_encode = {
            active_profile = "profile1",
            all_profiles = {
                profile1 = {
                    name = "profile1",
                    path = "path/to/binary1"
                },
                profile2 = {
                    name = "profile2",
                    path = "path/to/binary2"
                },
                profile3 = {
                    name = "profile3",
                    path = "path/to/binary3"
                },
            }
        }

        local file_path = "tests/toml_profiles.toml"
        toml.encode_to_file(file_path, table_to_encode)
        local decoded_table = toml.decode_from_file(file_path)

        assert.same(table_to_encode, decoded_table)
    end)
end)
