---@class Test
---@field func function
---@field cleanup function?

local M = {}

---@type table<string, Test>
M.tests = {}

M.assert_eq = function(actual, expected, msg)
	if actual ~= expected then
		error(
			string.format(
				"%s\n expected %s\n got:\t%s",
				msg or "assertion failed",
				tostring(expected),
				tostring(actual)
			)
		)
	end
end
M.assert_neq = function(actual, expected, msg)
	if actual == expected then
		error(
			string.format(
				"%s\nexpected: not: %s\ngot:\t%s",
				msg or "assertion failed",
				tostring(expected),
				tostring(actual)
			)
		)
	end
end

M.assert_false = function(val, msg)
	M.assert_eq(val, false, msg)
end


M.assert_true = function(val, msg)
	M.assert_eq(val, true, msg)
end

M["assert_false!"] = function(val, msg)
	assert(not val,
		string.format(
			"%s\nExpected: falsy\nGot:\t%s",
			msg or "assertion failed",
			tostring(val)
		))
end

M["assert_true!"] = function(val, msg)
	assert(val,
		string.format(
			"%s\nExpected: truthy\nGot:\t%s",
			msg or "assertion failed",
			tostring(val)
		))
end

---@param name string # The name of the test as a string
---@param test Test
M.register = function(name, test)
	assert(type(test.func) == "function", string.format('test "%s" missing func', name))
	M.tests[name] = test
end
M.add_test = M.register

M.test_all = function()
	local passed = 0
	local total = 0

	for t_name, test in pairs(M.tests) do
		total = total + 1
		local success, err = pcall(test.func)
		pcall(test.cleanup)
		if success then
			passed = passed + 1
			print(string.format("[PASS] %s", t_name))
		else
			print(string.format("[FAIL] %s: %s", t_name, err))
		end
	end
	print(string.format("\nResults: %d/%d passed", passed, total))
end

---@param name string string name of the test to run
M.run_test = function(name)
	if not M.tests[name] then
		error('there is no test named "' .. name .. '"')
		return
	end
	local test = M.tests[name]
	local success, err = pcall(test.func)
	pcall(test.cleanup)
	if success then
		print(string.format("[PASS] %s", name))
	else
		print(string.format("[FAIL] %s: %s", name, err))
	end
end
-- should be on user side
-- if arg and arg[1] == "--all" then
-- 	M.test_all()
-- end
return M
