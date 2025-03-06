function love.load()
    love.physics.setMeter(64) -- 1 meter = 64 pixels
    world = love.physics.newWorld(0, 0, true) -- No gravity

    -- Create a dynamic circle body at (400, 300)
    circleBody = love.physics.newBody(world, 400, 300, "dynamic")
    circleShape = love.physics.newCircleShape(50) -- Radius of 50 pixels
    circleFixture = love.physics.newFixture(circleBody, circleShape, 1)

    following = false       -- Whether the circle follows the mouse
    prevMouseInside = false -- Tracks if mouse was inside the circle in the previous frame
end

function love.update(dt)
    world:update(dt)

    local mouseX, mouseY = love.mouse.getPosition()
    local cx, cy = circleBody:getX(), circleBody:getY()
    local radius = circleShape:getRadius()
    local dx, dy = mouseX - cx, mouseY - cy
    local currentMouseInside = (dx * dx + dy * dy) <= (radius * radius)

    -- If not already following and the mouse has just entered the circle, start following
    if not following and not prevMouseInside and currentMouseInside then
        following = true
    end

    -- Update the previous mouse-inside state for the next frame
    prevMouseInside = currentMouseInside

    -- If following, snap the circle to the mouse cursor
    if following then
        circleBody:setPosition(mouseX, mouseY)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and following then  -- Left mouse button releases the circle
        following = false
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", circleBody:getX(), circleBody:getY(), circleShape:getRadius())
end

