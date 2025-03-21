local foods = {}

-- Spawn piece of food
function SpawnFood(x, y, saturation, spoilage, ants)
    local WindowWidth, WindowHeight = love.graphics.getDimensions()
    if not x and not y then x, y = math.random(WindowWidth), math.random(WindowHeight) end
    if not saturation then saturation = math.random(#ants * 10, #ants * 40) end
    if not spoilage then spoilage = math.random(300 ,500) end

    -- Implement food spreading later
    --[[local place = {}
    while saturation > 500 do
        place.x, place.y = x, y
    end]]
    local key = math.floor(x) .. "," .. math.floor(y)
    foods[key] = {
        time = spoilage,    -- Time until it rots (Disappears)
        amount = saturation -- Amount of food in node
    }
end

function UpdateFood(dt, ants)
    local toRemove = {}  -- Implement proper garbage removal later

    -- If there is no food, spawn new food
    if next(foods) == nil then
        for i = 1, math.random(2,5) do
            SpawnFood(nil, nil, nil, nil, ants)
        end
    end

    for id, food in pairs(foods) do
        food.time = food.time - dt
        if food.time < 0 or food.amount == 0 then
            table.insert(toRemove, id)
        end
    end

    -- Remove empty food
    for _, id in ipairs(toRemove) do
        foods[id] = nil
    end
end

function DrawFood()

    love.graphics.setColor(0,1,0,1)

    for key, _ in pairs(foods) do
        local x, y = key:match("(.+),(.+)")
        love.graphics.circle("fill", tonumber(x), tonumber(y), 3, 3)
    end

end

return foods