require 'direction';
require 'Area';

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

function Grid:TranslateToWorldCoordinates(worldPosition, direction, flip)
    local temp = {}
    for x=0, self.width-1, 1 do
        temp[x] = {};
        for y=0, self.height-1, 1 do
            local tx = 0;
            local ty = 0;
            temp[x][y] = copy(self.grid[x][y]); -- need to create a copy to prevent mutation of grid.

            if direction == defines.direction.north then
                if flip then
                    tx = worldPosition.x - x;
                    temp[x][y].direction = Direction.Mirror(temp[x][y].direction, defines.direction.north);
                else
                    tx = x + worldPosition.x;
                end
                ty = y + worldPosition.y;
            elseif direction == defines.direction.east then
                temp[x][y].direction = Direction.Right(temp[x][y].direction);
                tx = worldPosition.x-y;
                if flip then
                    ty = worldPosition.y - x;
                    temp[x][y].direction = Direction.Mirror(temp[x][y].direction, defines.direction.east);
                else
                    ty = x + worldPosition.y;
                end
            elseif direction == defines.direction.south then
                temp[x][y].direction = Direction.Opposite(temp[x][y].direction);
                if flip then
                    tx = x + worldPosition.x;
                    temp[x][y].direction = Direction.Mirror(temp[x][y].direction, defines.direction.south);
                else
                    tx = worldPosition.x - x;
                end
                ty = worldPosition.y-y;
            elseif direction == defines.direction.west then
                temp[x][y].direction = Direction.Left(temp[x][y].direction);
                tx = y + worldPosition.x;
                if flip then
                    ty = x + worldPosition.y;
                    temp[x][y].direction = Direction.Mirror(temp[x][y].direction, defines.direction.west);
                else
                    ty = worldPosition.y-x;
                end
            end

            -- set x , y coordinates
            temp[x][y].x = tx;
            temp[x][y].y = ty;
        end
    end
    return temp;
end

function Grid:getGridExtents(translatedGrid) -- grid with coords
    local xmin = 10000;
    local ymin = 10000;
    local xmax = -10000;
    local ymax = -10000;
    for i, row in pairs(translatedGrid) do
        for j, cell in pairs(row) do
            if cell and cell.x and cell.y then
                if cell.x < xmin then
                    xmin = cell.x;
                end
                if cell.y < ymin then
                    ymin = cell.y;
                end
                if cell.x > xmax then
                    xmax = cell.x;
                end
                if cell.y > ymax then
                    ymax = cell.y;
                end
            end
        end
    end
    debug("Grid Extents: "..xmin..", "..ymin..", "..xmax..", "..ymax);
    return Area:New(xmin,ymin,xmax,ymax);
end

return Grid;