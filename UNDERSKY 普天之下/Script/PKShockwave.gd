# PKShockwave.gd
extends ObjectPoolSupport

@export var collision: CollisionShape2D
@export var audio: AudioStreamPlayer2D

## 扩散参数
@export var max_radius: float = 1000.0		## 最终半径
@export var duration: float = 1.5			## 动画时长
@export var ring_width: float = 20.0		## 环的宽度
@export var color: Color = Color.WHITE		## 环的颜色

var tween: Tween
var _current_radius: float = 0.0
var _alpha: float = 1.0

func reset():
	# 终止正在进行的动画
	if tween and tween.is_valid():
		tween.kill()
	_current_radius = 0.0
	_alpha = 1.0
	queue_redraw()

## 启动冲击波动画
func activate():
	# 确保状态重置
	reset()
	# 播放扩散动画
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_method(_set_radius, 0.0, max_radius, duration)
	tween.tween_method(_set_alpha, 1.0, 0.0, duration)
	tween.chain().tween_callback(return_to_pool)

func _set_radius(value: float):
	_current_radius = value
	queue_redraw()

func _set_alpha(value: float):
	_alpha = value
	queue_redraw()

func _draw():
	var c = color
	c.a = _alpha
	draw_arc(Vector2.ZERO, _current_radius, 0.0, TAU, 128, c, ring_width, true)
	collision.shape.radius = _current_radius
