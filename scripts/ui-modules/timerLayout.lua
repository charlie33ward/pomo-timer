local helium = require 'libraries.helium'
local useState = require 'libraries.helium.hooks.state'
local useButton = require 'libraries.helium.shell.button'
local timer = require 'libraries.timer'
local anim8 = require 'libraries.anim8'

local gruppoFont = love.graphics.newFont('assets/fonts/Gruppo-Regular.ttf', 180)
local monogramFont = love.graphics.newFont('assets/fonts/monogram.ttf', 224)
monogramFont:setFilter('nearest', 'nearest')

local timerFont = monogramFont


local workIcon = love.graphics.newImage('assets/icons/icons8-work-100.png')
local shortRestIcon = love.graphics.newImage('assets/icons/icons8-tea-100.png')
local longRestIcon = love.graphics.newImage('assets/icons/icons8-resting-100.png')
workIcon:setFilter('linear', 'linear')
shortRestIcon:setFilter('linear', 'linear')
longRestIcon:setFilter('linear', 'linear')

local settingsIcon = love.graphics.newImage('assets/icons/icons8-settings-96.png')
settingsIcon:setFilter('linear', 'linear')

local pauseIcon = love.graphics.newImage('assets/icons/icons8-pause-90.png')
local pauseSheet = love.graphics.newImage('assets/icons/icons8-pause-sheet-50.png')
pauseSheet:setFilter('linear', 'linear')
local pauseGrid = anim8.newGrid(50, 50, pauseSheet:getWidth(), pauseSheet:getHeight())

local pauseFrameLength = 0.02
local pauseAnimForward = anim8.newAnimation(pauseGrid('1-14', 1), pauseFrameLength, 'pauseAtEnd')
local pauseAnimBackward = anim8.newAnimation(pauseGrid('14-1', 1), pauseFrameLength, 'pauseAtEnd')
local resetPauseAnimFunction = nil

local resetIcon = love.graphics.newImage('assets/icons/icons8-reset-64.png')
pauseIcon:setFilter('linear', 'linear')
resetIcon:setFilter('linear', 'linear')



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
    if seconds < 0 then
        seconds = 0
    end

    local min = math.floor(seconds / 60)
    local sec = math.floor(seconds % 60)
    
    return string.format('%02d:%02d', min, sec)
end
local function cancelTimer(timerRef)
    if timerRef then
        timer.cancel(timerRef)
        timerRef = nil
    end
end

