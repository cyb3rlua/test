---@class Test
---@field func function
---@field cleanup function?
---
---@alias TestList table<string, Test>

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
			),
			2
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
			),
			2
		)
	end
end
M.assert_is_true = function(val, msg)
	if val ~= true then
		error(
			string.format(
				"%s\nExpected: true (boolean)\nGot:\t%s",
				msg or "assertion failed",
				tostring(val)
			),
			2
		)
	end
end

M.assert_is_false = function(val, msg)
	if val ~= false then
		error(
			string.format(
				"%s\nExpected: false (boolean)\nGot:\t%s",
				msg or "assertion failed",
				tostring(val)
			),
			2
		)
	end
end

M.assert_false = function(val, msg)
	if val then
		error(
			string.format(
				"%s\nExpected: falsy\nGot:\t%s",
				msg or "assertion failed",
				tostring(val)
			),
			2
		)
	end
end

M.assert_true = function(val, msg)
	if not val then
		error(
			string.format(
				"%s\nExpected: truthy\nGot:\t%s",
				msg or "assertion failed",
				tostring(val)
			),
			2
		)
	end
end

local dcmp
dcmp = function(a, b)
	if a == b then return true end
	if type(a) ~= "table" or type(b) ~= "table" then return false end

	-- potentially infinite recursion with self-referencing tables
	for k, v in pairs(a) do
		if not dcmp(v, b[k]) then return false end
	end

	for k in pairs(b) do
		if a[k] == nil then return false end
	end

	return true
end

local function inspect(t, indent)
	indent = indent or 0
	local pad = string.rep("\t", indent)
	local innerPad = string.rep("\t", indent + 1)

	if type(t) ~= "table" then return tostring(t) end

	local result = "{\n"

	for k, v in pairs(t) do
		local key = type(k) == "string" and string.format("[%q]", k)
			or "[" .. tostring(k) .. "]"
		result = result
			.. innerPad
			.. key
			.. " = "
			.. inspect(v, indent + 1)
			.. ",\n"
	end
	return result .. pad .. "}"
end

M.assert_dpeq = function(actual, expected, msg)
	if not dcmp(actual, expected) then
		error(
			string.format(
				"%s\nDeep Equality check failed.\nExpected:\n%s\nGot:\n%s",
				msg or "Assertion Failed",
				inspect(expected),
				inspect(actual)
			),
			2
		)
	end
end

---@param name string # The name of the test as a string
---@param test Test
M.register = function(name, test)
	assert(
		type(test.func) == "function",
		string.format('test "%s" missing func', name)
	)
	M.tests[name] = test
end
M.add_test = M.register

M.test_all = function()
	local passed = 0
	local total = 0
	local running = true

	for t_name, test in pairs(M.tests) do
		total = total + 1
		local success, err = pcall(test.func)

		-- prevent state leakage from invalidating entire test set by
		-- stopping execution of a failed cleanup call
		-- (ugly, but should work)
		if test.cleanup then
			local cs, cerr = pcall(test.cleanup)
			if not cs then
				print(
					string.format(
						"\n\nTest cleanup failed:\n%s\nError\t:%s",
						t_name,
						cerr
					)
				)
				running = false
			end
		end

		if success then
			passed = passed + 1
			print(string.format("[PASS] %s", t_name))
		else
			print(string.format("[FAIL] %s: %s", t_name, err))
		end

		if not running then
			print("Test Execution halted due to cleanup failure.")
			break
		end
	end
	print(string.format("\nResults: %d/%d passed", passed, total))
end

---@param name string string name of the test to run
M.run_test = function(name)
	if not M.tests[name] then
		error('there is no test named "' .. name .. '"', 2)
		return
	end
	local test = M.tests[name]
	local success, err = pcall(test.func)

	-- prevent state leakage from invalidating entire test set by
	-- stopping execution of a failed cleanup call
	-- (ugly, but should work)
	if test.cleanup then
		local cs, cerr = pcall(test.cleanup)
		assert(cs, cerr)
	end

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
