extends Node

class State:
    func enter(entity):
        pass
    func update(entity, delta):
        pass
    func exit(entity):
        pass

class SkeppBaseState extends State:
    func update(skepp, delta):
        # Inputs
        var rotation_dir = 0
        if Input.is_action_pressed("turn_left"):
            rotation_dir -= 1
        if Input.is_action_pressed("turn_right"):
            rotation_dir += 1
        if Input.is_action_pressed("thrust"):
            skepp.apply_force(Vector2(skepp.speed, 0).rotated(skepp.rotation))            
        if Input.is_action_just_pressed("thrust"):
            skepp.thrust_audio.play("fade_in")
        if Input.is_action_just_released("thrust"):
            skepp.thrust_audio.play("fade_out")

        # Physics/movement
        skepp.rotation += rotation_dir * skepp.rotation_speed * delta
        skepp.apply_friction()
        skepp.velocity += skepp.acceleration
        skepp.velocity = skepp.velocity.clamped(skepp.max_speed)
        var collision_info = skepp.move_and_collide(skepp.velocity * delta)
        skepp.acceleration *= 0
        
        skepp.wrap_around()

class SkeppIdle extends SkeppBaseState:
    func update(skepp, delta):
        if Input.is_action_pressed("boost"):
            if skepp.boost_cool:
                skepp.state = States.SkeppBoosting.new()
        .update(skepp, delta)
            
class SkeppBoosting extends SkeppBaseState:
    func enter(skepp):
        skepp.boost_line_tween.interpolate_property(skepp, "boost_mag", 0.0, 1.0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        skepp.boost_line_tween.start()

    func update(skepp, delta):
        if Input.is_action_just_released("boost"):
            if skepp.boost_mag > 0.5:
                skepp.play_animation("boosted")
            skepp.state = States.SkeppIdle.new()
            return

        var t : Transform = skepp.get_global_transform()
        skepp.get_node("AreaHolder/Area2D").position = t.xform(skepp.get_boost_point())
        skepp.get_node("AreaHolder/Area2D").rotation = skepp.rotation
        skepp.boost_line.points = [Vector2(), skepp.get_boost_point()]
        skepp.emit_signal("boost", [skepp.global_position, skepp.global_position + Vector2(skepp.boost_len * skepp.boost_mag, 0).rotated(skepp.rotation)])
        skepp.boost_line.visible = true
        
        var bodies = skepp.get_node("AreaHolder/Area2D").get_overlapping_areas()
        for body in bodies:
            print("DEATH TO YOU! in the interzone")            
            skepp.deathzone = true
            print(body)
            
#        else:
#            skepp.deathzone = false

        .update(skepp, delta)

    func exit(skepp):
        if skepp.deathzone:
            print("DEATH TO YOU!")
        skepp.move_and_collide(Vector2(skepp.boost_len * skepp.boost_mag, 0).rotated(skepp.rotation))
        skepp.boost_line.visible = false
        skepp.boost_line.points = []
        skepp.boost_cool = false
        skepp.boost_mag = 0                
        skepp.boost_line_cooloff.start()
        skepp.boost_audio.play()
        skepp.emit_signal("boosted")


#        skepp.get_node("Area2D").position = Vector2()
        