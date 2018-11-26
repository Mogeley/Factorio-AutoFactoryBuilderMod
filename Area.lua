-- simple Area class


Area = {}
function Area:New(x1,y1,x2,y2)
    local this = {
        x1=x1,
        y1=y1,
        x2=x2,
        y2=y2
    }
    return this;
end