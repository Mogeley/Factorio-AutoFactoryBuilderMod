Recipes = {}

function Recipes.getAll(player)
	-- https://lua-api.factorio.com/latest/LuaForce.html#LuaForce.recipes 
	-- https://lua-api.factorio.com/latest/LuaRecipe.html
	local result = {};
	for _, recipe in pairs(player.force.recipes) do
		debug("Recipe: "..recipe.name.." Category: "..recipe.category);
		if recipe.enabled then
			table.insert(result, recipe);
		end
	end
	return result;
end

function Recipes.get(player, recipeName)
	-- https://lua-api.factorio.com/latest/LuaForce.html#LuaForce.recipes 
	-- https://lua-api.factorio.com/latest/LuaRecipe.html
	local result = {};
	for _, recipe in pairs(player.force.recipes) do
		if recipe.name == recipeName then
			return recipe;	
		end
	end
	return nil;
end

return Recipes;