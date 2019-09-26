assert(getmetatable(_G) == nil, "another global metatable exists")

-- The detecting of undeclared vars is discussed on:
-- http://www.lua.org/pil/14.2.html
-- http://lua-users.org/wiki/DetectingUndefinedVariables
setmetatable(_G, {
  __newindex = function (table, key, value)
    local info = debug.getinfo(2, "Sl")
    io.stderr:write(string.format(
      "strict: %s:%s: write to undeclared variable: %s\n",
      tostring(info.short_src), tostring(info.currentline), key))
    rawset(table, key, value)
  end,
  __index = function (table, key)
    error("attempt to read undeclared variable " .. key, 2)
  end,
})
