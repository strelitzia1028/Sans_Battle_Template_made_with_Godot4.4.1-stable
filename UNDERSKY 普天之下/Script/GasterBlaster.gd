# GasterBlaster.gd
extends ObjectPoolSupport

#region：预加载
@onready var ani = $GbAnimation
@onready var laser = $Laser
@onready var start_audio = $Start
@onready var emit_audio = $Emit
#endregion：预加载

@export var damage: int = 3
@export var kr: int = 8
var has_kr: bool = false

#region：动画参数
var tween: Tween = null
var start_x: float				## 龙骨炮的 x 坐标
var start_y: float				## 龙骨炮的 y 坐标
var angle: float				## 龙骨炮的发射角度
var auto_aim: bool				## 是否自动瞄准玩家
var direction: Vector2			## 用于自动瞄准的方向
var time_of_delay: float		## 发射前等待的时间
var time_of_last: float			## 发射时持续的时间
var time_of_appear: float		## 发射前动画的时长
var can_exit: bool				## 发射时是否可以后退
var exit_velocity: float		## 发射时后退的速度
var size: float					## 龙骨炮放大的倍数
var laser_width: float			## 激光的宽度
var offset_angle: float = 60	## 龙骨炮转向发射角度之前的偏转角度
var start_audio_can_play: bool = true
var emit_audio_can_play: bool = true

enum GbStage {IDLE, START, WAIT, EMIT, END}
var gb_stage: GbStage = GbStage.IDLE
var state_timer: float = 0.0

## 初始化参数
func init(config: Dictionary) -> void:
	start_x = config.get("start_x")
	start_y = config.get("start_y")
	angle = config.get("angle")
	auto_aim = config.get("auto_aim")
	time_of_delay = config.get("delay")
	time_of_last = config.get("last")
	time_of_appear = config.get("appear")
	exit_velocity = config.get("velocity")
	size = config.get("size")
	laser_width = config.get("width")
	
	# 初始化位置和旋转
	laser.init(config)
	global_position = Vector2(start_x, start_y)
	if auto_aim and is_instance_valid(Global.player_node):
		direction = Global.player_node.global_position - global_position
		rotation = direction.angle() - deg_to_rad(offset_angle)
	else:
		rotation = deg_to_rad(angle) - deg_to_rad(offset_angle)
	
	position -= Vector2.RIGHT.rotated(rotation) * 100
	velocity = Vector2.ZERO
	scale = Vector2(size, size)
	modulate = Color.TRANSPARENT
	visible = false
	
	# 重置状态
	reset_audio_status()
	gb_stage = GbStage.IDLE
	state_timer = 0.0
	can_exit = false
	
	if not is_in_group("gb"):
		add_to_group("gb")
#endregion：动画参数

#region：龙骨炮主体
func _process(delta: float) -> void:
	if gb_stage == GbStage.IDLE:
		return
	
	# 移动逻辑
	if is_in_camera_view():
		if can_exit:
			velocity -= Vector2.RIGHT.rotated(rotation) * exit_velocity
		else:
			velocity = Vector2.ZERO
	else:
		ani.stop()
		velocity = Vector2.ZERO
	move_and_slide()
	
	state_timer += delta
	match gb_stage:
		GbStage.START:
			appear()
			ani.play("start")
			if start_audio_can_play:
				start_audio.play(0.0)
				start_audio_can_play = false
			gb_stage = GbStage.WAIT
			state_timer = 0.0
		
		GbStage.WAIT:
			if state_timer >= time_of_delay:
				gb_stage = GbStage.EMIT
				state_timer = 0.0
		
		GbStage.EMIT:
			if time_of_last > 0:
				laser.set_is_casting(true)		# 启用激光的发射动画
				laser.set_active(true)			# 启用激光的伤害区域
			ani.play("emit")
			can_exit = true
			if emit_audio_can_play:
				emit_audio.play(0.0)
				emit_audio_can_play = false
			CameraShake.set_directional(true)
			CameraShake.add_trauma(0.7, -Vector2.RIGHT.rotated(rotation))
			gb_stage = GbStage.END
			state_timer = 0.0
		
		GbStage.END:
			if state_timer >= time_of_last:
				laser.set_is_casting(false)
				laser.set_active(false)
				if not laser.line.visible and (not is_in_camera_view()):
					return_to_pool()
#endregion：龙骨炮主体

#region：动画
func appear():
	visible = true
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1, time_of_appear)
	if auto_aim and is_instance_valid(Global.player_node):
		tween.tween_property(self, "rotation", direction.angle(), time_of_appear)
	else:
		tween.tween_property(self, "rotation", deg_to_rad(angle), time_of_appear)
	tween.tween_property(self, "position", Vector2(start_x, start_y), time_of_appear)
#endregion：动画

#region：重置音频
## 重置音频播放状态
func reset_audio_status():
	start_audio_can_play = true
	emit_audio_can_play = true
#endregion：重置音频

#region：对象池支持部分重写
## 重置状态（用于对象池）
func reset():
	# 取消任何进行中的 Tween
	if tween and tween.is_running():
		tween.kill()
	tween = null
	
	# 重置状态
	gb_stage = GbStage.IDLE
	state_timer = 0.0
	can_exit = false
	visible = false
	velocity = Vector2.ZERO
	reset_audio_status()
#endregion：对象池支持部分重写

#region：外部调用开始攻击
func start_attack():
	if gb_stage == GbStage.IDLE:
		gb_stage = GbStage.START
#endregion：外部调用开始攻击
