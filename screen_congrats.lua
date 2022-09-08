require "graphics_util"

screens.congrats = Splash:new {
    draw = function()
        local cy = height / 2
        print_centered(cy-150, love.graphics.newFont(50), "Congratulations!")
        print_centered(cy, love.graphics.newFont(30), "LEVEL COMPLETE")
    end
}