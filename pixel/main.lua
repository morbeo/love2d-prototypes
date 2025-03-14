local objects = {} -- Initialize objects table

function createRectangle(x, y, width, height, velocityX, velocityY, color)
    local rectangle = { points = {}, color = color }

    -- Function to create a point
    local function createPoint(px, py, parent)
        return {
            x = px,
            y = py,
            prevX = px,
            prevY = py,
            velocityX = velocityX * 5, -- Increase initial velocity
            velocityY = velocityY * 5, -- Increase initial velocity
            color = color,
            parent = parent,
            destroyed = false -- Flag to determine if point is removed
        }
    end

    -- Create a grid of points instead of just corners
    for i = 0, width - 1 do
        for j = 0, height - 1 do
            table.insert(rectangle.points, createPoint(x + i, y + j, rectangle))
        end
    end

    return rectangle
end

function createCircle(x, y, radius, velocityX, velocityY, color)
    local circle = { points = {}, color = color }

    local function createPoint(px, py, parent)
        return {
            x = px,
            y = py,
            prevX = px,
            prevY = py,
            velocityX = velocityX * 5, -- Increase initial velocity
            velocityY = velocityY * 5, -- Increase initial velocity
            color = color,
            parent = parent,
            destroyed = false
        }
    end

    for i = -radius, radius do
        for j = -radius, radius do
            if i * i + j * j <= radius * radius then
                table.insert(circle.points, createPoint(x + i, y + j, circle))
            end
        end
    end

    return circle
end

function updateRectangle(rectangle, dt)
    for i = #rectangle.points, 1, -1 do
        local point = rectangle.points[i]
        if not point.destroyed then
            -- Apply drag to slow down to a halt in 1 second
            local dragFactor = math.max(0, 1 - dt)
            point.velocityX = point.velocityX * dragFactor
            point.velocityY = point.velocityY * dragFactor

            -- Verlet integration
            local newX = point.x + (point.x - point.prevX) + point.velocityX * dt
            local newY = point.y + (point.y - point.prevY) + point.velocityY * dt

            point.prevX = point.x
            point.prevY = point.y
            point.x = newX
            point.y = newY
        else
            table.remove(rectangle.points, i) -- Remove destroyed points
        end
    end
end

function drawRectangle(rectangle)
    for _, point in ipairs(rectangle.points) do
        if not point.destroyed then
            love.graphics.setColor(point.color)
            love.graphics.points(point.x, point.y)
        end
    end
end

function love.load()
    table.insert(objects, createRectangle(100, 100, 20, 20, 30, 30, {1, 0, 0}))
end

function love.update(dt)
    for _, obj in ipairs(objects) do
        updateRectangle(obj, dt)
    end
end

function love.draw()
    for _, obj in ipairs(objects) do
        drawRectangle(obj)
    end

    -- Draw cursor outline
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), 50)

    -- Draw pixel counter
    love.graphics.print("Pixels: " .. countPixels(), 10, 10)
end

function countPixels()
    local count = 0
    for _, obj in ipairs(objects) do
        for _, point in ipairs(obj.points) do
            if not point.destroyed then
                count = count + 1
            end
        end
    end
    return count
end

function love.mousepressed(x, y, button)
    local radius = 50
    for _, obj in ipairs(objects) do
        for _, point in ipairs(obj.points) do
            local dx, dy = x - point.x, y - point.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= radius then
                if button == 1 then -- Attract pixels inside cursor circle
                    point.velocityX = point.velocityX + (dx / dist) * 2
                    point.velocityY = point.velocityY + (dy / dist) * 2
                elseif button == 2 then -- Repel pixels inside cursor circle
                    point.velocityX = point.velocityX - (dx / dist) * 2
                    point.velocityY = point.velocityY - (dy / dist) * 2
                end
            end
        end
    end
end

function love.keypressed(key)
    if key == "r" then -- Random object
        local x, y = love.math.random(50, 400), love.math.random(50, 400)
        local w, h = love.math.random(100, 300), love.math.random(100, 300)
        local color = {love.math.random(), love.math.random(), love.math.random()}
        table.insert(objects, createRectangle(x, y, w, h, 0, 0, color))
    elseif key == "c" then -- Clear all objects
        objects = {}
    elseif key == "o" then -- Create random circle
        local x, y = love.math.random(50, 400), love.math.random(50, 400)
        local radius = love.math.random(5, 15)
        local color = {love.math.random(), love.math.random(), love.math.random()}
        table.insert(objects, createCircle(x, y, radius, 0, 0, color))
    end
end

