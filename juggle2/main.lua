
Projectile = {}
Projectile.__index = Projectile
Projectile.pool = {}

function Projectile.new(name)
    local projectile = {}
    projectile.name = name
    projectile.position = {x = nil, y = nil}
    projectile.direction = {x = 0, y = 0}
    projectile.speed = 0
    projectile.active = false
    projectile.pool = {}
    setmetatable(projectile, Projectile)
    return projectile
end

function Projectile:spawn(start, direction, speed)
    for _, p in ipairs(self) do
        if not p.active then
            p.position = start
            p.direction = direction
            p.speed = speed
            p.active = true
            break
        end
    end
end

function Projectile:update(dt)
    for _, p in ipairs(self.pool) do
        if p.active then
            p.position.x = p.position.x + p.direction.x * p.speed * dt
            p.position.y = p.position.y + p.direction.y * p.speed * dt
        end
    end
end

function Projectile:render()
    for _, p in ipairs(self.pool) do
        if p.active then
            love.graphics.circle("fill", p.position.x, p.position.y, 5)
        end
    end
end

Throw = {}
Throw.__index = Throw

function Throw.new(start, target, projectile)
    local throw = {}
    setmetatable(throw, Throw)

    throw.start = start
    throw.target = target
    throw.projectile = projectile
    throw.control = {(start[1] + target[1]) / 2, math.min(start[2], target[2]) - 100}
    throw.bezier = love.math.newBezierCurve(start[1], start[2], throw.control[1], throw.control[2], target[1], target[2])
    throw.t = 0

    return throw
end

function Throw:update(dt)
    if self.t < 1 then
        self.t = self.t + dt
        if self.t > 1 then self.t = 1 end
    end
end

function Throw:evaluate()
    return self.bezier:evaluate(self.t)
end

function Throw:render()
    local curvePoints = self.bezier:render(5)
    for i = 1, #curvePoints, 2 do
        -- love.graphics.circle("fill", curvePoints[i], curvePoints[i + 1], 2)
        love.graphics.points(curvePoints[i], curvePoints[i + 1])
    end
end

Game = {}
Game.__index = Game

function Game.new()
    local game = {}
    setmetatable(game, Game)
    game.width, game.height = love.graphics.getDimensions()
    game.paused = false
    game.timeScale = 1 -- Control the flow of time
    game.throw = nil
    game.projectile = Projectile.new('ball')
    game.circle = {x = game.width / 2, y = game.height / 2, radius = 10}

    return game
end

function Game:testBall()
    self.projectile:spawn({x = 100, y = 100}, {x = 1, y = 1}, 100)
end

function Game:update(dt)
    if not self.paused and self.throw then
        self.throw:update(dt * self.timeScale)
        if self.throw.t < 1 then
            self.circle.x, self.circle.y = self.throw:evaluate()
        else
            self.paused = false
        end
    end
    self.projectile:update(dt * self.timeScale)
end

function Game:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Timescale " .. self.timeScale, 10, self.height - 20)

    if self.paused then
        self:drawPause()
    else
        self:drawPlay()
    end

    if self.paused and self.throw then
        love.graphics.setColor(1, 0, 0)
        self.throw:render()
    end

    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", self.circle.x, self.circle.y, self.circle.radius)

    self.projectile:render()
end

function Game:mousepressed(x, y, button)
    if button == 1 then
        self.throw = Throw.new({self.circle.x, self.circle.y}, {x, y}, self.projectile)
    end
end

function Game:drawPause()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", love.graphics.getWidth() - 32, 10, 10, 30)
    love.graphics.rectangle("fill", love.graphics.getWidth() - 20, 10, 10, 30)
    love.graphics.print("Press SPACE to resume", 10, 10)
end

function Game:drawPlay()
    love.graphics.polygon("fill", love.graphics.getWidth() - 32, 10, love.graphics.getWidth() - 32, 40, love.graphics.getWidth() - 2, 25)
end

function Game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        self.paused = not self.paused
    elseif key == "1" then
        self.timeScale = self.timeScale * 0.5 -- Slow motion
    elseif key == "2" then
        self.timeScale = 1 -- Normal speed
    elseif key == "3" then
        self.timeScale = self.timeScale * 2 -- Fast forward
    elseif key == "s" then
        self:testBall()
    end
end

local game

function love.load()
    love.window.setTitle("Bezier Curve Parabolic Movement")
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    game = Game.new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
end

function love.keypressed(key)
    game:keypressed(key)
end

