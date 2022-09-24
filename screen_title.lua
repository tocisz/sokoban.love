local love = require("love")
local screens = require("screens")
local commands = require("commands")
local board = require("board")
local history = require("history")

screens.title = screens.Splash:new {
    init = function()
        screens.redraw = true
        commands.command = nil
        board:read()
        history:read_best(board.level)
    end,

    draw = function()
        local cy = screens.height / 2
        screens.print_centered(cy-110, love.graphics.newFont(40), "Level "..board.level)
        local font20 = love.graphics.newFont(20)
        screens.print_centered(cy-40, font20, "Author: " .. board.metadata["Author"])
        screens.print_centered(cy, font20, "Title: " .. board.metadata["Title"])
        if history.best.moves > 0 then
            local font15 = love.graphics.newFont(15)
            screens.print_centered(cy+40, font15, "BEST")
            screens.print_centered(cy+60, font15, "pushes: " .. history.best.pushes)
            screens.print_centered(cy+80, font15, "moves: " ..  history.best.moves)
        end
    end
}
