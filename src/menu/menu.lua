
-- Please, do not look at this file. This is garbage code, it works. It doesn't have a lot to do with the actual game so it's fine

-- Initialize variables
local config = {width = 640, height = 480}
local resolutions = require("src.menu.aspect")
local resCounter = 1
local monCounter = 1

local buttons = {}
local interactions = {}

-- Draws mainmenu
function DrawMenu()

    -- The title screen
    if Gamestate == "mainmenu" then

        for _, button in ipairs(buttons.menu) do
            love.graphics.setColor(0.3,0.3,0.3,0.7)
            love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(button.text,button.x,button.y)
        end

    -- Options
    elseif Gamestate == "options" then

        for _, button in ipairs(buttons.options) do
            love.graphics.setColor(0.3,0.3,0.3,0.7)
            love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(button.text, button.x, button.y)
        end

    end

end

-- Run this when the player hits the 'play' button
function Play()

    Gamestate = "game"
    love.graphics.setBackgroundColor(0.56,0.39,0.129)
    SpawnFood(tonumber(WindowWidth / 2 + (math.random(-150, 150))), tonumber(WindowHeight / 2 + (math.random(-150, 150))), 20, nil)

end

function SetButtons()

    buttons = {
        menu = {
            {
                text = "LuAnts",
                x = (WindowWidth / 2) - 150,
                y = (WindowHeight / 2)  - 200,
                width = 300,
                height = 75
            },
            {
                text = "Placeholder",
                x = (WindowWidth / 2) + 20,
                y = (WindowHeight / 2) - 125,
                width = 80,
                height = 25
            },
            {
                text = "Play",
                x = (WindowWidth / 2) - 50,
                y = (WindowHeight / 2) - 50,
                width = 100,
                height = 50
            },
            {
                text = "Options",
                x = (WindowWidth / 2) - 50,
                y = (WindowHeight / 2) + 25,
                width = 100,
                height = 50
            },
            {
                text = "quit",
                x = (WindowWidth / 2) - 50,
                y = (WindowHeight / 2) + 100,
                width = 100,
                height = 50
            }
        },
        options = {
            {
                text = "Back",
                x = (WindowWidth / 2) - 150,
                y = (WindowHeight / 2) + 100,
                width = 100,
                height = 50
            },
            {
                text = "Apply",
                x = (WindowWidth / 2) + 50,
                y = (WindowHeight / 2) + 100,
                width = 100,
                height = 50
            },
            {
                text = "Resolution:" .. resolutions[resCounter].width .. ":" .. resolutions[resCounter].height,
                x = (WindowWidth / 2) - 75,
                y = (WindowHeight / 2) - 200,
                width = 150,
                height = 50
            },
            {
                text = "Screen mode",
                x = (WindowWidth / 2) - 75,
                y = (WindowHeight / 2) - 150,
                width = 150,
                height = 50
            },
            {
                text = "display monitor: " .. monCounter,
                x = (WindowWidth / 2) - 75,
                y = (WindowHeight / 2) - 100,
                width = 150,
                height = 50
            },
            {
                text = "something?",
                x = (WindowWidth / 2) - 75,
                y = (WindowHeight / 2) - 50,
                width = 150,
                height = 50
            }
        }
    }
    interactions = {
        menu = {
            {
                func = function() Play() end,
                startX = buttons.menu[3].x,
                startY = buttons.menu[3].y,
                boundX = (buttons.menu[3].x + buttons.menu[3].width),
                boundY = (buttons.menu[3].y + buttons.menu[3].height)
            },
            {
                func = function() Gamestate = "options" end,
                startX = buttons.menu[4].x,
                startY = buttons.menu[4].y,
                boundX = (buttons.menu[4].x + buttons.menu[4].width),
                boundY = (buttons.menu[4].y + buttons.menu[4].height)
            },
            {
                func = function() love.event.quit() end,
                startX = buttons.menu[5].x,
                startY = buttons.menu[5].y,
                boundX = (buttons.menu[5].x + buttons.menu[5].width),
                boundY = (buttons.menu[5].y + buttons.menu[5].height)
            }
        },
        options = {
            {
                func = function() Gamestate = "mainmenu" end,
                startX = buttons.options[1].x,
                startY = buttons.options[1].y,
                boundX = (buttons.options[1].x + buttons.options[1].width),
                boundY = (buttons.options[1].y + buttons.options[1].height)
            },
            {
                func = function() SaveConfig(config) love.event.quit("restart") end,
                startX = buttons.options[2].x,
                startY = buttons.options[2].y,
                boundX = (buttons.options[2].x + buttons.options[2].width),
                boundY = (buttons.options[2].y + buttons.options[2].height)
            },
            {
                func = function() if resCounter == #resolutions then resCounter = 1 else resCounter = resCounter + 1 end config.width = resolutions[resCounter].width config.height = resolutions[resCounter].height SetButtons() end,
                startX = buttons.options[3].x,
                startY = buttons.options[3].y,
                boundX = (buttons.options[3].x + buttons.options[3].width),
                boundY = (buttons.options[3].y + buttons.options[3].height)
            },
            {
                func = function() if love.window.getFullscreen() or config.fullscreen then buttons.options[4].text = "Windowed" config.fullscreen = false else buttons.options[4].text = "Fullscreen" config.fullscreen = true end end,
                startX = buttons.options[4].x,
                startY = buttons.options[4].y,
                boundX = (buttons.options[4].x + buttons.options[4].width),
                boundY = (buttons.options[4].y + buttons.options[4].height)
            },
            {
                func = function() monCounter = monCounter + 1 config.display = monCounter SetButtons() end,
                startX = buttons.options[2].x,
                startY = buttons.options[2].y,
                boundX = (buttons.options[2].x + buttons.options[2].width),
                boundY = (buttons.options[2].y + buttons.options[2].height)
            },
            {
                text = "something?",
                startX = buttons.options[2].x,
                startY = buttons.options[2].y,
                boundX = (buttons.options[2].x + buttons.options[2].width),
                boundY = (buttons.options[2].y + buttons.options[2].height)
            }
        }
    }

end

SetButtons()

return interactions
