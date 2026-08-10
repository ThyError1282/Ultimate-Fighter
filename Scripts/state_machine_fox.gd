class_name StateMachineFox extends StateMachine

@export var id: int = 1

func _ready() -> void:
	add_state("STAND")
	add_state("JUMP_SQUAT")
	add_state("SHORT_HOP")
	add_state("FULL_HOP")
	add_state("DASH")
	add_state("RUN")
	add_state("WALK")
	add_state("MOONWALK")
	add_state("TURN")
	add_state("CROUCH")
	add_state("AIR")
	add_state("LANDING")
	call_deferred("set_state", states.STAND)

func state_logic(delta) -> void:
	parent.update_frames(delta)
	parent._physics_process(delta)

func get_transition(delta):
	parent.move_and_slide()
	if landing() == true:
		parent.reset_frame()
		return states.LANDING
	
	if falling() == true:
		return states.AIR
	
	match state:
		states.STAND:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.reset_frame()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent.reset_frame()
				return states.CROUCH
			if Input.get_action_strength("right_%s" % id) == 1:
				parent.velocity.x = parent.RUNSPEED
				parent.reset_frame()
				parent.turn(false)
				return states.DASH
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.velocity.x = -parent.RUNSPEED
				parent.reset_frame()
				parent.turn(true)
				return states.DASH
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x += -parent.TRACTION * 1
				parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			if parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION * 1
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
		
		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump_%s" % id):
					parent.velocity.x = lerp(parent.velocity.x, 0.0, 0.08)
					parent.reset_frame()
					return states.SHORT_HOP
				else:
					parent.velocity.x = lerp(parent.velocity.x, 0.0, 0.08)
					parent.reset_frame()
					return states.FULL_HOP
		
		states.SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE
			parent.reset_frame()
			return states.AIR
		
		states.FULL_HOP:
			parent.velocity.y = -parent.MAX_JUMPFORCE
			parent.reset_frame()
			return states.AIR
		
		states.DASH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.reset_frame()
				return states.JUMP_SQUAT
			
			if Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent.reset_frame()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration - 1:
					if Input.is_action_pressed("down_%s" % id):
						parent.reset_frame()
						return states.MOONWALK
					parent.turn(true)
					return states.DASH
				else:
					parent.turn(true)
					parent.reset_frame()
					return states.RUN
			
			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent.reset_frame()
				parent.velocity.x = parent.DASHSPEED
				if parent.frame <= parent.dash_duration - 1:
					if Input.is_action_pressed("down_%s" % id):
						parent.reset_frame()
						return states.MOONWALK
					parent.turn(false)
					return states.DASH
				else:
					parent.turn(false)
					parent.reset_frame()
					return states.RUN
			
			else:
				if parent.frame >= parent.dash_duration - 1:
					for state in states:
						if state != "JUMP_SQUAT":
							parent.reset_frame()
							return states.STAND
		
		states.RUN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.reset_frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent.reset_frame()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				if parent.velocity.x <= 0:
					parent.velocity.x = -parent.RUNSPEED
					parent.turn(true)
				else:
					parent.reset_frame()
					return states.TURN
			elif Input.get_action_strength("right_%s" % id):
				if parent.velocity.x >= 0:
					parent.velocity.x = parent.RUNSPEED
					parent.turn(false)
				else:
					parent.reset_frame()
					return states.TURN
			else:
				parent.reset_frame()
				return states.STAND
		
		states.TURN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.reset_frame()
				return states.JUMP_SQUAT
			if parent.velocity.x > 0:
				parent.turn(true)
				parent.velocity.x += -parent.TRACTION * 2
				parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0:
				parent.turn(false)
				parent.velocity.x += parent.TRACTION * 2
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			else:
				if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
					parent.reset_frame()
					return states.STAND
				else:
					parent.reset_frame()
					return states.RUN
		
		states.MOONWALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.reset_frame()
				return states.JUMP_SQUAT
			
			elif Input.is_action_pressed("left_%s" % id) && parent.direction() == -1:
				if parent.velocity.x > 0:
					parent.reset_frame()
				parent.velocity.x += -parent.AIR_ACCEL * Input.get_action_strength("left_%s" % id)
				parent.velocity.x = clamp(parent.velocity.x, -parent.DASHSPEED * 1.4, parent.velocity.x)
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(false)
					return states.MOONWALK
				else:
					parent.turn(true)
					parent.reset_state()
					return states.STAND
			
			elif Input.is_action_pressed("right_%s" % id) && parent.direction() == 1:
				if parent.velocity.x > 0:
					parent.reset_frame()
				parent.velocity.x += parent.AIR_ACCEL * Input.get_action_strength("right_%s" % id)
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, parent.DASHSPEED * 1.4)
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(true)
					return states.MOONWALK
				else:
					parent.turn(false)
					parent.reset_state()
					return states.STAND
			
			else:
				if parent.frame >= parent.dash_duration - 1:
					for state in states:
						if state != "JUMP_STAND":
							return states.STAND
		
		states.WALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.reset_frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent.reset_frame()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				parent.velocity.x = -parent.WALKSPEED * Input.get_action_strength("left_%s" % id)
				parent.turn(true)
			if Input.get_action_strength("right_%s" % id):
				parent.velocity.x = parent.WALKSPEED * Input.get_action_strength("right_%s" % id)
				parent.turn(false)
			else:
				parent.reset_frame()
				return states.STAND
		
		states.CROUCH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.reset_frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("down_%s" % id):
				parent.reset_frame()
				return states.STAND
			elif parent.velocity.x > 0:
				if parent.velocity.x > parent.RUNSPEED:
					parent.velocity.x += -parent.TRACTION * 4
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				else:
					parent.velocity.x += -parent.TRACTION / 2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0:
				if abs(parent.velocity.x) > parent.RUNSPEED:
					parent.velocity.x += parent.TRACTION * 4
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
				else:
					parent.velocity.x += parent.TRACTION / 2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
		
		states.AIR:
			air_movement()
		
		states.LANDING:
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				if parent.frame == 1:
					pass
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x = parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
				if Input.is_action_just_pressed("jump_%s" % id):
					parent.reset_frame()
					return states.JUMP_SQUAT
			else:
				if Input.is_action_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent.reset_frame()
					return states.CROUCH
				else:
					parent.reset_frame()
					parent.lag_frames = 0
					return states.STAND
				parent.lag_frames = 0

