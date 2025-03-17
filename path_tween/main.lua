local function bezierPath(startVec, apexDistance, endVec, duration)
    local midVec = {x = (startVec.x + endVec.x) / 2, y = (startVec.y + endVec.y) / 2}
    local apexVec = {x = midVec.x, y = midVec.y - apexDistance}

    local function quadraticBezier(t, p0, p1, p2)
        local u = 1 - t
        return {
            x = u * u * p0.x + 2 * u * t * p1.x + t * t * p2.x,
            y = u * u * p0.y + 2 * u * t * p1.y + t * t * p2.y
        }
    end

    return {
        duration = duration,
        getPosition = function(t)
            return quadraticBezier(t, startVec, apexVec, endVec)
        end
    }
end

local easingFunctions

local function loadEasingFunctions()
    easingFunctions = {
        linear = function(t) return t end,
        easeInSine = function(t) return 1 - math.cos((t * math.pi) / 2) end,
        easeOutSine = function(t) return math.sin((t * math.pi) / 2) end,
        easeInOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end,
        easeOutInSine = function(t) return (math.sin(math.pi * t) + 1) / 2 end,
        easeInQuad = function(t) return t * t end,
        easeOutQuad = function(t) return t * (2 - t) end,
        easeInOutQuad = function(t)
            if t < 0.5 then return 2 * t * t end
            return -1 + (4 - 2 * t) * t
        end,
        easeInCubic = function(t) return t * t * t end,
        easeOutCubic = function(t) return (t - 1)^3 + 1 end,
        easeInOutCubic = function(t)
            if t < 0.5 then return 4 * t^3 end
            return (t - 1) * (2 * t - 2)^2 + 1
        end,
        easeInQuart = function(t) return t^4 end,
        easeOutQuart = function(t) return 1 - (t - 1)^4 end,
        easeInOutQuart = function(t)
            if t < 0.5 then return 8 * t^4 end
            return 1 - 8 * (t - 1)^4
        end,
        easeInQuint = function(t) return t^5 end,
        easeOutQuint = function(t) return 1 + (t - 1)^5 end,
        easeInOutQuint = function(t)
            if t < 0.5 then return 16 * t^5 end
            return 1 + 16 * (t - 1)^5
        end,
        easeInExpo = function(t) return (t == 0) and 0 or 2^(10 * (t - 1)) end,
        easeOutExpo = function(t) return (t == 1) and 1 or 1 - 2^(-10 * t) end,
        easeInOutExpo = function(t)
            if t == 0 then return 0 end
            if t == 1 then return 1 end
            if t < 0.5 then return 2^(20 * t - 10) / 2 end
            return (2 - 2^(-20 * t + 10)) / 2
        end,
        easeInCirc = function(t) return 1 - math.sqrt(1 - t^2) end,
        easeOutCirc = function(t) return math.sqrt(1 - (t - 1)^2) end,
        easeInOutCirc = function(t)
            if t < 0.5 then return (1 - math.sqrt(1 - 4 * t^2)) / 2 end
            return (math.sqrt(1 - (2 * t - 2)^2) + 1) / 2
        end,
        easeInBack = function(t) local c1 = 1.70158; local c3 = c1 + 1; return c3 * t^3 - c1 * t^2; end,
        easeOutBack = function(t) local c1 = 1.70158; local c3 = c1 + 1; return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2 end,
        easeInOutBack = function(t)
            local c1 = 1.70158 * 1.525
            if t < 0.5 then return ((2 * t)^2 * ((c1 + 1) * 2 * t - c1)) / 2 end
            return ((2 * t - 2)^2 * ((c1 + 1) * (t * 2 - 2) + c1) + 2) / 2
        end,
        easeInBounce = function(t) return 1 - easingFunctions.easeOutBounce(1 - t) end,
        easeOutBounce = function(t)
            local n1, d1 = 7.5625, 2.75
            if t < 1 / d1 then return n1 * t * t
            elseif t < 2 / d1 then t = t - 1.5 / d1; return n1 * t * t + 0.75
            elseif t < 2.5 / d1 then t = t - 2.25 / d1; return n1 * t * t + 0.9375
            else t = t - 2.625 / d1; return n1 * t * t + 0.984375 end
        end,
        easeInOutBounce = function(t)
            if t < 0.5 then return (1 - easingFunctions.easeOutBounce(1 - 2 * t)) / 2 end
            return (1 + easingFunctions.easeOutBounce(2 * t - 1)) / 2
        end
    }
end

loadEasingFunctions()


local easingFunctionNames = {}
for name in pairs(easingFunctions) do
    table.insert(easingFunctionNames, name)
end

table.sort(easingFunctionNames)
local currentEasingIndex = 1
local easing = easingFunctions[easingFunctionNames[currentEasingIndex]]

local start = {x = 100, y = 400}
local apexDistance = 150
local finish = {x = 500, y = 400}

local paths = {
    bezierPath(start, apexDistance, finish, 2.0),
    bezierPath({x = start.x, y = start.y + 100}, 0, {x = finish.x, y = finish.y + 100}, 2.0),
    bezierPath({x = 300, y = 200}, apexDistance, {x = 300, y = 200}, 2.0)
}

local canvas, easingCanvas
local timer = 0

function love.load()
    canvas = love.graphics.newCanvas(600, 500)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1, 0.5)
    for _, path in ipairs(paths) do
        local points = {}
        for t = 0, 1, 0.01 do
            local pos = path.getPosition(t)
            table.insert(points, pos.x)
            table.insert(points, pos.y)
        end
        love.graphics.line(points)
    end

    easingCanvas = love.graphics.newCanvas(120, 120)
    updateEasingCanvas()

    love.graphics.setCanvas()
end

function updateEasingCanvas()
    love.graphics.setCanvas(easingCanvas)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 10, 10, 100, 100)
    for i = 0, 100 do
        local et = easing(i / 100)
        love.graphics.points(10 + i, 110 - et * 100)
    end

    love.graphics.setCanvas()
end

function love.update(dt)
    timer = timer + dt
    if timer > paths[1].duration then
        timer = timer - paths[1].duration
    end
end

function love.draw()
    love.graphics.draw(canvas)

    local t = (timer / paths[1].duration) % 1
    local easedT = easing(t)

    for _, path in ipairs(paths) do
        local circlePos = path.getPosition(easedT)
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", circlePos.x, circlePos.y, 10)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Easing: " .. currentEasingIndex .. " - " .. easingFunctionNames[currentEasingIndex], 10, 10)

    love.graphics.draw(easingCanvas, 470, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "up" then
        currentEasingIndex = currentEasingIndex % #easingFunctionNames + 1
        easing = easingFunctions[easingFunctionNames[currentEasingIndex]]
        updateEasingCanvas()
    elseif key == "down" then
        currentEasingIndex = (currentEasingIndex - 2) % #easingFunctionNames + 1
        easing = easingFunctions[easingFunctionNames[currentEasingIndex]]
        updateEasingCanvas()
    end
end
