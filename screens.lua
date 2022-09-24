local love = require("love")
local commands = require("commands")
local options = require("options")

local screens = {
   redraw = false,
   width = 1,
   height = 1,
   scale = 1
}

function screens:set_screen(name)
   love.update = self[name].update
   local ddraw = self[name].draw
   if options.experimentalRun then
      love.draw = function()
         if screens.redraw then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.scale(screens.scale)
            ddraw()
            love.graphics.present()
            screens.redraw = false
         end
      end
   else
      love.draw = ddraw
   end
   love.keypressed = self[name].keypressed
   -- love.touchpressed = self[name].touchpressed
   love.mousepressed = self[name].mousepressed
   self[name].init()
end

screens.Splash = {
   keypressed = function()
      commands.command = commands.enter
   end,
   mousepressed = function()
      commands.command = commands.enter
   end,
   init = function()
      screens.redraw = true
      commands.command = nil
   end,
   update = function()
      if commands.command == commands.enter then
         commands.command = nil
         screens:set_screen("game")
      else
         commands.command = nil
      end
   end
}
screens.Splash.__index = screens.Splash

function screens.Splash:new(o)
   o = o or {}
   setmetatable(o, self)
   return o
end

function screens.cx(w)
   return math.floor((screens.width - w)/2)
end

function screens.cy(h)
   return math.floor((screens.height - h)/2)
end

function screens.print_centered(y, font, text)
   love.graphics.setFont(font)
   love.graphics.print(text, screens.cx(font:getWidth(text)), y)
end

return screens