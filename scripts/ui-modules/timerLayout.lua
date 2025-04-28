local helium = require 'libraries.helium'
local useState = require 'libraries.helium.hooks.state'

local timerFont = love.graphics.newFont('assets/fonts/monogram.ttf', 112)

local workIcon = love.graphics.newImage('assets/icons/icons8-business-100.png')
local workIconFilled = love.graphics.newImage('assets/icons/icons8-business-100-fill.png')
local shortRestIcon = love.graphics.newImage('assets/icons/icons8-coffee-100.png')
local shortRestIconFilled = love.graphics.newImage('assets/icons/icons8-coffee-100-fill.png')
local longRestIcon = love.graphics.newImage('assets/icons/icons8-resting-100.png')
local longRestIconFilled = love.graphics.newImage('assets/icons/icons8-resting-100-fill.png')

local timerLength = 50 * 60

local solidColorShader = love.graphics.newShader[[
    extern vec3 customColor;
    extern float opacity;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texColor = Texel(texture, texture_coords);
        if (texColor.a == 0.0) {
            discard;
        }
        return vec4(customColor, opacity * texColor.a);
    }
]]

local debug = {}

local function formatTime(seconds)
    local min = math.floor(seconds / 60)
    local sec = math.floor(seconds % 60)
    
    return string.format('%02d:%02d', min, sec)
end

local circleButtonFactory = helium(function(param, view)
    local buttonColor = param.buttonColor
    local iconColor = param.backgroundColor

    local radius = math.floor(view.w * 0.065)
    debug.radius = 'radius: ' .. radius

    local offset = {
        x = 0,
        y = 0
    }
    if param.iconOffset then
        offset.x = param.iconOffset.x
        offset.y = param.iconOffset.y
    end

    local iconScale = param.iconScale or 0.7
    local iconX = math.floor(param.x - iconScale * (param.icon:getWidth() / 2) + offset.x)
    local iconY = math.floor(param.y - iconScale * (param.icon:getHeight() / 2) + offset.y)

    return function()
        love.graphics.setColor(buttonColor[1], buttonColor[2], buttonColor[3], 1)
        love.graphics.ellipse('fill', param.x, param.y, radius, radius, 30)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setShader(solidColorShader)
        solidColorShader:send("customColor", iconColor)
        solidColorShader:send("opacity", 1)

        love.graphics.setColor(iconColor[1], iconColor[2], iconColor[3], 1)
        love.graphics.draw(param.icon, iconX, iconY, 0, iconScale, iconScale)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setShader()
    end
end)

local mainTimerFactory = helium(function(param, view)
    local palette = param.palette

    local x = math.floor(view.w / 3)
    local y = math.floor(view.h * 0.55)
    local radius = math.floor(view.w * 0.2)

    local time = nil
    if param.time then
        time = timerLength - param.time
    else
        time = 3680.32
    end

    local formattedTime = formatTime(time)
    
    local font = timerFont
    local textW = font:getWidth(formattedTime)
    local textH = font:getHeight(formattedTime)
    local textBoxW = math.floor(radius * 1.5)

    local textCoords = {
        x = x - math.floor(textBoxW / 2),
        y = y - math.floor(textH / 2)
    }

    return function()
        love.graphics.setColor(palette.timer[1], palette.timer[2], palette.timer[3], 1)
        love.graphics.ellipse('fill', x, y, radius, radius, 45)
        love.graphics.setColor(1, 1, 1, 1)


        love.graphics.setFont(font)

        local shadowOffset = {x = 3, y = 2}
        love.graphics.setColor(palette.textShadow[1], palette.textShadow[2], palette.textShadow[3], 1)
        love.graphics.printf(formattedTime, textCoords.x+ shadowOffset.x, textCoords.y + shadowOffset.y, textBoxW, 'center')

        love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3], 1)
        love.graphics.printf(formattedTime, textCoords.x, textCoords.y, textBoxW, 'center')
        love.graphics.setColor(1, 1, 1, 1)

    end
end)



return helium(function(param, view)
    local palette = param.palette

    local dummy = useState({
        tick = 0
    })

    local mainTimer = mainTimerFactory(param, view.w, view.h)

    local x = math.floor(view.w * 0.7)
    local y = math.floor(view.h * 0.32)
    local workButton = circleButtonFactory({
        buttonColor = palette.accent1,
        backgroundColor = palette.background,
        x = x, 
        y = y, 
        icon = workIcon,
        iconFilled = workIconFilled,
        iconScale = 0.7,
        iconOffset = {x = 0, y = -3}
    }, view.w, view.h)

    x = x + math.floor(view.w * 0.12)
    y = math.floor(view.h * 0.56)
    local shortRestButton = circleButtonFactory({
        buttonColor = palette.accent2,
        backgroundColor = palette.background,
        x = x, 
        y = y, 
        icon = shortRestIcon,
        iconFilled = shortRestIconFilled,
        iconScale = 0.7,
        iconOffset = {x = 0, y = 0}
    }, view.w, view.h)

    local x = math.floor(view.w * 0.7)
    y = math.floor(view.h * 0.8)
    local longRestButton = circleButtonFactory({
        buttonColor = palette.accent3,
        backgroundColor = palette.background,
        x = x, 
        y = y, 
        icon = longRestIcon,
        iconFilled = longRestIconFilled,
        iconScale = 0.7,
        iconOffset = {x = 0, y = 0}
    }, view.w, view.h)

    
    return function()
        love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3], 1)
        love.graphics.rectangle('fill', 0, 0, view.w, view.h)
        love.graphics.setColor(1, 1, 1, 1)

        mainTimer:draw()

        workButton:draw()
        shortRestButton:draw()
        longRestButton:draw()

        dummy.tick = dummy.tick + 1


        love.graphics.setColor(0, 0, 0, 1)
        local debugY = 50

        if debug then
            for _, message in pairs(debug) do
                love.graphics.print(message, 50, debugY)
                debugY = debugY + 20
            end
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
end)