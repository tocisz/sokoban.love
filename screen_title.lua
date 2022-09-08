require "graphics_util"

screens.title = Splash:new {
    draw = function()
        local cy = height / 2
        print_centered(cy-150, love.graphics.newFont(50), "Sokoban")
        print_centered(cy, love.graphics.newFont(30), "press any key to start")
    end
}
