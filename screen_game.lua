local love = require("love")
local screens = require("screens")
local board = require("board")
local commands = require("commands")
local history = require("history")

local board_px_width, board_px_height

screens.game = {
    -- init function for screen can set first command to be executed
    -- if it doesn't want to accept command from previous screen it should set command to nil
    init = function()
        board:read()
        history:load(board.level)
        board_px_width = board:px_width() --* screens.scale
        board_px_height = board:px_height() --* screens.scale
        screens.redraw = true
        if history:is_loading() then
            commands.command = commands.loading
        else
            commands.command = nil
        end
    end,

    keypressed = function(key)
        if key == "up" or key == "w" then
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
        if commands.command == commands.loading then
            local move, push = history:get_load_move()
            local moved = board:move(move)
            if not moved then error("invalid move in save file") end
            local m = history:peek()
            if not m then error("internal error") end
            if m[3] ~= push then error("push inconsistency in save file") end
            if not history:is_loading() then
                commands.command = nil -- ready for the next command
            end
            screens.redraw = true
        elseif commands.command == commands.restart then
            history:clear()
            history:save(board.level)
            screens.game.init()
        elseif commands.command == commands.next_lvl then
            history:save(board.level)
            board.level = board.level + 1
            screens.game.init()
        elseif commands.command == commands.previous_lvl then
            if board.level > 1 then
                history:save(board.level)
                board.level = board.level - 1
            end
            screens.game.init()
        elseif commands.command == commands.undo then
            board:apply(history:undo())
            screens.redraw = true
            commands.command = nil
        elseif commands.command == commands.redo then
            board:apply(history:redo())
            screens.redraw = true
            commands.command = nil
        elseif commands.command == commands.exit then
            history:save(board.level)
            love.event.quit()
        else
            -- game move
            local moved = board:move(commands.command)
            screens.redraw = moved
            commands.command = nil
            if moved and board:is_win() then
                board.level = board.level + 1
                screens:set_screen("congrats")
            end
        end
    end,

    draw = function()
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print("moves: " .. history.current.moves, 5, 5)
        love.graphics.print("pushes: " .. history.current.pushes, 5, 20)
        love.graphics.translate(screens.cx(board_px_width), screens.cy(board_px_height))
        board:draw()
    end
}