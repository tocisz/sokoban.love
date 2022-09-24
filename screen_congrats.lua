local love = require("love")
local screens = require("screens")
local commands = require("commands")

screens.congrats = screens.Splash:new {
    draw = function()
        local cy = screens.height / 2
        screens.print_centered(cy-150, love.graphics.newFont(50), "Congratulations!")
        screens.print_centered(cy, love.graphics.newFont(30), "LEVEL COMPLETE")
    end,
    update = function()
       if commands.command == commands.enter then
          commands.command = nil
          screens:set_screen("title")
       else
          commands.command = nil
       end
    end
}