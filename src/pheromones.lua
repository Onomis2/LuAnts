local pheromones = {}
local pheromoneGrid = 4
local colors = {home = {0.2,0.2,0.2}, food = {0,0.5,0}, danger = {1,0,0}}

-- Add a pheromone to the environment
function SpawnPheromone(x, y, type, strength, duration)
    local key = math.floor(x / pheromoneGrid) .. "," .. math.floor(y / pheromoneGrid)
    pheromones[key] = {
        type = type,            -- "home", "food", "death"
        strength = strength,    -- Ants will prioritize stronger pheromones
        duration = duration or 5-- How long the pheromone will persist for
    }
end

-- Update pheromones over time (decay)
function UpdatePheromones(dt)

    for key, p in pairs(pheromones) do
        p.duration = p.duration - dt
        p.strength = p.strength - (dt / 2)
        if p.duration <= 0 then
            pheromones[key] = nil
        end
    end

end

function DrawPheromones()

    for key, p in pairs(pheromones) do
        local x, y = key:match("(.+),(.+)")
        love.graphics.setColor(colors[p.type][1], colors[p.type][2], colors[p.type][3], p.duration / 150)
        love.graphics.circle("fill", x * pheromoneGrid, y * pheromoneGrid, pheromoneGrid, 4)
    end

end

return pheromones