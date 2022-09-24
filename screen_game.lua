local love = require("love")
local screens = require("screens")
local board = require("board")
local commands = require("commands")
local history = require("history")

local board_px_width, board_px_height

local key_to_command = {
    up = commands.up,
    down = commands.down,
    left = commands.left,
    right = commands.right,
    w = commands.up,
    s = commands.down,
    a = commands.left,
    d = commands.right,
    escape = commands.exit,
    r = commands.restart,
    n = commands.next_lvl,
    p = commands.previous_lvl,
    ["["] = commands.undo,
    ["]"] = commands.redo
}

local update_actions = {
    [commands.loading] = function()
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
    end,

    [commands.restart] = function()
        board:read()
        history:clear()
        history:save(board.level)
        screens.game.init()
    end,

    [commands.next_lvl] = function()
        history:save(board.level)
        board.level = board.level + 1
        screens:set_screen("title")
    end,

    [commands.previous_lvl] = function()
        if board.level > 1 then
            history:save(board.level)
            board.level = board.level - 1
        end
        screens:set_screen("title")
    end,

    [commands.undo] = function()
        board:apply(history:undo())
        screens.redraw = true
        commands.command = nil
    end,

    [commands.redo] = function()
        board:apply(history:redo())
        screens.redraw = true
        commands.command = nil
    end,

    [commands.exit] = function()
        history:save(board.level)
        love.event.quit()
    end
}

screens.game = {
    -- init function for screen can set first command to be executed
    -- if it doesn't want to accept command from previous screen it should set command to nil
    init = function()
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
        commands.command = key_to_command[key]
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
        local action = update_actions[commands.command]
        if action then
            action()
        else
            -- game move
            local moved = board:move(commands.command)
            screens.redraw = moved
            commands.command = nil
            if moved and board:is_win() then
                if history.best.moves == 0 or history.best > history.current then
                    history:save_as_best(board.level)
                end
                board.level = board.level + 1
                screens:set_screen("congrats")
            end
        end
    end,

    draw = function()
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print("pushes: " .. history.current.pushes, 5, 5)
        love.graphics.print("moves: " .. history.current.moves, 5, 20)
        love.graphics.translate(screens.cx(board_px_width), screens.cy(board_px_height))
        board:draw()
    end
}