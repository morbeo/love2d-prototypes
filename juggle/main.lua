local balls = {}
local gravity = 500
local tossDuration = 1.0
local shortTossRatio = 0.5
local ground = 500
local ballRadius = 20
local numBalls = 3
local handDistance = 200
local handCenter = 300
local handPositions = {handCenter - handDistance / 2, handCenter + handDistance / 2}
local colors = {{0.33, 1, 1}, {1, 0.33, 1}, {1, 1, 0.33},  {0, 0, 0.67}, {0, 0.67, 0}, {0, 0.67, 0.67}, {0.67, 0, 0}, {0.67, 0, 0.67}, {0.67, 0.33, 0}, {0.67, 0.67, 0.67}, {0.33, 0.33, 0.33}, {0.33, 0.33, 1}, {0.33, 1, 0.33}, {1, 1, 1}}
local stacks = {{}, {}}
local maxBalls = #colors

function love.load()
    love.window.setMode(600, 600)
    initializeBalls()
end

function initializeBalls()
    balls = {}
    stacks = {{}, {}}
    for i = 1, numBalls do
        local hand = (i % 2) + 1
        local ball = {
            x = handPositions[hand],
            y = ground,
            vy = 0,
            vx = 0,
            active = false,
            currentHand = hand,
            color = colors[(i - 1) % #colors + 1],
            trajectory = {}
        }
        table.insert(balls, ball)
        table.insert(stacks[hand], ball)
    end
end

function love.update(dt)
    for _, ball in ipairs(balls) do
        if ball.active then
            ball.vy = ball.vy + gravity * dt
            ball.y = ball.y + ball.vy * dt
            ball.x = ball.x + ball.vx * dt

            if ball.y >= ground then
                ball.y = ground
                ball.active = false
                ball.vx = 0
                ball.x = handPositions[ball.currentHand]
                table.insert(stacks[ball.currentHand], ball)
                ball.trajectory = {}
            end
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    local leftToss, rightToss = tossDuration, tossDuration
    if love.keyboard.isDown('w') then
        leftToss = leftToss * 2
    end
    if love.keyboard.isDown('s') then
        leftToss = leftToss * shortTossRatio
    end
    if love.keyboard.isDown('p') then
        rightToss = rightToss * 2
    end
    if love.keyboard.isDown(';') then
        rightToss = rightToss * shortTossRatio
    end

    if key == 'escape' then
        love.event.quit()
    elseif key == 'e' then
        throwBall(1, 2, leftToss)
    elseif key == 'o' then
        throwBall(2, 1, rightToss)
    elseif key == 'd' then
        throwBall(1, 2, leftToss * 0.75)
    elseif key == 'l' then
        throwBall(2, 1, rightToss * 0.75)
    elseif key == 'up' and numBalls < maxBalls then
        numBalls = numBalls + 1
        initializeBalls()
    elseif key == 'down' and numBalls > 1 then
        numBalls = numBalls - 1
        initializeBalls()
    elseif key == 'left' then
        handDistance = math.max(50, handDistance - 10)
        updateHandPositions()
    elseif key == 'right' then
        handDistance = math.min(400, handDistance + 10)
        updateHandPositions()
    elseif key == '9' then
        shortTossRatio = math.min(1, shortTossRatio + 0.05)
    elseif key == '0' then
        shortTossRatio = math.max(0.1, shortTossRatio - 0.05)
    elseif key == '=' or key == '+' then
        tossDuration = tossDuration + 0.1
    elseif key == '-' then
        tossDuration = math.max(0.1, tossDuration - 0.1)
    end
end

function updateHandPositions()
    handPositions = {handCenter - handDistance / 2, handCenter + handDistance / 2}
    for hand = 1, 2 do
        for _, ball in ipairs(stacks[hand]) do
            ball.x = handPositions[hand]
        end
    end
end

function throwBall(fromHand, toHand, duration)
    if #stacks[fromHand] > 0 then
        local ball = table.remove(stacks[fromHand])
        ball.trajectory = {}
        local steps = 60
        local dt = duration or tossDuration / steps

        local tempX, tempY = handPositions[fromHand], ground
        local targetX = handPositions[toHand]
        local tempVx = (targetX - tempX) / duration
        local tempVy = -0.5 * gravity * duration

        for i = 1, steps do
            tempVy = tempVy + gravity * dt
            tempY = tempY + tempVy * dt
            tempX = tempX + tempVx * dt
            table.insert(ball.trajectory, {x = tempX, y = tempY})
        end

        ball.active = true
        ball.vy = -0.5 * gravity * duration
        ball.currentHand = toHand
        ball.vx = tempVx
        ball.x = handPositions[fromHand]
        ball.y = ground
    end
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.print("Toss Duration: " .. string.format("%.2f", tossDuration), 10, 10)
    love.graphics.print("Short Toss Ratio: " .. string.format("%.2f", shortTossRatio), 10, 30)
    love.graphics.print("Hand Distance: " .. handDistance, 10, 50)
    love.graphics.print("Number of Balls: " .. numBalls, 10, 70)

    for hand = 1, 2 do
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.rectangle("fill", handPositions[hand] - 15, ground + 10, 30, 10)
        for i, ball in ipairs(stacks[hand]) do
            love.graphics.setColor(ball.color)
            love.graphics.circle("fill", handPositions[hand], ground - (i - 1) * ballRadius * 0.2, ballRadius)
        end
    end

    for _, ball in ipairs(balls) do
        love.graphics.setColor(ball.color)
        for i = 1, #ball.trajectory - 1 do
            local p1, p2 = ball.trajectory[i], ball.trajectory[i + 1]
            love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        end
        if ball.active then
            love.graphics.circle("fill", ball.x, ball.y, ballRadius)
        end
    end
end
