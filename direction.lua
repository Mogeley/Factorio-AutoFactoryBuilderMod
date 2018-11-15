
Direction = {}

function Direction.Opposite(direction)
	if direction == defines.direction.north then
		return defines.direction.south;
	elseif direction == defines.direction.south then
		return defines.direction.north;
	elseif direction == defines.direction.east then
		return defines.direction.west;
	elseif direction == defines.direction.west then
		return defines.direction.east;
	end
end

function Direction.Left(direction)
	if direction == defines.direction.north then
		return defines.direction.west;
	elseif direction == defines.direction.west then
		return defines.direction.south;
	elseif direction == defines.direction.south then
		return defines.direction.east;
	elseif direction == defines.direction.east then
		return defines.direction.north;
	end
end

function Direction.Right(direction)
	if direction == defines.direction.north then
		return defines.direction.east;
	elseif direction == defines.direction.east then
		return defines.direction.south;
	elseif direction == defines.direction.south then
		return defines.direction.west;
	elseif direction == defines.direction.west then
		return defines.direction.north;
	end
end

return Direction;