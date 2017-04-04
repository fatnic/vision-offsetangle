local Vision = class('Vision')

function Vision:initialize(walls)
    self.segments = {}
    self.points = {}
    for _, wall in pairs(walls) do
        for _, segment in pairs(wall.segments) do
            table.insert(self.segments, segment)
            table.insert(self.points, segment.a)
        end
    end

    self.origin = { x = 0, y = 0 }
    self.viewdistance = 300
    self.heading = 0
    self.fov = 65
    self:calcFoV()

    self.raylength = tools.distance({ x = 0, y = 0 },{ x = love.graphics:getWidth(), y = love.graphics:getHeight() })
    self.rays = {}
    self.mesh = {}
end

function Vision:findClosestInterect(point)
    local ray = { a = self.origin, b = point }
    local closestIntersect = ray.b
    closestIntersect.distance = tools.distance(ray.a, ray.b)
    for _, segment in pairs(self.segments) do
        local intersect = tools.segmentIntersect(ray.a, ray.b, segment.a, segment.b)
        if intersect then
            local distance = tools.distance(ray.a, intersect)
            if distance < closestIntersect.distance then
                closestIntersect = intersect
                closestIntersect.distance = distance
            end
        end
    end
    return closestIntersect
end

function Vision:setOrigin(x, y) 
    self.origin.x = x
    self.origin.y = y
end

function Vision:getOrigin() 
    return { x = self.origin.x, y = self.origin.y }
end

function Vision:setHeading(angle)
    self.heading = angle
    self:calcFoV()
end

function Vision:setViewDistance(dist)
    self.viewdistance = dist
end

function Vision:getViewDistance()
    return self.viewdistance
end

function Vision:setFoV(degrees)
    self.fov = degrees
    self:calcFoV()
end

function Vision:getFoV()
    return self.fov
end

function Vision:calcFoV()
    self.minFoV = self.heading - tools.normaliseRadian(math.rad(self.fov / 2))
    self.maxFoV = self.heading + tools.normaliseRadian(math.rad(self.fov / 2))
end

function Vision:update()
    self.angles = {}
    self.rays = {}
    self.mesh = {}

    local angles = self:calcAngles()
    local rays = self:calcRays(angles)
    self.rays = self:calcIntersects(rays)

    table.insert(self.mesh, {self.origin.x, self.origin.y})
    for _, ray in pairs(self.rays) do
        if ray.intersect then
            table.insert(self.mesh, {ray.intersect.x, ray.intersect.y})
        end
    end
    table.insert(self.mesh, self.mesh[2])

end

function Vision:calcAngles()
    local angles = {}
    local precision = 0.000001
    for _, point in pairs(self.points) do
        local angle = math.atan2(point.y - self.origin.y, point.x - self.origin.x)
        table.insert(angles, tools.normaliseRadian(angle) - precision)
        table.insert(angles, tools.normaliseRadian(angle))
        table.insert(angles, tools.normaliseRadian(angle) + precision)
    end
    table.sort(angles, function(a,b) return a < b end)
    return angles
end

function Vision:calcRays(angles)
    local rays = {}
    for _, angle in pairs(angles) do
        local ray = { a = self.origin, angle = angle }
        local delta = { x = math.cos(angle), y = math.sin(angle) }
        ray.b = { x = ray.a.x + delta.x * self.raylength, y = ray.a.y + delta.y * self.raylength }
        table.insert(rays, ray)
    end
    return rays
end

function Vision:calcIntersects(rays)
    for _, ray in pairs(rays) do
        local cIntersect = nil
        for _, segment in pairs(self.segments) do
            local intersect = tools.segmentIntersect(ray.a, ray.b, segment.a, segment.b)
            if intersect then
                intersect.distance = tools.distance(ray.a, intersect)
                if cIntersect then
                    if intersect.distance < cIntersect.distance then cIntersect = intersect end
                else
                    cIntersect = intersect
                end
            end
        end
        if cIntersect then ray.intersect = cIntersect end
    end
    return rays
end

function Vision:inVision(point)
    -- point too far away
    if tools.distance(self.origin, point) > self.viewdistance then return false end
    
    -- point with min/max FoV
    local pa = tools.normaliseRadian(math.atan2(point.y - self.origin.y, point.x - self.origin.x))
    if tools.isAngleBetween(pa, self.minFoV, self.maxFoV) then 
        if self.segments then
            intersect = self:findClosestInterect(point)
            if tools.distance(self.origin, intersect) < tools.distance(self.origin, point) then return false end
            return true
        end
        -- if no walls then true
        return true
    end

    return false
end

return Vision
