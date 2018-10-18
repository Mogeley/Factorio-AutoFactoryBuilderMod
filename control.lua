-- Logger Usage see: https://github.com/rxi/log.lua
require 'stdlib/log/logger';
LOGGER = Logger.new('AutoFactoryBuilder', 'AutoFactoryBuilder', true);

-- need way to determine "need" for each resource
-- need iterative method to determine "effectiveness", "eficiency", "resource need" of resource production and transportation layout
-- need way to prevent "circular designs", IE keep the iterating to a new design instead of repeating old designs. 
-- "effectiveness" - answers the question, Are enough resources being produced fast enough? and Are resources transported fast enough? 
-- "eficiency" - answers thw question: Can I produce less of a certain resource? and Are there ways to transport resources faster? Are there any choke points? 
-- "resource need" - where are resources needed the most? big picture of where the resources need to go.

-- Algorithm ideas. Start with designed end product for each resource per second then work back to what is needed for each and the recource bandwidth needed.

-- later can try an eficiency of space 

local firstTick = true;
local searchForOre = true;
local checkNeeds = true;
local exploreInterval = 1200; -- 1800 = 30 seconds
local needsInterval = 600;
local exploredArea = {{0,0}, {0,0}};

-- set initial minimums for map exploration. these numbers should be increased as the factory needs more resources
local minOilCount = 1000000;
local minIronOreCount = 1000000;
local minCopperOreCount = 1000000;
local minUraniumOreCount = 1000000;
local minCoalCount = 1000000;
local minStoneCount = 1000000;
local player;

local recipes;


function onTick(event)
	if firstTick then
		player = game.players[1];
		debug("Starting Auto Factory Builder...");
		SetupStartingArea();
		firstTick = false;
		--recipes = getRecipes();
		--getResearchableTech();
		local results = getRecipeRequirements("express-splitter", {});
		debug("Recipe Requirements Results: ");
		for _, result in pairs(results) do
			debug("Name: "..result.name.." Type: "..result.type.." Total: "..result.amount.." isRawResource: "..(result.isRawResource ? 'true' : 'false').." isEnabled: "..(result.isEnabled ? 'true' : 'false'));
		end
	else
		if event.tick % exploreInterval == 0 and searchForOre then
			debug("Searching for Ore...");
			expandExploredArea();
		end
		if event.tick % needsInterval == 0 and checkNeeds then
			
			checkNeeds = false;
		end
	end
end

function onResesarchFinish(event)
	recipes = getRecipes();
end

function debug(msg)
	player.print(msg);
	LOGGER.log(msg);
end

function SetupStartingArea()
	-- clear all ore in 200 x 200 area
	ClearArea(-512, -512, 512, 512, "resource");
end

function expandExploredArea()
	local size = 256;
	Explore(exploredArea[1][1]-size, exploredArea[1][2]-size, exploredArea[2][1]+size, exploredArea[1][1]); -- top
	Explore(exploredArea[1][1]-size, exploredArea[1][2], exploredArea[1][1], exploredArea[2][2]); -- left
	Explore(exploredArea[1][1], exploredArea[1][2], exploredArea[2][1]+size, exploredArea[2][2]); -- right
	Explore(exploredArea[1][1]-size, exploredArea[2][2], exploredArea[2][1]+size, exploredArea[2][2]+size); -- bottom

	exploredArea = { {exploredArea[1][1]-size, exploredArea[1][2]-size}, {exploredArea[2][1]+size, exploredArea[2][2]+size} };

	searchForOre = not hasEnoughOres();
end

function Explore(x, y, x2, y2)
	-- get known areas and expand known areas by a certain size or till a certain goal is met
	player.force.chart(player.surface, {{x, y}, {x2, y2}});
end

function getRecipes()
	-- https://lua-api.factorio.com/latest/LuaForce.html#LuaForce.recipes 
	-- https://lua-api.factorio.com/latest/LuaRecipe.html
	local result = {};
	for _, recipe in pairs(player.force.recipes) do
		if recipe.enabled then
			debug("Recipe: "..recipe.name);
			table.insert(result, recipe);
		end
	end
	return result;
end

function getRecipe(recipeName)
	return player.force.recipes[recipeName];
end

