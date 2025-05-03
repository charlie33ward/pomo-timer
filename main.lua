love.graphics.setDefaultFilter("linear", "linear")

local timer = require 'libraries.timer'
local anim8 = require 'libraries.anim8'
local helium = require 'libraries.helium'
local timerManager = require 'scripts.timerManager'

local timerLayout = require 'scripts.ui-modules.timerLayout'

local palettes = {}
palettes.default = {
    timer = {0.761, 0.184, 0.318},
    background = {0.93, 0.93, 0.93},

    accent1 = {0.22, 0.831, 0.498},
    accent2 = {0.698, 0.376, 0.922},
    accent3 = {0.404, 0.541, 0.91},

    textShadow = {0.251, 0, 0.251}
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

local timeTable = nil

local function setTimeTable(newTable)
    timeTable = newTable
end

local debug = {}
local function drawDebug()

    local timerObject = {}

    love.graphics.setColor(0, 0, 0, 1)

    local debugY = 110
    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 50, debugY)
            debugY = debugY + 20
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function love.load()
    love.graphics.setLineStyle('smooth')

    TimerManager = timerManager:new()
    TimerManager:load(setTimeTable)

    -- timeTable = TimerManager:startTimer('work')

    local startTimerFunction = TimerManager:getStartTimer()


    timerScene:activate()
    TimerUI = timerLayout({palette = palettes.default, timeData = timeTable, startTimerFunction = startTimerFunction}, screenDimensions.width, screenDimensions.height)
    TimerUI:draw()

end




function love.update(dt)
    timer.update(dt)
    TimerManager:update(dt)

    if timeTable then
        debug.sec = timeTable.seconds
    end
end

function love.draw()
    timerScene:draw()

    drawDebug()
    TimerManager:drawDebug()
end



function love.keypressed(key, scancode, isrepeat)
    if key == 'escape' then
        love.event.quit()
    end
end

