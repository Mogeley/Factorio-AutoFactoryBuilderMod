-- methods to get entity properties

EntityProperties = {}

function EntityProperties.BeltRate(beltName)
    local beltRate = {}; -- items per minute
    beltRate["transport-belt"] = 800;
    beltRate["fast-transport-belt"] = 1600;
    beltRate["express-transport-belt"] = 2400;
    return beltRate[beltName];
end

function EntityProperties.AssemblySpeed(assemblerName)
    local assemblerSpeed = {};
    assemblerSpeed["assembling-machine-1"] = 0.5;
    assemblerSpeed["assembling-machine-2"] = 0.75;
    assemblerSpeed["assembling-machine-3"] = 1.25;
    assemblerSpeed["stone-furnace"] = 1.0;
    assemblerSpeed["steel-furnace"] = 2.0;
    assemblerSpeed["electric-furnace"] = 2.0;
    assemblerSpeed["centrifuge"] = 0.75;
    assemblerSpeed["chemical-plant"] = 1.25;
    assemblerSpeed["oil-refinery"] = 1.0;
    assemblerSpeed["rocket-silo"] = 1.0;
    return assemblerSpeed[assemblerName];
end

function EntityProperties.getUndergroundBeltName(beltName)
	if beltName == "transport-belt" then
		return "underground-belt";
	elseif beltName == "fast-transport-belt" then
		return "fast-underground-belt";
	elseif beltName == "express-transport-belt" then
		return "express-underground-belt";
    end
    return beltName;
end

function EntityProperties.InserterRate(inserterName)
    local burnerRate = 35.4; -- 0.59 items/sec
    local normalRate = 49.8; -- 0.83 items/sec
    local longRate = 69;     -- 1.15 items/sec
    local fastRate = 138.6;  -- 2.31 items/sec
    local stackBonus = 12;   -- TODO: change based on current research - for now assume full research
    local otherBonus = 3;    -- TODO: change based on current research - for now assume full research

    local inserterRate = {}; -- items/minute - these change based on research bonuses
    inserterRate["burner-inserter"] = burnerRate * otherBonus;
    inserterRate["inserter"] = normalRate * otherBonus;
    inserterRate["fast-inserter"] = fastRate * otherBonus;
    inserterRate["filter-inserter"] = fastRate * otherBonus;
    inserterRate["stack-inserter"] = fastRate * stackBonus;
    inserterRate["stack-filter-inserter"] = fastRate * stackBonus;
    inserterRate["long-handed-inserter"] = longRate * otherBonus;
    return inserterRate[inserterName];
end

function EntityProperties.EntityPrototype(entityName)
    --debug("Looking for Entity Prototype: "..entityName);
    for _, entity in pairs(game.entity_prototypes) do
        --debug("Entity Prototype: "..entity.name);
		if entity.name == entityName then
			--debug("Entity Prototype:"..entity.name);
			return entity;
		end
	end
	debug("Cannot find Entity Prototype!");
	return nil;
end

function EntityProperties.Width(entityName)
	local entity = EntityProperties.EntityPrototype(entityName);
	return math.abs(entity.selection_box.left_top.x - entity.selection_box.right_bottom.x);
end

function EntityProperties.Height(entityName)
	local entity = EntityProperties.EntityPrototype(entityName);
	return math.abs(entity.selection_box.left_top.y - entity.selection_box.right_bottom.y);
end

function EntityProperties.getbestCrafterType(recipe, allRecipes)
    if recipe.category == "crafting" or recipe.category == "advanced-crafting" or recipe.category == "crafting-with-fluid" then
        return EntityProperties.getBestAvailableAssembler(recipe, allRecipes);
    elseif recipe.category == "smelting" then
        return EntityProperties.getBestAvailableSmelter(allRecipes);	
    elseif recipe.category == "chemistry" then
        return "chemical-plant";
    elseif recipe.category == "oil-processing" then
        return "oil-refinery";
    elseif recipe.category == "rocket-building" then
        return "rocket-silo";
    else -- recipe.category == "centrifuging"
        return "centrifuge";
    end
end

function EntityProperties.getIngredientCount(recipeToMake)
    local ingredientCount = 0;
    for _, ingredient in pairs(recipeToMake.ingredients) do
        ingredientCount = ingredientCount + 1;
    end
    return ingredientCount;
end

function EntityProperties.getBestAvailableAssembler(recipeToMake, allRecipes)
    local ingredientCount = EntityProperties.getIngredientCount(recipeToMake);
    local assembler = "";
    for _, recipe in pairs(allRecipes) do
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

function EntityProperties.getBestAvailableSmelter(allRecipes)
    for _, recipe in pairs(allRecipes) do
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

return EntityProperties;