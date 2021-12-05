function love.load()
    Game = require("game_obj")
end

function love.update(delta_time)
    Game:update(delta_time)
end

function love.draw()
    Game:draw_self()
end


function love.keypressed(key)
    Game:keypress(key)
end