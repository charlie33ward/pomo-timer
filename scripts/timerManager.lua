local timer = require 'libraries.timer'

local timerManager = {
    workLength = 50,
    shortRestLength = 15,
    longRestLength = 30,

    activeTimer = nil,
    activeTimerData = nil,
    remainingLength = nil,
    isPaused = false
}

local debug = {}

function timerManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function timerManager:load(setTimeTable)
    self.workTimer = timer.new()
    self.shortRestTimer = timer.new()
    self.longRestTimer = timer.new()

    self.setTimeTable = setTimeTable
end

function timerManager:startTimer(timer)
    local timeData = {seconds = 0}
    local length = 0

    if timer == 'work' then
        length = self.workLength * 60 + 1
        timeData.seconds = length
        self.workTimer:tween(length, timeData, {seconds = 0})
        self.activeTimer = self.workTimer
    elseif timer == 'shortRest' then
        length = self.shortRestLength * 60 + 1
        timeData.seconds = length
        self.shortRestTimer:tween(length, timeData, {seconds = 0})
        self.activeTimer = self.shortRestTimer

    elseif timer == 'longRest' then
        length = self.longRestLength * 60 + 1
        timeData.seconds = length
        self.longRestTimer:tween(length, timeData, {seconds = 0})
        self.activeTimer = self.longRestTimer
    end

    self.timeData = timeData
    self.setTimeTable(timeData)
    self.activeTimerData = timeData

    self.isPaused = false

    return timeData
end

function timerManager:getStartTimer()
    local manager = self
    return function(timerName)
        return manager:startTimer(timerName)
    end
end

function timerManager:resetCurrentTimer()

end

function timerManager:pauseCurrentTimer()
    if self.isPaused == false then
        self.isPaused = true
    else
        self.isPaused = false
    end
end

function timerManager:getPauseFunction()
    local manager = self
    return function()
        return manager:pauseCurrentTimer()
    end
end

function timerManager:update(dt)
    timer.update(dt)

    if self.activeTimer and self.isPaused == false then
        self.activeTimer:update(dt)
    end
end


function timerManager:drawDebug()
    love.graphics.setColor(0, 0, 0, 1)

    local debugY = 50
    if debug then
        for _, message in pairs(debug) do
            love.graphics.print(message, 150, debugY)
            debugY = debugY + 20
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end


return timerManager