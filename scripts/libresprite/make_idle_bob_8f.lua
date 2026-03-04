-- LibreSprite/Aseprite Lua script
-- Creates an 8-frame "idle bob" animation from frame 1 by shifting pixels up/down.
--
-- Usage (typical):
--  1) Open your sprite (single frame is fine).
--  2) Run this script.
--  3) Export sprite sheet (8 columns, 1 row).
--
-- Notes:
--  - Non-destructive: it will create/overwrite frames 1..8 (images only).
--  - Works best when your character is centered and background is transparent.

local spr = app.activeSprite
if not spr then
  app.alert('No active sprite')
  return
end

-- Settings
local frameCount = 8
local frameDuration = 0.10 -- seconds per frame

-- Pixel offsets per frame (in pixels). Negative = up.
-- This creates a simple breathing/bobbing loop.
local dy = { 0, -1, -2, -1, 0, 1, 2, 1 }

if #dy ~= frameCount then
  app.alert('Internal error: dy length must match frameCount')
  return
end

app.transaction(function()
  -- Ensure at least frameCount frames exist.
  while #spr.frames < frameCount do
    spr:newFrame()
  end

  -- Set durations.
  for i = 1, frameCount do
    spr.frames[i].duration = frameDuration
  end

  local baseFrame = spr.frames[1]

  -- For each image layer, copy frame-1 cel image and shift it in each frame.
  for _, layer in ipairs(spr.layers) do
    if layer.isGroup then
      -- Skip groups; cels live in image layers.
    else
      local baseCel = layer:cel(baseFrame)
      if baseCel then
        local src = baseCel.image
        local pos = baseCel.position

        for i = 1, frameCount do
          local fr = spr.frames[i]
          local dst = Image(src.width, src.height, spr.colorMode)
          -- dst is transparent by default.
          dst:drawImage(src, Point(0, dy[i]))

          local cel = layer:cel(fr)
          if cel then
            cel.image = dst
            cel.position = pos
          else
            spr:newCel(layer, fr, dst, pos)
          end
        end
      end
    end
  end
end)

app.refresh()
app.alert('Idle bob created: 8 frames')
