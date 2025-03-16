-- Load Love2D modules
love.physics = require("love.physics")

-- Define player properties
local player = {
    x = 100,
    y = 100,
    width = 20,
    height = 20,
    speed = 200,
    jumpPower = -300,
    doubleJumpPower = -250,
    canJump = false,
    canDoubleJump = false,
    grappling = false,
    hook = nil,
    velocityX = 0,
    velocityY = 0
}

-- Define world properties
local world
local objects = {}

function love.load()
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    world = love.physics.newWorld(0, 800, true)

    -- Create ground
    objects.ground = {}
    objects.ground.body = love.physics.newBody(world, 400, 580, "static")
    objects.ground.shape = love.physics.newRectangleShape(800, 40)
    objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
    
    -- Create platforms
    objects.platforms = {}
    local platformPositions = {{300, 450}, {500, 350}, {700, 250}}
    for i, pos in ipairs(platformPositions) do
        local platform = {}
        platform.body = love.physics.newBody(world, pos[1], pos[2], "static")
        platform.shape = love.physics.newRectangleShape(100, 20)
        platform.fixture = love.physics.newFixture(platform.body, platform.shape)
        table.insert(objects.platforms, platform)
    end
    
    -- Create walls
    objects.walls = {}
    local wallPositions = {{150, 500}, {650, 300}}
    for i, pos in ipairs(wallPositions) do
        local wall = {}
        wall.body = love.physics.newBody(world, pos[1], pos[2], "static")
        wall.shape = love.physics.newRectangleShape(20, 100)
        wall.fixture = love.physics.newFixture(wall.body, wall.shape)
        table.insert(objects.walls, wall)
    end
    
    -- Create player physics body
    player.body = love.physics.newBody(world, player.x, player.y, "dynamic")
    player.shape = love.physics.newRectangleShape(player.width, player.height)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setFixedRotation(true)
end

function love.update(dt)
    world:update(dt)
    handleInput(dt)
end

function handleInput(dt)
    local vx, vy = player.body:getLinearVelocity()
    
    -- Left and Right Movement
    if love.keyboard.isDown("left") then
        player.body:setLinearVelocity(-player.speed, vy)
    elseif love.keyboard.isDown("right") then
        player.body:setLinearVelocity(player.speed, vy)
    end
    
    -- Jumping
    if love.keyboard.isDown("w") then
        if player.canJump then
            player.body:setLinearVelocity(vx, player.jumpPower)
            player.canJump = false
            player.canDoubleJump = true
        elseif player.canDoubleJump then
            player.body:setLinearVelocity(vx, player.doubleJumpPower)
            player.canDoubleJump = false
        end
    end
    
    -- Grappling Hook Targeting
    if love.keyboard.isDown("e") and not player.grappling then
        local px, py = player.body:getPosition()
        local hookX, hookY = px, py
        
        if love.keyboard.isDown("up") then hookY = hookY - 100 end
        if love.keyboard.isDown("down") then hookY = hookY + 100 end
        if love.keyboard.isDown("left") then hookX = hookX - 100 end
        if love.keyboard.isDown("right") then hookX = hookX + 100 end
        
        player.grappling = true
        player.hook = {x = hookX, y = hookY}
    end
    
    if player.grappling then
        local px, py = player.body:getPosition()
        local angle = math.atan2(player.hook.y - py, player.hook.x - px)
        local forceX = math.cos(angle) * 500
        local forceY = math.sin(angle) * 500
        player.body:applyForce(forceX, forceY)
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
    love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
    
    -- Draw platforms
    for _, platform in ipairs(objects.platforms) do
        love.graphics.polygon("fill", platform.body:getWorldPoints(platform.shape:getPoints()))
    end
    
    -- Draw walls
    for _, wall in ipairs(objects.walls) do
        love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
    end
    
    -- Draw grappling hook
    if player.grappling then
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(player.body:getX(), player.body:getY(), player.hook.x, player.hook.y)
    end
end

function love.keyreleased(key)
    if key == "e" then
        player.grappling = false
    elseif key == "escape" then
        love.event.quit()
    end
end
