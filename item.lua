Item = {}
Item.__index = Item

function Item.Find_items(items, name)
    local amount = 0
    for i, value in ipairs(items) do
        if value.name == name then
            amount = amount + 1
        end
    end
    return amount
end

function Item.new(name, start_time, price_multiplier)
    local item = {}
    item.name = name
    item.spawn = start_time or 0
    item.price_multiplier = price_multiplier or 0
    setmetatable(item, Item)
    return item
end


function Item.get_price(items, name, price_power, price_multiplier)
    price_multiplier = price_multiplier or 0
    return Item.Find_items(items, name) ^ (price_power + price_multiplier)
end
function Item:get_name()
    return self.name
end
function Item:add_score(score)
    return score + 1
end

return Item