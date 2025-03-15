local maze = {}
local tileSize = 20
local mazeWidth, mazeHeight = 30, 20

function love.load()
    love.window.setMode(mazeWidth * tileSize, mazeHeight * tileSize)
    generateMaze()
end

function generateMaze()
    for y = 1, mazeHeight do
        maze[y] = {}
        for x = 1, mazeWidth do
            maze[y][x] = { visited = false, walls = { true, true, true, true } } -- top, right, bottom, left
        end
    end

    dfs(1, 1)
end

function dfs(cx, cy)
    maze[cy][cx].visited = true
    local directions = { {0, -1}, {1, 0}, {0, 1}, {-1, 0} }

    for i = #directions, 2, -1 do
        local j = love.math.random(i)
        directions[i], directions[j] = directions[j], directions[i]
    end

    for _, dir in ipairs(directions) do
        local nx, ny = cx + dir[1], cy + dir[2]
        if nx > 0 and nx <= mazeWidth and ny > 0 and ny <= mazeHeight and not maze[ny][nx].visited then
            if dir[1] == 1 then
                maze[cy][cx].walls[2] = false
                maze[ny][nx].walls[4] = false
            elseif dir[1] == -1 then
                maze[cy][cx].walls[4] = false
                maze[ny][nx].walls[2] = false
            elseif dir[2] == 1 then
                maze[cy][cx].walls[3] = false
                maze[ny][nx].walls[1] = false
            elseif dir[2] == -1 then
                maze[cy][cx].walls[1] = false
                maze[ny][nx].walls[3] = false
            end
            dfs(nx, ny)
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    for y = 1, mazeHeight do
        for x = 1, mazeWidth do
            local cell = maze[y][x]
            local px, py = (x - 1) * tileSize, (y - 1) * tileSize

            if cell.walls[1] then
                love.graphics.line(px, py, px + tileSize, py)
            end
            if cell.walls[2] then
                love.graphics.line(px + tileSize, py, px + tileSize, py + tileSize)
            end
            if cell.walls[3] then
                love.graphics.line(px + tileSize, py + tileSize, px, py + tileSize)
            end
            if cell.walls[4] then
                love.graphics.line(px, py + tileSize, px, py)
            end
        end
    end
end

