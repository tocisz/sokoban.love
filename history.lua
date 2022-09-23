local love = require("love")
local commands = require("commands")
local history = {}

function history:clear()
    self.list = {}
    self.current = {
        moves = 0,
        pushes = 0
    }
    self.total = {
        moves = 0,
        pushes = 0
    }
end

-- returns: {dj, di, push, is_undo}
function history:undo()
    if self.current.moves == 0 then return nil end

    local m = self.list[self.current.moves]
    local push = m[3]
    self.current.moves = self.current.moves - 1
    if push then
        self.current.pushes = self.current.pushes - 1
    end

    return {m[1], m[2], m[3], true}
end

-- returns: {dj, di, push, is_undo}
function history:redo()
    if self.current.moves == self.total.moves then return nil end

    local m = self.list[self.current.moves + 1]
    local push = m[3]
    self.current.moves = self.current.moves + 1
    if push then
        self.current.pushes = self.current.pushes + 1
    end

    return {m[1], m[2], m[3], false}
end

function history:peek()
    if self.current.moves == 0 then return nil end
    return self.list[self.current.moves]
end


function history:store(m)
    local push = m[3]
    -- reset redo history
    while #self.list > self.current.moves do
        table.remove(self.list)
    end

    table.insert(self.list, m)

    -- update stats
    self.current.moves = self.current.moves + 1
    if push then
        self.current.pushes = self.current.pushes + 1
    end
    self.total.moves = self.current.moves
    self.total.pushes = self.current.pushes
    -- print(self:repr())
end

-- string representation for future use
function history:repr()
    local moves = {}
    for _, m in ipairs(self.list) do
        local dj, di, push = m[1], m[2], m[3]
        table.insert(moves, history.repr1(dj, di, push))
    end
    return table.concat(moves)
end

function history.repr1(dj, di, push)
    local r
    if dj == 0 and di == 1 then
        r = 'r'
    elseif dj == 0 and di == -1 then
        r = 'l'
    elseif dj == 1 and di == 0 then
        r = 'd'
    elseif dj == -1 and di == 0 then
        r = 'u'
    end
    if push then
        r = string.upper(r)
    end
    return r
end

function history:save(name)
    local save_string = self:repr()
    love.filesystem.write(name .. ".sav", save_string)
end

function history:load(name)
    name = name .. ".sav"
    self.save_string = nil
    self.loading_pos = 0
    if love.filesystem.getInfo(name, "file") then
        self.save_string = love.filesystem.read(name)
        if string.len(self.save_string) > 0 then
            self.loading_pos = 1
        end
    end
end

function history:is_loading()
    return self.loading_pos > 0
end

function history:get_load_move()
    local r = string.sub(self.save_string, self.loading_pos, self.loading_pos)
    local ru = string.upper(r)
    local push = r == ru
    local cmd = nil
    if ru == "L" then cmd = commands.left
    elseif ru == "R" then cmd = commands.right
    elseif ru == "U" then cmd = commands.up
    elseif ru == "D" then cmd = commands.down
    end
    if cmd then
        self.loading_pos = self.loading_pos + 1
        if self.loading_pos > string.len(self.save_string) then
            self.loading_pos = 0
        end
        return cmd, push
    end
    error("wrong save file")
end


return history