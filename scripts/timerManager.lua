local timer = require 'libraries.timer'

local timerManager = {
    workLength = 50,
    shortRestLength = 15,
    longRestLength = 30
}

function timerManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function timerManager:load()

end

return timerManager