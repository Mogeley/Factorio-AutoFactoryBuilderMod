
-- need way to determine "need" for each resource
-- need iterative method to determine "effectiveness", "eficiency", "resource need" of resource production and transportation layout
-- need way to prevent "circular designs", IE keep the iterating to a new design instead of repeating old designs. 
-- "effectiveness" - answers the question, Are enough resources being produced fast enough? and Are resources transported fast enough? 
-- "eficiency" - answers thw question: Can I produce less of a certain resource? and Are there ways to transport resources faster? Are there any choke points? 
-- "resource need" - where are resources needed the most? big picture of where the resources need to go.

-- Algorithm ideas. Start with designed end product for each resource per second then work back to what is needed for each and the recource bandwidth needed.

-- later can try an eficiency of space 

function Explore()
	-- get known areas and expand known areas by a certain size or till a certain goal is met
end

function getRecipes()
end

function getRecipeRequirements()
end

function getResearchableTech()
	-- get researchable technologies, ordered by most beneficial first
end

function startResearch()
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

--/c for _, entity in ipairs(game.player.surface.find_entities_filtered{
--       area={{game.player.position.x-32, game.player.position.y-32},
--          {game.player.position.x+32, game.player.position.y+32}},
--           name="stone-rock"})
--do
--    entity.destroy()
--end
