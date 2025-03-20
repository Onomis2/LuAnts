-- Requires
_G.love = require("love")

-- Initialize variables
local currentTime = 0
local windowWidth, windowHeight = love.window.getDesktopDimensions(2)
local debug = false
-- local weather = "clear" -- "clear", "breeze", "windy", "rain", "storm" -- Implement this later
-- local objects = {} -- Implement this later
local ants = {}
local pheromones = {}
local foods = {}
local nest = {}
local textures = {}

-- Temps
local pheromoneGrid = 4

function love.load()

    -- Declare big variables/tables
    nest = {
        timer = 0,
        x = 200,
        y = 200,
        food = 20,
        tunnels = 1,
        resting = {}
    }
    textures = {
        ant = love.graphics.newImage("textures/ant.png")
    }

    math.randomseed(os.time())
    if windowWidth < 5 then
        windowWidth, windowHeight = love.window.getDesktopDimensions(1)
        love.window.setMode(windowWidth, windowHeight, { fullscreen = true , display = 1})
    else
        love.window.setMode(windowWidth, windowHeight, { fullscreen = true , display = 2})
    end
    love.graphics.setBackgroundColor(0.56,0.39,0.129)
    nest.x, nest.y = windowWidth / 2, windowHeight / 2
    spawnFood(tonumber(nest.x + (math.random(-150, 150))), tonumber(nest.y + (math.random(-150, 150))), 20)
end

-- Main update function
function love.update(dt)
    -- Update time tracker
    currentTime = currentTime + dt

    updateAnts(dt)
    updatePheromones(dt)
    updateFood(dt)
    updateNest(dt)

    -- Random event
end

