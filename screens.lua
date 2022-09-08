screens = {}
redraw = false

function screens:set_screen(name)
    love.update = self[name].update
    if options.experimentalRun then
       local ddraw = self[name].draw
       love.draw = function()
          if redraw then
             love.graphics.origin()
             love.graphics.clear(love.graphics.getBackgroundColor())
             ddraw()
             love.graphics.present()
             redraw = false
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

Splash = {
    keypressed = function(key)
       command = commands.enter
    end,
    mousepressed = function(x, y, button, istouch, presses)
       command = commands.enter
    end,
    init = function()
       redraw = true
    end,
    update = function()
       if command == commands.enter then
          screens:set_screen('game')
       end
       command = nil
    end
 }
 
 function Splash:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
 end