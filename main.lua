-- Requires
_G.love = require("love")

-- Initialize variables
local windowWidth, windowHeight = love.window.getDesktopDimensions(2)
local currentTime = 0
local debug = false
-- local weather = {type = "clear", timer = 300} -- "clear", "breeze", "windy", "rain", "storm"
-- local objects = {} -- Implement this later
local ants = require("src.ants.ants")
local pheromones = require("src.pheromones")
local foods = require("src.food")
local nest = require("src.nest")
local textures = {}

-- Temps
local pheromoneGrid = 4

function love.load()
    -- Declare big variables/tables
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
    SpawnFood(tonumber(nest.x + (math.random(-150, 150))), tonumber(nest.y + (math.random(-150, 150))), 20, nil, ants)
end

-- Main update function
function love.update(dt)
    -- Update time tracker
    currentTime = currentTime + dt

    UpdateAnts(dt, nest, foods)
    UpdatePheromones(dt)
    UpdateFood(dt, ants)
    UpdateNest(dt)
    UpdateWeather(dt)

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
        if ant.behavior == "dead" then love.graphics.setColor(1,0.5,0) else love.graphics.setColor(1, 1, 1) end
        love.graphics.draw(textures.ant, ant.x, ant.y, ant.angle, 1, 1, 8, 8)
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
            love.graphics.print(tostring(ant.behavior), ant.x, ant.y + 10)
            if ant.inventory.food then love.graphics.print(tostring(ant.inventory.food), ant.x, ant.y + 20) end
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
        SpawnFood(tonumber(nest.x + (math.random(-20, 20))), tonumber(nest.y + (math.random(-20, 20))), nil, nil, ants)
    elseif key == "h" then
        for _, ant in pairs(ants) do
            ant.x, ant.y = 400, 300
        end
    elseif key == "f" then
        local mx, my = love.mouse.getPosition()
        SpawnFood(mx, my, nil, nil, ants)
    elseif key == "d" then
        debug = not debug
    elseif key == "s" then
        local mx, my = love.mouse.getPosition()
        SpawnPheromone(mx, my, "danger", 100, 100)
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

    function SpawnRainDrop()

    end
    ----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Updating ----------------------------------------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------------------------------------------

    function UpdateWeather(dt)

    end

    -----------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Functions ----------------------------------------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------------------------------------------

function smell(x, y, angle, target, forward)

    -- Check for food
    if target == "food" then
        for key, _ in pairs(foods) do
            local fx, fy = key:match("(-?%d+),(-?%d+)")
            fx, fy = tonumber(fx), tonumber(fy)
            if (fx - x)^2 + (fy - y)^2 <= 35^2 then
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