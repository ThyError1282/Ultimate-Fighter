class_name StateMachineFox extends StateMachine

@onready var id = parent.id

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
	add_state("LEDGE_CATCH")
	add_state("LEDGE_HOLD")
	add_state("LEDGE_CLIMB")
	add_state("LEDGE_JUMP")
	add_state("LEDGE_ROLL")
	add_state("HITSTUN")
	add_state("GROUND_ATTACK")
	add_state("DOWN_TILT")
	add_state("UP_TILT")
	add_state("FORWARD_TILT")
	add_state("JAB")
	add_state("AIR_ATTACK")
	add_state("NAIR")
	add_state("UAIR")
	add_state("BAIR")
	add_state("FAIR")
	add_state("DAIR")
	call_deferred("set_state", states.STAND)

func state_logic(delta) -> void:
	parent.update_frames(delta)
	parent._physics_process(delta)
	if parent.regrab > 0:
		parent.regrab -= 1

func get_transition(delta):
	parent.move_and_slide()
	if landing() == true:
		parent.reset_frame()
		return states.LANDING
	
	if falling() == true:
		return states.AIR
	
	if ledge() == true:
		parent.reset_frame()
		return states.LEDGE_CATCH
	else:
		parent.reset_ledge()
	
	if Input.is_action_just_pressed("attack_%s" % id) && tilt() == true:
		parent.reset_frame()
		return states.GROUND_ATTACK
	
	if Input.is_action_just_pressed("attack_%s" % id) && aerial() == true:
		if Input.is_action_pressed("up_%s" % id):
				parent.reset_frame()
				return states.UAIR
		if Input.is_action_pressed("down_%s" % id):
			parent.reset_frame()
			return states.DAIR
		match parent.direction():
			1:
				if Input.is_action_pressed("left_%s" % id):
					parent.reset_frame()
					return states.BAIR
				if Input.is_action_pressed("right_%s" % id):
					parent.reset_frame()
					return states.FAIR
			-1:
				if Input.is_action_pressed("right_%s" % id):
					parent.reset_frame()
					return states.BAIR
				if Input.is_action_pressed("left_%s" % id):
					parent.reset_frame()
					return states.FAIR
		parent.reset_frame()
		return states.NAIR
	
	if Input.is_action_just_pressed("shield_%s" % id) && aerial() && parent.cooldown == 0:
		parent.l_cancel = 11
		parent.cooldown = 40
	
	match state:
		states.STAND:
			parent.reset_jumps()
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
				if Input.is_action_pressed("shield_%s" % id) and (Input.is_action_pressed("left_%s" % id) or Input.is_action_pressed("right_%s" % id)):
					if Input.is_action_pressed("right_%s" % id):
						parent.velocity.x = parent.AIR_DODGE_SPEED / parent.perfect_wavedash_modifier
					if Input.is_action_pressed("left_%s" % id):
						parent.velocity.x = -parent.AIR_DODGE_SPEED / parent.perfect_wavedash_modifier
					parent.lag_frames = 6
					parent.reset_frame()
					return states.LANDING
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
			if Input.is_action_just_pressed("jump_%s" % id) and parent.air_jump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.air_jump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED
		
		states.LANDING:
			if parent.frame == 1:
				if parent.l_cancel > 0:
					parent.lag_frames = floor(parent.lag_frames / 2)
			if parent.frame <= parent.landing_frames + parent.lag_frames:
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
					parent.reset_jumps()
					return states.CROUCH
				else:
					parent.lag_frames = 0
					parent.reset_jumps()
					parent.reset_frame()
					return states.STAND
				parent.lag_frames = 0
		
		states.LEDGE_CATCH:
			if parent.frame > 7:
				parent.lag_frames = 0
				parent.reset_jumps()
				parent.reset_frame()
				return states.LEDGE_HOLD
		
		states.LEDGE_HOLD:
			if parent.frame >= 390:
				self.parent.position.y += -25
				parent.reset_frame()
				return states.AIR
			if Input.is_action_just_pressed("down_%s" % id):
				parent.fastfall = true
				parent.regrab = 30
				parent.reset_ledge()
				self.parent.position.y += -25
				parent.catch = false
				parent.reset_frame()
				return states.AIR
			# Facing Right
			elif parent.Ledge_Grab_F.target_position.x > 0:
				if Input.is_action_just_pressed("left_%s" % id):
					parent.velocity.x = parent.AIR_ACCEL / 2
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y += -25
					parent.catch = false
					parent.reset_frame()
					return states.AIR
				elif Input.is_action_just_pressed("right_%s" % id):
					parent.reset_frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s" % id):
					parent.reset_frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.reset_frame()
					return states.LEDGE_JUMP
			
			# Facing Left
			elif parent.Ledge_Grab_F.target_position.x < 0:
				if Input.is_action_just_pressed("right_%s" % id):
					parent.velocity.x = parent.AIR_ACCEL / 2
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y += -25
					parent.catch = false
					parent.reset_frame()
					return states.AIR
				elif Input.is_action_just_pressed("left_%s" % id):
					parent.reset_frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s" % id):
					parent.reset_frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.reset_frame()
					return states.LEDGE_JUMP
		
		states.LEDGE_CLIMB:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y -= 25
			if parent.frame == 10:
				parent.position.y -= 25
			if parent.frame == 20:
				parent.position.y -= 25
			if parent.frame == 22:
				parent.catch = false
				parent.position.y -= 25
				parent.position.x += 50 * parent.direction()
			if parent.frame == 25:
				parent.velocity.x = 0
				parent.velocity.y = 0
				parent.move_and_collide(Vector2(parent.direction() * 20, 50))
			if parent.frame == 30:
				parent.reset_ledge()
				parent.reset_frame()
				return states.STAND
		
		states.LEDGE_JUMP:
			if parent.frame > 14:
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.reset_frame()
					return states.AIR_ATTACK
				if Input.is_action_just_pressed("special_%s" % id):
					parent.reset_frame()
					return states.SPECIAL
				if parent.frame == 5:
					parent.reset_ledge()
					parent.position.y -= 20
				if parent.frame == 10:
					parent.catch = false
					parent.position.y -= 20
					if Input.is_action_just_pressed("jump_%s" % id) and parent.air_jump > 0:
						parent.fastfall = false
						parent.velocity.y = -parent.DOUBLEJUMPFORCE
						parent.velocity.x = 0
						parent.air_jump -= 1
						parent.reset_frame()
						return states.AIR
				if parent.frame == 15:
					parent.position.y -= 20
					parent.velocity.y -= parent.DOUBLEJUMPFORCE
					parent.velocity.x += 220 * parent.direction()
					if Input.is_action_just_pressed("jump_%s" % id) and parent.air_jump > 0:
						parent.fastfall = false
						parent.velocity.y = -parent.DOUBLEJUMPFORCE
						parent.velocity.x = 0
						parent.air_jump -= 1
						parent.reset_frame()
						return states.AIR
					if Input.is_action_just_pressed("attack_%s" % id):
						parent.reset_frame()
						return states.AIR_ATTACK
				elif parent.frame > 15 and parent.frame < 20:
					parent.velocity.y += parent.FALLSPEED
					if Input.is_action_just_pressed("jump_%s" % id) and parent.air_jump > 0:
						parent.fastfall = false
						parent.velocity.y = -parent.DOUBLEJUMPFORCE
						parent.velocity.x = 0
						parent.air_jump -= 1
						parent.reset_frame()
						return states.AIR
					if Input.is_action_just_pressed("attack_%s" % id):
						parent.reset_frame()
						return states.AIR_ATTACK
				if parent.frame == 20:
					parent.reset_frame()
					return states.AIR
		
		states.LEDGE_ROLL:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y -= 30
			if parent.frame == 10:
				parent.position.y -= 30
			
			if parent.frame == 20:
				parent.catch = false
				parent.position.y -= 30
			
			if parent.frame == 22:
				parent.position.y -= 30
				parent.position.x += 50 * parent.direction()
			
			if parent.frame > 22 and parent.frame < 28:
				parent.position.x += 30 * parent.direction()
			
			if parent.frame == 29:
				parent.move_and_collide(Vector2(parent.direction() * 20, 50))
			
			if parent.frame == 30:
				parent.velocity.x = 0
				parent.velocity.y = 0
				parent.reset_ledge()
				parent.reset_frame()
				return states.STAND
		
		states.HITSTUN:
			if parent.knockback >= 3:
				var bounce = parent.move_and_collide(parent.velocity * delta)
				if bounce:
					parent.velocity = parent.velocity.bounce(bounce.normal) * 0.8
					parent.hitstun = round(parent.hitstun * 0.8)
			if parent.velocity.y < 0:
				parent.velocity.y += parent.vdecay * 0.5 * Engine.time_scale
				parent.velocity.y = clamp(parent.velocity.y, parent.velocity.y, 0)
			if parent.velocity.x < 0:
				parent.velocity.x -= parent.hdecay * 0.4 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			elif parent.velocity.x > 0:
				parent.velocity.x -= parent.hdecay * 0.4 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			
			if parent.frame >= parent.hitstun:
				if parent.knockback >= 24:
					parent.reset_frame()
					return states.AIR
				else:
					parent.reset_frame()
					return states.AIR
			elif parent.frame > 60 * 5:
				return states.AIR
		
		states.AIR_ATTACK:
			air_movement()
			if Input.is_action_pressed("up_%s" % id):
				parent.reset_frame()
				return states.UAIR
			if Input.is_action_pressed("down_%s" % id):
				parent.reset_frame()
				return states.DAIR
			match parent.direction():
				1:
					if Input.is_action_pressed("left_%s" % id):
						parent.reset_frame()
						return states.BAIR
					if Input.is_action_pressed("right_%s" % id):
						parent.reset_frame()
						return states.FAIR
				-1:
					if Input.is_action_pressed("right_%s" % id):
						parent.reset_frame()
						return states.BAIR
					if Input.is_action_pressed("left_%s" % id):
						parent.reset_frame()
						return states.FAIR
			parent.reset_frame()
			return states.NAIR
		
		states.NAIR:
			air_movement()
			if parent.frame == 0:
				parent.nair()
			if parent.nair() == true:
				parent.lag_frames = 0
				parent.reset_frame()
				return states.AIR
			elif parent.frame < 5:
				parent.lag_frames = 0
			elif parent.frame > 15:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 7
		
		states.UAIR:
			air_movement()
			if parent.frame == 0:
				parent.uair()
			if parent.uair() == true:
				parent.lag_frames = 0
				parent.reset_frame()
				return states.AIR
			elif parent.frame < 2:
				parent.lag_frames = 0
			elif parent.frame > 4:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 13
		
		states.BAIR:
			air_movement()
			if parent.frame == 0:
				parent.bair()
			if parent.bair() == true:
				parent.lag_frames = 0
				parent.reset_frame()
				return states.AIR
			elif parent.frame < 7:
				parent.lag_frames = 0
			elif parent.frame > 9:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 9
		
		states.FAIR:
			air_movement()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.air_jump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.air_jump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED
				return states.AIR
			if parent.frame == 0:
				parent.fair()
			if parent.fair() == true:
				parent.lag_frames = 30
				parent.reset_frame()
				return states.FAIR
			elif parent.frame < 5:
				parent.lag_frames = 0
			elif parent.frame > 10:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 18
		
		states.DAIR:
			if parent.frame == 0:
				parent.dair()
			if parent.dair() == true:
				parent.lag_frames = 0
				parent.reset_frame()
				return states.AIR
			elif parent.frame < 5:
				parent.lag_frames = 0
			elif parent.frame > 15:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 17
		
		states.GROUND_ATTACK:
			if Input.is_action_pressed("up_%s" % id):
				parent.reset_frame()
				return states.UP_TILT
			if Input.is_action_pressed("down_%s" % id):
				parent.reset_frame()
				return states.DOWN_TILT
			if Input.is_action_pressed("left_%s" % id):
				parent.turn(true)
				parent.reset_frame()
				return states.FORWARD_TILT
			if Input.is_action_pressed("right_%s" % id):
				parent.turn(false)
				parent.reset_frame()
				return states.FORWARD_TILT
			parent.reset_frame()
			return states.JAB
		
		states.DOWN_TILT:
			if parent.frame == 0:
				parent.down_tilt()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.down_tilt() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.reset_frame()
					return states.CROUCH
				else:
					parent.reset_frame()
					return states.STAND
		
		states.UP_TILT:
			if parent.frame == 0:
				parent.up_tilt()
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.up_tilt() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.reset_frame()
					return states.CROUCH
				else:
					parent.reset_frame()
					return states.STAND
		
		states.FORWARD_TILT:
			if parent.frame == 0:
				parent.forward_tilt()
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION * 2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.forward_tilt() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.reset_frame()
					return states.CROUCH
				else:
					parent.reset_frame()
					return states.STAND
		
		states.JAB:
			if parent.frame == 0:
				parent.jab()
			
			if parent.frame == 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION * 2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			
			if parent.jab() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.reset_frame()
					return states.CROUCH
				else:
					parent.reset_frame()
					return states.STAND

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
		states.LEDGE_CATCH:
			parent.play_animation("ledge_catch")
			parent.state.text = str("LEDGE_CATCH")
		states.LEDGE_HOLD:
			parent.play_animation("ledge_catch")
			parent.state.text = str("LEDGE_HOLD")
		states.LEDGE_JUMP:
			parent.play_animation("air")
			parent.state.text = str("LEDGE_JUMP")
		states.LEDGE_CLIMB:
			parent.play_animation("roll_forward")
			parent.state.text = str("LEDGE_CLIMB")
		states.LEDGE_ROLL:
			parent.play_animation("roll_forward")
			parent.state.text = str("LEDGE_ROLL")
		states.HITSTUN:
			parent.play_animation("hitstun")
			parent.state.text = str("HITSTUN")
		states.AIR_ATTACK:
			parent.state.text = str("AIR_ATTACK")
		states.NAIR:
			parent.play_animation("nair")
			parent.state.text = str("NAIR")
		states.UAIR:
			parent.play_animation("uair")
			parent.state.text = str("UAIR")
		states.BAIR:
			parent.play_animation("bair")
			parent.state.text = str("BAIR")
		states.FAIR:
			parent.play_animation("fair")
			parent.state.text = str("FAIR")
		states.DAIR:
			parent.play_animation("dair")
			parent.state.text = str("DAIR")
		states.GROUND_ATTACK:
			parent.state.text = str("GROUND_ATTACK")
		states.DOWN_TILT:
			parent.play_animation("down_tilt")
			parent.state.text = str("DOWN_TILT")
		states.UP_TILT:
			parent.play_animation("up_tilt")
			parent.state.text = str("UP_TILT")
		states.FORWARD_TILT:
			parent.play_animation("forward_tilt")
			parent.state.text = str("FORWARD_TILT")
		states.JAB:
			parent.play_animation("jab_1")
			parent.state.text = str("JAB")

