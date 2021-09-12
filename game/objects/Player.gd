extends RigidBody2D

export(float) var torque = 30
export(float) var brake_torque = 10
export(float) var jump_force = 200
export(float) var air_speed = 4

func _physics_process(delta):
	if(Input.is_action_pressed("left")):
		angular_velocity -= delta*torque
	elif(Input.is_action_pressed("right")):
		angular_velocity += delta*torque
	else:
		angular_velocity -= angular_velocity*(brake_torque*delta)

#holds the object to be jumped off of and the normal of our collision
var jump_info:Array = [null, Vector2()]

func _integrate_forces(state):
	if(state.get_contact_count() > 0):
		var p_i = 0
		for i in range(state.get_contact_count()):
			if(state.get_contact_collider_object(i).is_in_group("physics")):
				p_i = i
				break
		jump_info = [state.get_contact_collider_object(p_i), state.get_contact_local_normal(p_i)]
		can_jump = true
		$GroundCooldown.start()
	else:
		if(Input.is_action_pressed("left")):
			state.linear_velocity.x -= air_speed
		elif(Input.is_action_pressed("right")):
			state.linear_velocity.x += air_speed
	if(Input.is_action_just_pressed("jump") and can_jump and jump_info[0] != null):
		can_jump = false
		state.linear_velocity += jump_info[1]*jump_force
		var col = jump_info[0]
		if(col.is_in_group("physics")):
			col.linear_velocity -= jump_info[1]*jump_force

func _process(_delta):
	$Face.rotation = -rotation+linear_velocity.x*0.001

var can_jump:bool = false
func _on_GroundCooldown_timeout():
	can_jump = false
