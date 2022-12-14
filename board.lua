local love = require("love")
local sprites = require("sprites")
local commands = require("commands")
local history = require("history")

local board = {
   level = 1, -- current level
   metadata = {}
}
local index = {}

local function is_board_line(line)
   if #line == 0 then return false end
   local c = line:sub(1,1)
   return c == ' ' or c == '#'
end

local function is_comment_line(line)
   local c = line:sub(1,1)
   return c == ';'
end

local function is_empty_line(line)
   return string.len(line) == 0
end

--[[
This is the longest method and it's ugly. It reads text file line by line. If level to be loaded is not the first
than lines are skipped until we find it.

Better would be to read this whole file once and dump nicely parsed levels to disk.

This method also tries to remove outside-of-the-board squares (and fails in case when it's not beginning
or end of the line).
Better would be to do this as post processing by calculating (graph) reachability.
]]
function board:read()
   local t, ch, j, ln
   local board_chunk = false
   local meta_chunk = false
   local skip, bstart, bend, found
   local is_board
   local spaces

   self.width = 0
   self.height = 0
   self.square = {}

   if index[board.level] ~= nil then
      skip = index[board.level][1]
   elseif #index > 0 then
      skip = index[#index][2]
   end

   j = 1
   ln = 1
   found = false
   for line in love.filesystem.lines("data/levels.txt") do
      if skip and ln < skip then
         goto continue
      end

      if is_comment_line(line) then
         goto continue
      end

      is_board = is_board_line(line)
      if not board_chunk and is_board then
         bstart = ln
      elseif board_chunk and not meta_chunk and not is_board then
         meta_chunk = true
         self.metadata = {}
      end

      if meta_chunk then
         if is_empty_line(line) then
            -- empty line means end of metadata
            bend = ln
            if index[board.level] == nil then
               index[board.level] = {bstart, bend}
            end
            found = true
            break
         end
         for k, v in string.gmatch(line, "([^:]+): (.*)") do
            self.metadata[k] = v
         end
      elseif is_board then
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
      board.level = board.level - 1
      self:read()
   end
   history:clear()
 end

function board:draw()
   local x, y
   sprites:clear()
   for j, row in ipairs(self.square) do
      for i, what in ipairs(row) do
         y = (j-1) * sprites.height
         x = (i-1) * sprites.width
         if what == ' ' then
         sprites:add("empty", x, y)
         elseif what == '.' then
         sprites:add("empty", x, y)
         sprites:add("marker", x, y)
         elseif what == '#' then
         sprites:add("brick", x, y)
         elseif what == '$' then
         sprites:add("box", x, y)
         elseif what == '*' then
         sprites:add("box_ok", x, y)
         end
      end
   end
   local j, i = self.player.j, self.player.i
   y = (j-1) * sprites.height
   x = (i-1) * sprites.width
   sprites:add("player", x, y)
   if self.square[j][i] == '.' then
   sprites:add("marker", x, y)
   end
   sprites:draw(sprites.sprite_batch)
end

function board:move(command)
   local dj, di
   if     command == commands.right then dj, di = 0, 1
   elseif command == commands.left  then dj, di = 0, -1
   elseif command == commands.down  then dj, di = 1, 0
   elseif command == commands.up    then dj, di = -1, 0
   else
      return false
   end

   local move, push = board:can_move(dj, di)
   if move then
      local m = {dj, di, push}
      self:apply(m)
      history:store(m)
   end
   return move
end

-- can player move in given direction
-- returns: {can_move, is_push}
function board:can_move(dj, di)
   local new_j, new_i
   new_j = self.player.j + dj
   new_i = self.player.i + di
   if self:is_outside(new_j, new_i) then
      return false
   elseif self:is_empty(new_j, new_i) then
      return true, false
   elseif self.square[new_j][new_i] == '$' or self.square[new_j][new_i] == '*' then
      local next_j = new_j + dj
      local next_i = new_i + di
      local push = self:is_empty(next_j, next_i)
      return push, push
   end
   return false
end

function board:is_outside(j, i)
   return i < 1 or i > self.width or j < 1 or j > self.height
end

function board:is_empty(j, i)
   return not self:is_outside(j, i)
         and (self.square[j][i] == ' ' or self.square[j][i] == '.')
end

function board:is_win()
   for _, line in ipairs(self.square) do
      for _, c in ipairs(line) do
         if c == '.' then return false end
      end
   end
   return true
end

function board:apply(m)
   if not m then return end

   local dj, di, push, undo = m[1], m[2], m[3], m[4]
   if undo then
      dj, di = -dj, -di
   end
   local next_j = self.player.j + dj
   local next_i = self.player.i + di
   if push then
      local from_j, from_i, to_j, to_i
      if undo then
         to_j = self.player.j
         to_i = self.player.i
         from_j = to_j - dj
         from_i = to_i - di
      else
         from_j = next_j
         from_i = next_i
         to_j = from_j + dj
         to_i = from_i + di
      end
      local from_goal = self.square[from_j][from_i] == '*'
      local to_goal = self.square[to_j][to_i] == '.'
      self.square[from_j][from_i] = from_goal and '.' or ' '
      self.square[to_j][to_i]     = to_goal   and '*' or '$'
   end
   self.player.j = next_j
   self.player.i = next_i
end

function board:px_width()
   return self.width * sprites.width
end

function board:px_height()
   return self.height * sprites.height
end

return board