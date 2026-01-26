extends ColorRect

@export var animating : bool = true
@export var speed : float = 1
#@export var lapSpeed : float = 45.0

func _process(delta):
	if animating:
		var t = Time.get_ticks_msec() * 0.0005
		
		var x = -0.7 + cos(t * speed) * 0.2
		var y = 0.2 + sin(t * 0.5 * speed) * 0.3
		
		material.set_shader_parameter("c", Vector2(x, y))
	else:
		pass
