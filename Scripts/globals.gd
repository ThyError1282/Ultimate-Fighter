extends Node

func hitstun(mod, duration):
	Engine.time_scale = mod/100
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	Engine.time_scale = 1
