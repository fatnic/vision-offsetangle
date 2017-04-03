local Vision = class('Vision')

function Vision:initialize(segments)
    self.segments = segments

    self.points = {}
    for _, segment in pairs(self.segments) do table.insert(self.points, segment.a) end

    self.origin = { x = 0, y = 0 }
    self.raylength = tools.distance({ x = 0, y = 0 },{ x = love.graphics:getWidth(), y = love.graphics:getHeight() })
    self.rays = {}
    self.polygon = {}
    self.pp = {}
end

function Vision:setOrigin(x, y) 
    self.origin.x = x
    self.origin.y = y
end

function Vision:getOrigin() 
    return { x = self.origin.x, y = self.origin.y }
end

function Vision:update()
    self.angles = {}
    self.rays = {}
    self.polygon = {}

    local angles = self:calcAngles()
    local rays = self:calcRays(angles)
    self.rays = self:calcIntersects(rays)

    table.insert(self.polygon, {self.origin.x, self.origin.y})
    for _, ray in pairs(self.rays) do
        if ray.intersect then
            table.insert(self.polygon, {ray.intersect.x, ray.intersect.y})
            -- table.insert(self.polygon, ray.intersect.x)
            -- table.insert(self.polygon, ray.intersect.y)
            table.insert(self.pp, ray.intersect)
        end
    end
    table.insert(self.polygon, self.polygon[2])

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

return Vision

