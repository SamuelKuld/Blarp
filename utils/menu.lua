Menu = {}
Menu.__index = Menu
function Menu.new(menus, functions, offsetX, offsetY)
    local menu = {}
    menu.offsetX = offsetX or 0
    menu.offsetY = offsetY or 0
    menu.menus = menus
    menu.functions = functions
    menu.menu_functions = {}
    menu.selected_item = 1
    setmetatable(menu, Menu)
    return menu
end

function Menu:draw_self()
    for i=1, #self.menus do
        if self.selected_item == i then
            love.graphics.setColor(1,0,0,1)
        else
            love.graphics.setColor(1,1,1,.3)
        end

        love.graphics.print(self.menus[i], (love.graphics:getWidth() / 2 - (10 * #self.menus[i]) + self.offsetX),
                                           (love.graphics:getHeight() / 2 + ( 35*i - 30 * #self.menus)) + self.offsetY)
        love.graphics.setColor(1,1,1,.3)
    end
end

function Menu:press_key(key)
    if (key == "s" or key == "down")  and (self.selected_item <= #self.menus - 1) then
        self.selected_item = self.selected_item + 1
    elseif (key == "s" or key == "down") then
        self.selected_item = 1
    end
    if (key == "w" or key == "up") and (self.selected_item >= 2) then
        self.selected_item = self.selected_item - 1
    elseif (key == "w" or key == "up") then
        self.selected_item = #self.menus
    end

    if key == "return" or key == "space" then
        self.functions[self.selected_item]()
    end

end
return Menu