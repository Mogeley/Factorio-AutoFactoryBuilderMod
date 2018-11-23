-- simple position class

Position = {}
function Position:New(x,y)
    local this = {
        x=x,
        y=y
    }
    return this;
end