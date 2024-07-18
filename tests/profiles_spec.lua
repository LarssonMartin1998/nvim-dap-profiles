package.path = package.path .. ";lua/?.lua"

describe("Profiles", function()
    local profiles = require("nvim-dap-profiles.profiles")

    it("Create a new profile", function()
        local name = "profile"
        local path = "path/to/binary"
        profiles.create_profile(name, path, true)
        local profile = profiles.get_profile(name)
        local active_profile = profiles.get_active_profile()
        profiles.create_profile(name .. "2", path .. "2")

        assert.truthy(profile ~= nil)
        assert.truthy(active_profile ~= nil)
        assert.same(profile.name, name)
        assert.same(profile, active_profile)
        assert.is_not.same(profile, profiles.get_profile(name .. "2"))

        profiles.delete_all_profiles()
    end)
    it("Create a batch of profiles and activate one", function()
        local names = { "profile1", "profile2", "profile3" }
        local paths = { "path/to/binary", "path/to/binary2", "path/to/binary3" }
        local active_profile_name = names[2]
        profiles.create_profiles(names, paths, active_profile_name)

        for i, _ in ipairs(paths) do
            assert.truthy(profiles.is_profile_valid(names[i]))
        end

        assert.truthy(profiles.get_active_profile().name == active_profile_name)

        profiles.delete_all_profiles()
    end)
    it("Switch between profiles", function()
        local names = { "profile1", "profile2", "profile3" }
        local paths = { "path/to/binary", "path/to/binary2", "path/to/binary3" }
        profiles.create_profiles(names, paths)

        for i, _ in ipairs(paths) do
            assert.truthy(profiles.is_profile_valid(names[i]))
        end

        for i = #names, 1, -1 do
            profiles.set_active_profile(names[i])
            assert.truthy(profiles.get_active_profile().name == names[i])
        end

        assert.truthy(profiles.get_active_profile().name == names[1])

        profiles.delete_all_profiles()
    end)
    it("Get the active profile", function()
        local name = "profile1"
        profiles.create_profile(name, "path/to/binary", true)
        local active = profiles.get_active_profile()
        assert.truthy(active ~= nil)
        assert.truthy(active.name == name)
        assert.truthy(profiles.is_profile_valid(name))

        profiles.delete_all_profiles()
    end)
    it("Getters return the same value", function()
        local name = "profile1"
        profiles.create_profile(name, "path/to/binary", true)
        local profile = profiles.get_profile(name)
        local active = profiles.get_active_profile()
        assert.same(profile, active)

        profiles.delete_all_profiles()
    end)
    it("Profile exists behaves as expected", function()
        local profiles_to_create = {
            {
                name = "profile1",
                path = "path/to/binary"
            },
            {
                name = "profile2",
                path = "path/to/binary2"
            },
            {
                name = "profile3",
                path = "path/to/binary3"
            }
        }

        local invalid_profile_names = {
            "This is not a profile",
            nil,
            "Not this one either",
        }

        for _, profile in ipairs(profiles_to_create) do
            profiles.create_profile(profile.name, profile.path)
            assert.truthy(profiles.profile_exists(profile.name))
        end

        for _, name in ipairs(invalid_profile_names) do
            assert.falsy(profiles.profile_exists(name))
        end

        profiles.delete_all_profiles()
    end)
    it("Delete profiles", function()
        local profiles_to_create = {
            {
                name = "profile1",
                path = "path/to/binary"
            },
            {
                name = "profile2",
                path = "path/to/binary2"
            },
            {
                name = "profile3",
                path = "path/to/binary3"
            }
        }

        local function create_profiles()
            for _, profile in ipairs(profiles_to_create) do
                profiles.create_profile(profile.name, profile.path)
            end
        end

        local function test_profiles_exist()
            for _, profile in ipairs(profiles_to_create) do
                assert.truthy(profiles.profile_exists(profile.name))
            end
        end

        local function test_profiles_do_not_exist()
            for _, profile in ipairs(profiles_to_create) do
                assert.falsy(profiles.profile_exists(profile.name))
            end
        end

        create_profiles()
        test_profiles_exist()
        for _, profile in ipairs(profiles_to_create) do
            profiles.delete_profile(profile.name)
        end
        test_profiles_do_not_exist()

        create_profiles()
        test_profiles_exist()
        local profiles_to_delete = {}
        for _, profile in ipairs(profiles_to_create) do
            table.insert(profiles_to_delete, profile.name)
        end
        profiles.delete_profiles(profiles_to_delete)
        test_profiles_do_not_exist()

        create_profiles()
        test_profiles_exist()
        profiles.delete_all_profiles()
        test_profiles_do_not_exist()

        assert.truthy(profiles.get_num_profiles() == 0)
    end)
end)
