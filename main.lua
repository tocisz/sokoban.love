require "sprites"
require "board"
require "screens"
require "screen_title"
require "screen_congrats"
require "screen_game"

options = {
   experimentalRun = true
}

commands = {
   up = {},
   down = {},
   left = {},
   right = {},
   exit = {},
   restart = {},
   enter = {},
   next_lvl = {},
   previous_lvl = {}
}
command = nil

function love.load()
    love.keyboard.setKeyRepeat(true)
	local os = love.system.getOS()
	if os == "Android" then
		love.window.setFullscreen(true)
	end

    sprites:init()
    width, height = love.graphics.getDimensions()

    screens:set_screen('title')
end

function love.resize(w, h)
   width, height = w, h
   redraw = true
end

function love.displayrotated()
	width, height = love.graphics.getDimensions()
	redraw = true
end

function experimentalRun()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			-- love.graphics.origin()
			-- love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			-- love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end

end
if options.experimentalRun then
   love.run = experimentalRun
end