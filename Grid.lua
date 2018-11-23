require 'direction';

Grid = {}
Grid.__index = Grid;
function Grid:New(width, height)
    local this = {
        grid = {},
        width = width,
        height = height
    }

    for x=0, this.width-1, 1 do
        this.grid[x] = {};
        for y=0, this.height-1, 1 do
            this.grid[x][y] = {};
        end
    end

    setmetatable(this, self);
    return this;
end

function Grid:setCell(x, y, object)
    self.grid[x][y] = object;
end

function Grid:TranslateToWorldCoordinates(worldPosition, gridPosition, direction)
    local temp = {}
    if direction == defines.direction.north then
        -- render as is...
        for x=0, width-1, 1 do
            local tx = x + worldPosition.x;
            temp[tx] = {};
            for y=0, height-1, 1 do
                local ty = y + worldPosition.y;
                temp[tx][ty] = self.grid[x][y];
            end
        end
    elseif direction == defines.direction.east then
        for x=0, width-1, 1 do
            local tx = y + worldPosition.x;
            temp[tx] = {};
            for y=0, height-1, 1 do
                local ty = x + worldPosition.y;
                temp[tx][ty] = self.grid[x][y];
                temp.direction = Direction.Right(temp.direction);
            end
        end
    elseif direction == defines.direction.south then
        for x=0, width-1, 1 do
            local tx = worldPosition.x-x;
            temp[tx] = {};
            for y=0, height-1, 1 do
                local ty = worldPosition.y-y;
                temp[tx][ty] = self.grid[x][y];
                temp.direction = Direction.Opposite(temp.direction);
            end
        end
    elseif direction == defines.direction.west then
        for x=0, width-1, 1 do
            local tx = worldPosition.x-y;
            temp[tx] = {};
            for y=0, height-1, 1 do
                local ty = worldPosition.y-x;
                temp[tx][ty] = self.grid[x][y];
                temp.direction = Direction.Left(temp.direction);
            end
        end
    end
end

return Grid;