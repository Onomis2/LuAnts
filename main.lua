-- Requires
_G.love = require("love")
_G.Gamestate = "mainmenu"
_G.WindowWidth = 0
_G.WindowHeight = 0
require("src.utils")
LoadConfig()

-- Initialize variables
local currentTime = 0
local debug = false
local weather = { type = "clear", timer = 300 } -- "clear", "breeze", "windy", "rain", "storm"
-- local objects = {} -- Implement this later
local interactions = require("src.menu.menu")
local ants = require("src.entities.ants.ants")
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
    nest.x, nest.y = WindowWidth / 2, WindowHeight / 2
end

-- Main update function
function love.update(dt)
    if Gamestate == "game" then
        -- Update time
        currentTime = currentTime + dt

        UpdateAnts(dt, nest, foods)
        UpdatePheromones(dt)
        UpdateFood(dt, ants)
        UpdateNest(dt)
        UpdateWeather(dt)

        -- Random event
    elseif Gamestate == "mainmenu" then
        -- Menu things
    elseif Gamestate == "options" then

    end
end

-- Main drawing function
function love.draw()
    if Gamestate == "game" then
        love.graphics.setColor(0.56, 0.39, 0.129)
        love.graphics.rectangle("fill", 1, 1, WindowWidth, WindowHeight)
        love.graphics.setColor(1,1,1)
        DrawNest(textures)
        DrawPheromones()
        DrawAnts(textures)
        DrawFood()

    else
        DrawMenu()
    end

    -- Debugging
    if debug then
        love.graphics.setColor(1, 1, 0)
        love.graphics.setColor(1, 1, 1)
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
        love.graphics.setColor(1, 1, 0, 0.3)
    end
end

-- Love2D key press
function love.keypressed(key)
    if Gamestate == "game" then
        if key == "r" then
            SpawnFood(tonumber(nest.x + (math.random(-20, 20))), tonumber(nest.y + (math.random(-20, 20))), nil, nil,
                ants)
        elseif key == "f" then
            local mx, my = love.mouse.getPosition()
            SpawnFood(mx, my, nil, nil, ants)
        elseif key == "s" then
            local mx, my = love.mouse.getPosition()
            SpawnPheromone(mx, my, "danger", 100, 100)
        elseif key == "l" then

        end
    else
        --Menu things
    end

    -- General keys
    if key == "escape" then
        love.event.quit()
    elseif key == "d" then
        debug = not debug
    end
end

function love.mousepressed(x, y, button, istouch)
    if Gamestate == "game" then
        if button == 2 or button == 1 then
            for px = x - 25, x + 25 do
                for py = y - 25, y + 25 do
                    local key = math.floor(px / pheromoneGrid) .. "," .. math.floor(py / pheromoneGrid)
                    if pheromones[key] then
                        pheromones[key] = nil
                    end
                end
            end
        end
    elseif Gamestate == "mainmenu" then
        for _, interaction in pairs(interactions.menu) do
            if x >= interaction.startX and x <= interaction.boundX and y >= interaction.startY and y <= interaction.boundY then
                if interaction.func then
                    interaction.func()
                end
            end
        end
    elseif Gamestate == "options" then
        for _, interaction in pairs(interactions.options) do
            if x >= interaction.startX and x <= interaction.boundX and y >= interaction.startY and y <= interaction.boundY then
                if interaction.func then
                    interaction.func()
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

function Smell(x, y, angle, target, forward)
    -- Check for food
    if target == "food" then
        for key, _ in pairs(foods) do
            local fx, fy = key:match("(-?%d+),(-?%d+)")
            fx, fy = tonumber(fx), tonumber(fy)
            if (fx - x) ^ 2 + (fy - y) ^ 2 <= 35 ^ 2 then
                return { key = key, x = fx, y = fy }
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

            if pheromones[key] and pheromones[key].type == target and
                (not foundPheromone or pheromones[key].strength > foundPheromone.strength) then
                foundPheromone = { strength = pheromones[key].strength, x = sx, y = sy }
            end
        end
    end

    return foundPheromone
end
