local shaders = {}

shaders.brighten = love.graphics.newShader [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
      vec4 c = Texel(texture, texture_coords);
      return vec4(min(1, c.r * 1.2), min(1, c.g * 1.2), min(1, c.b * 1.2), c.a);
    }
]]

shaders.boxblur = love.graphics.newShader [[
    extern int radius;
    vec4 effect(vec4 col, Image tex, vec2 texcoord, vec2 screencoord) {
        vec4 sum = vec4(0.0, 0.0, 0.0, 0.0);
        for (int x = -radius; x <= radius; x++) {
          for (int y = -radius; y <= radius; y++) {
            sum += Texel(tex, texcoord.xy + vec2(x / love_ScreenSize.x, y / love_ScreenSize.y));
          }
        }
        float size = 2.0 * radius + 1.0;
        return sum / (size * size);
    }
]]

return shaders
