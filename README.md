# test

A minimal Lua testing library. Register tests, run them individually or all at once, and get clean pass/fail output. No dependencies.

## Installation

Install with [lux](https://github.com/LuaLuxa):

```lua
{
    "cyb3rkun/lua-test",
    opts = { scope = "local" },
}
```

> **Note:** lux and the LuaLuxa ecosystem are not yet publicly released. Manual installation is available in the meantime — just drop `init.lua` into your project.

## Usage

```lua
local t = require("test")

t.register("my test", {
    func = function()
        t.assert_eq(1 + 1, 2)
        t.assert_true(type("hello") == "string")
    end,
    cleanup = function()
        -- optional: teardown logic here
    end,
})

t.test_all()
```

Output:
```
[PASS] my test

Results: 1/1 passed
```

### Running from the command line

The entry point is left to the user. A typical pattern:

```lua
-- tests.lua
local t = require("test")

-- register your tests...

if arg and arg[1] == "--all" then
    t.test_all()
elseif arg and arg[1] then
    t.run_test(arg[1])
end
```

```sh
lua tests.lua --all
lua tests.lua "my test"
```

## API

### `t.register(name, test)` / `t.add_test(name, test)`

Registers a test. `test.func` is required and must be a function. `test.cleanup` is optional — if provided, it will be called after the test regardless of whether it passed or failed, useful for teardown and restoring state.

If cleanup itself fails, `test_all` will halt execution to prevent corrupted state from contaminating subsequent tests.

```lua
t.register("example", {
    func = function() ... end,
    cleanup = function() ... end, -- optional
})
```

### `t.test_all()`

Runs all registered tests and prints a summary. Halts if a cleanup function fails.

### `t.run_test(name)`

Runs a single test by name.

### Assertions

| Function | Description |
|---|---|
| `t.assert_eq(actual, expected, msg?)` | Fails if `actual ~= expected` |
| `t.assert_neq(actual, expected, msg?)` | Fails if `actual == expected` |
| `t.assert_true(val, msg?)` | Fails if `val` is falsy |
| `t.assert_false(val, msg?)` | Fails if `val` is truthy |
| `t.assert_is_true(val, msg?)` | Fails if `val ~= true` (strict boolean) |
| `t.assert_is_false(val, msg?)` | Fails if `val ~= false` (strict boolean) |
| `t.assert_dpeq(actual, expected, msg?)` | Fails if tables are not deeply equal |

`assert_true`/`assert_false` check truthiness. Use `assert_is_true`/`assert_is_false` when you need strict boolean equality.

`assert_dpeq` recursively compares tables by value, and pretty-prints both sides on failure.

## License

MIT