func enter_state(new_state, old_state) -> void:
	match new_state:
		states.STAND:
			parent.play_animation("idle")
			parent.state.text = str("STAND")
		states.DASH:
			parent.play_animation("dash")
			parent.state.text = str("DASH")
		states.MOONWALK:
			parent.play_animation("walk")
			parent.state.text = str("MOONWALK")
		states.TURN:
			parent.play_animation("turn")
			parent.state.text = str("TURN")
		states.CROUCH:
			parent.play_animation("crouch")
			parent.state.text = str("CROUCH")
		states.RUN:
			parent.play_animation("run")
			parent.state.text = str("RUN")
		states.JUMP_SQUAT:
			parent.play_animation("jump_squat")
			parent.state.text = str("JUMP_SQUAT")
		states.SHORT_HOP:
			parent.play_animation("air")
			parent.state.text = str("SHORT_HOP")
		states.FULL_HOP:
			parent.play_animation("air")
			parent.state.text = str("FULL_HOP")
		states.AIR:
			parent.play_animation("air")
			parent.state.text = str("AIR")
		states.LANDING:
			parent.play_animation("landing")
			parent.state.text = str("LANDING")

func exit_state(new_state, old_state) -> void:
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func air_movement():
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y += parent.FALLSPEED
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall:
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		parent.set_collision_mask_value(4, false)
		parent.velocity.y = parent.MAXFALLSPEED
	
	if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.AIR_ACCEL
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = parent.velocity.x
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x += parent.AIR_ACCEL
	
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x += -parent.AIR_ACCEL
		if Input.is_action_pressed("right_%s" % id):
			parent.velocity.x += parent.AIR_ACCEL
	
	if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL / 5
		elif parent.velocity.x > 0:
			parent.velocity.x += -parent.AIR_ACCEL / 5

func landing():
	if state_includes([states.AIR]):
		if parent.GroundL.is_colliding() and parent.velocity.y >= 0:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
		
		elif parent.GroundR.is_colliding() and parent.velocity.y >= 0:
			var collider2 = parent.GroundR.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true

func falling():
	if state_includes([states.STAND, states.DASH, states.MOONWALK, states.RUN, states.CROUCH, states.WALK]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true
