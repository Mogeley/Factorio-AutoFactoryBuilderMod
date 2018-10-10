# Factorio-Auto Factory Builder Design
Auto Factory Builder for Factorio

## Build Logic

In short Auto Factory Builder tries to create x number of each craftable item and stores them for use. Starting with a low number (like 10) the AI can increase/decrease the needed number of items as need is determined. The AI first determines which recipes are currently craftable and which are blocked by lack of recources or lack of research (which is a kind of lack of resources).

When starting a map the AI will need to farm for small amounts of coal or wood and setup a small powerplant.

The AI will attempt to research each kind of research that results in more kinds of craftable items first, then enhancements.

Note - the AI currently does not consider resources for building structures. A strict mode could be added later to enforce the AI to the same limits as a regular player and crafting items.

1. Determine craftable recipes
1. Determine items/second to produce
1. Determine prerequisite items/second to produce recursively
1. Determine amounts of ore/second needed
  1. Use needed ore/second to determine if more mines are needed
1. Setup Ore mines
  1. for layout interation use crates full of ore
1. Estimate required power
1. Setup Powerplant
1. Setup transportation routes and power lines
1. Setup Factory
  1. Make a guess as to layout and setup
1. Monitor power
  1. increase plant size as needed
1. Monitor production
  1. Monitor effectiveness
  1. Monitor Time - need to wait till resources reach factory then start or just fill crates with resources for this testing
1. Monitor transportation
  1. Are there choke points?
  1. Are there enough resources and resources/second? 

1. Overall logic
  1. Save layout pattern with monitoring results and score
  1. make new guesses
  1. wipe factory and start with new guesses
  1. Monitor
  1. Is the result better / worse


-- need way to determine "need" for each resource
-- need iterative method to determine "effectiveness", "eficiency", "resource need" of resource production and transportation layout
-- need way to prevent "circular designs", IE keep the iterating to a new design instead of repeating old designs. 
-- "effectiveness" - answers the question, Are enough resources being produced fast enough? and Are resources transported fast enough? 
-- "eficiency" - answers thw question: Can I produce less of a certain resource? and Are there ways to transport resources faster? Are there any choke points? 
-- "resource need" - where are resources needed the most? big picture of where the resources need to go.

-- Algorithm ideas. Start with designed end product for each resource per second then work back to what is needed for each and the recource bandwidth needed.