--test.lua
---@class Test
---@field func function
---@field cleanup function

local M = {}

---@type table<string, Test>
M.tests = {}

M.test_all = function()
	local passed = 0
	local total = 0

	for t_name, t_func in pairs(M.tests) do
		total = total + 1
		local success, err = pcall(t_func.func)
		t_func.cleanup()
		if success then
			passed = passed + 1
			print(string.format("[PASS] %s", t_name))
		else
			print(string.format("[FAIL] %s: %s", t_name, err))
		end
	end
	print(string.format("\nResults: %d/%d passed", passed, total))
end

-- should be on user side
-- if arg and arg[1] == "--all" then
-- 	M.test_all()
-- end
return M
