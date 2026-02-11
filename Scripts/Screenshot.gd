# ------------------------------------------------------------------------------
# Screenshot & Sequence Tool for Godot 4.x
# Developed by: PhilippeZ-Dev
# License: MIT
# ------------------------------------------------------------------------------
class_name Screenshot
extends Node

var frameCounter:int = 0
var sequenceRunning:bool = false

enum captureMode {
	## Save a single frame.
	SINGLE, 
	## Save a sequence of frames.
	SEQUENCE}

#region Export Params

# Save a single frame or a sequence of consecutive frames
@export var mode:captureMode = captureMode.SINGLE

## Amount of frames that will be saved.
@export var sequenceLength:int = 10:
	get:
		if sequenceLength < 0:
			push_error("Invalid end frame")
			return 1
		else:
			return sequenceLength

## Path of the folder where the frames will be saved to.
## Must be a valid path format.
## Tip: copy your desired path from the FileSystem
@export var destinationFolderPath = "res://Screenshots/"

## Name of the screenshot file.
## If empty, it will save the timestamp as the name.
@export var screenshotName:String:
	get:
		if screenshotName == '':
			return GetTimeStr()
		else:
			return screenshotName
#endregion

func _input(event):
	if not InputMap.has_action("Screenshot"):
		push_error("Input Action 'Screenshot' is not defined in the Project Settings")
		return
	
	if event.is_action_pressed("Screenshot"):
		if mode == captureMode.SINGLE:
			TakeScreenshot(0)
		elif mode == captureMode.SEQUENCE and sequenceRunning == false:
			StartSequence()

func _process(delta: float) -> void:
	if sequenceRunning == true:
		if frameCounter >= sequenceLength:
			StopSequence()
			return
		
		TakeScreenshot(frameCounter)
		frameCounter += 1
	pass

func StartSequence():
	sequenceRunning = true
	pass

func StopSequence():
	sequenceRunning = false
	frameCounter = 0
	print("Sequence saved!")
	print("---")
	pass

func TakeScreenshot(currentFrame:int = 0):
	await RenderingServer.frame_post_draw
	
	var viewport = get_viewport()
	var texture = viewport.get_texture()
	
	var img = texture.get_image()
	
	VerifyDestinationFolder()
	
	var savePath:String
	if mode == captureMode.SINGLE:
		savePath = destinationFolderPath + screenshotName + ".png"
	else:
		savePath = destinationFolderPath + screenshotName + "_" + str(currentFrame) + ".png"
	
	var error = img.save_png(savePath)
	
	if error == 0:
		if mode == captureMode.SINGLE:
			print("Screenshot saved to: ", ProjectSettings.globalize_path(savePath))
		elif mode == captureMode.SEQUENCE: 
			print("Saving sequence, frame: #", str(currentFrame))
	else:
		print("Error saving screenshot: ", error)

func GetTimeStr() -> String:
	return Time.get_datetime_string_from_system().replace(":", "-")

func VerifyDestinationFolder() -> void:
	var path = destinationFolderPath
	if not DirAccess.dir_exists_absolute(path):
		var error = DirAccess.make_dir_absolute(path)
		if error == 0:
			print("Created missing destination folder")
		else:
			push_error("Failed to create destination folder: ", error_string(error), " ,error: " ,error)
