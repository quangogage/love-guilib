local guilib = require("guilib/guilib")
local displayOptions = {x = 0, y = 0, width = love.graphics.getWidth(), love.graphics.getHeight()}

function love.load()
    mainMenu = guilib.newDisplay("main-menu.html", "main-menu.css", displayOptions)
end
function love.update(dt)
    mainMenu:update(dt)
end
function love.draw()
    mainMenu:draw()
end
