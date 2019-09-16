local Object = require "classic"

local Event = Object:extend()
function Event:new(device, type, attr)
  self.device = device
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

function filter(events, attributes)
  r = {}

  for _, event in ipairs(events) do
    for k, v in pairs(attributes) do
      if event[k] ~= v then
        goto skip
      end
    end
    table.insert(r, event)
    ::skip::
  end

  return r
end

return {
  Event = Event,
  filter = filter,
}
