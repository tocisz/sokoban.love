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

return history