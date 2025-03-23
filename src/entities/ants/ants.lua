local ants = {}

-- Create a new ant (worker or soldier)
function SpawnNewAnt(nest, type)
    local ant = {
        -- team = team
        type = type, -- Worker or soldier
        x = nest.x,
        y = nest.y,
        behavior = "exploring",              -- AI to follow
        energy = 60,                         -- Amount of energy stored in the ant
        speed = 50,                          -- Walk speed of the ant
        angle = math.random() * math.pi * 2, -- Angle which it faces
        clock = math.random(5) / 10,         -- Internal clock
        inventory = {}                       -- Can hold dead ants or food
    }

    table.insert(ants, ant)
end

function UpdateAnts(dt, nest, foods)
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
            if ant.x < 1 or ant.x > WindowWidth or ant.y < 1 or ant.y > WindowHeight then
                ant.angle = ant.angle + math.pi
            end

            if ant.behavior == "exploring" then -- Explore randomly until it finds something interesting
                -- Smell for food
                local food = Smell(
                    math.floor(ant.x),
                    math.floor(ant.y),
                    ant.angle,
                    "food",
                    15
                ) -- Change to output pheromones it found and handle logic in here from there

                -- If it smells food then go towards it, otherwise keep exploring
                if food then
                    local kek = math.sqrt((ant.x - food.x) ^ 2 + (ant.y - food.y) ^ 2)

                    if kek <= 3 and foods[food.key] then
                        local take = math.min(5, foods[food.key].amount)
                        foods[food.key].amount = foods[food.key].amount - take
                        ant.inventory = { food = take }
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
                    table.insert(nest.resting, { type = "worker", time = math.random(10, 15) })
                    table.remove(ants, id)

                    return
                end

                -- Smell for home
                local home = Smell(math.floor(ant.x), math.floor(ant.y), ant.angle, "home", 15) -- Change to output pheromones it found and handle logic in here from there
                -- Follow pheromones home
                if home then
                    ant.angle = math.atan2(home.y - ant.y, home.x - ant.x)
                else
                    ant.behavior = "lost"
                    ant.speed = 10
                end
            elseif ant.behavior == "fleeing" then -- Run away from danger
                -- Go back to the nest while leaving 'danger' pheromones

                -- This will be implemented in beta when soldiers are introduced.
            elseif ant.behavior == "lost" then -- Try to find your way back to the nest
                -- Preserve energy while finding way back home
                ant.energy = ant.energy + (dt / 2)

                -- Smell for home
                local home = Smell(math.floor(ant.x), math.floor(ant.y), ant.angle, "home", 30)

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
            elseif ant.behavior == "dead" then -- it's dead...
                --SpawnPheromone(ant.x, ant.y, "death", ant.energy + 500, 100)

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
                        SpawnFood(ant.x, ant.y, ant.inventory.food, nil, ants)
                        ant.inventory.food = nil
                    --else]]

                    ant.inventory.food = ant.inventory.food - 1
                    ant.energy = 60

                    break
                end

                ant.speed = 0
                ant.behavior = "dead"
                return
            end

            -- Drop pheromones
            if ant.inventory.food then
                SpawnPheromone(ant.x, ant.y, "food", ant.energy, ant.energy * 1.2)
            elseif ant.behavior ~= "returning" and ant.behavior ~= "lost" then
                SpawnPheromone(ant.x, ant.y, "home", ant.energy, ant.energy * 1.2)
            end

            -- Reset clock
            ant.clock = math.random(5) / 10
        end
    end
end

function DrawAnts(textures)
    -- Set color to white
    love.graphics.setColor(1, 1, 1)

    for _, ant in pairs(ants) do
        love.graphics.draw(textures.ant, ant.x, ant.y, ant.angle, 1, 1, 8, 8)
    end
end

return ants
