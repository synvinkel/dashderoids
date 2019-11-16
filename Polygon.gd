extends RigidBody2D

export var debug = false
export var max_speed = 800
onready var skepp = $"../Skepp"
onready var polygon = $Polygon2D
onready var collision_polygon = $CollisionPolygon2D
var Polygon = load("res://Polygon.tscn") 
var intersections = []
var lhs_poly = []
var rhs_poly = []
export var first = false

var poly_label = Label.new()
var poly_font = poly_label.get_font("")

var line = []

var new_poly = []

signal camera_shake_requested
signal stone_split

func init(_new_poly, _new_pos, _new_vel, _new_angular, _rotation, _debug):
    new_poly = _new_poly
    rotation = _rotation
    position = _new_pos
    angular_velocity = _new_angular
    linear_velocity = _new_vel
    debug = _debug

func sync_polygon_and_collision():
    collision_polygon.position = polygon.position
    collision_polygon.polygon = polygon.polygon
    update()

func set_new_polygon(_new_poly):
    polygon.polygon = _new_poly
    sync_polygon_and_collision()
    
func _ready():
    add_to_group("camera_shaker")
    if skepp:
        skepp.connect("boost", self, "_on_Skepp_boost")
        skepp.connect("boosted", self, "split")
    if(new_poly != []):
        set_new_polygon(new_poly)
    else:
        sync_polygon_and_collision()
    # Sync up position with centroid
#    var p_centroid = G.centroid(polygon.polygon)
#    for i in polygon.polygon.size():
#        polygon.polygon[i] -= p_centroid
    mass = G.area(polygon.polygon)
    if mass < 4000:
        $DeathTimer.start()
        $Animation.play("blink")
    
    if debug:
        polygon.color.a = 0.1

func kill():
    queue_free()
    
func _draw():
    if(debug):
        var p = polygon.polygon
    #    draw polygon edges
        for i in p.size():
            draw_line(p[i],p[((i + 1) % p.size() )], Color.red)
        
        draw_circle(Vector2(), 15, Color.pink)
        draw_circle(G.centroid(p), 10, Color.green)
            
    #    draw intersection points
        for intersect in intersections:
            draw_circle(intersect, 10, Color.red)
        
        for i in lhs_poly.size():
            draw_line(lhs_poly[i],lhs_poly[((i + 1) % lhs_poly.size() )], Color.red, 3.0)
            draw_string(poly_font, lhs_poly[i], str(i), Color.black)
        for i in rhs_poly.size():
            draw_line(rhs_poly[i],rhs_poly[((i + 1) % rhs_poly.size() )], Color.blue, 3.0)
            draw_string(poly_font, rhs_poly[i], str(i), Color.black)

func split() -> void:
    if lhs_poly != [] and rhs_poly != []:
        var lhs_centroid = G.centroid(lhs_poly)
        var rhs_centroid = G.centroid(rhs_poly)

        for i in lhs_poly.size():
            lhs_poly[i] -= lhs_centroid
        
        for i in rhs_poly.size():
            rhs_poly[i] -= rhs_centroid
        
        var lhs = Polygon.instance()
        lhs.init(lhs_poly, position + lhs_centroid.rotated(rotation), linear_velocity + lhs_centroid.rotated(rotation), angular_velocity, rotation, debug)
        get_parent().add_child(lhs)
        var rhs = Polygon.instance()
        rhs.init(rhs_poly, position + rhs_centroid.rotated(rotation), linear_velocity + rhs_centroid.rotated(rotation), angular_velocity, rotation, debug)
        get_parent().add_child(rhs)
        emit_signal("camera_shake_requested")
        emit_signal("stone_split")
        queue_free()
        
func wrap_around(state) -> void:
    var size : Vector2 = get_viewport().size
    var xform = state.get_transform()
    
    xform.origin.x = wrapf(xform.origin.x, 0, size.x)
    xform.origin.y = wrapf(xform.origin.y, 0, size.y)
    
    state.set_transform(xform)
        
func _integrate_forces(state):
    wrap_around(state)
    sync_polygon_and_collision()
    
    $SizeIndicator/Control.position = position
    
    if first:
       angular_velocity = 0.2
    
    if line.size() == 2:
        # 2D plane
        var dvec = (line[0] - line[1]).normalized()
        var normal = Vector2(dvec.y, -dvec.x)
        var N = normal
        var D = normal.dot(line[0])
                       
        intersections.clear()            
        lhs_poly.clear()
        rhs_poly.clear()
    
        var p = polygon.polygon
        var t = polygon.get_global_transform()
        var i = 0
        for i in p.size():
            var dist = N.dot(t.xform(p[i])) - D
            if dist < 0:
                lhs_poly.push_back(p[i])
            else:
                rhs_poly.push_back(p[i])
                
            var polygon_segment = [ t.xform(p[i]) , t.xform(p[((i + 1) % p.size() )]) ]
            var intersection = G.intersect(polygon_segment, line)
            if intersection:
                lhs_poly.push_back(t.xform_inv(intersection))
                rhs_poly.push_back(t.xform_inv(intersection))
                intersections.push_back(t.xform_inv(intersection))
                
     
        if intersections.size() != 2:
            lhs_poly.clear()
            rhs_poly.clear()

    update()
    linear_velocity = linear_velocity.clamped(max_speed)

func _on_Skepp_boost(_line):
    line = _line
