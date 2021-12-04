Menu = require("menu")
Blobs = require("loveblobs")

Score = 1000000 -- How many time thge user has clicked
Time_running = 0.0

-- Screen Variables
ScreenX = 650
ScreenY = 650
Screen_resizable = true

local noises = {
    love.audio.newSource("sounds/crackle1.wav", "stream"),
    love.audio.newSource("sounds/crackle2.wav", "stream"),
    love.audio.newSource("sounds/crackle3.wav", "stream"),
    love.audio.newSource("sounds/crackle4.wav", "stream"),
    love.audio.newSource("sounds/crackle5.wav", "stream"),
    love.audio.newSource("sounds/plop_1.wav", "stream"),
    love.audio.newSource("sounds/plop_2.wav", "stream"),
    love.audio.newSource("sounds/plop_3.wav", "stream"),
    love.audio.newSource("sounds/plop_4.wav", "stream"),
    love.audio.newSource("sounds/plop_5.wav", "stream"),
}
local key_noises = {
    love.audio.newSource("sounds/keypress_2.wav", "stream"),
    love.audio.newSource("sounds/keypress_3.wav", "stream"),
    love.audio.newSource("sounds/keypress_4.wav", "stream"),
    love.audio.newSource("sounds/keypress_1.wav", "stream")
}
Font = love.graphics.newImageFont("fonts/Resource-Imagefont.png",
                                   " abcdefghijklmnopqrstuvwxyz" ..
                                   "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
                                   "123456789.,!?-+/():;%&`'*#=[]\"")
Font_small = love.graphics.newImageFont("fonts/Resource-Imagefont-Small.png",
                                   " abcdefghijklmnopqrstuvwxyz" ..
                                   "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
                                   "123456789.,!?-+/():;%&`'*#=[]\"")


