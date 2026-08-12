extends Area2D

@export_enum("Left", "Right") var ledge_side = "Left"
@onready var label: Label = $Label
@onready var collision: CollisionShape2D = $Collision
var is_grabbed = false

func _on_ledge_body_exited(body: Node2D) -> void:
	is_grabbed = false

func _ready() -> void:
	if ledge_side == "Left":
		label.text = "Ledge_L"
	else:
		label.text = "Ledge_R"
