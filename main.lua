class = require 'ext.middleclass'

tools = require 'tools'

local width, height = love.graphics:getDimensions()

local Wall = require 'wall'
local Vision = require 'vision'

local wall_list = {
    {0, 0, width, height },
    {10*16, 10*16, 2*16, 10*16},
    {15*16, 10*16, 2*16, 10*16},
    {20*16, 10*16, 2*16, 10*16},
    {25*16, 10*16, 2*16, 10*16},
    {30*16, 10*16, 2*16, 10*16},
    {35*16, 10*16, 2*16, 10*16},
    {40*16, 10*16, 2*16, 10*16},

    {10*16, 25*16, 32*16, 2*16},
}

local walls = {}
local target = { x = 100, y = 100 }

function visionStencil()
    love.graphics.arc('fill', vision.origin.x, vision.origin.y, vision.viewdistance, vision.maxFoV, vision.minFoV, 50)
end

function love.load()

    local segments = {}
    for _, w in pairs(wall_list) do
        local wall = Wall.new(unpack(w))
        for _, segment in pairs(wall.segments) do table.insert(segments, segment) end
        table.insert(walls, wall)
    end
    walls[1].visible = false

    vision = Vision(walls)
    vision:setOrigin(width/2, 70)

    floor = love.graphics.newImage('floor.jpg')
    floor:setWrap('repeat', 'repeat')
    quad = love.graphics.newQuad(0, 0, width, height, floor:getWidth(), floor:getHeight())

    cscale = 1
    bcanvas = love.graphics.newCanvas(width/cscale, height/cscale)
    
    love.graphics.setBackgroundColor(150, 150, 150)
end

function love.mousemoved(x, y)
    local o = vision:getOrigin()
    local angle = math.atan2(y - o.y, x - o.x)
    vision:setHeading(angle)
    vision:setViewDistance(tools.distance(o, { x = x, y = y }))
end

function love.keypressed(key)
    if key == 'up' then 
        local d = vision:getViewDistance()
        vision:setViewDistance(d + 10)
    end
    if key == 'down' then 
        local d = vision:getViewDistance()
        vision:setViewDistance(d - 10)
    end
    if key == 'left' then 
        local f = vision:getFoV()
        vision:setFoV(f - 2)
    end
    if key == 'right' then 
        local f = vision:getFoV()
        vision:setFoV(f + 2)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        vision:setOrigin(x, y)
    end

    if button == 2 then
        target.x = x
        target.y = y
    end
end

function love.update(dt)
    love.window.setTitle(love.timer.getFPS() .. ' fps')
    vision:update()

    -- draw
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(floor, quad, 0, 0)

    local o = vision:getOrigin()
    love.graphics.setColor(0, 255, 0, 100)
    love.graphics.circle('fill', o.x, o.y, 4)

    love.graphics.push()
    love.graphics.scale(1/cscale, 1/cscale)
    love.graphics.setCanvas(bcanvas)
    love.graphics.clear()
    local color = tools.ternary(vision:inVision(target), {255,0,0,25}, {255,255,255,55})
    love.graphics.setColor(color)
    love.graphics.stencil(visionStencil, 'replace', 1)
    love.graphics.setStencilTest('equal', 1)
    local mesh = love.graphics.newMesh(vision.mesh, 'fan')
    love.graphics.draw(mesh)
    love.graphics.setStencilTest()
    love.graphics.setCanvas()
    love.graphics.pop()

    love.graphics.setBlendMode('alpha', 'premultiplied')
    -- love.graphics.setShader(bloom)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(bcanvas, 0, 0, 0, cscale, cscale)
    -- love.graphics.setShader()

    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(0, 0, 255)
    for _, wall in pairs(walls) do
        if wall.visible then love.graphics.rectangle('fill', wall.x, wall.y, wall.width, wall.height) end
    end

    love.graphics.setColor(255, 0, 0)
    love.graphics.circle('fill', target.x, target.y, 5)
end


