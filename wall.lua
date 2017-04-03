Wall = {}

function Wall.new(x, y, w, h)
    wall = {}

    wall.x = x
    wall.y = y
    wall.width = w
    wall.height = h

    wall.visible = true

    wall.segments = {}
    table.insert(wall.segments, { a = { x = x, y = y }, b = { x = x + w, y = y } })
    table.insert(wall.segments, { a = { x = x + w, y = y }, b = { x = x + w, y = y + h } })
    table.insert(wall.segments, { a = { x = x + w, y = y + h }, b = { x = x, y = y + h } })
    table.insert(wall.segments, { a = { x = x, y = y + h }, b = { x = x, y = y } })

    wall.points = {}
    for _, segment in pairs(wall.segments) do
        table.insert(wall.points, segment.a)
    end

    return wall
end

return Wall
