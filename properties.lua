function getters(cls, getters)
  cls.__index = function(obj, k)
    if getters[k] then return obj[getters[k]](obj) end
    return rawget(cls, k)
  end
end

return {
  getters = getters,
}
