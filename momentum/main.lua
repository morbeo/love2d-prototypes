function love.load()
    -- Define the circle with initial position, radius, and zero velocity.
    circle = {
        x = 400,
        y = 300,
        radius = 30,
        vx = 0,
        vy = 0,
        impulseFactor = 5  -- Adjust this value to change the impact strength
    }
end

function love.update(dt)
    -- Update the circle's position based on its velocity.
    circle.x = circle.x + circle.vx * dt
    circle.y = circle.y + circle.vy * dt

    -- Apply friction to gradually slow the circle.
    circle.vx = circle.vx * 0.98
    circle.vy = circle.vy * 0.98
end

function love.draw()
    -- Draw the circle.
    love.graphics.circle("fill", circle.x, circle.y, circle.radius)
end

-- Helper function to check if a point is inside the circle.
function isInsideCircle(px, py, cx, cy, r)
    return ((px - cx)^2 + (py - cy)^2) <= r^2
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- If the mouse is over the circle, add momentum based on the mouse movement.
    if isInsideCircle(x, y, circle.x, circle.y, circle.radius) then
        circle.vx = circle.vx + dx * circle.impulseFactor
        circle.vy = circle.vy + dy * circle.impulseFactor
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        circle.x = 400
        circle.y = 300
        circle.vx = 0
        circle.vy = 0
    end
end
