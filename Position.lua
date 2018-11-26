-- simple position class

Position = {}
function Position:New(x,y)
    local this = {
        x=x,
        y=y
    }
    return this;
end

function Position.Add(position1, position2)
    local this = {
        x=position1.x + position2.x,
        y=position1.y + position2.y
    }
    return this;
end

function Position.Offset(position, direction, distance)
    local offset = position;
    if direction == defines.direction.north then
		offset.y = offset.y - distance;
	elseif direction == defines.direction.south then
		offset.y = offset.y + distance;
	elseif direction == defines.direction.east then
		offset.x = offset.x + distance;
	elseif direction == defines.direction.west then
		offset.x = offset.x - distance;
	end
    return offset;
end