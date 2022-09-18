local history = {
    moves = {},
    x = 1
}

function history.test(self, y)
    print("x = " .. self.x .. " " .. y)
end

function history:test2(y)
    print("x = " .. self.x .. " " .. y)
end

return history