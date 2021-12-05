Items = {items = {}}
function Items:new()
    local object = {}
    setmetatable(object, self)
    self.__index =  self
    return object
end
function Items:Find_items(name)
    local amount = 0
    for i, value in ipairs(self.items) do
        if value.name == name then
            amount = amount + 1
        end
    end
    return amount
end
function Items:get_price(name, multiplier)
    return self:Find_items(name) ^ (Price_power + multiplier)
end
function Items:add_item(item)
    table.insert(self.items, item)
end

return Items