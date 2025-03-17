local function bezierPath(startVec, apexVec, endVec, duration)
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
            t = math.min(math.max(t, 0), 1)
            return quadraticBezier(t, startVec, apexVec, endVec)
        end
    }
end

local start = {x = 100, y = 400}
local apex = {x = 300, y = 100}
local finish = {x = 500, y = 400}
local path = bezierPath(start, apex, finish, 2.0)

local canvas
local timer = 0

function love.load()
    canvas = love.graphics.newCanvas(600, 500)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    -- Draw bezier path on the canvas
    love.graphics.setColor(1, 1, 1, 0.5)
    local points = {}
    for t = 0, 1, 0.01 do
        local pos = path.getPosition(t)
        table.insert(points, pos.x)
        table.insert(points, pos.y)
    end
    love.graphics.line(points)

    love.graphics.setCanvas()
end

function love.update(dt)
    timer = timer + dt
    if timer > path.duration then
        timer = timer - path.duration
    end
end

function love.draw()
    love.graphics.draw(canvas)

    local t = timer / path.duration
    local circlePos = path.getPosition(t)

    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", circlePos.x, circlePos.y, 10)
end

