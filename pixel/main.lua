local PixelLayer = {}
PixelLayer.__index = PixelLayer

function PixelLayer:new()
    return setmetatable({ pixels = {} }, self)
end

function PixelLayer:addPixel(x, y, color, parent)
    local pixel = {
        x = x,
        y = y,
        prevX = x,
        prevY = y,
        velocityX = 0,
        velocityY = 0,
        color = color,
        parent = parent,
        destroyed = false,
        active = false
    }
    table.insert(self.pixels, pixel)
    return pixel
end

function PixelLayer:addRectangle(x, y, width, height, color)
    local parent = { shape = "rectangle", x = x, y = y, width = width, height = height }
    for i = 0, width - 1 do
        for j = 0, height - 1 do
            self:addPixel(x + i, y + j, color, parent)
        end
    end
    print(string.format("Add rectangle at (%d, %d) of size %dx%d", x, y, width, height))
end

function PixelLayer:addCircle(x, y, radius, color)
    local parent = { shape = "circle", x = x, y = y, radius = radius }
    for i = -radius, radius do
        for j = -radius, radius do
            if i * i + j * j <= radius * radius then
                self:addPixel(x + i, y + j, color, parent)
            end
        end
    end
    print(string.format("Add circle at (%d, %d) of radius %d", x, y, radius))
end

function PixelLayer:addTriangle(x1, y1, x2, y2, x3, y3, color)
    local parent = { shape = "triangle", vertices = { {x1, y1}, {x2, y2}, {x3, y3} } }
    -- Barycentric coordinates method to fill the triangle
    local minX = math.min(x1, x2, x3)
    local maxX = math.max(x1, x2, x3)
    local minY = math.min(y1, y2, y3)
    local maxY = math.max(y1, y2, y3)
    
    local function sign(x, y, x2, y2, x3, y3)
        return (x - x3) * (y2 - y3) - (x2 - x3) * (y - y3)
    end

    for x = minX, maxX do
        for y = minY, maxY do
            local b1 = sign(x, y, x1, y1, x2, y2) < 0.0
            local b2 = sign(x, y, x2, y2, x3, y3) < 0.0
            local b3 = sign(x, y, x3, y3, x1, y1) < 0.0

            if (b1 == b2) and (b2 == b3) then
                self:addPixel(x, y, color, parent)
            end
        end
    end

    print(string.format("Add triangle with vertices (%d, %d), (%d, %d), (%d, %d)", x1, y1, x2, y2, x3, y3))
end


function nextitem(t)
    local item = table.remove(t,1)
    table.insert(t, item)
    return item
end

local disperse = 1

function PixelLayer:update(dt)
    local newPixels = {}
    for _, pixel in pairs(self.pixels) do
        if not pixel.destroyed then
            local dragFactor = math.max(0, 1 - dt)
            pixel.velocityX = pixel.velocityX * dragFactor
            pixel.velocityY = pixel.velocityY * dragFactor
            if pixel.velocityX ~= 0 or pixel.velocityY ~= 0 then
                pixel.active = true
                if toggleDisperse then
                    local angle = math.random(-disperse, disperse)
                    local cosAngle = math.cos(math.rad(angle))
                    local sinAngle = math.sin(math.rad(angle))
                    local newVelX = pixel.velocityX * cosAngle - pixel.velocityY * sinAngle
                    local newVelY = pixel.velocityX * sinAngle + pixel.velocityY * cosAngle
                    pixel.velocityX = newVelX
                    pixel.velocityY = newVelY
                end
            end
            local newX = pixel.x + (pixel.x - pixel.prevX) + pixel.velocityX * dt
            local newY = pixel.y + (pixel.y - pixel.prevY) + pixel.velocityY * dt

            if newX < 0 or newX > love.graphics.getWidth() or newY < 0 or newY > love.graphics.getHeight() then
                pixel.destroyed = true
            end

            pixel.prevX = pixel.x
            pixel.prevY = pixel.y
            pixel.x = newX
            pixel.y = newY
            table.insert(newPixels, pixel)
        end
        self.pixels = newPixels
    end
end


function PixelLayer:draw()
    for _, pixel in ipairs(self.pixels) do
        if not pixel.destroyed then
            love.graphics.setColor(pixel.color)
            love.graphics.points(pixel.x, pixel.y)
        end
    end
end

local layer = PixelLayer:new()
local cursorRadius = 50
local forceStrength = 2
local scale = 1
function love.load()
    
end

function love.update(dt)
    layer:update(dt)
end

function love.draw()
    layer:draw()

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), cursorRadius) -- cursor

    love.graphics.print("R: rectangle O: circle C: clear Space: disintegrate Arrows: radius and power [ and ]: scale", 10, 10)
    love.graphics.print("Pixels: " .. #layer.pixels, 10, 30)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 50)
    love.graphics.print("Cursor radius " .. cursorRadius,10, 70)
    love.graphics.print("Force strength " .. forceStrength,10, 90)
    love.graphics.print("Pixel disperse angle ±" .. disperse,10, 110)
end


function randomColor()
    local function rc()
        return math.floor(love.math.random() + 0.5)
    end
    local color
    repeat
        color = {rc(), rc(), rc(), 1}
    until color[1] ~= 0 or color[2] ~= 0 or color[3] ~= 0
    return color
end

function love.keypressed(key)
    if key == "r" then
        layer:addRectangle(love.math.random(50, 400), love.math.random(50, 400), love.math.random(10, 30)*10, love.math.random(10, 30)*10, randomColor())
    elseif key == "o" then
        layer:addCircle(love.math.random(50, 400), love.math.random(50, 400), love.math.random(5, 15)*10, randomColor())
    elseif key == "t" then
        layer:addTriangle(love.math.random(50, 400), love.math.random(50, 400), love.math.random(50, 400), love.math.random(50, 400), love.math.random(50, 400), love.math.random(50, 400), randomColor())
    elseif key == "c" then
        layer.pixels = {}
    elseif key == "up" then
        cursorRadius = cursorRadius + 5
    elseif key == "down" then
        cursorRadius = math.max(5, cursorRadius - 5)
    elseif key == "left" then
        forceStrength = math.max(0.5, forceStrength - 0.5)
    elseif key == "right" then
        forceStrength = forceStrength + 0.5
    elseif key == "[" then
        disperse = disperse - 1
    elseif key == "]" then
        disperse = disperse + 1
    elseif key == "escape" then
        love.event.quit()
    elseif key == "space" then
        toggleDisperse = not toggleDisperse
    end
end

function love.mousepressed(x, y, button)
    local radius = cursorRadius
    for _, pixel in ipairs(layer.pixels) do
        local dx, dy = x - pixel.x, y - pixel.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist <= radius then
            if button == 1 then -- Attract pixels inside cursor circle
                pixel.velocityX = pixel.velocityX + (dx / dist) * forceStrength
                pixel.velocityY = pixel.velocityY + (dy / dist) * forceStrength
            elseif button == 2 then -- Repel pixels inside cursor circle
                pixel.velocityX = pixel.velocityX - (dx / dist) * forceStrength
                pixel.velocityY = pixel.velocityY - (dy / dist) * forceStrength
            end
        end
    end
end
