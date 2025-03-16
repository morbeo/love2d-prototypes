-- love2d fetch game prototype

local player = {x = 5, y = 5, speed = 200, lastDirX = 1, lastDirY = 1}
local dog = {x = 8, y = 8, speed = 150, targetX = 8, targetY = 8, hasBall = false}
local ball = {x = 10, y = 10, thrown = false, throwDistance = 3}
local gridSize = 32
local gridWidth, gridHeight = 20, 20
local throwHoldTime = 0
local throwIndicator = {x = 0, y = 0, visible = false}

function love.load()
    love.window.setTitle("Fetch Game")
    love.window.setMode(1024, 768)
end

function love.update(dt)
    movePlayer(dt)
    moveDog(dt)
    updateThrow(dt)
end

function movePlayer(dt)
    local dirX, dirY = 0, 0
    if love.keyboard.isDown("up") then dirY = dirY - 1 end
    if love.keyboard.isDown("down") then dirY = dirY + 1 end
    if love.keyboard.isDown("left") then dirX = dirX - 1 end
    if love.keyboard.isDown("right") then dirX = dirX + 1 end

    local magnitude = math.sqrt(dirX^2 + dirY^2)
    if magnitude > 0 then
        player.x = math.max(1, math.min(gridWidth, player.x + (dirX / magnitude) * player.speed * dt / gridSize))
        player.y = math.max(1, math.min(gridHeight, player.y + (dirY / magnitude) * player.speed * dt / gridSize))
        player.lastDirX, player.lastDirY = dirX / magnitude, dirY / magnitude
    end
end

function moveDog(dt)
    if ball.thrown then
        dog.targetX, dog.targetY = ball.x, ball.y
    elseif dog.hasBall then
        dog.targetX, dog.targetY = player.x, player.y
    end
    
    local dx, dy = dog.targetX - dog.x, dog.targetY - dog.y
    if math.abs(dx) > 0.1 or math.abs(dy) > 0.1 then
        local dist = math.sqrt(dx^2 + dy^2)
        dog.x = dog.x + (dx / dist) * dog.speed * dt / gridSize
        dog.y = dog.y + (dy / dist) * dog.speed * dt / gridSize
    else
        if ball.thrown then
            dog.hasBall = true
            ball.thrown = false
        elseif dog.hasBall and math.abs(dog.x - player.x) < 0.1 and math.abs(dog.y - player.y) < 0.1 then
            dog.hasBall = false
            ball.x, ball.y = player.x, player.y
        end
    end
end


function updateThrow(dt)
    if love.keyboard.isDown("space") and not ball.thrown and not dog.hasBall then
        throwHoldTime = throwHoldTime + dt
        local distance = math.min(ball.throwDistance + throwHoldTime * 5, 10)
        throwIndicator.x, throwIndicator.y = player.x + player.lastDirX * distance, player.y + player.lastDirY * distance
        throwIndicator.visible = true
    else
        if throwHoldTime > 0 then
            ball.x, ball.y = throwIndicator.x, throwIndicator.y
            ball.thrown = true
        end
        throwHoldTime = 0
        throwIndicator.visible = false
    end
end

function love.draw()
    drawGrid()
    drawEntity(player, {0, 0, 1})
    drawEntity(dog, {1, 0.5, 0})
    if not dog.hasBall then drawBall() end
    if throwIndicator.visible then drawThrowIndicator() end
end

function drawGrid()
    love.graphics.setColor(0.8, 0.8, 0.8)
    for x = 0, gridWidth do
        for y = 0, gridHeight do
            local screenX, screenY = toIsometric(x, y)
            love.graphics.line(screenX, screenY, screenX + gridSize / 2, screenY + gridSize / 4)
            love.graphics.line(screenX, screenY, screenX - gridSize / 2, screenY + gridSize / 4)
        end
    end
end

function drawEntity(entity, color)
    love.graphics.setColor(color)
    local screenX, screenY = toIsometric(entity.x, entity.y)
    love.graphics.rectangle("fill", screenX - gridSize / 4, screenY - gridSize / 8, gridSize / 2, gridSize / 4)
end

function drawBall()
    love.graphics.setColor(1, 0, 0)
    local screenX, screenY = toIsometric(ball.x, ball.y)
    love.graphics.circle("fill", screenX, screenY, 6)
end

function drawThrowIndicator()
    love.graphics.setColor(0, 1, 0, 0.5)
    local screenX, screenY = toIsometric(throwIndicator.x, throwIndicator.y)
    love.graphics.circle("fill", screenX, screenY, 5)
end

function toIsometric(x, y)
    local screenX = (x - y) * (gridSize / 2) + 512
    local screenY = (x + y) * (gridSize / 4) + 100
    return screenX, screenY
end