-- Main drawing function
function love.draw()

    -- Draw the nest
    love.graphics.setColor(0, 0, 1)
    love.graphics.circle("fill", nest.x, nest.y, 20, 6)

    -- Draw pheromones (just visualize them as small circles)
    for key, p in pairs(pheromones) do
        local x, y = key:match("(.+),(.+)")
        if p.type == "home" then
            love.graphics.setColor(0.2,0.2,0.2,p.duration / 150)
        elseif p.type == "food" then
            love.graphics.setColor(0,0.5,0,p.duration / 150)
        end
        love.graphics.circle("fill", x * pheromoneGrid, y * pheromoneGrid, pheromoneGrid, 4)
    end

    -- Draw ants (just visualize them as small circles)
    for _, ant in ipairs(ants) do
        if ant.behavior == "dead" then love.graphics.setColor(0.6,0.2,0.4) else love.graphics.setColor(1, 1, 1) end
        love.graphics.draw(textures.ant, ant.x - 8, ant.y - 8, ant.angle)
    end

    -- Draw food
    love.graphics.setColor(0,1,0,1)
    for key, food in pairs(foods) do
        local x, y = key:match("(.+),(.+)")
        love.graphics.circle("fill", tonumber(x), tonumber(y), 3, 3)
    end

    -- Debugging
    if debug then
        love.graphics.setColor(1,1,0)
        love.graphics.setColor(1,1,1)
        for _, ant in pairs(ants) do
            love.graphics.print(tostring(ant.energy), ant.x, ant.y)
            love.graphics.print(tostring(ant.clock), ant.x, ant.y + 10)
            love.graphics.print(tostring(ant.behavior), ant.x, ant.y + 20)
            if ant.inventory.food then love.graphics.print(tostring(ant.inventory.food), ant.x, ant.y + 30) end
        end
        for key, food in pairs(foods) do
            local x, y = key:match("(.+),(.+)")
            love.graphics.print(tostring(food.amount), tonumber(x), tonumber(y))
            love.graphics.print(tostring(food.time), tonumber(x), tonumber(y) + 10)
        end
        love.graphics.print(nest.food, nest.x + 10, nest.y + 10)
        love.graphics.print(tostring(#nest.resting), nest.x, nest.y + 20)
        love.graphics.print(tostring(love.timer.getFPS()), 1, 1)
        love.graphics.print(tostring(currentTime % 1), 1, 10)
        love.graphics.print(tostring(#ants), 1, 20)
        love.graphics.setColor(1,1,0,0.3)
    end
end

-- Love2D key press (initialize game state or restart simulation)
function love.keypressed(key)
    if key == "r" then
        -- Reset simulation (clear everything and start fresh)
        ants = {}
        pheromones = {}
        foods = {}
        nest.food = 20
        spawnFood(tonumber(nest.x + (math.random(-20, 20))), tonumber(nest.y + (math.random(-20, 20))))
    elseif key == "h" then
        for _, ant in pairs(ants) do
            ant.x, ant.y = 400, 300
        end
    elseif key == "f" then
        local mx, my = love.mouse.getPosition()
        spawnFood(mx, my)
    elseif key == "d" then
        debug = not debug
    elseif key == "s" then
        local mx, my = love.mouse.getPosition()
        spawnPheromone(mx, my, "danger", 100, 100)
    elseif key == "esc" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 2 or button == 1 then
        for px = x -25, x + 25 do
            for py = y -25, y + 25 do
                local key = math.floor(px / pheromoneGrid) .. "," .. math.floor(py / pheromoneGrid)
                if pheromones[key] then
                    pheromones[key] = nil
                end
            end
        end
    end
 end

    ----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Spawning ----------------------------------------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------------------------------------------
    

-- Create a new ant (worker or soldier)
function spawnNewAnt(type--[[, team]])
    local ant = {
        -- team = team
        type = type,                            -- Worker or soldier
        x = nest.x,
        y = nest.y,
        behavior = "exploring",                 -- AI to follow
        energy = 60,                            -- Amount of energy stored in the ant
        speed = 50,                             -- Walk speed of the ant
        angle = math.random() * math.pi * 2,    -- Angle which it faces
        clock = math.random(5) / 10,            -- Internal clock
        inventory = {}                          -- Can hold dead ants or food
    }
    table.insert(ants, ant)
end


-- Add a pheromone to the environment
function spawnPheromone(x, y, type, strength, duration)
    local key = math.floor(x / pheromoneGrid) .. "," .. math.floor(y / pheromoneGrid)
    pheromones[key] = {
        type = type,            -- "home", "food", "death"
        strength = strength,    -- Ants will prioritize stronger pheromones
        duration = duration or 5-- How long the pheromone will persist for
    }
end

-- Spawn piece of food
function spawnFood(x, y, saturation, spoilage)
    if not x and not y then x, y = math.random(windowWidth), math.random(windowHeight) end
    if not saturation then saturation = math.random(#ants * 20, #ants * 60) end
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

    ----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Updating ----------------------------------------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------------------------------------------

function updateAnts(dt)

    -- Loop through every single ant
    for id, ant in pairs(ants) do
        -- Update internal clock
        ant.clock = ant.clock - dt
        ant.clock = ant.clock - dt

        -- Ant AI
        -- Worker behavior
        if ant.type == "worker" then

            -- Move ant in its current direction
            ant.x = ant.x + math.cos(ant.angle) * ant.speed * dt
            ant.y = ant.y + math.sin(ant.angle) * ant.speed * dt
            ant.energy = ant.energy - dt
            if ant.x < 0 or ant.x > windowWidth or ant.y < 0 or ant.y > windowHeight then
                ant.angle = ant.angle + math.pi
            end
            
            if ant.behavior == "exploring" then     -- Explore randomly until it finds something interesting

                -- Smell for food
                local food = smell(math.floor(ant.x), math.floor(ant.y), ant.angle, "food", 15) -- Change to output pheromones it found and handle logic in here from there

                -- If it smells food then go towards it, otherwise keep exploring
                if food then
                    if math.sqrt((ant.x - food.x)^2 + (ant.y - food.y)^2) <= 3 and foods[food.key] then
                        local take = math.min(5, foods[food.key].amount)
                        foods[food.key].amount = foods[food.key].amount - take
                        ant.inventory = {food = take}
                        ant.behavior = "returning"
                        ant.angle = ant.angle + math.pi
                    else
                        ant.angle = math.atan2(food.y - ant.y, food.x - ant.x)
                    end
                elseif ant.clock <= 0 then
                    ant.angle = ant.angle + (math.random() * 2 - 1) * 0.75
                end

                -- Return home if it gets tired
                if ant.energy < 35 then
                    ant.behavior = "returning"
                    ant.angle = ant.angle + math.pi
                end

            elseif ant.behavior == "returning" then -- Return to the nest

                -- If it is on the nest, enter it to rest.
                if ant.x > nest.x - 15 and ant.x < nest.x + 15 and ant.y > nest.y - 15 and ant.y < nest.y + 15 then
                    -- Deposit food
                    if ant.inventory.food then
                        nest.food = nest.food + ant.inventory.food
                        ant.inventory.food = 0
                    end
                    table.insert(nest.resting, {type = "worker", time = math.random(10,15)})
                    table.remove(ants, id)
                    return
                end

                -- Smell for home
                local home = smell(math.floor(ant.x), math.floor(ant.y), ant.angle, "home", 15) -- Change to output pheromones it found and handle logic in here from there
                
                -- Follow pheromones home
                if home then
                    ant.angle = math.atan2(home.y - ant.y, home.x - ant.x)
                else
                    ant.behavior = "lost"
                    ant.speed = 10
                end

            elseif ant.behavior == "fleeing" then   -- Run away from danger
                -- Go back to the nest while leaving 'danger' pheromones

                -- This will be implemented in beta when soldiers are introduced.
                
            elseif ant.behavior == "lost" then      -- Try to find your way back to the nest
                -- Preserve energy while finding way back home
                ant.energy = ant.energy + (dt / 2)
            
                -- Smell for home
                local home = smell(math.floor(ant.x), math.floor(ant.y), ant.angle, "home", 30)

                -- If home, return, else, keep looking
                if home then
                    ant.angle = math.atan2(home.y - ant.y, home.x - ant.x)
                    ant.behavior = "returning"
                    ant.speed = 50
                else
                    if ant.clock <= 0 then
                        ant.angle = ant.angle + (math.random() * 2 - 1) * 0.7
                    end
                end


            elseif ant.behavior == "dead" then      -- it's dead...
            
                --spawnPheromone(ant.x, ant.y, "death", ant.energy + 500, 100)

                -- Decay into nothingness
                if ant.energy < -50 then
                    table.remove(ants, id)
                end
            end
        end

        -- Rest of Ant

        if ant.clock <= 0 then

            -- Declare the ant dead if it runs out of energy
            if ant.energy < 0 then

                -- Drop all items from inventory
                if ant.inventory.food then
                    --[[if ant.health == 0 then
                        spawnFood(ant.x, ant.y, ant.inventory.food)
                        ant.inventory.food = nil
                    --else]]
                    ant.inventory.food = ant.inventory.food - 1
                    ant.energy = 60
                    break
                end
                ant.speed = 0
                ant.behavior = "dead"
            end

            -- Drop pheromones
            if ant.inventory.food then
                spawnPheromone(ant.x, ant.y, "food", ant.energy, ant.energy * 1.2)
            elseif ant.behavior ~= "returning" and ant.behavior ~= "lost" then
                spawnPheromone(ant.x, ant.y, "home", ant.energy, ant.energy * 1.2)
            end

            -- Reset clock
            ant.clock = math.random(5) / 10
        end

    end

end

-- Update pheromones over time (decay)
function updatePheromones(dt)
    for key, p in pairs(pheromones) do
        p.duration = p.duration - dt
        p.strength = p.strength - (dt / 2)
        if p.duration <= 0 then
            pheromones[key] = nil
        end
    end
end

function updateFood(dt)
    local toRemove = {}  -- Implement proper garbage removal later

    -- If there is no food, spawn new food
    if next(foods) == nil then
        for i = 1, math.random(2,5) do
            spawnFood()
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

-- Update the nest's status (e.g., food collection)
function updateNest(dt)
    nest.timer = nest.timer + dt

    if nest.timer > 1 then
        nest.timer = 0

        if love.timer.getFPS() >= 50 then
            for i = 1, math.min(10, math.floor(nest.food / 5)) do
                if nest.food >= 5 then
                    spawnNewAnt("worker")
                    nest.food = nest.food - 5
                else
                    break
                end
            end
        end

        for id, ant in ipairs(nest.resting) do
            ant.time = ant.time - 5
            if ant.time < 0 then
                spawnNewAnt(ant.type)
                table.remove(nest.resting, id)
            end
        end
    end
end

function updateWeather(dt)
    
end

    -----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Functions ----------------------------------------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Get pheromone strength at a position
function getPheromone(x, y, type)
    local key = math.floor(x) .. "," .. math.floor(y)
    if pheromones[key] and pheromones[key].type == type then
        return pheromones[key]
    end
    return nil
end

function smell(x, y, angle, target, forward)

    -- Check for food
    if target == "food" then
        for key, _ in pairs(foods) do
            local fx, fy = key:match("(-?%d+),(-?%d+)")
            fx, fy = tonumber(fx), tonumber(fy)
            if (fx - x)^2 + (fy - y)^2 <= 30^2 then
                return {key = key, x = fx, y = fy}
            end
        end
    end

    -- Begin with nil found pheromones
    local foundPheromone = nil

    -- Check 5 steps in front of the ant for pheromones
    for i = 3, forward do
        local fx, fy = x + math.cos(angle) * i * 3, y + math.sin(angle) * i * 3
        local cx, sy = math.cos(angle + math.pi / 2) * 3, math.sin(angle + math.pi / 2) * 3
    
        for j = -forward / 2, forward / 2 do
            local sx, sy = fx + cx * j, fy + sy * j
            local key = math.floor(sx / pheromoneGrid) .. "," .. math.floor(sy / pheromoneGrid)
    
            if pheromones[key] and pheromones[key].type == target and (not foundPheromone or pheromones[key].strength > foundPheromone.strength) then
                foundPheromone = {strength = pheromones[key].strength, x = sx, y = sy}
            end
        end
    end

    return foundPheromone
end