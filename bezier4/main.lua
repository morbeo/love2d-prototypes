v = {}
v.__index = v
setmetatable( v, { __call = function( _, ... ) return v.new( ... ) end } )

function v.new( x, y )
    return setmetatable( { x = x, y = y }, v )
end

function v.__add( a, b )
    return v( a.x + b.x, a.y + b.y )
end

function v.__sub( a, b )
    return v( a.x - b.x, a.y - b.y )
end

function v.__mul( a, b )
    return v( a.x * b, a.y * b )
end

function v.__div( a, b )
    return v( a.x / b, a.y / b )
end

function v.__unm( a )
    return v( -a.x, -a.y )
end

function v.__eq( a, b )
    return a.x == b.x and a.y == b.y
end

function v.__tostring( a )
    return "(" .. a.x .. ", " .. a.y .. ")"
end

function v.__concat( a, b )
    return tostring( a ) .. b
end

function v:unpack()
    return self.x, self.y
end

function v:clone()
    return v( self.x, self.y )
end

function v:__len()
    return math.sqrt( self.x * self.x + self.y * self.y )
end

function v.midpoint( a, b )
    return ( a + b ) / 2
end

function arc(source,target,power)
    local apex = {
        -- x = math.abs(source.x - target.x)/2+math.min(source.x,target.x),
        x = screen.x/2,
        y = screen.y - screen_part * (power * 3)
    }
    return love.math.newBezierCurve(source.x, source.y, apex.x, apex.y, target.x, target.y)
end

function grid(screen_part)
    love.graphics.setColor(0.5, 0.5, 0.5)
    for i = 0, screen.x, screen_part do
        love.graphics.line(i, 0, i, screen.y)
    end
    for i = 0, screen.y, screen_part do
        love.graphics.line(0, i, screen.x, i)
    end
end

function love.load()
    screen = v( love.graphics.getDimensions() )
    height = 1
    renderdepth = 0
    screen_part = screen.y / 9
    source = v(screen_part * 2, screen.y - screen_part * 2)
    target = v(screen.x - screen_part * 2, screen.y - screen_part * 2)
    curve = arc(source,target, 3 )
    canvas = love.graphics.newCanvas(800,600)
end

function love.update( dt )
    curve = arc( source, target, height )
end

function love.draw()
    -- draw grid
    grid(screen_part)

    -- draw curve
    love.graphics.setColor( 1, 1, 1 )
    love.graphics.line(curve:render())

    -- draw curve points
    love.graphics.setPointSize( 5 )
    love.graphics.points(curve:render(0))

    -- draw control points
    love.graphics.setColor( 1, 0, 0 )
    love.graphics.setPointSize( 5 )
    love.graphics.points(curve:render(1))
    love.graphics.print(string.format("mouse: %d %d", love.mouse.getX(), love.mouse.getY()), 10, 10)
    love.graphics.print(string.format("height: %d", height), 10, 30)
end

function love.keypressed( key )
    if key == "escape" then
        love.event.quit()
    elseif key == "down" then
        height = math.max(1,height - 1)
    elseif key == "up" then
        height = math.min(15,height + 1)
    elseif key == "left" then
        renderdepth = math.max(0,renderdepth - 1)
    elseif key == "right" then
        renderdepth = math.min(5,renderdepth + 1)
    elseif key == "space" then
        canvas = love.graphics.newCanvas()
        for i = 1, curve:getControlPointCount() do
            local p = {curve:getControlPoint(i)}
            if p.x and p.y then
            love.graphics.print(string.format("%d: x %d y %d", i, p.x, p.y), 10, 30 + i * 15)
            love.graphics.circle("fill", p.x, p.y, 2)
            end
        end
    end
end

function love.mousepressed( x, y, button )
    if button == 1 then
        target = v( x, y )
    end
end