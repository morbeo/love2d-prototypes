function love.load()
    love.window.setTitle("Explosion Simulation with Reference Polygons")
    love.window.setMode(800, 600)

    explosions = {}

    -- Reference explosion properties
    referenceExplosion = {
        x = 700, y = 150, sides = 10,
        minRadius = 10, maxRadius = 100
    }

    -- Reference layered explosion
    referenceLayers = {
        {scale = 1.0, color = {1, 0.4, 0, 1}},  -- Outer layer (Orange)
        {scale = 0.7, color = {1, 0.7, 0.2, 0.8}},  -- Middle layer (Lighter Orange)
        {scale = 0.4, color = {1, 1, 0.5, 0.6}}   -- Inner layer (Yellowish)
    }
end

function createExplosion(x, y)
    return {
        x = x,
        y = y,
        sides = 10,
        maxRadius = 100,
        currentRadius = 10,
        speed = 80,
        alpha = 255,
        fadeSpeed = 100,
        layers = referenceLayers
    }
end

function generatePolygon(x, y, sides, radius)
    local points = {}
    for i = 1, sides do
        local angle = (i / sides) * (2 * math.pi)
        local randFactor = love.math.random(80, 120) / 100 -- Adds randomness to the shape
        local px = x + math.cos(angle) * radius * randFactor
        local py = y + math.sin(angle) * radius * randFactor
        table.insert(points, px)
        table.insert(points, py)
    end
    return points
end

function love.update(dt)
    for i = #explosions, 1, -1 do
        local explosion = explosions[i]
        if explosion.currentRadius < explosion.maxRadius then
            explosion.currentRadius = explosion.currentRadius + explosion.speed * dt
            explosion.alpha = explosion.alpha - explosion.fadeSpeed * dt
        else
            explosion.alpha = 0
        end

        if explosion.alpha <= 0 then
            table.remove(explosions, i)
        end
    end
end

function love.draw()
    -- Draw Active Explosions
    for _, explosion in ipairs(explosions) do
        for _, layer in ipairs(explosion.layers) do
            local radius = explosion.currentRadius * layer.scale
            local points = generatePolygon(explosion.x, explosion.y, explosion.sides, radius)
            love.graphics.setColor(layer.color[1], layer.color[2], layer.color[3], explosion.alpha / 255 * layer.color[4])
            love.graphics.polygon("fill", points)
        end
    end

    -- Draw Reference Explosions (Static)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Reference Explosion Sizes", 650, 30)

    -- Simple Min and Max Explosion
    love.graphics.setColor(1, 0.5, 0, 0.8)  -- Orange
    love.graphics.polygon("line", generatePolygon(referenceExplosion.x, referenceExplosion.y, referenceExplosion.sides, referenceExplosion.maxRadius))

    love.graphics.setColor(1, 0.5, 0, 1)  -- Brighter Orange
    love.graphics.polygon("line", generatePolygon(referenceExplosion.x, referenceExplosion.y, referenceExplosion.sides, referenceExplosion.minRadius))

    -- Layered Min and Max Explosion
    local offsetY = 200
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Layered Explosion Preview", 650, offsetY - 20)

    for _, layer in ipairs(referenceLayers) do
        local radius = referenceExplosion.maxRadius * layer.scale
        local points = generatePolygon(referenceExplosion.x, referenceExplosion.y + offsetY, referenceExplosion.sides, radius)
        love.graphics.setColor(layer.color[1], layer.color[2], layer.color[3], 0.6 * layer.color[4])
        love.graphics.polygon("line", points)
    end

    -- Debug Info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Explosions: " .. #explosions, 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        local x, y = love.math.random(100, 600), love.math.random(100, 500)
        table.insert(explosions, createExplosion(x, y))
    end
end

