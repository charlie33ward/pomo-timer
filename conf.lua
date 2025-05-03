function love.conf(t)
    t.window.msaa = 8
    t.window.borderless = false
    t.window.resizable = false
    t.window.width = 800
    t.window.height = 600
    t.window.title = 'Pomo Timer'
    t.window.icon = nil

    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
end