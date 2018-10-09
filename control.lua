
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
local exploreInterval = 1200; -- 1800 = 30 seconds
local exploredArea = {{0,0}, {0,0}};

-- set initial minimums for map exploration. these numbers should be increased as the factory needs more resources
local minOilCount = 1000000;
local minIronOreCount = 1000000;
local minCopperOreCount = 1000000;
local minUraniumOreCount = 1000000;
local minCoalCount = 1000000;
local minStoneCount = 1000000;
local player;


function onTick(event)
	if firstTick then
		player = game.players[1];
		player.print("Starting Auto Factory Builder...");
		SetupStartingArea();
		firstTick = false;
	elseif event.tick % exploreInterval == 0 and searchForOre then
		player.print("Searching for Ore...");
		expandExploredArea();
	end
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
end

function getRecipeRequirements()
end

function getResearchableTech()
	-- get researchable technologies, ordered by most beneficial first, benfit is weighted by first increased production types, then enhancements. Tech that is not researchable (research type is not produced yet) is also filtered out.
end

function startResearch()
end

function hasEnoughOres()
	local counts = game.surfaces[1].get_resource_counts();
	-- wplayer.print(serpent.block(counts));
	if not counts["crude-oil"] or (counts["crude-oil"] and counts["crude-oil"] < minOilCount) then 
		--player.print(counts["crude-oil"]);
		player.print("Not Enough Oil...");
		return false;
	elseif not counts["iron-ore"] or (counts["iron-ore"] and counts["iron-ore"] < minIronOreCount) then
		--player.print(counts["iron-ore"]);
		player.print("Not Enough Iron Ore...");
		return false;
	elseif not counts["copper-ore"] or (counts["copper-ore"] and counts["copper-ore"] < minCopperOreCount) then
		--player.print(counts["copper-ore"]);
		player.print("Not Enough Copper Ore...");
		return false;
	elseif not counts["uranium-ore"] or (counts["uranium-ore"] and counts["uranium-ore"] < minUraniumOreCount) then
		--player.print(counts["uranium-ore"]);
		player.print("Not Enough Uranium Ore...");
		return false;
	elseif not counts["coal"] or (counts["coal"] and counts["coal"] < minCoalCount) then
		--player.print(counts["coal"]);
		player.print("Not Enough Coal...");
		return false;
	elseif not counts["stone"] or (counts["stone"] and counts["stone"] < minStoneCount) then
		--player.print(counts["stone"]);
		player.print("Not Enough Stone...");
		return false;
	end
	return true;


	--if counts["crude-oil"] < minOilCount then
	--	return false;
	--elseif counts["iron-ore"] < minIronOreCount then
	--	return false;
	--elseif counts["copper-ore"] < minCopperOreCount then
	--	return false;
	--elseif counts["uranium-ore"] < minUraniumOreCount then
	--	return false;
	--elseif counts["coal"] < minCoalCount then
	--	return false;
	--elseif counts["stone"] < minStoneCount then
	--	return false;
	--end
	--return true;
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
