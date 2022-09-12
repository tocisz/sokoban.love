require "graphics_util"

local board_px_width, board_px_height

screens.game = {
    init = function()
        board:read()
        board_px_width = board:px_width()
        board_px_height = board:px_height()
        redraw = true
    end,

    keypressed = function(key)
        if     key == "up"     then command = commands.up
        elseif key == "down"   then command = commands.down
        elseif key == "left"   then command = commands.left
        elseif key == "right"  then command = commands.right
        elseif key == "escape" then command = commands.exit
        elseif key == "r"      then command = commands.restart
        elseif key == "n"      then command = commands.next_lvl
        elseif key == "p"      then command = commands.previous_lvl
        end
    end,

    mousepressed = function(x, y, button, istouch, presses)
        local dx = x - width/2
        local dy = y - height/2
        local absx = math.abs(dx)
        local absy = math.abs(dy)
        if absx < 20 and absy < 20 then
            if presses == 1 then
                command = commands.next_lvl
            elseif presses == 2 then
                command = commands.previous_lvl
            else
                command = commands.exit
            end
        elseif absx > absy then
            command = dx > 0 and commands.right or commands.left
        else
            command = dy > 0 and commands.down or commands.up
        end
    end,

    update = function(dt)
        local moved = board:move(command)
        if moved and board:is_win() then
            level = level + 1
            screens:set_screen('congrats')
        end
        redraw = redraw or moved
        if command == commands.restart then
            screens.game.init()
        elseif command == commands.next_lvl then
            level = level + 1
            screens.game.init()
        elseif command == commands.previous_lvl then
            if level > 1 then
                level = level - 1
            end
            screens.game.init()
        elseif command == commands.exit then
            love.event.quit()
        end
        command = nil
    end,

    draw = function()
        if redraw then
            love.graphics.translate(cx(board_px_width), cy(board_px_height))
            board:draw()
            redraw = false
        end
    end
}