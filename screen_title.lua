local love = require("love")
local screens = require("screens")
local commands = require("commands")
local board = require("board")

screens.title = screens.Splash:new {
    init = function()
        screens.redraw = true
        commands.command = nil
        board:read()
    end,

    draw = function()
        local cy = screens.height / 2
        screens.print_centered(cy-110, love.graphics.newFont(40), "Level "..board.level)
        screens.print_centered(cy-40, love.graphics.newFont(20), "Author: " .. board.metadata["Author"])
        screens.print_centered(cy, love.graphics.newFont(20), "Title: " .. board.metadata["Title"])
    end
}
