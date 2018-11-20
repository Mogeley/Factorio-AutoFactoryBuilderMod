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
    return assemblerSpeed[assemblerSpeed];
end

return EntityProperties;