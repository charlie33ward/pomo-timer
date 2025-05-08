

local audioManager = {
    endTimerSounds = {
        work = nil,
        shortRest = nil,
        longRest = nil
    }
}

local allSounds = {}

function audioManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function audioManager:load()
    allSounds.clock = love.audio.newSource('assets/timer-sounds/alarm-clock.mp3', 'static')
    allSounds.crowd = love.audio.newSource('assets/timer-sounds/alarm-crowd.mp3', 'static')
    allSounds.deepSea = love.audio.newSource('assets/timer-sounds/alarm-deepsea.mp3', 'static')
    allSounds.digiWatch = love.audio.newSource('assets/timer-sounds/alarm-digiWatch.mp3', 'static')
    allSounds.guitar = love.audio.newSource('assets/timer-sounds/alarm-guitar.mp3', 'static')
    allSounds.redAlert = love.audio.newSource('assets/timer-sounds/alarm-redalert.mp3', 'static')
    
    self:loadCustomSounds()

    self.endTimerSounds.work = allSounds.digiWatch
    self.endTimerSounds.shortRest = allSounds.digiWatch
    self.endTimerSounds.longRest = allSounds.digiWatch
end

function audioManager:playEndTimerSound(timer)
    love.audio.play(self.endTimerSounds[timer])
end

function audioManager:loadCustomSounds()

end

function audioManager:update(dt)

end

return audioManager