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
end

function love.mousemoved(x, y)
    vision:setOrigin(x, y)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        target.x = x
        target.y = y
    end
end

function love.update(dt)
    love.window.setTitle(love.timer.getFPS() .. ' fps')
    vision:update()
end

function love.draw()
    -- love.graphics.setLineWidth(1)
    -- love.graphics.setColor(0, 0, 255, 180)
    -- for _, wall in pairs(walls) do
    --     love.graphics.rectangle('line', wall.x, wall.y, wall.width, wall.height)
    -- end

    local o = vision:getOrigin()
    love.graphics.setColor(0, 255, 0, 100)
    love.graphics.circle('fill', o.x, o.y, 4)

    -- for i, ray in ipairs(vision.rays) do 

    --     love.graphics.setLineWidth(1)
    --     love.graphics.setColor(255, 255, 255, 50)
    --     love.graphics.line(ray.a.x, ray.a.y, ray.b.x, ray.b.y)

    --     if ray.intersect then 
    --         love.graphics.setColor(5, 255, 5, 250)
    --         love.graphics.circle('fill', ray.intersect.x, ray.intersect.y, 4) 
    --     end
    -- end
    local color = tools.ternary(vision:inVision(target), {255,0,0,50}, {255,255,255,50})
    love.graphics.setColor(color)
    love.graphics.stencil(visionStencil, 'replace', 1)
    love.graphics.setStencilTest('equal', 1)
    local mesh = love.graphics.newMesh(vision.mesh, 'fan')
    love.graphics.draw(mesh)
    love.graphics.setStencilTest()
    --
    love.graphics.setColor(0, 0, 255)
    for _, wall in pairs(walls) do
        if wall.visible then love.graphics.rectangle('fill', wall.x, wall.y, wall.width, wall.height) end
    end

    love.graphics.setColor(255, 0, 0)
    love.graphics.circle('fill', target.x, target.y, 5)
end


