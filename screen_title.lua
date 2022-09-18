local love = require("love")
local screens = require("screens")

screens.title = screens.Splash:new {
    draw = function()
        local cy = screens.height / 2
        screens.print_centered(cy-150, love.graphics.newFont(50), "Sokoban")
        screens.print_centered(cy, love.graphics.newFont(30), "press any key to start")
    end
}