function getRecipeRequirements(recipeName, resources)
	debug("Getting Recipe Requirements For: "..recipeName);
	local recipe = getRecipe(recipeName);
	if recipe ~= nil then
		for _, ingredient in pairs(recipe.ingredients) do
			local item = {
				type = ingredient.type,
				name = ingredient.name,
				amount = ingredient.amount,
				isRawResource = isItemRawResource(ingredient.name),
				isEnabled = isRecipeEnabled(ingredient.name)
			};
			local resourceExists = false;
			local resourceIndex = 0;

			-- does resources table contain the ingredient? 
			for index, resource in pairs(resources) do
				if resource.name == ingredient.name then
					-- update table
					resourceExists = true;

					item.amount = resources[index].amount + item.amount;
					resources[index] = item;
					break
				end
			end
			if not resourceExists then
				-- insert into table
				table.insert(resources, item);
			end

			if getRecipe(ingredient.name) ~= nill then
				resources = getRecipeRequirements(ingredient.name, resources);
			end
		end
	end
	return resources;
end

function isItemRawResource(itemName)
	if getRecipe(itemName) == nil then
		--debug("isItemRawResource: "..itemName..": true");
		return true;
	end
	--debug("isItemRawResource: "..itemName..": false");

	return false;
end

function isRecipeEnabled(recipeName)
	local recipe = getRecipe(recipeName);
	if recipe ~= nil then
		return recipe.enabled;
	end
	return false;
end

function getResearchableTech()
	-- https://lua-api.factorio.com/latest/LuaForce.html#LuaForce.technologies 
	-- https://lua-api.factorio.com/latest/LuaTechnology.html
	-- get researchable technologies, ordered by most beneficial first, benfit is weighted by first increased production types, then enhancements. Tech that is not researchable (research type is not produced yet) is also filtered out.
	for _, technology in pairs(player.force.technologies) do
		debug("Technology: "..technology.name..", Enabled: "..(technology.enabled and 'true' or 'false')..", Researched: "..(technology.researched and 'true' or 'false')..", Valid: "..(technology.valid and 'true' or 'false'));
		if technology.enabled == true and technology.researched == false then -- enabled = can be researched
			--debug(technology.enabled);
			--debug(technology.researched);
			--debug(technology.order);	
		end
	end
end

function startResearch()
end

function hasEnoughOres()
	local counts = game.surfaces[1].get_resource_counts();
	-- debug(serpent.block(counts));
	if not counts["crude-oil"] or (counts["crude-oil"] and counts["crude-oil"] < minOilCount) then 
		--debug(counts["crude-oil"]);
		debug("Not Enough Oil...");
		return false;
	elseif not counts["iron-ore"] or (counts["iron-ore"] and counts["iron-ore"] < minIronOreCount) then
		--debug(counts["iron-ore"]);
		debug("Not Enough Iron Ore...");
		return false;
	elseif not counts["copper-ore"] or (counts["copper-ore"] and counts["copper-ore"] < minCopperOreCount) then
		--debug(counts["copper-ore"]);
		debug("Not Enough Copper Ore...");
		return false;
	elseif not counts["uranium-ore"] or (counts["uranium-ore"] and counts["uranium-ore"] < minUraniumOreCount) then
		--debug(counts["uranium-ore"]);
		debug("Not Enough Uranium Ore...");
		return false;
	elseif not counts["coal"] or (counts["coal"] and counts["coal"] < minCoalCount) then
		--debug(counts["coal"]);
		debug("Not Enough Coal...");
		return false;
	elseif not counts["stone"] or (counts["stone"] and counts["stone"] < minStoneCount) then
		--debug(counts["stone"]);
		debug("Not Enough Stone...");
		return false;
	end
	return true;
end

function ClearArea(x, y, x2, y2, type)
	items = getItemsInArea(x, y, x2, y2, type);
  	for _, item in pairs(items) do
  		item.destroy();
  	end
end

function getItemsInArea(x, y, x2, y2, type)
	if type == "player" then
		return game.player.surface.find_entities({{x, y}, {x2, y2}});
	elseif type == "resource" then
		return game.surfaces[1].find_entities_filtered{area = {{x, y}, {x2, y2}}, type= "resource"}
	end
	return game.surfaces[1].find_entities({{x, y}, {x2, y2}});
end

function getTiles(x, y, x2, y2)
	tiles= {};
	for i=x, x2, 1 do
		for j=y, y2, 1 do
			table.insert(tiles, getTile(i,j));
		end
	end
	return tiles;
end

-- run this every onTick event
script.on_event(defines.events.on_tick, onTick);
