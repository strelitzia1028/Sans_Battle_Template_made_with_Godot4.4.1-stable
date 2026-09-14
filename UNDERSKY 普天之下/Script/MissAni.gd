# MissAni.gd
extends AnimatedSprite2D

@export var duration: float = 0.5
@export var initial_position: Vector2 = Vector2(0.0, -285.0)
@export var offset_position: Vector2 = Vector2(0.0, -20.0)
@onready var tween: Tween = null
var state_timer: float = 0.0

func _ready() -> void:
	visible = false
	modulate = Color.TRANSPARENT
	position = initial_position

func _process(delta: float) -> void:
	if Global.menu_or_not:
		state_timer += delta
		
		if state_timer >= duration * 1.5:
			if tween and tween.is_running():
				tween.kill()
			
			var tween = create_tween()
			tween.set_parallel(true)				# 启用并行模式
			tween.set_ease(Tween.EASE_IN_OUT)	# 两端的插值最慢
			tween.tween_property(self, "modulate:a", 0, duration / 2)

#region：动画
func play_miss_ani():
	visible = true
	modulate = Color.TRANSPARENT
	position = initial_position
	state_timer = 0.0
	if tween and tween.is_running():
		tween.kill()
	
	var tween = create_tween()
	tween.set_parallel(true)				# 启用并行模式
	tween.set_ease(Tween.EASE_IN_OUT)	# 两端的插值最慢
	tween.tween_property(self, "modulate:a", 1, duration)
	tween.tween_property(self, "position", initial_position + offset_position, duration)
#endregion：动画