local circleButtonFactory = helium(function(param, view)
    local baseButtonColor = param.buttonColor
    local baseIconColor = param.backgroundColor

    local endButtonColor = baseIconColor
    local endIconColor = baseButtonColor

    local radius = param.radius

    local offset = {
        x = 0,
        y = 0
    }
    if param.iconOffset then
        offset.x = param.iconOffset.x
        offset.y = param.iconOffset.y
    end

    local iconScale = param.iconScale or 0.7
    local iconX = math.floor(radius - iconScale * (param.icon:getWidth() / 2) + offset.x)
    local iconY = math.floor(radius - iconScale * (param.icon:getHeight() / 2) + offset.y)


    local button = useState({
        state = 0
    })

    button.buttonColor = baseButtonColor
    button.iconColor = baseIconColor

    local temp = {
        state = 0,
        enterTimer = nil,
        exitTimer = nil
    }

    local timerLength = 0.2

    local buttonState = useButton(
        param.startTimerFunction,
        nil,
        function()
            cancelTimer(temp.exitTimer)

            temp.enterTimer = timer.tween(timerLength, temp, {state = 1}, 'out-back', function()
                button.iconColor = endIconColor
                button.buttonColor = endButtonColor
            end)

            timer.during(timerLength, function()
                button.state = temp.state
                button.iconColor = {
                    baseIconColor[1] + ((endIconColor[1] - baseIconColor[1]) * temp.state),
                    baseIconColor[2] + ((endIconColor[2] - baseIconColor[2]) * temp.state),
                    baseIconColor[3] + ((endIconColor[3] - baseIconColor[3]) * temp.state)
                }
                button.buttonColor = {
                    baseButtonColor[1] + ((endButtonColor[1] - baseButtonColor[1]) * temp.state),
                    baseButtonColor[2] + ((endButtonColor[2] - baseButtonColor[2]) * temp.state),
                    baseButtonColor[3] + ((endButtonColor[3] - baseButtonColor[3]) * temp.state)
                }
            end)
        end,
        function()
            cancelTimer(temp.enterTimer)

            temp.exitTimer = timer.tween(timerLength, temp, {state = 0}, 'out-back', function()
                button.iconColor = baseIconColor
                button.buttonColor = baseButtonColor
            end)

            timer.during(timerLength, function()
                button.state = temp.state
                button.iconColor = {
                    baseIconColor[1] + ((endIconColor[1] - baseIconColor[1]) * temp.state),
                    baseIconColor[2] + ((endIconColor[2] - baseIconColor[2]) * temp.state),
                    baseIconColor[3] + ((endIconColor[3] - baseIconColor[3]) * temp.state)
                }
                button.buttonColor = {
                    baseButtonColor[1] + ((endButtonColor[1] - baseButtonColor[1]) * temp.state),
                    baseButtonColor[2] + ((endButtonColor[2] - baseButtonColor[2]) * temp.state),
                    baseButtonColor[3] + ((endButtonColor[3] - baseButtonColor[3]) * temp.state)
                }
            end)
        end
    )



    return function()
        love.graphics.setColor(button.buttonColor[1], button.buttonColor[2], button.buttonColor[3], 1)
        love.graphics.ellipse('fill', radius, radius, radius, radius, 30)

        love.graphics.setColor(baseButtonColor[1], baseButtonColor[2], baseButtonColor[3], 1)
        love.graphics.setLineWidth(3)
        love.graphics.ellipse('line', radius, radius, radius - 1, radius - 1, 30)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setShader(solidColorShader)
        solidColorShader:send("customColor", button.iconColor)
        solidColorShader:send("opacity", 1)

        love.graphics.draw(param.icon, iconX, iconY, 0, iconScale, iconScale)

        love.graphics.setShader()

    end
end)

local dummyTickTimer = nil

local timerButtonFactory = helium(function(param, view)
    local palette = param.palette

    local offset = {
        x = 0,
        y = 0
    }
    if param.offset then
        offset.x = param.offset.x
        offset.y = param.offset.y
    end
    if param.iconOffset then
        offset.x = param.iconOffset.x
        offset.y = param.iconOffset.y
    end

    local iconW = param.icon:getWidth()
    local iconH = param.icon:getHeight()
    local iconScale = param.scale or view.w / iconW

    local iconX = math.floor(iconW / 2)
    local iconY = math.floor(iconH / 2)

    local button = useState({
        state = 0,
        opacity = 1,
        frame = 0,
        anim = nil,
        animticks = 0
    })

    local anims = nil
    local length = pauseFrameLength * 14
    if param.animsTable then
        anims = {
            forward = param.animsTable.forward,
            backward = param.animsTable.backward
        }
    end

    local function resetThisPauseAnim()
        button.anim = anims.forward
        button.anim:gotoFrame(1)
        button.anim:pause()

        button.state = 0
    end

    if param.registerPauseResetFunc then
        param.registerPauseResetFunc(resetThisPauseAnim())
    end

    local function updatePauseAnimation()
        if dummyTickTimer then
            timer.cancel(dummyTickTimer)
        end

        dummyTickTimer = timer.during(length, function(dt)
            button.anim:update(dt)
            button.animticks = button.animticks + 1
        end)

        timer.after(length, function()
            if button.state == 0 then
                button.state = 1
                button.anim = anims.backward
                button.anim:gotoFrame(1)
                button.anim:pause()
            else
                resetThisPauseAnim()
            end
        end)
    end

    if button.anim then
        resetThisPauseAnim()
    end

    local buttonState = useButton(
        function()
            
            button.opacity = 0.6
            if param.clickFunction then
                param.clickFunction()
            end
            
            timer.after(param.timerLength, function()
                button.opacity = 1.0
            end)

            if button.anim then
                button.anim:resume()
                updatePauseAnimation()
            end
        end,
        function()
            button.opacity = 1.0
        end,
        function()
            button.opacity = 0.9
        end,
        function()
            button.opacity = 1.0
        end
    )

    return function()

        if button.anim then
            button.frame = button.anim.position
        end
        
        local shadowOffset = {x = 3, y = 2}

        love.graphics.setShader(solidColorShader)
        solidColorShader:send('customColor', param.accentColor)
        solidColorShader:send('opacity', button.opacity - 0.2)

        local x = offset.x + shadowOffset.x
        local y = offset.y + shadowOffset.y

        if button.anim then
            button.anim:draw(pauseSheet, x, y, 0, iconScale, iconScale)
        else

            love.graphics.draw(param.icon, x, y, 0, iconScale, iconScale)
        end

        love.graphics.setShader(solidColorShader)
        solidColorShader:send('customColor', palette.background)
        solidColorShader:send('opacity', button.opacity)

        if button.anim then
            button.anim:draw(pauseSheet, offset.x, offset.y, 0, iconScale, iconScale)
        else
            love.graphics.draw(param.icon, offset.x, offset.y, 0, iconScale, iconScale)
        end

        
        
        love.graphics.setShader()
    end
end)


