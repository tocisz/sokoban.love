sprites = {}
spriteBatch = nil


function sprites:init()
    local w, h = 32, 32
    local tiles = love.graphics.newImage("data/sprites.png")
    local dx, xy = tiles:getDimensions()
    spriteBatch = love.graphics.newSpriteBatch(tiles)
    self.qBrick = love.graphics.newQuad(0, 0, w, h, dx, xy)
    self.qBox   = love.graphics.newQuad(0, h+1, w, h, dx, xy)
    self.qBoxOk = love.graphics.newQuad((w+1)*2, 0, w, h, dx, xy)
    self.qEmpty = love.graphics.newQuad((w+1)*2, h+1, w, h, dx, xy)
    self.qMarker = love.graphics.newQuad(w+1, 0, w, h, dx, xy)
    self.qPlayer = love.graphics.newQuad(w+1, h, w, h+1, dx, xy)
    self.width = w
    self.height = h
end