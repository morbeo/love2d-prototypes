function love.load()
    -- Screen dimensions
    love.window.setMode(800, 600)

    -- Circle properties
    circle = { x = 0, y = 0, radius = 20 }

    -- Animation parameters
    startX, startY = 100, 500
    endX, endY = 700, 500
    peakHeight = 100 -- How high the arc should go
    duration = 2 -- Duration in seconds
    t = 0 -- Animation progress
    animationActive = true -- Is the ball moving?

    -- Cache for trajectory canvases
    trajectoryCache = {}

    -- Precompute trajectory points and draw it on the canvas
    trajectoryCanvas = getTrajectoryCanvas(peakHeight, duration)
end

-- Function to compute a quadratic Bézier curve point
function calculateBezierPoint(t, x1, y1, x2, y2, peakHeight)
    local peakX = (x1 + x2) / 2
    local peakY = math.min(y1, y2) - peakHeight -- Control point at the peak

    local u = 1 - t
    local x = u^2 * x1 + 2 * u * t * peakX + t^2 * x2
    local y = u^2 * y1 + 2 * u * t * peakY + t^2 * y2

    return x, y
end

-- Function to check cache or create a new trajectory canvas
function getTrajectoryCanvas(peakHeight, duration)
    -- Convert float duration to string-friendly format (rounded for better caching)
    local durationKey = string.format("%.1f", duration)

    -- Check if the canvas for this peakHeight and duration already exists
    if trajectoryCache[peakHeight] and trajectoryCache[peakHeight][durationKey] then
        return trajectoryCache[peakHeight][durationKey]
    end

    -- If not cached, create a new canvas
    local newCanvas = love.graphics.newCanvas(800, 600)
    love.graphics.setCanvas(newCanvas)
    love.graphics.clear()

    -- Draw the trajectory path
    love.graphics.setColor(0, 1, 0) -- Green color for trajectory
    local segments = 50
    for i = 0, segments do
        local t = i / segments
        local x, y = calculateBezierPoint(t, startX, startY, endX, endY, peakHeight)
        love.graphics.circle("fill", x, y, 3)
    end

    -- Draw key trajectory points
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", startX, startY, 5)
    love.graphics.circle("fill", (startX + endX) / 2, math.min(startY, endY) - peakHeight, 5)
    love.graphics.circle("fill", endX, endY, 5)

    love.graphics.setCanvas() -- Reset to the default canvas

    -- Store in cache
    if not trajectoryCache[peakHeight] then
        trajectoryCache[peakHeight] = {}
    end
    trajectoryCache[peakHeight][durationKey] = newCanvas

    return newCanvas
end

-- Function to update the trajectory when parameters change
function updateTrajectory()
    trajectoryCanvas = getTrajectoryCanvas(peakHeight, duration)
    t = 0
    animationActive = true
end

function love.update(dt)
    -- If animation is active, update the ball's position
    if animationActive and t < 1 then
        t = t + dt / duration -- Normalize time based on duration
        circle.x, circle.y = calculateBezierPoint(t, startX, startY, endX, endY, peakHeight)
    elseif t >= 1 then
        animationActive = false -- Stop animation when it completes
    end
end

function love.draw()
    -- Draw the trajectory from the cached canvas
    love.graphics.draw(trajectoryCanvas, 0, 0)

    -- Draw the moving circle
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", circle.x, circle.y, circle.radius)

    -- Display ball information in the upper left
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Ball Information:", 10, 10)
    love.graphics.print("Peak Height: " .. peakHeight, 10, 30)
    love.graphics.print("Duration: " .. string.format("%.2f", duration) .. "s", 10, 50)
    love.graphics.print("Ball Position: (" .. string.format("%.1f", circle.x) .. ", " .. string.format("%.1f", circle.y) .. ")", 10, 70)
    love.graphics.print("Press SPACE to throw again", 10, 100)
    love.graphics.print("Use UP/DOWN to change height", 10, 120)
    love.graphics.print("Use LEFT/RIGHT to change duration", 10, 140)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit() -- Exit the game
    elseif key == "space" then
        updateTrajectory() -- Restart animation
    elseif key == "up" then
        peakHeight = peakHeight + 50 -- Increase peak height
        updateTrajectory()
    elseif key == "down" then
        peakHeight = math.max(10, peakHeight - 50) -- Decrease peak height (min 10)
        updateTrajectory()
    elseif key == "right" then
        duration = duration + 0.2 -- Increase duration
        updateTrajectory()
    elseif key == "left" then
        duration = math.max(0.2, duration - 0.2) -- Decrease duration (min 0.2s)
        updateTrajectory()
    end
end

