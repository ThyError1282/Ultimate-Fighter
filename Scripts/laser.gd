extends Area2D

@export var laser_speed = 1500
@onready var parent = get_parent()
@export var duration = 60
@export var damage = 3

var frame = 0
var dir_x = 1
var dir_y = 0
var player_list = []

func _ready() -> void:
	player_list.append(parent)
	set_process(true)

func _physics_process(delta: float) -> void:
	frame += floor(delta * 60)
	if frame >= duration:
		queue_free()
	var motion = (Vector2(dir_x,dir_y)).normalized() * laser_speed
	set_position(get_position() + motion * delta)
	position.direction_to(motion)
	
	set_rotation_degrees(rad_to_deg(Vector2(dir_x,dir_y).angle()))

func dir(directionx, directiony):
	dir_x = directionx
	dir_y = directiony

func _on_laser_body_entered(body: Node2D) -> void:
	if not body in player_list:
		body.percentage += damage
		queue_free()
