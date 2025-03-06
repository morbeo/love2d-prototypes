---@diagnostic disable: duplicate-set-field

local function lerp(a, b, t)
    return a * (1 - t) + b * t
end

local function createPixel(x, y, r, g, b, a, positionX, positionY)
    return {
        image = { x = x, y = y },
        global = { x = x + positionX, y = y + positionY },
        last = { x = x + positionX, y = y + positionY },
        target = { x = x + positionX, y = y + positionY },
        color = { r = r, g = g, b = b, a = a }
    }
end

Pixelized = {}

function Pixelized.new(image, positionX, positionY, duration)
    local imageData = love.image.newImageData(image)
    local imgWidth, imgHeight = imageData:getDimensions()
    local instance = {
        x = positionX,
        y = positionY,
        target = { x = positionX, y = positionY },
        image = love.graphics.newImage(imageData),
        imageData = imageData,
        imgWidth = imgWidth,
        imgHeight = imgHeight,
        pixels = {},
        duration = duration or 1,
        elapsed = 0,
        state = "assembled",
        disintegrated = 0,
        lerp_speed = 0.5,
        speed = 10
    }
    setmetatable(instance, { __index = Pixelized })
    for y = 0, imgHeight - 1 do
        for x = 0, imgWidth - 1 do
            local r, g, b, a = imageData:getPixel(x, y)
            if a > 0 then
                table.insert(instance.pixels, createPixel(x, y, r, g, b, a, positionX, positionY))
            end
        end
    end
    return instance
end

function Pixelized:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.print("source X " .. self.x .. "  source Y " .. self.y, 5, 0)
    love.graphics.print("target X " .. self.target.x .. "  target Y " .. self.target.y, 5, 15)
    love.graphics.print("state " .. self.state, 5, 30)
    love.graphics.print("lerp_speed " .. self.lerp_speed, 5, 45)
    love.graphics.print("elapsed " .. self.elapsed, 5, 60)
    love.graphics.print("disintegrated " .. self.disintegrated, 5, 75)

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.imgWidth, self.imgHeight)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("line", self.target.x, self.target.y, self.imgWidth, self.imgHeight)

    love.graphics.setColor(r, g, b, a)
    if self.state == "assembled" or self.state == "move" then
        love.graphics.draw(self.image, self.x, self.y)
    else
        for _, p in ipairs(self.pixels) do
            love.graphics.setColor(p.color.r, p.color.g, p.color.b, p.color.a)
            love.graphics.points(p.global.x, p.global.y)
        end
    end
    love.graphics.setColor(r, g, b, a)
end

function Pixelized:update(dt)
    if self.state ~= "assembled" then
        self.elapsed = self.elapsed + dt
    else
        if self.x ~= self.target.x or self.y ~= self.target.y then
            self.state = "move"
        end
        self.elapsed = 0
    end

    local progress = math.min(self.elapsed * self.lerp_speed / self.duration, 1)

    if self.state == "move" then
        self.x = lerp(self.x, self.target.x, progress)
        self.y = lerp(self.y, self.target.y, progress)
        if progress >= 1 then
            self.state = "assembled"
        end
    end

    if self.state == "disintegrated" then
        self.disintegrated = self.disintegrated + dt
        if self.elapsed >= 0.5 then
            self.state = "reform"
            self.disintegrated = 0
        end
    end

    if self.state == "reform" then
        --if self.elapsed >= 0.5 then
            self.x = lerp(self.x, self.target.x, progress)
            self.y = lerp(self.y, self.target.y, progress)
            if self.elapsed >= self.duration then
                self.state = "assembled"
            end
        -- end
    end

    for _, p in ipairs(self.pixels) do
        p.last.x = p.global.x
        p.last.y = p.global.y
        if self.disintegrated > 0 then
            p.global.x = lerp(p.global.x, p.target.x, progress)
            p.global.y = lerp(p.global.y, p.target.y, progress)
        else
            p.global.x = lerp(p.global.x, self.target.x + p.image.x, progress^2)
            p.global.y = lerp(p.global.y, self.target.y + p.image.y, progress^2)
        end
    end
end

function Pixelized:moveabsolute(x, y, duration)
    self.state = "reform"
    self.elapsed = 0
    self.target.x = x
    self.target.y = y
    for _, p in ipairs(self.pixels) do
        p.target.x = p.image.x + x
        p.target.y = p.image.y + y
    end
end

function Pixelized:teleport(x, y)
    self.state = "disintegrated"
    self.elapsed = 0
    local distance = math.sqrt((self.x - x)^2 + (self.y - y)^2)
    self.target.x = x - self.imgWidth / 2
    self.target.y = y - self.imgHeight / 2
    for _, p in ipairs(self.pixels) do
        local angle = math.random() * 2 * math.pi
        local radius = math.random(-distance, distance)
        p.target.x = p.global.x + radius * math.cos(angle) + self.lerp_speed^(radius/distance)
        p.target.y = p.global.y + radius * math.sin(angle) + self.lerp_speed^(radius/distance)
    end
end

function Pixelized:moverandom(distance)
    local x = self.x + math.random(-distance, distance)
    local y = self.y + math.random(-distance, distance)
    self:teleport(x, y)
end

function Pixelized:input(key)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if love.keyboard.isDown("space") then
        self:moverandom(10 * self.speed)
    end
    if love.keyboard.isDown("up") then
        self.target.y = self.target.y - self.speed
    end
    if love.keyboard.isDown("down") then
        self.target.y = self.target.y + self.speed
    end
    if love.keyboard.isDown("left") then
        self.target.x = self.target.x - self.speed
    end
    if love.keyboard.isDown("right") then
        self.target.x = self.target.x + self.speed
    end
    if love.keyboard.isDown("t") then
        self:teleport(400, 400)
    end
    if love.keyboard.isDown("e") then
        self.lerp_speed = self.lerp_speed + 0.1
    end
    if love.keyboard.isDown("d") then
        self.lerp_speed = self.lerp_speed - 0.1
    end
    if love.keyboard.isDown("r") then
        self:moveabsolute(100, 100)
    end
end

function love.load()
    love.keyboard.setKeyRepeat( true )
    Tank = Pixelized.new("bullseye.png", 200, 200)
end

function love.update(dt)
    Tank:update(dt)
end

function love.draw()
    Tank:draw()
end

function love.keypressed(key)
    Tank:input(key)
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        Tank:teleport(x, y)
    end
end