local mainTimerFactory = helium(function(param, view)
    local palette = param.palette

    local x = math.floor(view.w / 3) - 200
    local y = math.floor(view.h * 1.1)
    local radius = math.floor(view.w * 0.8)

    local timeData = useState({
        seconds = 0
    })


    local time = nil
    if param.time then
        time = timerLength - param.time
    else
        time = 0
    end

    local buttonSideLength = 40
    timerLength = 0.05

    local pauseButton = timerButtonFactory({
        palette = param.palette,
        icon = pauseIcon,
        iconOffset = {x = -3.5, y = -2},
        scale = 0.90,
        animsTable = {
            forward = pauseAnimForward,
            backward = pauseAnimBackward
        },
        timerLength = 0.1,
        accentColor = palette.pauseAccent,
        clickFunction = function()
            param.pauseTimerFunction()
        end,

        registerPauseResetFunc = function(fn) resetPauseAnimFunction = fn end
    }, buttonSideLength, buttonSideLength)

    local resetButton = timerButtonFactory({
        palette = param.palette,
        icon = resetIcon,
        scale = 0.74,
        iconOffset = {x = -3.5, y = -4},
        timerLength = 0.1,
        accentColor = palette.resetAccent,

        clickFunction = function()
            param.resetCurrentTimerFunction()
        end
    }, buttonSideLength, buttonSideLength)
    
    --
    return function()
        
        local font = timerFont
        timeData.formattedTime = formatTime(timeData.seconds)

        local textW = font:getWidth(timeData.formattedTime)
        local textH = font:getHeight(timeData.formattedTime)
        local textBoxW = math.floor(radius * 4)

        if param.timeData then
            timeData.seconds = param.timeData.seconds
        end

        local textCoords = {
            x = -801 * (650 / view.w),
            y = 37 * (300 / view.h) + 14
        }
        
        love.graphics.setColor(palette.timer[1], palette.timer[2], palette.timer[3], 1)
        love.graphics.ellipse('fill', x, y, radius, radius, 60)
        love.graphics.setColor(1, 1, 1, 1)


        love.graphics.setFont(font)

        local shadowOffset = {x = 3, y = 2}

        love.graphics.setColor(palette.darkerTextShadow[1], palette.darkerTextShadow[2], palette.darkerTextShadow[3], palette.darkerTextShadow[4])
        love.graphics.rectangle('fill', 14, 70, 440, textH + 30, 16, 16, 20)

        love.graphics.setColor(palette.timer[1], palette.timer[2], palette.timer[3], 0.8)
        love.graphics.printf(timeData.formattedTime, textCoords.x + shadowOffset.x, textCoords.y + shadowOffset.y, textBoxW, 'center')

        -- love.graphics.setColor(palette.textShadow[1], palette.textShadow[2], palette.textShadow[3], 1)
        -- love.graphics.printf(timeData.formattedTime, textCoords.x + shadowOffset.x, textCoords.y + shadowOffset.y, textBoxW, 'center')

        love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3], 1)
        love.graphics.printf(timeData.formattedTime, textCoords.x, textCoords.y, textBoxW, 'center')
        love.graphics.setColor(1, 1, 1, 1)

        pauseButton:draw(148, 220)
        resetButton:draw(280, 220)

    end
