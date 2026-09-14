# Player.gd
extends CharacterBody2D

#region：预加载
@export var menu_node: Node2D
@export var death_scene: PackedScene
@export var spr_red: Texture = preload("res://Asset/heart/red.png")
@export var spr_blue: Texture = preload("res://Asset/heart/blue_down.png")
@onready var spr = $Heart
@onready var ani = $HeartTransitionAni
@onready var toggle_heart_audio = $ToggleHeart
@onready var dominated_audio = $Dominated
@onready var pk_shockwave = $ObjectPool
@onready var dominated_audio_can_play: bool = false
#endregion：预加载

#region：运动参数
@export var gravity: float = 3.0
@export var usual_velocity: float = 120.0			## 通用速度
@export var jump_velocity: float = -200.0			## 跳跃速度，向上为负方向
@export var light_jump_threshold: float = -180	## 短跳阈值，向上为负方向

## 松开跳跃键后，上升速度的衰减比例。
## 1 表示额外衰减 100%，表现效果为立即下落
@export var jump_attenuation: float = 0.65

@export var max_fall_speed: float = 240.0			## 最大下落速度的值
@export var slide_angle: float = 30.0			## 不下滑的最大倾角
enum MoveMode {IDLE, RED, BLUE, MENU, DOMINATED}	## 移动模式
@export var move_mode: MoveMode
#endregion：运动参数

#region：重力系统
# 重力方向系统
## 初始状态下，重力方向为向下的单位向量；
## 但在调用 _update_gravity() 之后，重力方向正式成为一个可变的方向，
## 后续使用 gravity_unit_vector 将与最新重力方向保持一致，不再特指向下的单位向量
var gravity_unit_vector: Vector2 = Vector2.DOWN
## 当前重力方向的旋转角度
var gravity_rotation: float = 0.0
var dominate_lock: float = 0.0

## 重力分段系统，用字典存储跳跃过程中不同速度区间对应的重力加速度，具体如下：
## rise_high （高速上升阶段） - 角色刚刚起跳后的高速上升阶段；
## rise_mid （中速上升阶段） - 上升速度减缓后的阶段；
## fall_light （低速下降阶段） - 从上升转为下降的过渡阶段；
## fall_heavy （高速下降阶段） - 加速下落阶段
@export var gravity_piecewise: Dictionary = {
	"rise_high": {"max": -150.0, "accel": 2.5},
	"rise_mid": {"max": -20.0, "accel": 3.0},
	"fall_light": {"max": 10.0, "accel": 4.0},
	"fall_heavy": {"max": 240.0, "accel": 6.0}
}
#endregion：重力系统

#region：初始化
func _ready() -> void:
	Global.register_player(self)	# 注册玩家，用于全局访问玩家节点
	position = Vector2(0.0, 50.0)
	rotation = 0.0
	spr.texture = spr_red
	move_mode = MoveMode.IDLE
	Global.hp = 100
	Global.menu_or_not = false
	gravity_piecewise["rise_high"]["min"] = jump_velocity
	gravity_piecewise["fall_heavy"]["max"] = max_fall_speed
	floor_stop_on_slope = true						# 允许在斜坡上停止滑动，避免自动下滑
	floor_max_angle = deg_to_rad(slide_angle)			# 允许视为地面的最大斜坡角度，弧度
	floor_snap_length = 1.0  						# 启用自动吸附
#endregion：初始化

#region：重力旋转系统 和 方向获取系统
## 传入重力顺时针转过的角度，同时更新重力向量和角色旋转，其中正数代表顺时针
func rotate_gravity(rotation_angle: int, dominate_mode: bool = false):
	if move_mode == MoveMode.BLUE:
		gravity_rotation = deg_to_rad(rotation_angle)
		# 此时，重力方向正式成为一个可变的方向，后续使用 gravity_unit_vector 将与最新重力方向保持一致，不再特指向下的单位向量
		_update_gravity()
	if dominate_mode:
		dominate_lock = 0.0
		dominated_audio_can_play = true
		move_mode = MoveMode.DOMINATED

## 更新重力向量和角色旋转
func _update_gravity():
	# 调整角色旋转，仅对蓝心有效
	if move_mode == MoveMode.BLUE:
		# 获取重力单位向量，它是向下的单位向量旋转后的结果
		gravity_unit_vector = Vector2.DOWN.rotated(gravity_rotation)
		rotation = gravity_rotation
		spr.texture = spr_blue

## 获取水平轴的相对正方向
func _get_horizontal_direction() -> Vector2:
	if move_mode == MoveMode.BLUE:
		# 获取水平轴输入
		var horizontal_input = Input.get_axis("left", "right")
		# 将向下的单位向量顺时针旋转90度，从而获取水平轴正方向
		var horizontal_direction = gravity_unit_vector.rotated(deg_to_rad(-90.0))
		
		return horizontal_input * horizontal_direction
	else:
		return Vector2.ZERO
#endregion：重力旋转系统 和 方向获取系统

