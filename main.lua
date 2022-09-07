tile_x, tile_y = 24, 24
time = 0

level = {}

commands = {
   up = {},
   down = {},
   left = {},
   right = {},
   exit = {}
}
command = nil

function love.load()
    math.randomseed(os.time())
    love.keyboard.setKeyRepeat(true)

    local tiles = love.graphics.newImage("tiles.jpg")
    local dx, xy = tiles:getDimensions()
    spriteBatch = love.graphics.newSpriteBatch(tiles)
    qBrick = love.graphics.newQuad(1, 0, tile_x, tile_y, dx, xy)
    qBox = love.graphics.newQuad(1+tile_x*2, 0, tile_x, tile_y, dx, xy)
    qBoxOk = love.graphics.newQuad(1+tile_x, 2*tile_y, tile_x, tile_y, dx, xy)
    qEmpty = love.graphics.newQuad(1+tile_x, tile_y, tile_x, tile_y, dx, xy)
    qEmptyOk = love.graphics.newQuad(1+tile_x*2, tile_y, tile_x, tile_y, dx, xy)
    qPlayer = love.graphics.newQuad(1+tile_x*3, tile_y-1, tile_x, tile_y, dx, xy)

    level:generate()
    level_px_width = level.width * tile_x
    level_px_height = level.height * tile_y
    canvas = love.graphics.newCanvas(level_px_width, level_px_height)
end

function level:generate()
   self.width = 20
   self.height = 10
   self.square = {}
   for j = 1, self.height do
      self.square[j] = {}
      for i = 1, self.width do
         local r = math.random()
         local what
         if r < 0.6 then
            what = ' '
         elseif r < 0.7 then
            what = '#'
         elseif r < 0.8 then
            what = '*'
         elseif r < 0.9 then
            what = '$'
         else
            what = '.'
         end
         self.square[j][i] = what
      end
   end
   self.player = { j = 5, i = 5 }
end

function level:draw(canvas)
   local what, x, y
   spriteBatch:clear()
   for j = 1, self.height do
      for i = 1, self.width do
         what = self.square[j][i]
         y = (j-1) * tile_y
         x = (i-1) * tile_x
         if what == ' ' then
            spriteBatch:add(qEmpty, x, y)
         elseif what == '.' then
            spriteBatch:add(qEmptyOk, x, y)
         elseif what == '#' then
            spriteBatch:add(qBrick, x, y)
         elseif what == '$' then
            spriteBatch:add(qBox, x, y)
         elseif what == '*' then
            spriteBatch:add(qBoxOk, x, y)
         end
      end
   end
   y = (self.player.j-1) * tile_y
   x = (self.player.i-1) * tile_x
   spriteBatch:add(qPlayer, x, y)
   love.graphics.setCanvas(canvas)
   love.graphics.draw(spriteBatch)
   love.graphics.setCanvas()
end

redraw = true
function love.update(dt)
   if command == commands.right then
      level.player.i = level.player.i + 1
      redraw = true
   elseif command == commands.left then
      level.player.i = level.player.i - 1
      redraw = true
   elseif command == commands.down then
      level.player.j = level.player.j + 1
      redraw = true
   elseif command == commands.up then
      level.player.j = level.player.j - 1
      redraw = true
   elseif love.keyboard.isDown("escape") then
      love.event.quit()
   end
   command = nil
end

function love.keypressed(key)
   if key == "up" then command = commands.up
   elseif key == "down" then command = commands.down
   elseif key == "left" then command = commands.left
   elseif key == "right" then command = commands.right
   elseif key == "escape" then command = commands.exit
   end
end
 
function love.draw()
   width, height = love.graphics.getDimensions()
   if redraw then
      level:draw(canvas)
      redraw = false
   end
   offset_x = math.floor((width - level_px_width)/2)
   offset_y = math.floor((height - level_px_height)/2)
   love.graphics.draw(canvas, offset_x, offset_y)
end
 