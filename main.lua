tile_x, tile_y = 24, 24
time = 0

level = {}

function love.load()
    math.randomseed(os.time())

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
    canvas = love.graphics.newCanvas()
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
            what = '#'
         elseif r < 0.8 then
            what = '$'
         else
            what = '.'
         end

         self.square[j][i] = what
      end
   end
   self.player = { j = 5, i = 5}
end

function level:draw(canvas)
end
 
function love.update(dt)
--     if love.keyboard.isDown("right") then
--        x = x + (speed * dt)
--     end
--     if love.keyboard.isDown("left") then
--        x = x - (speed * dt)
--     end
 
--     if love.keyboard.isDown("down") then
--        y = y + (speed * dt)
--     end
--     if love.keyboard.isDown("up") then
--        y = y - (speed * dt)
--     end
   if love.keyboard.isDown("escape") then
      love.event.quit()
   end
end
 
function love.draw()
   width, height = love.graphics.getDimensions()
   if time % 60 == 0 then
      spriteBatch:clear()
      for y = 0, height, tile_y do
         for x = 0, width, tile_x do
            r = math.random()
            if r < 0.5 then
               spriteBatch:add(qEmpty, x, y)
            elseif r < 0.6 then
               spriteBatch:add(qPlayer, x, y)
            elseif r < 0.7 then
               spriteBatch:add(qEmptyOk, x, y)
            elseif r < 0.8 then
               spriteBatch:add(qBoxOk, x, y)
            elseif r < 0.9 then
               spriteBatch:add(qBrick, x, y)
            else
               spriteBatch:add(qBox, x, y)
            end
         end
      end
      love.graphics.setCanvas(canvas)
      love.graphics.draw(spriteBatch)
      love.graphics.setCanvas()
      time = 0
   end
   time = time + 1
   love.graphics.draw(canvas)
end
 