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
local exploreTick = exploreInterval;
local buildTick = 600;
local build = true;
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

local beltRate = {}; -- items per minute
beltRate["transport-belt"] = 800;
beltRate["fast-transport-belt"] = 1600;
beltRate["express-transport-belt"] = 2400;

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


function onTick(event)
	if firstTick then
		player = game.players[1];
		debug("Starting Auto Factory Builder...");
		--SetupStartingArea();
		firstTick = false;

		recipes = getRecipes();
		--getResearchableTech();
	else
		if event.tick > exploreTick and searchForOre then
			debug("Searching for Ore...");
			expandExploredArea();
			exploreTick = exploreTick + exploreInterval;
		end
		if event.tick > buildTick and build then
			newSaturatedBelt(getRecipe("solar-panel"), "transport-belt", {100,0}, defines.direction.west);
			build = false;
		end
	end
end

function newSaturatedBelt(recipe, beltName, beltEndPosition, beltDirection)
	-- determine items per minute to saturate belt
	local saturatedItemRate = beltRate[beltName];
	local bestCrafterType = "";

	-- determine number of assemblers, smelters, miners, trains, or rockets needed to meet the needed rate
	if recipe.category == "crafting" or recipe.category == "advanced-crafting" or recipe.category == "crafting-with-fluid" then
		bestCrafterType = getBestAvailableAssembler();
	elseif recipe.category == "smelting" then
		bestCrafterType = getBestAvailableSmelter();	
	elseif recipe.category == "chemistry" then
		bestCrafterType = "chemical-plant";
	elseif recipe.category == "oil-processing" then
		bestCrafterType = "oil-refinery";
	elseif recipe.category == "rocket-building" then
		bestCrafterType = "rocket-silo";
	elseif recipe.category == "centrifuging" then
		bestCrafterType = "centrifuge";
	end

	local itemRate = 60 / recipe.energy / assemblerSpeed[bestCrafterType]; -- items/minute
	local numberOfCrafters = roundUp(saturatedItemRate / itemRate);

	-- get ingredients
	local ingredients = recipe.ingredients;

	-- calculate the number of crafters in a row can be placed before items on supply belt are used
	local crafterDepth = 1000;
	for _, ingredient in pairs(ingredients) do
		ingredientsPerMinute = itemRate * ingredient.amount;
		local temp = math.floor(saturatedItemRate / ingredientsPerMinute);
		if temp < crafterDepth then -- crafterDepth is the maximum number of crafters that can be built in a row per saturated belt.
			crafterDepth = temp;
		end
	end
	local crafterWidth = roundUp(numberOfCrafters / (crafterDepth * 2));

	SetupCrafterLayout(recipe, beltName, beltEndPosition, beltDirection);

	-- create output belts bus to end position and direction
end

