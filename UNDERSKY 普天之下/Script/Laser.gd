# Laser.gd
extends RayCast2D

#region：预加载
@onready var line = $Beam
@onready var area = $HurtBox
@onready var collision = $HurtBox/CollisionShape2D
@onready var shape = collision.shape
#endregion：预加载

#region：动画参数
@onready var tween: Tween = null
@export var color: Color = Color.WHITE
@export var is_casting: bool = false
@export var laser_width: float				## 激光的基础宽度
@export var start_distance: float = 30.0	## 激光的起点
@export var max_length: float = 1500.0		## 激光的长度
@export var cast_speed: float = 3000.0		## 激光射出的速度
@export var extend_time: float = 0.15		## 激光动画完成所需的时间
@export var pulse_amplitude: float			## 正弦浮动幅度（宽度变化的相对值）
@export var pulse_speed: float				## 正弦浮动速度（Hz）
var pulse_time: float = 0.0					## 正弦浮动计时器
#endregion：动画参数

#region：初始化
func init(config: Dictionary) -> void:
	line.visible = false
	line.modulate = color
	line.rotation = 0.0
	line.points = [Vector2.ZERO, Vector2.DOWN]
	laser_width = config.get("width")
	pulse_amplitude = config.get("pulse_amplitude")
	pulse_speed = config.get("pulse_speed")
	if not shape:
		shape = RectangleShape2D.new()
		collision.shape = shape
	set_active(false)
	
	if not is_in_group("laser"):
		add_to_group("laser")
#endregion：初始化

#region：激光延伸效果
func _process(delta: float) -> void:
	target_position = target_position.move_toward(
		Vector2.DOWN * max_length, 
		cast_speed * delta
	)
	set_line_point(1, target_position)
	if is_casting:
		pulse_time += delta
		# 使用正弦波创建正弦浮动效果
		var pulse = sin(pulse_time * pulse_speed * PI * 2.0) * pulse_amplitude
		line.width = laser_width * (1.0 + pulse)
	
	var len = line.points[1].y
	var w = _current_width()
	shape.size = Vector2(w, len)
	collision.position = Vector2(0, len * 0.5)
#endregion：激光延伸效果

#region：设置函数
func set_is_casting(new_status: bool) -> void:
	if is_casting == new_status:
		return
	is_casting = new_status
	
	if is_casting:
		var laser_start_position: Vector2 = Vector2.DOWN * start_distance
		set_line_point(0, laser_start_position)
		set_line_point(1, laser_start_position)
		target_position = laser_start_position
		pulse_time = 0.0	# 重置正弦浮动计时器
		appear()
	else:
		target_position = Vector2.DOWN * max_length
		disappear()

func set_line_point(index: int, position: Vector2) -> void:
	if index < line.points.size():
		var points = line.points
		points.set(index, position)
		line.points = points
#endregion：设置函数

#region：动画
func appear():
	if tween and tween.is_running():
		tween.kill()
	
	line.modulate = Color.TRANSPARENT
	line.visible = true
	tween = create_tween()
	tween.set_parallel(true)
	
	# 快速变宽
	tween.set_trans(Tween.TRANS_CIRC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(line, "width", laser_width * 2.15, extend_time * 0.7)
	
	# 透明度变化
	tween.parallel()
	tween.tween_property(line, "modulate:a", 1.0, extend_time * 0.7)
	
	# 收缩到基础宽度
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.chain()
	tween.tween_property(line, "width", laser_width, extend_time * 1.2)

func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	# 慢速收缩
	tween.set_trans(Tween.TRANS_CIRC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.chain()
	tween.tween_property(line, "width", laser_width * 1.35, extend_time)
	
	# 快速收缩
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.tween_property(line, "width", 0.0, extend_time * 3)
	
	# 淡出
	tween.parallel()
	tween.tween_property(line, "modulate:a", 0.0, extend_time * 3)
	tween.chain().tween_callback(line.hide)
#endregion：动画

#region：伤害区域绘制
## 伤害区域是否处于可用状态
func set_active(enable: bool) -> void:
	area.monitoring = enable
	area.monitorable = enable
	area.visible = enable
	# 非发射阶段把形状尺寸清 0，防止残留
	if not enable:
		shape.size = Vector2.ZERO

## 计算实时宽度
func _current_width() -> float:
	var t = min(pulse_time / extend_time, 1.0)
	var w = laser_width * lerpf(2.0, 1.0, t)
	if pulse_amplitude > 0 and pulse_speed > 0:
		w *= 1.0 + sin(pulse_time * pulse_speed * PI * 2.0) * pulse_amplitude
	return max(w, 0.01)

## 获取PK力场的碰撞点
func get_pk_collision() -> void:
	pass
#endregion：伤害区域绘制
