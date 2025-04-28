love.graphics.setDefaultFilter("nearest", "nearest")

local timer = require 'libraries.timer'
local anim8 = require 'libraries.anim8'
local helium = require 'libraries.helium'

local timerLayout = require 'scripts.ui-modules.timerLayout'

local palettes = {}
palettes.default = {
    timer = {0.89, 0.212, 0.373},
    background = {0.93, 0.93, 0.93},

    accent1 = {0.698, 0.376, 0.922},
    accent2 = {0.22, 0.831, 0.498},
    accent3 = {0.404, 0.541, 0.91}
    -- darkPurple = {0.051, 0.004, 0.102, 1},
    -- green = {0.22, 0.831, 0.498},
    -- yellow = {0.976, 0.98, 0.361},
    -- pastelPurple = {0.698, 0.376, 0.922},
}

--[[ VARIABLES IN PARAM TABLE:

current timer's time

]]


local timerScene = helium.scene.new(true)

local screenDimensions = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}

function love.load()
    love.graphics.setLineStyle('smooth')

    timerScene:activate()
    TimerUI = timerLayout({palette = palettes.default}, screenDimensions.width, screenDimensions.height)
    TimerUI:draw()

end

function love.update(dt)
    timer.update(dt)

end

function love.draw()
    timerScene:draw()

end

function love.keypressed(key, scancode, isrepeat)
    if key == 'escape' then
        love.event.quit()
    end
end

