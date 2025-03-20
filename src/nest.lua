local nest = {
    timer = 0,
    x = 200,
    y = 200,
    food = 20,
    tunnels = 1,
    resting = {}
}

-- Update the nest's status (e.g., food collection)
function UpdateNest(dt)
    nest.timer = nest.timer + dt

    if nest.timer > 1 then
        nest.timer = 0

        if love.timer.getFPS() >= 50 then
            for i = 1, math.min(10, math.floor(nest.food / 5)) do
                if nest.food >= 5 then
                    SpawnNewAnt(nest, "worker")
                    nest.food = nest.food - 5
                else
                    break
                end
            end
        end

        for id, ant in ipairs(nest.resting) do
            ant.time = ant.time - 5
            if ant.time < 0 then
                SpawnNewAnt(nest, ant.type)
                table.remove(nest.resting, id)
            end
        end
    end
end

return nest