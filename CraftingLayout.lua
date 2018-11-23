-- Plans layouts
require 'EntityProperties';
require 'direction';
require 'Position';
require 'Grid';

CraftingLayout = {}
CraftingLayout.__index = CraftingLayout;
function CraftingLayout:New(craftingPlan, isLeftSide)
    local this = {
        craftingPlan = craftingPlan,
        isLeftSide = isLeftSide,
        outputInserterType = "",
        outputBeltDistance = 3, -- set with type
        grid = {}
    }
    setmetatable(this, self);
    
    -- determine output inserter needed - to maintain CraftingPlan.itemRate
    this.outputInserterType = this:getOutputInserterType(this.craftingPlan);

    -- setup grid
    --debug("Best Crafter type: "..this.craftingPlan.bestCrafterType);
    this:NewGrid(this.craftingPlan.bestCrafterType, this.craftingPlan.beltDirection);

    -- everything is added to the grid is if the grid was northward facing - when rendered everything id moved and rotated ot the proper orientation

    -- add crafter to grid
    this:AddEntityToGrid(this.craftingPlan.bestCrafterType, "crafter", this.outputBeltDistance, 2, defines.direction.north);
    
    this:AddEntityToGrid(this.craftingPlan.beltName, "belt", 0, 0, defines.direction.north);

    return this;
end

function CraftingLayout:NewGrid(entityName, direction)
    local entitySize = CraftingLayout:getEntityWidthHeight(entityName, direction);

    local width = entitySize.x + self.outputBeltDistance + 3;
    local heigth = entitySize.y + 4;

    self.grid = Grid:New(width,heigth);
end

function CraftingLayout:AddEntityToGrid(entityName, entityType, x, y, direction)
    local entitySize = CraftingLayout:getEntityWidthHeight(entityName, direction);

    local entityMain = true;
    for i=x, entitySize.x + x-1, 1 do
        for j=y, entitySize.y + y-1, 1 do
            if entityMain then
                self.grid:setCell(i,j,{
                    entityName = entityName,
                    entityType = entityType,
                    direction = direction        
                });
                entityMain = false;
            else
                self.grid:setCell(i,j,{
                    entityName = entityName,
                    entityType = "",
                    direction = direction        
                });
            end
        end
    end
end

function CraftingLayout:getEntityWidthHeight(entityName, direction)
    local w = EntityProperties.Width(entityName);
    local h = EntityProperties.Height(entityName);
    if entityName ~= "rocket-silo" and (direction == defines.direction.east or direction == defines.direction.west) then
        -- rotate width / height for east west because some crafters are not square and do not rotate.
        w = EntityProperties.Height(entityName);
        h = EntityProperties.Width(entityName);
    end
    return Position:New(w,h);
end

function CraftingLayout:getOutputInserterType(craftingPlan)
    if EntityProperties.InserterRate("long-handed-inserter") >= craftingPlan.itemRate then
        self.outputBeltDistance = 3;
        return "long-handed-inserter";
    end
    self.outputBeltDistance = 2;
    return "stack-inserter";
end

function CraftingLayout:Render()
    local tempGrid = self.grid:TranslateToWorldCoordinates(self.craftingPlan.beltEndPosition, Position:New(0,0), self.craftingPlan.beltDirection);

    for i, v in pairs(tempGrid) do
        for j, v2 in pairs(v) do
            local cell = tempGrid[i][j];
            if cell.entityType == "inserter" then
                game.surfaces[1].create_entity({
                    name=cell.entityName, 
                    position={i,j}, 
                    direction=cell.direction,
                    force="player" 
                });
            elseif cell.entityType == "crafter" then
                game.surfaces[1].create_entity({
                    name=cel.entityName, 
                    position={i,j}, 
                    direction=cell.direction,
                    recipe=self.craftingPlan.recipe, 
                    force="player" 
                });
            elseif cell.entityType == "belt" then
                game.surfaces[1].create_entity({
                    name=cell.entityName, 
                    position={i,j}, 
                    direction=cell.direction, 
                    force="player" 
                });
            end
        end
    end
end

return CraftingLayout;