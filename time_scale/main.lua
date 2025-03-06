function love.load()
    -- Window setup
    love.window.setTitle("Bouncing Ball with Time Rewind")

    -- Screen size
    screenWidth, screenHeight = love.graphics.getDimensions()

    -- Ball properties
    ball = {
        x = screenWidth / 2,
        y = screenHeight / 2,
        radius = 20,
        speedX = 200,  -- pixels per second
        speedY = 150,
        history = {}   -- Stores past positions for rewinding
    }

    -- Time scale variable
    timeScale = 1
end

function love.update(dt)
    -- Apply time scaling
    dt = dt * timeScale

    -- Record history for rewinding (store every frame)
    if timeScale >= 0 then
        table.insert(ball.history, {x = ball.x, y = ball.y})
    elseif #ball.history > 0 then
        -- If rewinding, retrieve past positions
        local lastState = table.remove(ball.history)
        ball.x, ball.y = lastState.x, lastState.y
        return  -- Skip regular movement
    end

    -- Update ball position
    ball.x = ball.x + ball.speedX * dt
    ball.y = ball.y + ball.speedY * dt

    -- Bounce off walls
    if ball.x - ball.radius < 0 then
        ball.x = ball.radius
        ball.speedX = -ball.speedX
    elseif ball.x + ball.radius > screenWidth then
        ball.x = screenWidth - ball.radius
        ball.speedX = -ball.speedX
    end

    if ball.y - ball.radius < 0 then
        ball.y = ball.radius
        ball.speedY = -ball.speedY
    elseif ball.y + ball.radius > screenHeight then
        ball.y = screenHeight - ball.radius
        ball.speedY = -ball.speedY
    end
end

function love.draw()
    -- Draw ball
    love.graphics.setColor(1, 0, 0) -- Red
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)

    -- Display time scale info
    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.print("Time Scale: " .. string.format("%.2f", timeScale), 10, 10)
    love.graphics.print("Press ↑ to speed up, ↓ to slow down", 10, 30)
    love.graphics.print("Press ← to reverse, → to reset, SPACE to pause", 10, 50)
end

function love.keypressed(key)
    if key == "up" then
        timeScale = timeScale + 0.1  -- Increase speed
    elseif key == "down" then
        timeScale = timeScale - 0.1   -- Decrease speed (can go negative)
    elseif key == "left" then
        timeScale = -1  -- Reverse time
    elseif key == "right" then
        timeScale = 1   -- Reset to normal speed
    elseif key == "space" then
        if timeScale ~= 0 then
          timeScale = 0 
        else 
          timeScale = 1
        end
    end
end

