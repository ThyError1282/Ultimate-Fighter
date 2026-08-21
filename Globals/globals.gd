extends Node

func hitstun(mod, duration):
	Engine.time_scale = mod/100
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	Engine.time_scale = 1

var css = {
	"char_1" : "",
	"char_2" : "",
	"stocks" : 1,
	"time" : 1,
	"token_1_pos" : Vector2(866.741, 666.626),
	"token_2_pos" : Vector2(1073.43, 666.626)
}

var player_1 = {
	"percentage" : 0,
	"stocks" : 1
}

var player_2 = {
	"percentage" : 0,
	"stocks" : 1
}
