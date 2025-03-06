function love.load()
-- Create a physics World with gravity (0, 200) and enable sleep for objects at rest
    World = love.physics.newWorld(0, 100, true)
-- Set the collision callbacks for the World
    World:setCallbacks(beginContact, endContact, preSolve, postSolve)


    Platform = {}
-- Create a Platform body for the Platform object at position (400, 400)
    Platform.body = love.physics.newBody(World, 400, 400, "static")
-- Create a rectangle shape for the Platform object with width 200 and height 50
    Platform.shape = love.physics.newRectangleShape(200, 50)
-- Create a fixture for the Platform object using its body and shape
    Platform.fixture = love.physics.newFixture(Platform.body, Platform.shape)
-- Set the user data of the Platform fixture to "Block"
    Platform.fixture:setUserData("Platform")

    Ball = {}
-- Create a dynamic body for the Ball at position (400, 200)
    Ball.body = love.physics.newBody(World, 400, 200, "dynamic")
-- Set the mass of the Ball body to 10
    Ball.body:setMass(10)
-- Create a circle shape for the Ball with radius 50
    Ball.shape = love.physics.newCircleShape(50)
-- Create a fixture for the Ball using its body and shape
    Ball.fixture = love.physics.newFixture(Ball.body, Ball.shape)
-- Set the restitution (bounciness) of the Ball fixture to 0.4
    Ball.fixture:setRestitution(0.4)
-- Set the user data of the Ball fixture to "Ball"
    Ball.fixture:setUserData("Ball")

    Text = ""     -- we'll use this to put info Text on the screen later
    Persisting = 0 -- we'll use this to store the state of repeated callback calls

    love.window.setTitle ("Persisting: "..Persisting)
end

function love.update(dt)
-- Update the physics World with the specified time step (dt)
    World:update(dt)

-- Apply forces to the Ball based on keyboard input
    if love.keyboard.isDown("right") then
-- Apply a force of (1000, 0) to the Ball's body in the right direction
        Ball.body:applyForce(1000, 0)
    elseif love.keyboard.isDown("left") then
-- Apply a force of (-1000, 0) to the Ball's body in the left direction
        Ball.body:applyForce(-1000, 0)
    end
    if love.keyboard.isDown("up") then
-- Apply a force of (0, -5000) to the Ball's body in the upward direction
        Ball.body:applyForce(0, -5000)
    elseif love.keyboard.isDown("down") then
-- Apply a force of (0, 1000) to the Ball's body in the downward direction
        Ball.body:applyForce(0, 1000)
    end

    if string.len(Text) > 768 then-- Cleanup when 'Text' gets too long
        Text = "" -- Reset the Text variable when it exceeds the specified length
    end
end


function love.draw()
-- Draw the Ball as a circle using the Ball's position, radius, and line style
    love.graphics.circle("line", Ball.body:getX(), Ball.body:getY(), Ball.shape:getRadius(), 20)

-- Draw the Platform object as a polygon using the points of its shape and line style
    love.graphics.polygon("line", Platform.body:getWorldPoints(Platform.shape:getPoints()))

-- Draw the Text on the screen at position (10, 10)
    love.graphics.print(Text, 10, 10)
end



-- define beginContact, endContact, preSolve, postSolve functions:

function beginContact(a, b, coll)
    Persisting = 1
    local x, y = coll:getNormal()
    local textA = a:getUserData()
    local textB = b:getUserData()
-- Get the normal vector of the collision and concatenate it with the collision information
    Text = Text.."\n 1.)" .. textA.." colliding with "..textB.." with a vector normal of: ("..x..", "..y..")"
    love.window.setTitle ("Persisting: "..Persisting)
end

function endContact(a, b, coll)
    Persisting = 0
    local textA = a:getUserData()
    local textB = b:getUserData()
-- Update the Text to indicate that the objects are no longer colliding
    Text = Text.."\n 3.)" .. textA.." uncolliding with "..textB
    love.window.setTitle ("Persisting: "..Persisting)
end

function preSolve(a, b, coll)
    if Persisting == 1 then
    local textA = a:getUserData()
    local textB = b:getUserData()
-- If this is the first update where the objects are touching, add a message to the Text
        Text = Text.."\n 2.)" .. textA.." touching "..textB..": "..Persisting
    elseif Persisting <= 10 then
-- If the objects have been touching for less than 20 updates, add a count to the Text
        Text = Text.." "..Persisting
    end

-- Update the Persisting counter to keep track of how many updates the objects have been touching
    Persisting = Persisting + 1
    love.window.setTitle ("Persisting: "..Persisting)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
-- This function is empty, no actions are performed after the collision resolution
-- It can be used to gather additional information or perform post-collision calculations if needed
end
