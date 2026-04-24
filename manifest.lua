---@type LuxManifest

return {

	name = "test",
	namespace = "luxa.test",
	license = {
		spdx = "MIT",
		files = { "LICENSE" },
	},
	lua_modules = {
		{
			name = "test",
			sources = { "init.lua" },
		},
	},
}
-- NOTE:
-- still many things to work out and refine regarding the package
-- manifest standard, this is only a prototype and there will
-- be breaking changes!
