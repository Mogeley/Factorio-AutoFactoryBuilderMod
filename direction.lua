
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

function Direction.Mirror(direction, axis) -- mirrors a direction perpendicular to the axis
	if axis == defines.direction.north or axis == defines.direction.south then
		if direction == defines.direction.east or direction == defines.direction.west then
			return Direction.Opposite(direction);
		end
	end
	if axis == defines.direction.east or axis == defines.direction.west then
		if direction == defines.direction.north or direction == defines.direction.south then
			return Direction.Opposite(direction);
		end
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

function Direction.ToString(direction)
	if direction == defines.direction.north then
		return "North";
	elseif direction == defines.direction.east then
		return "East";
	elseif direction == defines.direction.south then
		return "South";
	elseif direction == defines.direction.west then
		return "West";
	end
	return "none";
end

return Direction;