end)

local settingsButton = helium(function(param, view)
    local palette = param.palette

    local button = useState({
        state = 0,
        opacity = 1
    })

    local iconW = param.icon:getWidth()
    local iconH = param.icon:getHeight()
    local iconScale = param.scale or view.w / iconW

    local buttonState = useButton(
        function ()
            if param.clickFunction then
                param.clickFunction()
            end
            
            timer.during(param.timerLength, function()
                button.opacity = 0.6
            end)

            timer.after(param.timerLength, function()
                button.opacity = 1.0
            end)
        end,
        function()
            button.opacity = 1.0
        end,
        function()
            button.opacity = 0.9
        end,
        function()
            button.opacity = 1.0
        end
    )

    return function()

        local shadowOffset = {x = 3, y = 2}

        love.graphics.setShader(solidColorShader)
        solidColorShader:send('customColor', palette.timer)
        solidColorShader:send('opacity', button.opacity)
        love.graphics.draw(param.icon, shadowOffset.x, shadowOffset.y, 0, iconScale, iconScale)

        love.graphics.setShader(solidColorShader)
        solidColorShader:send('customColor', palette.textShadow)
        solidColorShader:send('opacity', button.opacity)
        love.graphics.draw(param.icon, 0, 0, 0, iconScale, iconScale)

        

        love.graphics.setShader()
    end
end)


return helium(function(param, view)
    local palette = param.palette


    local dummy = useState({
        tick = 0
    })
    local timeData = useState({
        seconds = 0
    })

    local mainTimer = mainTimerFactory({palette = param.palette, timeData = param.timeData, pauseTimerFunction = param.pauseTimerFunction, resetCurrentTimerFunction = param.resetCurrentTimerFunction}, view.w, view.h)

    local radius = math.floor(view.w * 0.06)
    local buttonSideLength = radius * 2 + 2

    local workX = math.floor(view.w * 0.8)
    local workY = math.floor(view.h * 0.2)
    local workButton = circleButtonFactory({
        buttonColor = palette.accent1,
        backgroundColor = palette.background,
        icon = workIcon,
        iconScale = 0.55,
        iconOffset = {x = 1, y = -1},
        radius = radius,

        startTimerFunction = function()
            param.startTimerFunction('work')
        end}, buttonSideLength, buttonSideLength)

    local shortRestX = math.floor(view.w * 0.86)
    local shortRestY = math.floor(view.h * 0.49)
    local shortRestButton = circleButtonFactory({
        buttonColor = palette.accent2,
        backgroundColor = palette.background,
        icon = shortRestIcon,
        iconScale = 0.55,
        iconOffset = {x = -2, y = 1},
        radius = radius,

        startTimerFunction = function()
            param.startTimerFunction('shortRest')
        end
    }, buttonSideLength, buttonSideLength)

    local longRestX = math.floor(view.w * 0.895)
    local longRestY = math.floor(view.h * 0.8)
    local longRestButton = circleButtonFactory({
        buttonColor = palette.accent3,
        backgroundColor = palette.background, 
        icon = longRestIcon,
        iconScale = 0.55,
        iconOffset = {x = 0, y = 0},
        radius = radius,

        startTimerFunction = function()
            param.startTimerFunction('longRest')
        end
    }, buttonSideLength, buttonSideLength)

    local settingsButtonWidth = 50
    local settingsButton = settingsButton({
        palette = palette,
        icon = settingsIcon,
        timerLength = 0.1
    }, 72, 72)

    
    return function()
        if param.timeData then
            timeData.seconds = param.timeData.seconds
        end

        love.graphics.setColor(palette.background[1], palette.background[2], palette.background[3], 1)
        love.graphics.rectangle('fill', 0, 0, view.w, view.h)
        love.graphics.setColor(1, 1, 1, 1)

        mainTimer:draw()

        workButton:draw(workX - radius, workY - radius)
        shortRestButton:draw(shortRestX - radius, shortRestY - radius)
        longRestButton:draw(longRestX - radius, longRestY - radius)

        settingsButton:draw(view.w - (settingsButtonWidth + 26), 6)

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