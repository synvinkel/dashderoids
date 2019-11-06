extends Node
# Line/line intersection from turf.js
# https://github.com/Turfjs/turf/blob/master/packages/turf-line-intersect/index.ts
func intersect(coords1, coords2):
    var x1 = coords1[0][0]
    var y1 = coords1[0][1]
    var x2 = coords1[1][0]
    var y2 = coords1[1][1]
    var x3 = coords2[0][0]
    var y3 = coords2[0][1]
    var x4 = coords2[1][0]
    var y4 = coords2[1][1]
    var denom = ((y4 - y3) * (x2 - x1)) - ((x4 - x3) * (y2 - y1))
    var numeA = ((x4 - x3) * (y1 - y3)) - ((y4 - y3) * (x1 - x3))
    var numeB = ((x2 - x1) * (y1 - y3)) - ((y2 - y1) * (x1 - x3))

    if denom == 0:
        if numeA == 0 and numeB == 0:
            return null
        return null

    var uA = numeA / denom
    var uB = numeB / denom

    if uA >= 0 and uA <= 1 and uB >= 0 and uB <= 1:
        var x = x1 + (uA * (x2 - x1))
        var y = y1 + (uA * (y2 - y1))
        return Vector2(x, y)
    return null
