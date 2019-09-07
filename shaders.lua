local shaders = {}

shaders.brighten = love.graphics.newShader [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
      vec4 c = Texel(texture, texture_coords);
      return vec4(min(1, c.r * 1.2), min(1, c.g * 1.2), min(1, c.b * 1.2), c.a);
    }
]]

return shaders
