local love = require("love")
local screens = require("screens")

screens.congrats = screens.Splash:new {
    draw = function()
        local cy = screens.height / 2
        screens.print_centered(cy-150, love.graphics.newFont(50), "Congratulations!")
        screens.print_centered(cy, love.graphics.newFont(30), "LEVEL COMPLETE")
    end
}