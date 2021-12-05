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
return Screen