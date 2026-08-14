extends Camera2D

@onready var p1 = get_parent().get_node("Fox")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	self.position = p1.position
