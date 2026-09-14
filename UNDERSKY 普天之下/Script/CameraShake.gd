# CameraShake.gd
extends Node2D

var trauma: float = 0.0
var trauma_power: float = 20.0
var trauma_decay: float = 2.0
var shake_dir: Vector2 = Vector2.RIGHT		## 方向性抖动方向
var use_directional: bool = false			## 是否方向性抖动
var noise = FastNoiseLite.new()

func _ready():
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 20.0

## 设置抖动方向（direction 仅在 use_directional = true 时生效）
func add_trauma(amount: float, direction: Vector2 = Vector2.RIGHT):
	trauma = min(trauma + amount, 1.0)
	shake_dir = direction.normalized()

## 使用方向性抖动
func set_directional(enabled: bool):
	use_directional = enabled

func _process(delta):
	if Global.hp <= 0:
		return
	
	if trauma <= 0.0:
		get_viewport().get_camera_2d().offset = Vector2.ZERO
		return
	
	trauma = max(trauma - trauma_decay * delta, 0.0)
	if use_directional:
		# 方向性抖动
		var raw := noise.get_noise_1d(trauma * 100) * trauma * trauma_power
		var offset := shake_dir * raw
		get_viewport().get_camera_2d().offset = offset
	else:
		# 普通随机抖动
		var offset := Vector2(
			noise.get_noise_1d(trauma * 100),
			noise.get_noise_1d(trauma * 100 + 1000)
		) * trauma * trauma_power
		get_viewport().get_camera_2d().offset = offset
