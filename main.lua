tile_x, tile_y = 24, 24

board = {}
level = 1

commands = {
   up = {},
   down = {},
   left = {},
   right = {},
   exit = {},
   restart = {},
   enter = {},
   next_lvl = {},
   previous_lvl = {}
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
    width, height = love.graphics.getDimensions()

    screens:set_screen('title')
end

index = {}

function board:read()
   local t, ch, i, j
   local board_chunk = false
   local skip, bstart, bend, found
   local is_board

   self.width = 0
   self.height = 0
   self.square = {}

   if index[level] ~= nil then
      skip = index[level][1]
   elseif #index > 0 then
      skip = index[#index][2]
   end

   print(level, skip)

   j = 1
   ln = 1
   found = false
   for line in love.filesystem.lines("levels.txt") do
      if skip and ln < skip then
         goto continue
      end

      is_board = is_board_line(line)
      if not board_chunk and is_board then
         bstart = ln
      elseif board_chunk and not is_board then
         bend = ln
         if index[level] == nil then
            index[level] = {bstart, bend}
         end
         found = true
         break
      end

      if is_board then
         board_chunk = true
         if #line > self.width then
            self.width = #line
         end

         t = {}
         for i = 1, #line do
            ch = line:sub(i,i)
            if ch == '@' then
               self.player = { j = j, i = i }
               ch = ' '
            elseif ch == '+' then
               self.player = { j = j, i = i }
               ch = '.'
            end
            table.insert(t, ch)
         end

         table.insert(self.square, t)
         j = j + 1
      end
      ::continue::
      ln = ln + 1
   end
   self.height = j - 1

   if not found then
      level = level - 1
      board:read()
   end
end

function is_board_line(line)
   if #line == 0 then return false end
   local c = line:sub(1,1)
   return c == ' ' or c == '#'
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

function board:is_win()
   for j, line in ipairs(self.square) do
      for i, c in ipairs(line) do
         if c == '.' then return false end
      end
   end
   return true
end

Splash = {
   keypressed = function(key)
      command = commands.enter
   end,
   update = function()
      if command == commands.enter then
         screens:set_screen('game')
      end
      command = nil
   end,
   draw = function()
      love.graphics.draw(canvas)
   end
}

function Splash:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

screens = {

   title = Splash:new{
      init = function()
         canvas = love.graphics.newCanvas()
         love.graphics.setCanvas(canvas)
         local cy = height / 2
         print_centered(cy-150, love.graphics.newFont(50), "Sokoban")
         print_centered(cy, love.graphics.newFont(30), "press any key to start")
         love.graphics.setCanvas()
      end
   },

   game = {
      init = function()
         board:read()
         board_px_width = board.width * tile_x
         board_px_height = board.height * tile_y
         canvas = love.graphics.newCanvas(board_px_width, board_px_height)
         redraw = true
      end,
      keypressed = function(key)
         if     key == "up"     then command = commands.up
         elseif key == "down"   then command = commands.down
         elseif key == "left"   then command = commands.left
         elseif key == "right"  then command = commands.right
         elseif key == "escape" then command = commands.exit
         elseif key == "r"      then command = commands.restart
         elseif key == "n"      then command = commands.next_lvl
         elseif key == "p"      then command = commands.previous_lvl
         end
      end,
      update = function(dt)
         local moved = board:move(command)
         if moved and board:is_win() then
            level = level + 1
            screens:set_screen('congrats')
         end
         redraw = redraw or moved
         if command == commands.restart then
            screens.game.init()
         elseif command == commands.next_lvl then
            level = level + 1
            screens.game.init()
         elseif command == commands.previous_lvl then
            if level > 1 then
               level = level - 1
            end
            screens.game.init()
         elseif command == commands.exit then
            love.event.quit()
         end
         command = nil
      end,
      draw = function()
         if redraw then
            board:draw(canvas)
            redraw = false
         end
         love.graphics.draw(canvas, cx(board_px_width), cy(board_px_height))
      end
   },

   congrats = Splash:new{
      init = function()
         canvas = love.graphics.newCanvas()
         love.graphics.setCanvas(canvas)
         local cy = height / 2
         print_centered(cy-150, love.graphics.newFont(50), "Congratulations!")
         print_centered(cy, love.graphics.newFont(30), "LEVEL COMPLETE")
         love.graphics.setCanvas()
      end
   }

}

function screens:set_screen(name)
   love.update = self[name].update
   love.draw = self[name].draw
   love.keypressed = self[name].keypressed
   self[name].init()
end

function cx(w)
   return math.floor((width - w)/2)
end

function cy(h)
   return math.floor((height - h)/2)
end

function print_centered(y, font, text)
   love.graphics.setFont(font)
   love.graphics.print(text, cx(font:getWidth(text)), y)
end