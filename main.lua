local function lerp(a, b, t)
    return a + (b - a) * t
end

Pixelized = {}

function Pixelized.new(image, positionX , positionY, duration)
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
        duration = duration or 1, -- default duration to 1 second if not provided
        timer = 0,
        state = "assembled",
        disintegrateTimer = 0
    }
    setmetatable(instance, { __index = Pixelized })
    for y = 0, imgHeight - 1 do
        for x = 0, imgWidth - 1 do
            local r, g, b, a = imageData:getPixel(x, y)
            if a > 0 then
                table.insert(instance.pixels, {
                    image = { x = x, y = y },
                    global = { x = x + positionX, y = y + positionY },
                    last = { x = x + positionX, y = y + positionY },
                    target = { x = x + positionX, y = y + positionY },
                    color = { r = r, g = g, b = b, a = a }
                })
            end
        end
    end
    return instance
end

function Pixelized:draw()
    love.graphics.print("X "..self.x.." Y "..self.y, 20, 0)
    love.graphics.print("state "..self.state, 20, 20)
    love.graphics.print("timer "..self.timer, 20, 40)
    love.graphics.print("disintegrateTimer "..self.disintegrateTimer, 20, 60)

    -- draw bounding box
    love.graphics.rectangle("line", self.x , self.y, self.imgWidth, self.imgHeight)

    local r, g, b, a = love.graphics.getColor() -- Save current color
    if self.state == "assembled" or self.state == "move" then
        love.graphics.draw(self.image, self.x, self.y)
    else
        for _, p in ipairs(self.pixels) do
            love.graphics.setColor(p.color.r, p.color.g, p.color.b, p.color.a)
            love.graphics.points(p.global.x, p.global.y)
        end
    end
    love.graphics.setColor(r, g, b, a) -- Restore color
end

function Pixelized:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
    end
    if self.state ~= "assembled" then
        self.disintegrateTimer = self.disintegrateTimer + dt
    end
    if self.timer > self.duration / 2 then
        if self.disintegrateTimer > 0 then
            self.state = "disintegrate"
        end
    elseif self.timer < self.duration / 2 then
        if self.timer <= 0 then
            self.timer = 0
            self.disintegrateTimer = 0
            self.state = "assembled"
        else
            if self.state == "disintegrate" then
                self.state = "reform"
                for _, p in ipairs(self.pixels) do
                    p.target.x = self.x + p.image.x
                    p.target.y = self.y + p.image.y
                end
            end
        end
    end
    for _, p in ipairs(self.pixels) do
        p.last.x = p.global.x
        p.last.y = p.global.y
        if self.state == "disintegrate" then
            p.global.x = lerp(p.global.x, p.target.x, math.sqrt(dt / self.duration))
            p.global.y = lerp(p.global.y, p.target.y, math.sqrt(dt / self.duration))
        -- elseif self.state == "move" then
        --     p.global.x = lerp(p.global.x, p.target.x, math.sqrt(dt / self.timer))
        --     p.global.y = lerp(p.global.y, p.target.y, math.sqrt(dt / self.timer))
        else
            p.global.x = lerp(p.global.x, self.x + p.image.x, math.sqrt(dt / self.duration))
            p.global.y = lerp(p.global.y, self.y + p.image.y, math.sqrt(dt / self.duration))
        end
        if p.global.x == p.target.x and p.global.y == p.target.y then
            self.disintegrateTimer = 0
        end
    end
end

function Pixelized:moveabsolute(x, y, duration)
    self.state = "reform"
    if self.timer > 0 then
        self.timer = self.timer + love.timer.getAverageDelta()
    else
        self.timer = duration or self.duration
    end
    self.x = x
    self.y = y
    for _, p in ipairs(self.pixels) do
        p.target.x = p.image.x + x
        p.target.y = p.image.y + y
    end
end

function Pixelized:moverelative(x, y, duration)
    self.state = "move"
    if self.timer > 0 then
        self.timer = self.timer + love.timer.getAverageDelta()
    else
        self.timer = duration or self.duration
    end
    self.x = self.x + x
    self.y = self.y + y
    for _, p in ipairs(self.pixels) do
        p.target.x = p.global.x + x
        p.target.y = p.global.y + y
    end
end

function Pixelized:teleport(x, y, duration)
    self.state = "disintegrate"
    self.timer = duration or self.duration
    local distance = math.sqrt(( self.x - x )^2 + ( self.y - y )^2)
    self.x = x - self.imgWidth / 2
    self.y = y - self.imgHeight / 2
    for _,p in ipairs(self.pixels) do
        local angle = math.random() * 2 * math.pi
        local radius = math.random() * distance
        p.target.x = p.global.x + radius * math.cos(angle) - self.imgWidth / 2
        p.target.y = p.global.y + radius * math.sin(angle) - self.imgHeight / 2
    end
end

function Pixelized:moverandom(distance, duration, shape)
    self.state = "disintegrate"
    self.timer = duration or self.duration
    shape = shape or "circle" -- default to square if no shape is provided

    self.x = self.x + math.random(-distance,distance) - self.imgWidth / 2
    self.y = self.y + math.random(-distance,distance) - self.imgHeight / 2
    for _,p in ipairs(self.pixels) do
        local angle = math.random() * 2 * math.pi
        local radius = math.random() * distance
        p.target.x = p.global.x + radius * math.cos(angle) - self.imgWidth / 2
        p.target.y = p.global.y + radius * math.sin(angle) - self.imgHeight / 2
    end
end

function Pixelized:input(key)
    local speed = 10
    local duration = 0.5
    local keyActions = {
        escape = function() love.event.quit() end,
        space = function() self:moverandom(100,1,"circle") end,
        up = function() Tank:moverelative(0, -speed, duration) end,
        down = function() Tank:moverelative(0, speed, duration) end,
        left = function() Tank:moverelative(-speed, 0, duration) end,
        right = function() Tank:moverelative(speed, 0, duration) end,
        t = function() Tank:teleport(400, 400) end,
        r = function() Tank:moveabsolute(100, 100) end
    }
    if keyActions[key] then
        keyActions[key]()
    end
end

function love.load()
    Tank = Pixelized.new("horror.png", 200, 200) -- Set duration to 2 seconds
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