extends RigidBody2D

export var debug = false
onready var line = $"../Line2D"
onready var polygon = $Polygon2D
onready var collision_polygon = $CollisionPolygon2D
var Polygon = load("res://Polygon.tscn") 
var intersections = []
var lhs_poly = []
var rhs_poly = []

var poly_label = Label.new()
var poly_font = poly_label.get_font("")

var new_poly = []

func init(_new_poly, _new_pos, _new_vel, _new_angular, _debug):
    new_poly = _new_poly
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
    if(new_poly != []):
        set_new_polygon(new_poly)
    else:
        sync_polygon_and_collision()
    
func _draw():
    if(debug):
        var p = polygon.polygon
    #    draw polygon edges
        for i in p.size():
            draw_line(p[i],p[((i + 1) % p.size() )], Color.red)
        
        var t = polygon.get_global_transform_with_canvas()    
        draw_circle(t.xform_inv(position), 10, Color.pink)
            
    #    draw intersection points
        for intersect in intersections:
            draw_circle(intersect, 10, Color.red)
        
        for i in lhs_poly.size():
            draw_line(lhs_poly[i],lhs_poly[((i + 1) % lhs_poly.size() )], Color.red, 3.0)
            draw_string(poly_font, lhs_poly[i], str(i), Color.black)
        for i in rhs_poly.size():
            draw_line(rhs_poly[i],rhs_poly[((i + 1) % rhs_poly.size() )], Color.blue, 3.0)
            draw_string(poly_font, rhs_poly[i], str(i), Color.black)
     
func _process(delta):
    if Input.is_action_just_pressed("ui_down"):
        if lhs_poly != [] and rhs_poly != []:
            var lhs = Polygon.instance()
            lhs.init(lhs_poly, position, -linear_velocity * 0.4, angular_velocity, debug)
            get_parent().add_child(lhs)
            var rhs = Polygon.instance()
            rhs.init(rhs_poly, position, linear_velocity, rand_range(-10.0, 10.0), debug)
            get_parent().add_child(rhs)
            queue_free()
        
func _physics_process(delta):
    sync_polygon_and_collision()
    
    # 2D plane
    var dvec = (line.points[0] - line.points[1]).normalized()
    var normal = Vector2(dvec.y, -dvec.x)
    var N = normal
    var D = normal.dot(line.points[0])
                   
    intersections.clear()            
    lhs_poly.clear()
    rhs_poly.clear()

    var p = polygon.polygon
    var t = polygon.get_global_transform_with_canvas()
    var i = 0
    for i in p.size():
        var dist = N.dot(t.xform(p[i])) - D
        if dist < 0:
            lhs_poly.push_back(p[i])
        else:
            rhs_poly.push_back(p[i])
            
        var polygon_segment = [ t.xform(p[i]) , t.xform(p[((i + 1) % p.size() )]) ]
        var intersection = G.intersect(polygon_segment, line.points)
        if intersection:
            lhs_poly.push_back(t.xform_inv(intersection))
            rhs_poly.push_back(t.xform_inv(intersection))
            intersections.push_back(t.xform_inv(intersection))
            
 
    if intersections.size() != 2:
        lhs_poly.clear()
        rhs_poly.clear()

    update()