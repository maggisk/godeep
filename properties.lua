function getters(cls, getters)
  cls.__index = function(obj, k)
    if getters[k] then return obj[getters[k]](obj) end
    -- TODO: this is poorly tested with inheritance
    return rawget(cls, k) or rawget(cls, "super")[k]
  end
end

return {
  getters = getters,
}
