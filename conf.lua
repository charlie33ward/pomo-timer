function love.conf(t)
    t.window.msaa = 8
    t.window.borderless = false
    t.window.resizable = false
    t.window.width = 800
    t.window.height = 600

    t.modules.joystick = false
    t.modules.physics = false
end