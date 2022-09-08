require "sprites"

board = {}
index = {}

level = 1 -- current level

--[[]
This is the longest method and it's ugly. It reads text file line by line. If level to be loaded is not the first
than lines are skipped until we find it.

Better would be to read this whole file once and dump nicely parsed levels to disk.

This method also tries to remove outside-of-the-board squares (and fails in case when it's not beginning or end of the line).
Better would be to do this as post processing by calculating (graph) reachability.
]]
function board:read()
    local t, ch, i, j
    local board_chunk = false
    local skip, bstart, bend, found
    local is_board
    local spaces
 
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
    for line in love.filesystem.lines("data/levels.txt") do
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
          spaces = true
          for i = 1, #line do
             ch = line:sub(i,i)
             if ch == '@' then
                self.player = { j = j, i = i }
                ch = ' '
             elseif ch == '+' then
                self.player = { j = j, i = i }
                ch = '.'
             end
             if ch ~= ' ' then
                spaces = false
             elseif spaces then
                ch = '_'
             end
             table.insert(t, ch)
          end
 
          while t[#t] == ' ' do
             table.remove(t)
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
            spriteBatch:add(sprites.qEmpty, x, y)
          elseif what == '.' then
            spriteBatch:add(sprites.qEmptyOk, x, y)
          elseif what == '#' then
            spriteBatch:add(sprites.qBrick, x, y)
          elseif what == '$' then
            spriteBatch:add(sprites.qBox, x, y)
          elseif what == '*' then
            spriteBatch:add(sprites.qBoxOk, x, y)
          end
       end
    end
    y = (self.player.j-1) * tile_y
    x = (self.player.i-1) * tile_x
    spriteBatch:add(sprites.qPlayer, x, y)
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