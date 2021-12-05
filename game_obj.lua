local dir = (...):gsub('%.[^%.]+$', '')
Utils = require("utils")
Item = require("item")
Menu = Utils.menu
Blobs = Utils.blobs
Screen = Utils.screen
Audio = Utils.noises

Score = 1000000 --? How many time the user has clicked
Time_running = 0.0

--? Screen Variables
ScreenX = 650
ScreenY = 650
Screen_resizable = true

--? The exponent that is applied to the amount of items in an Item object
Price_power = 4


Font = love.graphics.newImageFont("utils/fonts/Resource-Imagefont.png",
                                   " abcdefghijklmnopqrstuvwxyz" ..
                                   "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
                                   "123456789.,!?-+/():;%&`'*#=[]\"")
Font_small = love.graphics.newImageFont("utils/fonts/Resource-Imagefont-Small.png",
                                   " abcdefghijklmnopqrstuvwxyz" ..
                                   "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
                                   "123456789.,!?-+/():;%&`'*#=[]\"")


--? Items object
Items = require("items")


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

    --? Sets the game up for the menu
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
        local previous_score = game.Score
        game.Score = game.Score + 1
        for i,v in ipairs(game.items.items) do
            game.Score = v:add_score(game.Score)
        end
        for i=game.Score - previous_score, 1, -1 do
            table.insert(game.particles, game.get_random_particle())
        end
    end
    game.functions["add_score"] = game.add_score

    --? Creates a new world and softbody for the game
    game.world = love.physics.newWorld(0, 0, true)
    game.blorp = Blobs.softbody(game.world, game.screen.width/2, game.screen.height/2, 100, 1, 3)
    game.blorp:setFrequency(.6)
    game.blorp:setDamping(0)
    game.blorp:setFriction(0)
    game.items = Items:new()

    --? Adds an item to the Items object that's an attribute to the game table
    function game.add_item(item, price_multiplier)
        price_multiplier = price_multiplier or 0
        local price = game.items:get_price(item.name, price_multiplier)
        if game.Score >= price then
            game.Score = game.Score - price
            game.items:add_item(item)
        end
    end

    function game.add_spacer()
        game.add_item(Item.new("spacer", game.Time_running))
        game.set_status_game()
    end
    --? Sets up the game for the store menu
    function game.set_status_store()
        game.store_menu_object = Menu.new(
            {"Back",
             "Extra Space : " .. game.items:get_price("spacer", 0),
            },
            {game.set_status_game
            ,game.add_spacer
            }
        )
        game.status = "store_menu"
    end


    --? Store Menu
    function game.store_menu(type, args)
        if type == "draw" then
            game.store_menu_object:draw_self()
        end
        if type == "keypress" then
            game.store_menu_object:press_key(args.key)
        end
    end
    game.functions["store_menu"] = game.store_menu

    --? Primary game function
    function game.blorp_screen(type, args)
        args = args or {}
        if type == "draw" then
            for key, particle_body in ipairs(game.particles) do
                love.graphics.setColor(particle_body.color)
                particle_body:draw_self("fill", false)
                if particle_body.body:getY() >= love.graphics:getHeight() then
                    Audio.play_random_audio(Audio.noises)
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

--? Gets the item name and adds it to a string
local function get_items_as_string(items)
    if items ~= nil then
        local names = ""
        for i, v in ipairs(items) do
            names = "{" .. names .. v.name .. "} , {"
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
        love.graphics.print("Items : " .. #self.items.items, 0, 40)
        love.graphics.print("Items names : " .. get_items_as_string(self.items.items), 0, 50)
        self.screen:set_font(Font)
    end
end

function Game:update(dt)
    self.functions[self.status]("update", {dt=dt})
end
function Game:keypress(key)
    Audio.play_random_audio(Audio.key_noises)
    self.functions[self.status]("keypress", {key=key})

end


return Game.new()