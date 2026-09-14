extends CanvasLayer

@export var bgm: AudioStreamPlayer2D
var can_flash: bool = false
var state_timer: float = 0.0
var paused_position: float = 0.0

func _ready() -> void:
	visible = false
	can_flash = false
	state_timer = 0.0
	Global.is_screen_flashing = false

func _process(delta: float) -> void:
	state_timer += delta
	if can_flash and state_timer >= 0.2:
			bgm.play(paused_position)
			visible = false
			can_flash = false
			state_timer = 0.0
			set_process(false)
			Global.is_screen_flashing = false

func screen_flash():
	paused_position = bgm.get_playback_position()
	bgm.stop()
	visible = true
	can_flash = true
	state_timer = 0.0
	set_process(true)
	Global.is_screen_flashing = true
