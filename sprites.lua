local love = require("love")
local sprites = {}

local defs = {}

function sprites:init()
    local w, h = 32, 32
    local tiles = love.graphics.newImage("data/sprites.png")
    local dx, xy = tiles:getDimensions()
    self.sprite_batch = love.graphics.newSpriteBatch(tiles)
    defs = {
        brick = {
            q = love.graphics.newQuad(0, 0, w, h, dx, xy)
        },
        box = {
            q = love.graphics.newQuad(0, h+1, w, h, dx, xy)
        },
        box_ok = {
            q = love.graphics.newQuad((w+1)*2, 0, w, h, dx, xy)
        },
        empty = {
            q = love.graphics.newQuad((w+1)*2, h+1, w, h, dx, xy)
        },
        marker = {
            q = love.graphics.newQuad(w+1+9, 9, w-18, h-20, dx, xy),
            ox = 9,
            oy = 9
        },
        player = {
            q = love.graphics.newQuad(w+1+3, h, w-6, h+1, dx, xy),
            ox = 3,
            oy = -1
        }
    }
    self.width = w
    self.height = h
end

function sprites:clear()
    self.sprite_batch:clear()
end

function sprites:add(s, x, y)
    local ox = defs[s].ox or 0
    local oy = defs[s].oy or 0
    self.sprite_batch:add(defs[s].q, x+ox, y+oy)
end

function sprites:draw()
    love.graphics.draw(self.sprite_batch)
end

return sprites