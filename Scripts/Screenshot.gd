extends Node

@export var screenshotName:String:
	get:
		if screenshotName == '':
			return GetTimeStr()
		else:
			return screenshotName

func _input(event):
	if event.is_action_pressed("Screenshot"):
		take_screenshot()

func take_screenshot():
	await RenderingServer.frame_post_draw
	
	var viewport = get_viewport()
	var texture = viewport.get_texture()
	
	var img = texture.get_image()
	
	var save_path = "res://Screenshots/" + screenshotName + ".png"
	
	var error = img.save_png(save_path)
	
	if error == OK:
		print("Screenshot saved to: ", ProjectSettings.globalize_path(save_path))
	else:
		print("Error saving screenshot: ", error)


func GetTimeStr() -> String:
	return Time.get_datetime_string_from_system().replace(":", "-")
