extends TextureButton

@export var path = ""

func _on_pressed():
	if path != "":
		get_tree().change_scene_to_file(path)
