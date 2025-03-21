function LoadConfig()

    local config = love.filesystem.getInfo("settings.lua")

    if config then
        config = love.filesystem.load("settings.lua")()
        love.window.setMode(config.width, config.height, {fullscreen = config.fullscreen, display = config.display})
        WindowWidth, WindowHeight = config.width, config.height
    else
        local data = string.format("return { width = 800, height = 600, fullscreen = false, display = 1 }")
        love.filesystem.write("settings.lua", data)
        LoadConfig()
    end

end

function SaveConfig(configs)

    local settings = love.filesystem.load("settings.lua")()
    for setting, value in pairs(configs) do
        settings[setting] = value
    end

    local data = {}
    for key, value in pairs(settings) do
        table.insert(data, tostring(key) .. " = " .. tostring(value))
    end
    data = "return {" .. table.concat(data, ", ") .. "}"

    love.filesystem.write("settings.lua", data)
    LoadConfig()

end