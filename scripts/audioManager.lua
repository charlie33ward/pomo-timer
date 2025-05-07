

local audioManager = {

}

function audioManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function audioManager:load()
    
end

function audioManager:update(dt)

end

return audioManager