function SetupCrafterLayout(recipe, beltName, beltEndPosition, beltDirection)
	local width = getEntityWidth(recipe.name);
	local heigth = getEntityHeight(recipe.name);

	local x_offset = 0;
	local y_offset = 0;
	local x_column_offset = 0;
	local y_column_offset = 0;
	local beltLength = width + 4;
	local crafterLength = width;
	local beltDirectionLeft;
	local beltDirectionRight;
	if beltDirection == defines.direction.north then
		x_column_offset = 1;
		y_offset = -1;
		beltLength = heigth + 4;
		crafterLength = height;
		beltDirectionLeft = defines.direction.west;
		beltDirectionRight = defines.direction.east;
	elseif beltDirection == defines.direction.south then
		x_column_offset = 1;
		y_offset = 1;
		beltLength = heigth + 4;
		crafterLength = height;
		beltDirectionLeft = defines.direction.east;
		beltDirectionRight = defines.direction.west;
	elseif beltDirection == defines.direction.east then
		y_column_offset = 1;
		x_offset = -1;
		beltDirectionLeft = defines.direction.north;
		beltDirectionRight = defines.direction.south;
	elseif beltDirection == defines.direction.west then
		y_column_offset = 1;
		x_offset = 1;
		beltDirectionLeft = defines.direction.south;
		beltDirectionRight = defines.direction.north;
	end

	-- start with output belt, then put crafters on each side
	for l=0, beltLength, 1 do
		game.surfaces[1].create_entity({name=beltName, position={beltEndPosition.x+l*x_offset,beltEndPosition.y+l*y_offset}, direction=beltDirection, force="player" });
	end

	

	if string.match(recipe.name, "assembling-machine") or recipe.name == "electric-furnace" then
		local beltpos = 2;
		for _, ingredient in pairs(recipe.ingredients) do
			if ingredient.type == "item" then
				if beltpos > 4 then -- full belts
					for l=0, beltLength, 1 do
						-- left side
						game.surfaces[1].create_entity({
							name=beltName, 
							position={beltEndPosition.x+l*x_offset-beltpos*x_column_offset,beltEndPosition.y+l*y_offset-beltpos*y_column_offset}, 
							direction=beltDirection, 
							force="player" 
						});

						-- right side
						game.surfaces[1].create_entity({
							name=beltName, 
							position={beltEndPosition.x+l*x_offset+beltpos*x_column_offset,beltEndPosition.y+l*y_offset+beltpos*y_column_offset}, 
							direction=beltDirection, 
							force="player" 
						});
					end
					-- inserters
					-- input inserter

					
				else -- underground belts
					-- left side
					-- input
					game.surfaces[1].create_entity({
						name=undergroundBeltName, 
						position={beltEndPosition.x+beltLength*x_offset-beltpos*x_column_offset,beltEndPosition.y+beltLength*y_offset-beltpos*y_column_offset}, 
						direction=beltDirection,
						force="player" 
					});
					-- output
					game.surfaces[1].create_entity({
						name=undergroundBeltName, 
						position={beltEndPosition.x-beltpos*x_column_offset,beltEndPosition.y-beltpos*y_column_offset}, 
						direction=beltDirection,
						force="player" 
					});
					game.surfaces[1].create_entity({
						name="stack-inserter", 
						position={beltEndPosition.x+(2+crafterLength)*x_offset-beltpos*x_column_offset,beltEndPosition.y+(2+crafterLength)*y_offset-beltpos*y_column_offset}, 
						direction=beltDirection,
						force="player" 
					});

					-- right side
					-- input
					game.surfaces[1].create_entity({
						name=undergroundBeltName, 
						position={beltEndPosition.x+beltLength*x_offset+beltpos*x_column_offset,beltEndPosition.y+beltLength*y_offset+beltpos*y_column_offset}, 
						direction=beltDirection,
						force="player" 
					});
					-- output
					game.surfaces[1].create_entity({
						name=undergroundBeltName, 
						position={beltEndPosition.x+beltpos*x_column_offset,beltEndPosition.y+beltpos*y_column_offset}, 
						direction=beltDirection,
						force="player" 
					});
					game.surfaces[1].create_entity({
						name="stack-inserter", 
						position={beltEndPosition.x+(2+crafterLength)*x_offset+beltpos*x_column_offset,beltEndPosition.y+(2+crafterLength)*y_offset+beltpos*y_column_offset}, 
						direction=beltDirection,
						force="player" 
					});
				end

				beltpos = beltpos + 1;
				if beltpos == 5 then
					beltpos = 6;
				end
			else
			end
		end

		-- output inserters
		-- left
		game.surfaces[1].create_entity({
			name="stack-inserter", 
			position={beltEndPosition.x+2*x_offset-1*x_column_offset,beltEndPosition.y+2*y_offset-1*y_column_offset}, 
			direction=beltDirectionRight, 
			force="player" 
		});
		game.surfaces[1].create_entity({
			name="stack-inserter", 
			position={beltEndPosition.x+2*x_offset+1*x_column_offset,beltEndPosition.y+2*y_offset+1*y_column_offset}, 
			direction=beltDirectionLeft, 
			force="player" 
		});
		-- right
	elseif string.match(recipe.name, "furnace") then
	elseif recipe.name == "oil-refinery" then
	elseif recipe.name == "chemical-plant" then
	elseif recipe.name == "rocket-silo" then
    end
end

function getBestAvailableAssembler()
	for _, recipe in pairs(recipes) do
		if recipe.name == "assembling-machine-3" then 
			return "assembling-machine-3";
		elseif recipe.name == "assembling-machine-2" then
			return "assembling-machine-2";
		elseif recipe.name == "assembling-machine-1" then
			return "assembling-machine-1";
		end
	end
	return "assembling-machine-1";
end

function getBestAvailableSmelter()
	for _, recipe in pairs(recipes) do
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

function EntityPrototype(entityName)
	return game.entity_prototypes[1][entityName];
end

function getEntityWidth(entityName)
	return math.abs(EntityPrototype(entityName).drawing_box.left_top.x - EntityPrototype(entityName).drawing_box.bottom_right.x);
end

function getEntityHeight(entityName)
	return math.abs(EntityPrototype(entityName).drawing_box.left_top.y - EntityPrototype(entityName).drawing_box.bottom_right.y);
end

function onResearchFinish(event)	
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
		debug("Recipe: "..recipe.name.." Category: "..recipe.category);
		if recipe.enabled then
			table.insert(result, recipe);
		end
	end
	return result;
end

function getRecipe(recipeName)
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

function getRecipeRequirements()
end

function getResearchableTech()
	-- https://lua-api.factorio.com/latest/LuaForce.html#LuaForce.technologies 
	-- https://lua-api.factorio.com/latest/LuaTechnology.html
	-- get researchable technologies, ordered by most beneficial first, benfit is weighted by first increased production types, then enhancements. Tech that is not researchable (research type is not produced yet) is also filtered out.
	local i = 1;
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

function roundUp(value)
	if math.fmod(value,1) > 0 then
		value = value + 1;
	end
	return math.floor(value);
end

-- run this every onTick event
script.on_event(defines.events.on_tick, onTick);
