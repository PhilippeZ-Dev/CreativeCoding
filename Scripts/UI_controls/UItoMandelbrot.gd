class_name UItoMandelbrot
extends Node

@export var material:ShaderMaterial

@export var u_zoom:String

@export var u_offset:String
@onready var offset_x: SpinBox = $Offset/Vector2/X_offset
@onready var offset_y: SpinBox = $Offset/Vector2/Y_offset

@export var u_iterations:String

func _on_v_zoom_value_changed(value: float) -> void:
	material.set_shader_parameter(u_zoom, value)

func _on_x_offset_value_changed(value: float) -> void:
	material.set_shader_parameter(u_offset, Vector2(value, offset_y.value))

func _on_y_offset_value_changed(value: float) -> void:
	material.set_shader_parameter(u_offset, Vector2(offset_x.value, value))

func _on_v_iterations_value_changed(value: float) -> void:
	material.set_shader_parameter(u_iterations, value)
