extends Control

var current_state = States.PLAY
@onready var pointer: Area2D = $Pointer

enum States {
	PLAY,
	OPTIONS,
	EXIT
}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pointer.global_position = Vector2(960, 540)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select_1") or Input.is_action_just_pressed("ui_select_2"):
		var dec = pointer.get_overlapping_areas()
		for b in dec:
			if b.get_parent().name == "Play":
				b.get_parent().emit_signal("pressed")
			if b.get_parent().name == "Options":
				b.get_parent().emit_signal("pressed")
			if b.get_parent().name == "Quit":
				b.get_parent().emit_signal("pressed")
	
	match current_state:
		States.PLAY:
			play()
			if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("up_2"):
				current_state = States.EXIT
			if Input.is_action_just_pressed("down_1") or Input.is_action_just_pressed("down_2"):
				current_state = States.OPTIONS
		States.OPTIONS:
			options()
			if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("up_2"):
				current_state = States.PLAY
			if Input.is_action_just_pressed("down_1") or Input.is_action_just_pressed("down_2"):
				current_state = States.EXIT
		States.EXIT:
			exit()
			if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("up_2"):
				current_state = States.OPTIONS
			if Input.is_action_just_pressed("down_1") or Input.is_action_just_pressed("down_2"):
				current_state = States.PLAY

func play():
	pointer.global_position = Vector2(546, 422)

func options():
	pointer.global_position = Vector2(546, 540)

func exit():
	pointer.global_position = Vector2(546, 655)
