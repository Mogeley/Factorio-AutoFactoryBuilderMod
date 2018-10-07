
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
local exploreInterval = 1800; -- 1800 = 30 seconds
local exploredArea = {{0,0}, {0,0}};

-- set initial minimums for map exploration. these numbers should be increased as the factory needs more resources
local minOilCount = 1000;
local minIronOreCount = 10000;
local minCopperOreCount = 10000;
local minUraniumOreCount = 10000;
local minCoalCount = 10000;
local minStoneCount = 10000;


function onTick()
	if firstTick then
		SetupStartingArea();
		firstTick = false;
	elseif event.tick % exploreInterval == 0 and searchForOre then
		expandExploredArea();
	end
end

function SetupStartingArea()
	-- clear all ore in 200 x 200 area
	ClearArea(-100, -100, 100, 100, "resource");
end

function expandExploredArea()
	Explore(exploredArea[1][1]-100, exploredArea[1][2]-100, exploredArea[2][1]+100, exploredArea[1][1]); -- top
	Explore(exploredArea[1][1]-100, exploredArea[1][2], exploredArea[1][1], exploredArea[2][2]); -- left
	Explore(exploredArea[1][1], exploredArea[1][2], exploredArea[2][1]+100, exploredArea[2][2]); -- right
	Explore(exploredArea[1][1]-100, exploredArea[2][2], exploredArea[2][1]+100, exploredArea[2][2]+100); -- bottom

	exploredArea = { {exploredArea[1][1]-100, exploredArea[1][2]-100}, {exploredArea[2][1]+100, exploredArea[2][2]+100} };

	searchForOre = not hasEnoughOres();
end

function Explore(x, y, x2, y2)
	-- get known areas and expand known areas by a certain size or till a certain goal is met
	game.player.force.chart(game.player.surface, {{x, y}, {x2, y2}});
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
	if counts["crude-oil"] < minOilCount then
		return false;
	if counts["iron-ore"] < minIronOreCount then
		return false;
	if counts["copper-ore"] < minCopperOreCount then
		return false;
	if counts["uranium-ore"] < minUraniumOreCount then
		return false;
	if counts["coal"] < minCoalCount then
		return false;
	if counts["stone"] < minStoneCount then
		return false;
	return true;
end

function ClearArea(x, y, x2, y2, type)
	items = getItemsInArea(x, y, x2, y2, type);
  	for _, item in pairs(items) do
  		item.destroy();
  	end
end

function getItemsInArea(x, y, x2, y2, type)
	if type == "player" do
		return game.player.surface.find_entities({{x, y}, {x2, y2}});
	else if type == "resource" do
		return game.surfaces[1].find_entities_filtered{area = {{x, y}, {x2, y2}}, type= "resource"}
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