func exit_state(new_state, old_state) -> void:
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func tilt():
	if state_includes([states.STAND, states.MOONWALK, states.DASH, states.RUN, states.WALK, states.CROUCH]):
		return true

func aerial():
	if state_includes([states.AIR, states.DAIR, states.NAIR]):
		if !(parent.GroundL.is_colliding() and parent.GroundR.is_colliding()):
			return true
		else:
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
	if state_includes([states.AIR, states.NAIR, states.UAIR, states.BAIR, states.DAIR, states.FAIR]):
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

func ledge():
	if state_includes([states.AIR]):
		if parent.Ledge_Grab_F.is_colliding():
			var collider = parent.Ledge_Grab_F.get_collider()
			if collider.get_node("Label").text == "Ledge_L" and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.y = collider.position.y - 2
				self.parent.position.x = collider.position.x - 20
				parent.turn(false)
				parent.reset_jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
			
			if collider.get_node("Label").text == "Ledge_R" and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.y = collider.position.y + 1
				self.parent.position.x = collider.position.x + 20
				parent.turn(true)
				parent.reset_jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
		
		if parent.Ledge_Grab_B.is_colliding():
			var collider = parent.Ledge_Grab_B.get_collider()
			if collider.get_node("Label").text == "Ledge_L" and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.y = collider.position.y - 1
				self.parent.position.x = collider.position.x - 20
				parent.turn(false)
				parent.reset_jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
			
			if collider.get_node("Label").text == "Ledge_R" and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.y = collider.position.y + 1
				self.parent.position.x = collider.position.x + 20
				parent.turn(true)
				parent.reset_jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
