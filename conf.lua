local love = require("love")
function love.conf(t)
    t.identity = "sokoban"
    t.window.title = "Sokoban"
    t.window.fullscreen = false
    t.window.resizable = true
end