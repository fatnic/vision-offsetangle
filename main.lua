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
local player = { x = 50, y = 50 }

local target = { x = 100, y = 100 }

function visionStencil()
    love.graphics.arc('fill', vision.origin.x, vision.origin.y, vision.viewdistance, vision.maxFoV, vision.minFoV, 20)
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

    bloom = love.graphics.newShader('bloom.frag')
    bloom:send("size", { width, height })
    bloom:send("quality", 10)
end

function love.mousemoved(x, y)
    local o = vision:getOrigin()
    local angle = math.atan2(y - o.y, x - o.x)
    vision:setHeading(angle)
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
end

function love.draw()

    local o = vision:getOrigin()
    love.graphics.setColor(0, 255, 0, 100)
    love.graphics.circle('fill', o.x, o.y, 4)

    local color = tools.ternary(vision:inVision(target), {255,0,0,55}, {255,255,255,55})
    love.graphics.setColor(color)
    love.graphics.stencil(visionStencil, 'replace', 1)
    love.graphics.setStencilTest('equal', 1)
    local mesh = love.graphics.newMesh(vision.mesh, 'fan')
    love.graphics.draw(mesh)
    love.graphics.setStencilTest()
    --
    love.graphics.setColor(0, 0, 255)
    -- love.graphics.setShader(effect)
    for _, wall in pairs(walls) do
        if wall.visible then love.graphics.rectangle('fill', wall.x, wall.y, wall.width, wall.height) end
    end
    -- love.graphics.setShader()

    love.graphics.setColor(255, 0, 0)
    love.graphics.circle('fill', target.x, target.y, 5)
end


