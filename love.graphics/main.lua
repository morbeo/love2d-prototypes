function love.load()
    love.window.setTitle("love.graphics Functions Showcase")
    love.window.setMode(800, 600)

    image = love.graphics.newImage("example.png") -- Image for demonstration purposes
    quad = love.graphics.newQuad(0, 0, 32, 32, image:getDimensions()) -- Quad defines a section of an image

    canvas = love.graphics.newCanvas(100, 100)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", 10, 10, 80, 80) -- Drawing a rectangle to canvas
    love.graphics.setCanvas()
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white

    -- Points (useful for pixel art or visual markers)
    love.graphics.points(50, 50, 60, 60, 70, 50)
    love.graphics.print("Points", 50, 60)

    -- Lines (useful for drawing paths, borders, or simple shapes)
    love.graphics.line(100, 50, 150, 100, 200, 50)
    love.graphics.print("Line", 150, 110)

    -- Circle (good for circular shapes like buttons or projectiles)
    love.graphics.circle("line", 300, 75, 40)
    love.graphics.print("Circle (line)", 260, 120)
    love.graphics.circle("fill", 400, 75, 30)
    love.graphics.print("Circle (fill)", 370, 120)

    -- Ellipse (oval shapes useful for UI elements or characters)
    love.graphics.ellipse("line", 500, 75, 50, 25)
    love.graphics.print("Ellipse (line)", 460, 110)
    love.graphics.ellipse("fill", 600, 75, 40, 20)
    love.graphics.print("Ellipse (fill)", 570, 110)

    -- Arc (partial circles useful for progress bars or gauges)
    love.graphics.arc("line", 700, 75, 30, math.rad(0), math.rad(270))
    love.graphics.print("Arc", 680, 110)

    -- Polygon (for custom shapes or game terrain)
    love.graphics.polygon("line", 100, 150, 150, 200, 50, 200)
    love.graphics.print("Polygon (line)", 80, 210)
    love.graphics.polygon("fill", 200, 150, 250, 200, 150, 200)
    love.graphics.print("Polygon (fill)", 180, 210)

    -- Rectangle (very common for platforms, UI, and bounding boxes)
    love.graphics.rectangle("line", 300, 150, 80, 50)
    love.graphics.print("Rect (line)", 310, 210)
    love.graphics.rectangle("fill", 400, 150, 80, 50)
    love.graphics.print("Rect (fill)", 410, 210)

    -- Image (useful for sprites, backgrounds, and UI graphics)
    love.graphics.draw(image, 500, 150)
    love.graphics.print("Image", 510, 200)

    -- Quad (drawing subsections of an image for tilesets or sprite sheets)
    love.graphics.draw(image, quad, 600, 150)
    love.graphics.print("Quad", 610, 200)

    -- Canvas (for off-screen rendering, post-processing, or compositing)
    love.graphics.draw(canvas, 700, 150)
    love.graphics.print("Canvas", 710, 260)

    -- Text (UI, instructions, debug output)
    love.graphics.print("Simple Text", 50, 250)
    love.graphics.printf("Centered Text", 200, 250, 400, "center")

    -- Bezier Curve (smooth paths, animations, and curves)
    love.graphics.line(love.math.newBezierCurve(50, 350, 150, 300, 200, 400):render())
    love.graphics.print("Bezier Curve", 110, 410)

    -- Set color example (demonstrating transparency and tinting)
    love.graphics.setColor(1, 0, 0, 0.5) -- Red, half-transparent
    love.graphics.rectangle("fill", 250, 300, 100, 100)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color
    love.graphics.print("Colored Rect", 255, 410)

    -- Transformations (useful for rotation, scaling, or moving objects)
    love.graphics.push()
    love.graphics.translate(400, 350)
    love.graphics.rotate(math.rad(45))
    love.graphics.rectangle("line", -50, -50, 100, 100)
    love.graphics.pop()
    love.graphics.print("Rotated Rect", 370, 410)
end

