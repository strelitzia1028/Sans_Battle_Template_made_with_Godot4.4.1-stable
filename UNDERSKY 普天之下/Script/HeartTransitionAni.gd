# HeartTransitionAni.gd
extends Node2D

#region：预加载
@onready var heart: Sprite2D = $Heart
@export var red: Resource = preload("res://Asset/heart/red.png")
@export var blue: Resource = preload("res://Asset/heart/blue_down.png")
#endregion：预加载

#region：动画参数
@onready var tween: Tween = null
@export var duration: float = 0.5  					# 动画持续时间
@export var start_scale: Vector2 = Vector2(1, 1)	# 起始缩放
@export var mid_scale: Vector2 = Vector2(3, 3)		# 过渡缩放
@export var mid_proportion: float = 0.5  			# 过渡缩放占比
@export var end_scale: Vector2 = Vector2(2, 2)		# 结束缩放
@export var start_alpha: float = 1.0				# 起始透明度
@export var end_alpha: float = 0.0					# 结束透明度
enum PresentHeart {RED, BLUE, MENU}
#endregion：动画参数

#region：动画
## 播放动画
func play_animation(present_heart):
	match present_heart:
		PresentHeart.RED:
			heart.texture = red
		
		PresentHeart.BLUE:
			heart.texture = blue
	
	if tween and tween.is_running():
		tween.kill()
	
	# 创建Tween实例
	var tween = create_tween()
	tween.set_parallel(true)			# 启用并行模式
	tween.set_ease(Tween.EASE_IN_OUT)	# 两端的插值最慢
	
	# 缩放动画
	tween.tween_property(heart, "scale", mid_scale, duration)
	tween.tween_property(heart, "scale", end_scale, duration * mid_proportion)\
	.set_delay(duration * (1 - mid_proportion))
	
	# 透明度动画
	tween.tween_property(heart, "modulate:a", end_alpha, duration)
	
	# 动画结束后自动销毁场景
	tween.tween_callback(queue_free).set_delay(duration)
#endregion：动画
