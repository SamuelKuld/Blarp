love._openConsole()
Dir = os.getenv("PWD") or io.popen("cd"):read()
local dir = (...):gsub('%.[^%.]+$', '')
Utils = require("utils")
Item = require("item")
Menu = Utils.menu
Blobs = Utils.blobs
Screen = Utils.screen
Audio = Utils.noises
Files = Utils.file_handler

Score = 1 --? How many time the user has clicked
Time_running = 0.0

--? Screen Variables
ScreenX = 650
ScreenY = 650
Screen_resizable = true

--? The exponent that is applied to the amount of items in an Item object
Price_power = 4

local function scan_directory()
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('dir "'.. Dir  .. '/saves/" /b ')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

local function in_array(value, array)
    for iteration, array_value in ipairs(array) do
        if array_value == value then
            return true
        end
    end
    return false
end

--? Gets the item name and adds it to a string
local function get_items_as_string(items)
    if items ~= nil then
        local names = ""
        for i, v in ipairs(items) do
            names =  names .. " " .. v.name
        end
        return names
    end
    return ""
end

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
    game.debug = true
    game.most_recent_key = "return"

    --? Sets the game up for the menu
    function game.set_status_menu()
        game.blorp:destroy()
        game.blorp = Blobs.softbody(game.world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 100, 1, 3)
        game.blorp:setFrequency(.6)
        game.blorp:setDamping(0)
        game.blorp:setFriction(0)
        game.status = "menu"
    end

    function game.set_status_game()
        game.blorp:destroy()
        game.blorp = Blobs.softbody(game.world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 100, 1, 3)
        game.blorp:setFrequency(.6)
        game.blorp:setDamping(0)
        game.blorp:setFriction(0)
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
    function game.add_score_loop()
        local previous_score = game.Score
        for i,v in ipairs(game.items.items) do
            if v.impulse == false then
                game.Score = v:add_score(game.Score)
            end
        end
        for i=game.Score - previous_score, 1, -1 do
            table.insert(game.particles, game.get_random_particle())
        end
    end
    game.functions["add_score"] = game.add_score

    --? Creates a new world and softbody for the game
    game.world = love.physics.newWorld(0, 0, true)
    game.blorp = Blobs.softbody(game.world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 100, 1, 3)
    game.blorp:setFrequency(.6)
    game.blorp:setDamping(0)
    game.blorp:setFriction(0)
    game.items = Items:new()

    --? Allows us to count how many times the game has iterated
    game.iterations = 0
    --? If we need to display the prompt for the store
    game.first_section = true

    --? Adds an item to the Items object that's an attribute to the game table
    function game.add_item(item, price_multiplier)
        price_multiplier = price_multiplier or 0
        local price = game.items:get_price(item.name, price_multiplier)
        if game.Score >= price + item.initial_price then
            game.Score = game.Score - price - item.initial_price
            game.items:add_item(item)
        end
    end

    function game.add_spacer()
        local spacer = Item.new("spacer", game.Time_running)
        spacer.initial_price = 10
        game.add_item(spacer, 1)
        game.set_status_game()
    end
    function game.add_auto_spacer()
        local new_auto_spacer = Item.new("auto_spacer", game.Time_running)
        new_auto_spacer.impulse = false
        new_auto_spacer.initial_price = 10
        new_auto_spacer.last_add = 0
        function new_auto_spacer:add_score(Score)
            if math.floor(game.Time_running - self.spawn) % 5 == 0 and (game.Time_running - new_auto_spacer.last_add > 5) then
                new_auto_spacer.last_add = game.Time_running
                Score = Score + 1
            end
            return Score
        end
        game.add_item(new_auto_spacer, -2)
        game.set_status_game()
    end

    function game.add_mega_auto_spacer()
        local new_auto_spacer = Item.new("mega_auto_spacer", game.Time_running)
        new_auto_spacer.impulse = false
        new_auto_spacer.last_add = 0
        new_auto_spacer.initial_price = 100
        function new_auto_spacer:add_score(Score)
            if math.floor(game.Time_running - self.spawn) % 5 == 0 and (game.Time_running - new_auto_spacer.last_add > 5) then
                new_auto_spacer.last_add = game.Time_running
                Score = Score + 5
            end
            return Score
        end
        game.add_item(new_auto_spacer, 2)
        game.set_status_game()
    end
    --? Sets up the game for the store menu
    function game.set_status_store()
        game.first_section = false
        game.store_menu_object = Menu.new(
            {"Back",
             "Extra Space : " .. game.items:get_price("spacer", 1) + 10,
             "Auto Spacer : " .. game.items:get_price("auto_spacer", -2) + 10,
             "Mega Auto Spacer : " .. game.items:get_price("mega_auto_spacer", 2) + 100,
            },
            {
            game.set_status_game,
            game.add_spacer,
            game.add_auto_spacer,
            game.add_mega_auto_spacer,
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
            if game.first_section then
                love.graphics.print("Press 'S' to go to the store", game.blorp.centerBody:getX() - 250, game.blorp.centerBody:getY() + 200)
            end
            love.graphics.print(game.Score, game.blorp.centerBody:getX() - #tostring(game.Score) * 10, game.blorp.centerBody:getY() - 10)
        end

        if type == "keypress" then
            if (args.key == "space" or args.key == "return") then
                game.add_score()
                game.blorp = game.random_nodes(game.blorp)
            end
            if args.key == "escape" then
                game.set_status_menu()
            end
            if (args.key == "s") then
                game.set_status_store()
            end
        end

        if type == "update" then
            game.iterations = game.iterations + 1
            game.Time_running = game.Time_running + args.dt
            game.blorp:update(args.dt)
            game.add_score_loop()
            for i=1, 4 do
                game.world:update(args.dt)
            end
            game.blorp.centerBody:setPosition(love.graphics:getWidth()/2, love.graphics:getHeight()/2)
            game.blorp.centerBody:setLinearVelocity(0,0)

        end
    end
    game.functions["game"] = game.blorp_screen


    game.save_menu = Menu.new(
        {"Back",
         "Done",},
        {game.set_status_menu}
    )
    function game.set_status_save()
        game.status = "save"
    end
    game.save_keys = ""
    game.save_done_typing = false
    function game.save_state(name)
        local save_array = {
            get_items_as_string(game.items.items), -- Single line multiple Spaces
            tostring(game.Time_running), -- Single line from integer
            tostring(game.Score), -- Single line from integer
        }
        Files.write_array_to_file(name, save_array)
        game.save_done_typing = false
        game.save_keys = ""
        game.set_status_game()

    end
    function game.save(type, args)
        if type == "keypress" then
            if game.save_done_typing then
                game.save_menu.press_key(args.key)
            else
                if not in_array(args.key, {"lshift", "rshift", "lalt", "lctrl", 'rctrl', 'ralt', 'space', 'escape', 'return', 'capslock', 'tab', '.', ',', '+', '+'})  then
                    game.save_keys = game.save_keys .. args.key
                end
                if args.key == "escape" then
                    game.save_done_typing = true
                end
            end
        end
        if type == "draw" then
            if not game.save_done_typing then
                love.graphics.setColor(1,1,1,1)
                love.graphics.print("Begin typing to name your save", love.graphics:getWidth() / 2 - #"Begin typing to name your save" * 9, love.graphics:getHeight() / 2 - 200)
                love.graphics.print("Press 'ESC' when complete", love.graphics:getWidth() / 2 - #"Press 'ESC' when complete" * 9, love.graphics:getHeight() / 2 - 100)
                love.graphics.print(game.save_keys, love.graphics:getWidth() / 2 - #game.save_keys * 9, love.graphics:getHeight() / 2 )
            else
                game.save_state(game.save_keys)
            end

        end

    end
    game.functions["save"] = game.save


    function game.set_status_load()
        game.status = "load"
    end

    function game.parse_data(file_position)
        print(file_position)
        local name = scan_directory()[file_position]
        local raw_data = Files.read_lines_of_file_as_array(name)
        local items = Files.split(raw_data[1], " ")
        local time_running = Files[2]
        local score = Files[3]
        game.Score = score
        game.Time_running = time_running
        game.set_status_game()
    end
    game.previous_load_menu = {}
    local files = scan_directory()
    local parse_data_amount = #files
    local parse_data_list = {}
    for i=1, parse_data_amount do
        parse_data_list[i] = game.parse_data
    end
    Load_menu = Menu.new(files, parse_data_list)

    function game.load(type, args)

        if type == "draw" then
            Load_menu:draw_self()
        end
        if type == "keypress" then
            local item = Load_menu.selected_item
            Load_menu:press_key(args.key, item)
        end
        game.previous_load_menu = Load_menu
    end
    game.functions["load"] = game.load

    game.Main_menu = Menu.new(
        {"Start",
        "Save",
        "Load",
        "Quit"},
        {
        game.set_status_game,
        game.set_status_save,
        game.set_status_load,
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

function Game:draw_self()
    self.screen:set_font(Font)
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
        love.graphics.print("Save State : " .. tostring(self.save_done_typing), 0, 60)
        love.graphics.print("Save Keys : " .. self.save_keys, 0, 70)
        love.graphics.print("Most recent key : " .. self.most_recent_key, 0, 80)
        self.screen:set_font(Font)
    end
end

function Game:update(dt)
    self.functions[self.status]("update", {dt=dt})
end
function Game:keypress(key)
    Audio.play_random_audio(Audio.key_noises)
    self.most_recent_key = key
    self.functions[self.status]("keypress", {key=key})

end


return Game.new()