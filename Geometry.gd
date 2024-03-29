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
    
func centroid(polygon : Array) -> Vector2:
    var xSum : float = 0
    var ySum : float = 0
    var length : int = 0
    for point in polygon:
        xSum += point[0]
        ySum += point[1]
        length += 1
    return Vector2(xSum / length, ySum / length)
    
# https://stackoverflow.com/a/24468019 
# Shoelace formula
func area(polygon : Array) -> int:
    var n : int = polygon.size() # of corners
    var area : float = 0.0
    for i in range(n):
        var j = (i + 1) % n
        area += polygon[i][0] * polygon[j][1]
        area -= polygon[j][0] * polygon[i][1]
    area = abs(area) / 2.0
    return int(area)
