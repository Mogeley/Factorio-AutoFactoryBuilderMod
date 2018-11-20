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

return EntityProperties;