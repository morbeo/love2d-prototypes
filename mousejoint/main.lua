function love.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)

    -- Create a ball
    ball = {}
    ball.body = love.physics.newBody(world, 400, 300, "dynamic")
    ball.shape = love.physics.newCircleShape(20)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setRestitution(0.8) -- Makes it bouncy

    mouseJoint = nil
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        if ball.fixture:testPoint(x, y) then
            mouseJoint = love.physics.newMouseJoint(ball.body, x, y)
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and mouseJoint then
        mouseJoint:destroy()
        mouseJoint = nil
    end
end

function love.update(dt)
    world:update(dt)
    if mouseJoint then
        mouseJoint:setTarget(love.mouse.getPosition())
    end
end

function love.draw()
    love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
end

