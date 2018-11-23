-- Crafting Plan contains all the information needed for filing one or more belts with a specific item.
require 'EntityProperties';
require 'Recipes';

CraftingPlan = {}
CraftingPlan.__index = CraftingPlan;
function CraftingPlan:New(player, recipe, beltName, beltEndPosition, beltDirection)
    local this = {
        player = player,
        recipe = recipe,
        beltName = beltName,
        beltEndPosition = beltEndPosition,
        beltDirection = beltDirection,
        saturatedItemRate = EntityProperties.BeltRate(beltName),
        bestCrafterType = "", --EntityProperties.getbestCrafterType(this.recipe, Recipes.getAll(player)),
        recipes = Recipes.getAll(player),
        itemRate = 0,               -- items/minute - crafting rate for one assembler
        numberOfCrafters = 1,       -- number of assemblers needed to achieve saturated rate
        crafterArrayDepth = 1000,   -- crafterArrayDepth is the maximum number of crafters that can be built in a row per saturated belt.
        crafterArrayWidth = 1       -- crafterArrayWidth is the number of Crafter Rows Needed to produce the needed itemRate
    }
    setmetatable(this, self);
    
    this.bestCrafterType = EntityProperties.getbestCrafterType(this.recipe, this.recipes);
    this.itemRate = 60 / this.recipe.energy / EntityProperties.AssemblySpeed(this.bestCrafterType); -- items/minute - crafting rate for one assembler
    this.numberOfCrafters = roundUp(this.saturatedItemRate / this.itemRate);

	-- calculate the number of crafters in a row can be placed before items on supply belt are used
	for _, ingredient in pairs(this.recipe.ingredients) do
		local ingredientsPerMinute = this.itemRate * ingredient.amount;
		local temp = math.floor(this.saturatedItemRate / ingredientsPerMinute);
		if temp < this.crafterArrayDepth then -- crafterArrayDepth is the maximum number of crafters that can be built in a row per saturated belt.
			this.crafterArrayDepth = temp;
		end
	end
    this.crafterArrayWidth = roundUp(this.numberOfCrafters / (this.crafterArrayDepth * 2));
   
    return this;
end

function CraftingPlan:getNumberofBeltsNeeded()
    local ingredientCount = 0;
    for _, ingredient in pairs(self.recipe.ingredients) do
        ingredientCount = ingredientCount + 1;
    end
    return ingredientCount;
end

function CraftingPlan:getUndergroundBeltNameFromBeltName()
    if self.beltName == "transport-belt" then
        return "underground-belt";
    elseif self.beltName == "fast-transport-belt" then
        return "fast-underground-belt";
    elseif self.beltName == "express-transport-belt" then
        return "express-underground-belt";
    end
end

return CraftingPlan;