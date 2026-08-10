class_name StateMachineFox extends StateMachine

@export var id: int = 1

func _ready() -> void:
	add_state("STAND")
	add_state("JUMP_SQUAT")
	add_state("FULL_HOP")
	add_state("DASH")
	add_state("MOONWALK")
	add_state("WALK")
	add_state("CROUCH")
	call_deferred("set_state", states.STAND)

func state_logic(delta) -> void:
	parent.update_frames(delta)
	parent._physics_process(delta)

func get_transition(delta):
	parent.move_and_slide()
	parent.state.text = str(state)
	match state:
		states.STAND:
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
			pass
		states.FULL_HOP:
			pass
		states.DASH:
			if Input.is_action_just_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent.reset_frame()
				parent.velocity.x = -parent.DASHSPEED
			elif Input.is_action_just_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent.reset_frame()
				parent.velocity.x = parent.DASHSPEED
			else:
				if parent.frame >= parent.dash_duration - 1:
					return states.STAND
		states.MOONWALK:
			pass
		states.WALK:
			pass
		states.CROUCH:
			pass

func enter_state(new_state, old_state) -> void:
	pass

func exit_state(new_state, old_state) -> void:
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
