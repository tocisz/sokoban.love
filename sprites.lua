sprites = {}
spriteBatch = nil

function sprites:init()
    local tiles = love.graphics.newImage("data/tiles.jpg")
    local dx, xy = tiles:getDimensions()
    spriteBatch = love.graphics.newSpriteBatch(tiles)
    self.qBrick = love.graphics.newQuad(1, 0, tile_x, tile_y, dx, xy)
    self.qBoxOk = love.graphics.newQuad(1+tile_x*2, 0, tile_x, tile_y, dx, xy)
    self.qBox = love.graphics.newQuad(1+tile_x, 2*tile_y, tile_x, tile_y, dx, xy)
    self.qEmpty = love.graphics.newQuad(1+tile_x, tile_y, tile_x, tile_y, dx, xy)
    self.qEmptyOk = love.graphics.newQuad(1+tile_x*2, tile_y, tile_x, tile_y, dx, xy)
    self.qPlayer = love.graphics.newQuad(1+tile_x*3, tile_y-1, tile_x, tile_y, dx, xy)
end