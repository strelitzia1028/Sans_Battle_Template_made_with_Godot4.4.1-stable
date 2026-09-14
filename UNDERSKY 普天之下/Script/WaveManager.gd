# WaveManager.gd
extends AnimationPlayer

@export var sans: CharacterBody2D
@export var menu_manager: Node2D
@export var event_manager: Node2D
var current_round: int = 0
var paused_animation: String = ""
var paused_position: float = 0.0

func _process(delta: float) -> void:
	var should_pause = Global.is_sans_talking or Global.menu_or_not or Global.is_screen_flashing
	if should_pause and is_playing():
		paused_animation = current_animation
		paused_position = get_current_animation_position()
		stop()
	elif not should_pause and not is_playing() and paused_animation != "":
		seek(paused_position)
		play(paused_animation)
		paused_animation = ""

func next_round():
	stop()
	sans.sans_dialogue_box.clear_all_dialogue()
	menu_manager.dialogue_box.clear_all_dialogue()
	event_manager.trigger_clean_all()
	current_round += 1
	play("Round Library/Round " + str(current_round))
	paused_animation = current_animation
	paused_position = 0.0

func _on_stop_pressed() -> void:
	stop()
	sans.sans_dialogue_box.clear_all_dialogue()
	menu_manager.dialogue_box.clear_all_dialogue()
	event_manager.trigger_clean_all()

func _on_next_round_pressed() -> void:
	next_round()

'''
战斗框 Border 的世界坐标是 (0.0, 50.0)
'''
