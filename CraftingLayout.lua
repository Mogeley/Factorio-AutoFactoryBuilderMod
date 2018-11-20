-- Plans layouts

LayoutPlanner = {}

function LayoutPlanner:New(craftingPlan)
    local this = {
        craftingPlan = craftingPlan
        grid = {},
        nodes = {}
    }

    -- determine output inserter needed - to maintain CraftingPlan.itemRate
    
    return this;
end

return LayoutPlanner;