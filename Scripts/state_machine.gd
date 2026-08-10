class_name StateMachine extends Node

var state = null: set = set_state
var previous_state = null
var states = {}

@onready var parent = get_parent()

func _physics_process(delta: float) -> void:
	if state != null:
		state_logic(delta)
		var transition = get_transition(delta)
		if transition != null:
			set_state(transition)

func state_logic(delta) -> void:
	pass

func get_transition(delta):
	return null

func enter_state(new_state, old_state) -> void:
	pass

func exit_state(new_state, old_state) -> void:
	pass

func set_state(new_state) -> void:
	previous_state = state
	state = new_state
	
	if previous_state != null:
		exit_state(previous_state, new_state)
	if new_state != null:
		enter_state(new_state, previous_state)

func add_state(state_name) -> void:
	states[state_name] = states.size()