#region：角色主体
## 注意：gravity_unit_vector 已与最新重力方向保持一致，不再特指向下的单位向量！
func _physics_process(delta: float) -> void:
	# 运动状态匹配
	match move_mode:
		# 红心：自由移动
		MoveMode.RED:
			velocity = Input.get_vector("left", "right", "up", "down") * usual_velocity		# 获取向量
		
		# 蓝心：受重力
		MoveMode.BLUE:
			# 设置正确的地面检测方向，即重力方向的反方向
			up_direction = -gravity_unit_vector  # 设置地面检测方向为重力反方向
			
			## 由于下方的水平移动脚本会覆盖速度，而速度又是向量，
			## 所以要加上垂直速度的向量，从而保留重力方向的速度
			var vertical_velocity = velocity.dot(gravity_unit_vector) * gravity_unit_vector
			
			# 只改变水平分量
			velocity = _get_horizontal_direction() * usual_velocity + vertical_velocity
			
			# 重力
			if not is_on_floor():
				if velocity.dot(gravity_unit_vector) <= gravity_piecewise["rise_high"]["max"]:
					gravity = gravity_piecewise["rise_high"]["accel"]
				elif velocity.dot(gravity_unit_vector) <= gravity_piecewise["rise_mid"]["max"]:
					gravity = gravity_piecewise["rise_mid"]["accel"]
				elif velocity.dot(gravity_unit_vector) <= gravity_piecewise["fall_light"]["max"]:
					gravity = gravity_piecewise["fall_light"]["accel"]
				elif velocity.dot(gravity_unit_vector) < gravity_piecewise["fall_heavy"]["max"]:
					gravity = gravity_piecewise["fall_heavy"]["accel"]
				else:
					gravity = 0.0
				
				velocity += gravity_unit_vector * gravity
				
			# 跳跃
			if Input.is_action_just_pressed("up") and is_on_floor():
				velocity += gravity_unit_vector * jump_velocity
			
			# 跳跃衰减
			if Input.is_action_just_released("up") and \
			velocity.dot(gravity_unit_vector) <= light_jump_threshold:
				velocity += gravity_unit_vector * usual_velocity * 1.1
			elif Input.is_action_just_released("up") and \
			jump_attenuation != 0 and velocity.dot(gravity_unit_vector) < 0:
				# 额外衰减向上的分量
				velocity += gravity_unit_vector * (-velocity.dot(gravity_unit_vector) * jump_attenuation)
		
		# 菜单模式：固定位置移动
		MoveMode.MENU:
			if Global.menu_or_not:
				position = menu_node.get_menu_position()
		
		MoveMode.DOMINATED:
			dominate_lock += delta
			floor_snap_length = 0.0
			velocity = gravity_unit_vector * 1250
			if dominated_audio_can_play:
				dominated_audio.play(0.3)
				dominated_audio_can_play = false
			
			if is_on_floor() or dominate_lock > 0.1:
				dominate_ani()
	# 执行移动并检测碰撞
	# 决定表面是否为“墙壁”的是内置的 up_direction 和 floor_max_angle
	# 注意：脚本中修改了 up_direction 的方向！
	move_and_slide()
	apply_floor_snap()
	
	if Input.is_action_just_pressed("pk"):
		var wave = pk_shockwave.get_object()
		if wave == null:
			return
		wave.activate()   # 开始扩散动画
#endregion：角色主体

	#region：调试
	## 跳跃调试
	#if Input.is_action_just_pressed("up") and is_on_floor():
		#print("跳跃触发! 重力方向: ", gravity_unit_vector, " 跳跃速度: ", -gravity_unit_vector * jump_velocity)
	## 重力方向调试
	#print("重力方向: ", rad_to_deg(gravity_rotation), "°")
	## 地面检测调试
	#print("地面状态: ", is_on_floor())
	## 速度监测
	#print('now velocity: ', velocity.dot(gravity_unit_vector))
	#endregion：调试

#region：动画调用
## 状态切换动画
func change_heart_color(present_heart):
	# 加载动画场景
	var scene = preload("res://Scene/HeartTransitionAni.tscn")
	var instance = scene.instantiate()
	
	# 添加子对象
	add_child(instance)
	
	# 开始播放动画
	instance.play_animation(present_heart)

func dominate_ani():
	CameraShake.set_directional(true)
	CameraShake.add_trauma(0.7, gravity_unit_vector)
	move_mode = MoveMode.BLUE
#endregion：动画调用

#region：运动模式切换
func enter_red_mode() -> void:
	change_heart_color(ani.PresentHeart.RED)
	spr.texture = spr_red
	move_mode = MoveMode.RED
	velocity = Vector2.ZERO
	gravity_rotation = 0.0
	rotation = 0.0
	toggle_heart_audio.play(0.0)
	_update_gravity()

func enter_blue_mode() -> void:
	change_heart_color(ani.PresentHeart.BLUE)
	spr.texture = spr_blue
	move_mode = MoveMode.BLUE
	velocity = Vector2.ZERO
	toggle_heart_audio.play(0.0)
	_update_gravity()

func enter_menu_mode() -> void:
	move_mode = MoveMode.MENU
	velocity = Vector2.ZERO
	toggle_heart_audio.play(0.0)
	if spr.texture == spr_red:
		change_heart_color(ani.PresentHeart.RED)
	elif spr.texture == spr_blue:
		change_heart_color(ani.PresentHeart.BLUE)
	menu_node.enter_menu_mode()
#endregion：运动模式切换

#region：死亡逻辑
func check_death():
	if Global.hp <= 0:
		# 立即停止所有逻辑
		set_physics_process(false)
		set_process(false)
		Global.player_final_position = global_position
		Global.player_final_texture = spr.texture
		# 进入死亡场景
		get_tree().change_scene_to_packed(death_scene)
		queue_free()
#endregion：死亡逻辑

func _on_get_player_position_pressed() -> void:
	print(position)
