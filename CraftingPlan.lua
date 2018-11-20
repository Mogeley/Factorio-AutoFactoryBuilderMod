-- Crafting Plan contains all the information needed for filing one or more belts with a specific item.
require 'EntityProperties';
require 'Recipes';

CraftingPlan = {}
function CraftingPlan:New(recipe, beltName, beltEndPosition, beltDirection)
    local this = {
        recipe = recipe,
        beltName = beltName,
        beltEndPosition = beltEndPosition,
        beltDirection = beltDirection,
        saturatedItemRate = EntityProperties.BeltRate(beltName),
        bestCrafterType = self.getbestCrafterType(),
        recipes = Recipes.getAll(),
        itemRate = 0,               -- items/minute - crafting rate for one assembler
        numberOfCrafters = 1,       -- number of assemblers needed to achieve saturated rate
        crafterArrayDepth = 1000,   -- crafterArrayDepth is the maximum number of crafters that can be built in a row per saturated belt.
        crafterArrayWidth = 1       -- crafterArrayWidth is the number of Crafter Rows Needed to produce the needed itemRate
    }

    this.itemRate = 60 / recipe.energy / EntityProperties.AssemblySpeed(bestCrafterType); -- items/minute - crafting rate for one assembler
    this.numberOfCrafters = roundUp(this.saturatedItemRate / this.itemRate);

	-- calculate the number of crafters in a row can be placed before items on supply belt are used
	for _, ingredient in pairs(recipe.ingredients) do
		local ingredientsPerMinute = this.itemRate * ingredient.amount;
		local temp = math.floor(saturatedItemRate / ingredientsPerMinute);
		if temp < this.crafterArrayDepth then -- crafterArrayDepth is the maximum number of crafters that can be built in a row per saturated belt.
			this.crafterArrayDepth = temp;
		end
	end
    this.crafterArrayWidth = roundUp(this.numberOfCrafters / (this.crafterArrayDepth * 2));
    

    -- *** Begin Methods ***
    function CraftingPlan:getbestCrafterType()
        if self.recipe.category == "crafting" or self.recipe.category == "advanced-crafting" or self.recipe.category == "crafting-with-fluid" then
            return self.getBestAvailableAssembler(recipe);
        elseif self.recipe.category == "smelting" then
            return self.getBestAvailableSmelter(recipe);	
        elseif self.recipe.category == "chemistry" then
            return "chemical-plant";
        elseif self.recipe.category == "oil-processing" then
            return "oil-refinery";
        elseif self.recipe.category == "rocket-building" then
            return "rocket-silo";
        else -- self.recipe.category == "centrifuging"
            return "centrifuge";
        end
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
    
    function CraftingPlan:getIngredientCount(recipeToMake)
        local ingredientCount = 0;
        for _, ingredient in pairs(recipeToMake.ingredients) do
            ingredientCount = ingredientCount + 1;
        end
        return ingredientCount;
    end

    function CraftingPlan:getBestAvailableAssembler(recipeToMake)
        local ingredientCount = self.getIngredientCount(recipeToMake);
        local assembler = "";
        for _, recipe in pairs(self.recipes) do
            if recipe.name == "assembling-machine-3" then 
                assembler = "assembling-machine-3";
            elseif recipe.name == "assembling-machine-2" and ingredientCount <= 4 and (assembler == "" or assembler == "assembling-machine-1") then
                assembler = "assembling-machine-2";
            elseif recipe.name == "assembling-machine-1" and assembler == "" and ingredientCount <= 2 then
                assembler = "assembling-machine-1";
            end
        end
        debug("Assembler Selected: "..assembler);
        return assembler;
    end
    
    function CraftingPlan:getBestAvailableSmelter()
        for _, recipe in pairs(self.recipes) do
            if recipe.name == "electric-furnace" then 
                return "electric-furnace";
            elseif recipe.name == "steel-furnace" then
                return "steel-furnace";
            elseif recipe.name == "stone-furnace" then
                return "stone-furnace";
            end
        end
        return "stone-furnace";
    end

    return this;
end

return CraftingPlan;