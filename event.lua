local Object = require "classic"

local Event = Object:extend()
function Event:new(type, attr)
  self.type = type
  self.halted = false
  for k, v in pairs(attr) do
    assert(self[k] == nil)
    self[k] = v
  end
end

function Event:halt()
  self.halted = true
end

function Event:callFunc(func, ...)
  if not self.halted then
    func(self, ...)
  end
end

function Event:callMethod(obj, methodName, ...)
  if not self.halted then
    obj[methodName](obj, self, ...)
  end
end

return Event
