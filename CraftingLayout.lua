-- Plans layouts
require 'EntityProperties';
require 'direction';
require 'Position';
require 'Grid';

CraftingLayout = {}
CraftingLayout.__index = CraftingLayout;
function CraftingLayout:New(craftingPlan)
    local this = {
        craftingPlan = craftingPlan,
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
    this:AddEntityToGrid(this.craftingPlan.bestCrafterType, "crafter", this.outputBeltDistance+1, 3, defines.direction.north, "");
    this:AddEntityToGrid(this.outputInserterType, "inserter", this.outputBeltDistance-1, 2, defines.direction.east, "");

    -- add ingredient inserters
    local ingredientCount = this.craftingPlan:getIngredientCount();
    local crafterSize = this:getEntityWidthHeight(this.craftingPlan.bestCrafterType, this.craftingPlan.beltDirection, "");
    if this.outputInserterType == "long-handed-inserter" then 
        local column = 1;
        for i=1, ingredientCount, 1 do
            if column == 1 then
                -- left of crafter
                this:AddEntityToGrid("stack-inserter", "inserter", 2, crafterSize.y+1, defines.direction.west, "");
                this:AddBelt(column);
            elseif column >= 2 and column <= crafterSize.x + 1 then
                -- above crafter
                this:AddEntityToGrid("stack-inserter", "inserter", column + 1, 1, defines.direction.north, "");
                this:AddUndergroundBelt(column + 1);
            elseif column == crafterSize.x + 2 then
                -- right of crafter
                this:AddEntityToGrid("stack-inserter", "inserter", crafterSize.x + 3, crafterSize.y+1, defines.direction.east, "");
                this:AddBelt(column + 2);
            elseif column == crafterSize.x + 3 then
                -- right of crafter - long handed inserter
                this:AddEntityToGrid("long-handed-inserter", "inserter", crafterSize.x + 3, crafterSize.y-1, defines.direction.east, "");
                this:AddBelt(column + 2);
            end
            column = column + 1;
        end
    else
        local column = 1;
        for i=1, ingredientCount, 1 do
            if column >= 1 and column <= crafterSize.x + 1 then
                -- above crafter
                this:AddEntityToGrid("stack-inserter", "inserter", column + 1, 1, defines.direction.north, "");
                this:AddUndergroundBelt(column + 1);
            elseif column == crafterSize.x + 2 then
                -- right of crafter
                this:AddEntityToGrid("stack-inserter", "inserter", crafterSize.x + 2, crafterSize.y+1, defines.direction.east, "");
                this:AddBelt(column + 2);
            elseif column == crafterSize.x + 3 then
                -- right of crafter - long handed inserter
                this:AddEntityToGrid("long-handed-inserter", "inserter", crafterSize.x + 2, crafterSize.y-1, defines.direction.east, "");
                this:AddBelt(column + 2);
            end
            column = column + 1;
        end
    end


    -- add belts

    -- add output Belt
    this:AddBelt(0); 

    -- add power poles

    return this;
end

function CraftingLayout:NewGrid(entityName, direction)
    local entitySize = CraftingLayout:getEntityWidthHeight(entityName, direction);

    local width = entitySize.x + self.outputBeltDistance + 3;
    local height = entitySize.y + 4;

    self.grid = Grid:New(width, height);
end

function CraftingLayout:AddBelt(col)
    for h=0, self.grid.height-1, 1 do
        self.grid:setCell(col,h,{
            entityName = self.craftingPlan.beltName,
            entityType = "belt",
            direction = defines.direction.north,
            kind = ""
        });
    end
end

function CraftingLayout:AddUndergroundBelt(x)
    local undergroundBelt = EntityProperties.getUndergroundBeltName(self.craftingPlan.beltName);
    self.grid:setCell(x,0,{
        entityName = undergroundBelt,
        entityType = "underground-belt",
        direction = defines.direction.north,
        kind = "output"
    });
    self.grid:setCell(x,self.grid.height-1,{
        entityName = undergroundBelt,
        entityType = "underground-belt",
        direction = defines.direction.north,
        kind = "input"
    });
end

function CraftingLayout:AddEntityToGrid(entityName, entityType, x, y, direction, kind) -- kind: used to designate "input" or "output" 
    local entitySize = CraftingLayout:getEntityWidthHeight(entityName, direction);
    --debug("Entity: "..entityName.." type: "..entityType.." size.x: "..entitySize.x.." size.y: "..entitySize.y)
    local entityMain = true;
    for i=x, roundUp(entitySize.x) + x-1, 1 do
        for j=y, roundUp(entitySize.y) + y-1, 1 do
            if entityMain then
                self.grid:setCell(i,j,{
                    entityName = entityName,
                    entityType = entityType,
                    direction = direction,
                    kind = kind
                });
                entityMain = false;
            else
                self.grid:setCell(i,j,{
                    entityName = entityName,
                    entityType = "",
                    direction = direction,
                    kind = kind
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

function CraftingLayout:Render(offset, flip)
    local tempGrid = self.grid:TranslateToWorldCoordinates(offset, self.craftingPlan.beltDirection, flip);

    local gridArea = self.grid:getGridExtents(tempGrid);

    ClearArea(gridArea.x1,gridArea.y1,gridArea.x2,gridArea.y2,"");
    FillWater(gridArea.x1,gridArea.y1,gridArea.x2,gridArea.y2);


    for i=0, self.grid.width-1, 1  do
        for j=0, self.grid.height-1, 1 do
            local cell = tempGrid[i][j];
            if cell and cell.entityType and cell.entityName then
                debug("Entity Type: "..cell.entityType)
                if cell.entityType == "inserter" then
                    debug("Rendering Inserter");
                    game.surfaces[1].create_entity({
                        name=cell.entityName, 
                        position={cell.x,cell.y}, 
                        direction=cell.direction,
                        force="player" 
                    });
                elseif cell.entityType == "crafter" then
                    debug("Rendering Crafter");
                    game.surfaces[1].create_entity({
                        name=cell.entityName, 
                        position={cell.x,cell.y}, 
                        direction=cell.direction,
                        recipe=self.craftingPlan.recipe.name, 
                        force="player" 
                    });
                elseif cell.entityType == "belt" then
                    debug("Rendering Belt");
                    game.surfaces[1].create_entity({
                        name=cell.entityName, 
                        position={cell.x,cell.y}, 
                        direction=cell.direction, 
                        force="player" 
                    });
                elseif cell.entityType == "underground-belt" then
                    debug("Rendering Underground Belt");
                    game.surfaces[1].create_entity({
                        name=cell.entityName, 
                        position={cell.x,cell.y}, 
                        direction=cell.direction,
                        type=cell.kind,
                        force="player" 
                    });
                end
            end
        end
    end
end

return CraftingLayout;