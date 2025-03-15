function love.load()
    love.physics.setMeter(64) -- 1 meter = 64 pixels
    world = love.physics.newWorld(0, 0, true) -- No gravity

    -- Create a dynamic circle body
    circleBody = love.physics.newBody(world, 400, 300, "dynamic")
    circleShape = love.physics.newCircleShape(50) -- Radius 50
    circleFixture = love.physics.newFixture(circleBody, circleShape, 1)

    mouseJoint = nil -- No joint initially
end

function love.update(dt)
    world:update(dt) -- Update physics world

    -- If the MouseJoint exists, update its target position to follow the mouse
    if mouseJoint then
        mouseJoint:setTarget(love.mouse.getX(), love.mouse.getY())
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        local cx, cy = circleBody:getX(), circleBody:getY()
        local radius = circleShape:getRadius()

        -- Check if the mouse click is inside the circle
        if (x - cx)^2 + (y - cy)^2 <= radius^2 then
            -- Create a MouseJoint at the circle's center
            mouseJoint = love.physics.newMouseJoint(circleBody, cx, cy)
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and mouseJoint then
        mouseJoint:destroy() -- Remove the joint when mouse is released
        mouseJoint = nil
    end
end

function love.draw()
    -- Draw the circle
    local x, y = circleBody:getX(), circleBody:getY()
    love.graphics.setColor(1, 1, 1) -- White
    love.graphics.circle("line", x, y, circleShape:getRadius())

    -- Draw the center point
    love.graphics.setColor(1, 0, 0) -- Red
    love.graphics.circle("fill", x, y, 5)

    -- If dragging, draw a line from the body to the mouse
    if mouseJoint then
        love.graphics.setColor(0, 1, 0) -- Green
        love.graphics.line(x, y, love.mouse.getX(), love.mouse.getY())
    end
end

