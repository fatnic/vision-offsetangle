class = require 'ext.middleclass'
vec = require 'ext.vector'

tools = require 'tools'

local Wall = require 'wall'
local Vision = require 'vision'

local wall_list = {
    {0, 0, love.graphics:getWidth(), love.graphics:getHeight() },
    { 300, 300, 200, 70 },
    { 200, 500, 40, 20 }
}

local walls = {}
local player = { x = 50, y = 50 }

local currentRay = 1

function love.load()

    local segments = {}
    for _, w in pairs(wall_list) do
        local wall = Wall.new(unpack(w))
        for _, segment in pairs(wall.segments) do table.insert(segments, segment) end
        table.insert(walls, wall)
    end

    vision = Vision(segments)
end

function love.mousemoved(x, y)
    vision:setOrigin(x, y)
end

function love.update(dt)
    love.window.setTitle(love.timer.getFPS() .. ' fps')
    vision:update()
end

function love.keypressed(key)
    if key == 'q' then currentRay = currentRay - 1 end
    if key == 'w' then currentRay = currentRay + 1 end

    if currentRay < 1 then currentRay = 1 end
    if currentRay > #vision.rays then currentRay = #vision.rays end
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

    love.graphics.setColor(255,255,255,20)
    local mesh = love.graphics.newMesh(vision.polygon, 'fan')
    love.graphics.draw(mesh)
    -- love.graphics.polygon('fill', vision.polygon)
end