local function play_random_audio(noise_group)
    love.audio.play(noise_group[math.random(1, #noise_group)])
end


Screen = {}
Screen.__index = Screen
function Screen.new()
    local screen = {}
    screen.width = ScreenX
    screen.height = ScreenY
    screen.resizable = Screen_resizable
    screen.font = Font
    setmetatable(screen, Screen)
    return screen
end
function Screen:resize(resize)
    resize = resize or self
    self.width = resize.width
    self.height = resize.height
    self.resizable = resize.resizable
    self.font = resize.font
    love.window.setMode(self.width, self.height, {resizable = self.resizable })
end
function Screen:set_font(font)
    self.font = font
    love.graphics.setFont(self.font)
end
function Screen:get_width()
    self.width = love.graphics:getWidth()
    return self.width
end
function Screen:get_height()
    self.height = love.graphics:getHeight()
    return self.height
end

Items = {}
function Items.new()
    local items = {}
    setmetatable(items, Items)
    return items
end

Spacer = {}
Spacer.__index = Spacer
function Spacer.new(time_running)
    time_running = time_running or 0
    local spacer = {}
    spacer.spawn = time_running
    spacer.name = "spacer"
    function spacer.add_score(score)
        return score + 1
    end

    function spacer.test()
        return "Functional"
    end
    setmetatable(spacer, Spacer)
    return spacer
end
function Spacer:get_price(items)
    local amount = 0
    for key,value in ipairs(items) do
        if value.name == "spacer" then
            amount = amount + 1
        end
    end

    return amount ^ 4
end
function Spacer:get_name()
    return self.name
end




Game = {}
Game.__index = Game
function Game.new()
    local game = {}
    game.screen = Screen.new()
    game.screen:resize()

    game.Score = Score
    game.Time_running = Time_running
    game.status = "game"
    game.debug = "true"

    function game.set_status_menu()
        game.blorp:destroy()
        game.blorp = Blobs.softbody(game.world, game.screen.width/2, game.screen.height/2, 100, 1, 3)
        game.blorp:setFrequency(.6)
        game.blorp:setDamping(0)
        game.blorp:setFriction(0)
        game.status = "menu"
    end
    function game.set_status_game()
        game.status = "game"
    end

    game.functions = {}
    game.__index = game
    local function get_score_per_sec()
        return Score / Time_running
    end

    function game.random_coordinates(x, y)
        return x + math.random(-2, 2),y + math.random(-2,2)
    end

    function game.random_nodes(obj)
        for i,node in ipairs(obj.nodes) do
            node.body:applyForce(math.random(-750,750), math.random(-750, 750))
        end
        return obj
    end

    function game.get_random_particle()
        local x, y = math.random(love.graphics:getWidth()), -10
        local radius = math.random(10, 25)
        local body = love.physics.newBody(game.world, x, y, "dynamic")
        local shape = love.physics.newCircleShape(radius)
        local circle = {radius = radius, body = body, x = x, y = y, shape = shape,
                        color = {
                                            2/math.random(0,10),
                                            2/math.random(0,10),
                                            2/math.random(0,10), 1
                                        }
                        }
        function circle:draw_self()
            love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
            self.body:applyForce(0, 100)
        end
        return circle
    end

    game.particles = {}
    function game.add_score()
        game.Score = game.Score + 1
        for i,v in ipairs(game.items) do
            game.Score = v.add_score(game.Score)
        end
    end
    game.functions["add_score"] = game.add_score

    game.world = love.physics.newWorld(0, 0, true)
    game.blorp = Blobs.softbody(game.world, game.screen.width/2, game.screen.height/2, 100, 1, 3)
    game.blorp:setFrequency(.6)
    game.blorp:setDamping(0)
    game.blorp:setFriction(0)
    --[[function game.add_item(item, price)
        if price <= game.Score then
            table.insert(game.items, item)
            game.Score = game.Score - price
        end
    end

    game.presser = {}
    game.presser.spawn = game.Time_running + 0 -- Allows game.presser.spawn to be an independent object of game.Time_running
    function game.presser.add_score()
        if game.Time_running - game.presser.spawn >= 5 then
            game.Score = game.Score + 1
            game.presser.spawn = 0
        end
    end
    function game.presser.get_name()
        return "presser"
    end
    function game.presser.get_price()
        local amount = 0
        for i,v in ipairs(game.items) do
            if v.get_name() == "presser" then
                amount = amount + 1
            end
        end
        return amount ^ 3.5
    end
    function game.add_presser()
        game.add_item(game.presser, game.presser.get_price())
        game.set_status_game()
    end

    game.spacer = {}
    function game.spacer.add_score()
        game.Score = game.Score + 1
    end
    function game.spacer.spacer_get_price()
        local amount = 0
        for i,v in ipairs(game.items) do
            if v.get_name() == "spacer" then
                amount = amount + 1
            end
        end
        return amount ^ 4
    end
    function game.spacer.get_name()
        return "spacer"
    end
    function game.add_spacer()
        game.add_item(game.spacer, game.spacer.spacer_get_price())
        game.set_status_game()
    end

    ]]
    game.items = Items.new()

    function game.add_item(item, score)
        if game.Score >= item:get_price(game.items) then
            game.Score = game.Score - item:get_price(game.items)
            table.insert(game.items, item)
            game.set_status_game()
        end
    end
    function game.get_price_of_spacer()
        local amount = 0
        for i,v in ipairs(game.items) do
            if v.get_name == "spacer" then
                amount = amount + 1
            end
        end
        return amount ^ 4
    end
    function game.add_spacer()
        game.add_item(Spacer.new(), game.Score)
    end
    function game.set_status_store()
        game.store_menu_object = Menu.new(
            {"Back",
             "Extra Space : " .. Spacer.new():get_price(game.items),
             "Presser - Presses once every 5 seconds" .. "0"
            },
            {game.set_status_game
            ,game.add_spacer
            }
        )
        game.status = "store_menu"
    end

    game.items = {}


    function game.store_menu(type, args)
        if type == "draw" then
            game.store_menu_object:draw_self()
        end
        if type == "keypress" then
            game.store_menu_object:press_key(args.key)
        end
    end
    game.functions["store_menu"] = game.store_menu


    function game.blorp_screen(type, args)
        args = args or {}
        if type == "draw" then
            for key, particle_body in ipairs(game.particles) do
                love.graphics.setColor(particle_body.color)
                particle_body:draw_self("fill", false)
                if particle_body.body:getY() >= love.graphics:getHeight() then
                    play_random_audio(noises)
                    game.particles[key].body:destroy()
                    table.remove(game.particles,key)
                end
            end
            love.graphics.setColor(1,0,0,1)
            game.blorp:draw("fill", true)
            love.graphics.print(game.Score, game.blorp.centerBody:getX() - #tostring(game.Score) * 10, game.blorp.centerBody:getY() - 10)
        end

        if type == "keypress" then
            if (args.key == "space" or args.key == "return") then
                game.blorp = game.random_nodes(game.blorp)
                game.add_score()
            end
            if args.key == "escape" then
                game.set_status_menu()
            end
            if (args.key == "s") then
                game.set_status_store()
            end
        end

        if type == "update" then
            game.Time_running = game.Time_running + args.dt
            game.blorp:update(args.dt)
            for i=1, 4 do
                game.world:update(args.dt)
            end
            game.blorp.centerBody:setPosition(love.graphics:getWidth()/2, love.graphics:getHeight()/2)
            game.blorp.centerBody:setLinearVelocity(0,0)

        end
    end
    game.functions["game"] = game.blorp_screen

    game.Main_menu = Menu.new(
        {"Start",
        "Quit"},
        {
        game.set_status_game,
        love.event.quit
        }
    )

    function game.main_menu(type, args)
        args = args or nil
        if type == "draw" then
            game.Main_menu:draw_self()
        end

        if type == "keypress" then
            game.Main_menu:press_key(args.key)
        end
    end
    game.functions["menu"] = game.main_menu


    setmetatable(game, Game)
    return game
end

local function get_items_as_string(items)
    if items ~= nil then
        local names = ""
        for i, v in ipairs(items) do
            names = "{" .. names .. v:get_name() .. v.test() .. "} , {"
        end
        return names
    end
    return ""
end

function Game:draw_self()
    self.functions[self.status]("draw", {})
    if self.debug then
        self.screen:set_font(Font_small)
        love.graphics.setColor(1,0,0,.5)
        love.graphics.print("Time Running : " .. self.Time_running, 0, 0)
        love.graphics.print("Screen Size : " .. self.screen.width .. ", " .. self.screen.height, 0, 10)
        love.graphics.print("Score : " .. self.Score, 0, 20)
        love.graphics.print("Status : " .. self.status, 0, 30)
        love.graphics.print("Items : " .. #self.items, 0, 40)
        love.graphics.print("Items names : " .. get_items_as_string(self.items), 0, 50)
        self.screen:set_font(Font)
    end
end

function Game:update(dt)
    self.functions[self.status]("update", {dt=dt})
end
function Game:keypress(key)
    play_random_audio(key_noises)
    self.functions[self.status]("keypress", {key=key})

end


return Game