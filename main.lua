tile_x, tile_y = 24, 24

board = {}

commands = {
   up = {},
   down = {},
   left = {},
   right = {},
   exit = {}
}
command = nil

redraw = true

function love.load()
    math.randomseed(os.time())
    love.keyboard.setKeyRepeat(true)

    local tiles = love.graphics.newImage("tiles.jpg")
    local dx, xy = tiles:getDimensions()
    spriteBatch = love.graphics.newSpriteBatch(tiles)
    qBrick = love.graphics.newQuad(1, 0, tile_x, tile_y, dx, xy)
    qBoxOk = love.graphics.newQuad(1+tile_x*2, 0, tile_x, tile_y, dx, xy)
    qBox = love.graphics.newQuad(1+tile_x, 2*tile_y, tile_x, tile_y, dx, xy)
    qEmpty = love.graphics.newQuad(1+tile_x, tile_y, tile_x, tile_y, dx, xy)
    qEmptyOk = love.graphics.newQuad(1+tile_x*2, tile_y, tile_x, tile_y, dx, xy)
    qPlayer = love.graphics.newQuad(1+tile_x*3, tile_y-1, tile_x, tile_y, dx, xy)

    board:generate()
    board_px_width = board.width * tile_x
    board_px_height = board.height * tile_y
    canvas = love.graphics.newCanvas(board_px_width, board_px_height)
end

function board:generate()
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

function board:draw(canvas)
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

function board:move(command)
   local dj, di, can_move
   if     command == commands.right then dj, di = 0, 1
   elseif command == commands.left  then dj, di = 0, -1
   elseif command == commands.down  then dj, di = 1, 0
   elseif command == commands.up    then dj, di = -1, 0
   else
      return false
   end

   if board:can_move(dj, di) then
      self.player.j = self.player.j + dj
      self.player.i = self.player.i + di
      return true
   end
   return false
end

-- can player move in given direction
function board:can_move(dj, di)
   new_j = self.player.j + dj
   new_i = self.player.i + di
   if board:is_outside(new_j, new_i) then
      return false
   elseif board:is_empty(new_j, new_i) then
      return true
   elseif self.square[new_j][new_i] == '$' or self.square[new_j][new_i] == '*' then
      local next_j = new_j + dj
      local next_i = new_i + di
      local push = board:is_empty(next_j, next_i)
      -- do push
      if push then
         local from_goal = self.square[new_j][new_i] == '*'
         local to_goal = self.square[next_j][next_i] == '.'
         self.square[new_j][new_i]   = from_goal and '.' or ' '
         self.square[next_j][next_i] = to_goal   and '*' or '$'
      end
      return push
   end
   return false
end

function board:is_outside(j, i)
   return i < 1 or i > self.width or j < 1 or j > self.height
end

function board:is_empty(j, i)
   return not board:is_outside(j, i)
          and (self.square[j][i] == ' ' or self.square[j][i] == '.')
end

function love.keypressed(key)
   if     key == "up"     then command = commands.up
   elseif key == "down"   then command = commands.down
   elseif key == "left"   then command = commands.left
   elseif key == "right"  then command = commands.right
   elseif key == "escape" then command = commands.exit
   end
end

function love.update(dt)
   redraw = redraw or board:move(command)
   if command == commands.exit then
      love.event.quit()
   end
   command = nil
end
 
function love.draw()
   width, height = love.graphics.getDimensions()
   if redraw then
      board:draw(canvas)
      redraw = false
   end
   offset_x = math.floor((width - board_px_width)/2)
   offset_y = math.floor((height - board_px_height)/2)
   love.graphics.draw(canvas, offset_x, offset_y)
end
 