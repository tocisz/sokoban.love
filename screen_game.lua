local love = require("love")
local screens = require("screens")
local board = require("board")
local commands = require("commands")
local history = require("history")

local board_px_width, board_px_height

screens.game = {
    init = function()
        board:read()
        board_px_width = board:px_width()
        board_px_height = board:px_height()
        screens.redraw = true
    end,

    keypressed = function(key)
        if     key == "up" or key == "w" then
            commands.command = commands.up
        elseif key == "down" or key == "s" then
            commands.command = commands.down
        elseif key == "left" or key == "a" then
            commands.command = commands.left
        elseif key == "right" or key == "d" then
            commands.command = commands.right
        elseif key == "escape" or key == "q" then
            commands.command = commands.exit
        elseif key == "r" then
            commands.command = commands.restart
        elseif key == "n" then
            commands.command = commands.next_lvl
        elseif key == "p" then
            commands.command = commands.previous_lvl
        elseif key == "[" then
            commands.command = commands.undo
        elseif key == "]" then
            commands.command = commands.redo
        end
    end,

    mousepressed = function(x, y, _, _, presses)
        local dx = x - screens.width/2
        local dy = y - screens.height/2
        local absx = math.abs(dx)
        local absy = math.abs(dy)
        if absx < 20 and absy < 20 then
            if presses == 1 then
                commands.command = commands.next_lvl
            elseif presses == 2 then
                commands.command = commands.previous_lvl
            else
                commands.command = commands.exit
            end
        elseif absx > absy then
            commands.command = dx > 0 and commands.right or commands.left
        else
            commands.command = dy > 0 and commands.down or commands.up
        end
    end,

    update = function()
        local moved = board:move(commands.command)
        if moved and board:is_win() then
            board.level = board.level + 1
            screens:set_screen("congrats")
        end
        screens.redraw = screens.redraw or moved
        if commands.command == commands.restart then
            screens.game.init()
        elseif commands.command == commands.next_lvl then
            board.level = board.level + 1
            screens.game.init()
        elseif commands.command == commands.previous_lvl then
            if board.level > 1 then
                board.level = board.level - 1
            end
            screens.game.init()
        elseif commands.command == commands.undo then
            board:apply(history:undo())
            screens.redraw = true
        elseif commands.command == commands.redo then
            board:apply(history:redo())
            screens.redraw = true
        elseif commands.command == commands.exit then
            love.event.quit()
        end
        commands.command = nil
    end,

    draw = function()
        if screens.redraw then
            love.graphics.setFont(love.graphics.newFont(10))
            love.graphics.print("moves: " .. history.current.moves, 5, 5)
            love.graphics.print("pushes: " .. history.current.pushes, 5, 20)
            love.graphics.translate(screens.cx(board_px_width), screens.cy(board_px_height))
            board:draw()
            screens.redraw = false
        end
    end
}