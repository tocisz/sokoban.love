local love = require("love")
local commands = require("commands")
local options = require("options")

local screens = {
   redraw = false,
   width = 1,
   height = 1
}

function screens:set_screen(name)
   love.update = self[name].update
   if options.experimentalRun then
      local ddraw = self[name].draw
      love.draw = function()
         if screens.redraw then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            ddraw()
            love.graphics.present()
            screens.redraw = false
         end
      end
   else
      love.draw = self[name].draw
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
   end,
   update = function()
      if commands.command == commands.enter then
         screens:set_screen('game')
      end
      commands.command = nil
   end
}

function screens.Splash:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
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