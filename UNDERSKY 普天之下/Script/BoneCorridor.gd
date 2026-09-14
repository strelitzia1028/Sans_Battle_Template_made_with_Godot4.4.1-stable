# BoneCorridor.gd
extends ObjectPoolSupport
class_name BoneCorridor

## 骨头场景（在编辑器中拖入 Bone.tscn）
@export var bone_scene: PackedScene
@export var corridor_group: CanvasGroup
## 可选计时器
@export var timer: Timer
## 预设着色器
@export var shader_1: ShaderMaterial

# 内部骨头对象池
var _bone_pool: Array = []		## 可用的骨头实例
var _active_bones: Array = []	## 当前激活的骨头
var _max_pool_size: int = 100	## 骨头池最大容量（可根据需要调整）

# 配置参数
var start_x: float		## 首根骨头的 x 坐标
var start_y: float		## 首根骨头的 y 坐标
var space_x: float		## 骨头之间的水平间距
var space_h: float		## 长廊高度空间
var speed: float			## 长廊移动速度
var angle: float			## 长廊倾斜角度
var count: int			## 骨头数量
var bone_type: String	## 骨头类型
var bone_height: int		## 骨头高度
var corridor_velocity: Vector2 = Vector2.ZERO
var wave_amplitude: float	## 波浪的振幅，0 表示无波浪
var wave_frequency: float	## 波浪的频率（每单位 rel_x 的周期数，越大波越密）
var wave_offset: float		## 波浪的相位偏移（弧度），可用来微调初始波形

func init(config: Dictionary) -> void:
	start_x = config.get("start_x", 0.0)
	start_y = config.get("start_y", 0.0)
	count = config.get("count", 10)
	space_x = config.get("space_x", 10.0)
	space_h = config.get("space_h", 100.0)
	speed = config.get("speed", 5.0)
	angle = config.get("angle", 0.0)
	bone_type = config.get("type", "white")
	bone_height = config.get("height", 10)
	wave_amplitude = config.get("wave_amplitude", 0.0)
	wave_frequency = config.get("wave_frequency", 1.0)
	wave_offset = config.get("wave_offset", 0.0)
	
	global_position = Vector2(start_x, start_y)
	rotation = deg_to_rad(angle)
	var direction = Vector2.RIGHT.rotated(rotation)
	corridor_velocity = direction * speed
	
	_max_pool_size = max(count * 2 + 10, 100)
	# 确保骨头池已初始化
	if _bone_pool.size() == 0:
		_prepare_pool()

func _prepare_pool():
	# 清空旧数据
	for bone in _bone_pool:
		if is_instance_valid(bone):
			bone.queue_free()
	_bone_pool.clear()
	_active_bones.clear()

	# 预创建一些骨头放入池中
	for i in range(min(count * 2, _max_pool_size)):
		var bone = _create_new_bone()
		_bone_pool.append(bone)

func _create_new_bone() -> Node2D:
	if bone_scene == null:
		push_error("BoneCorridor: 未设置 bone_scene")
		return null
	var bone = bone_scene.instantiate()
	bone.visible = false
	bone.process_mode = Node2D.PROCESS_MODE_DISABLED
	corridor_group.add_child(bone)
	return bone

func _get_bone_from_pool() -> Node2D:
	var bone: Node2D
	if _bone_pool.size() > 0:
		bone = _bone_pool.pop_back()
	elif _active_bones.size() < _max_pool_size:
		bone = _create_new_bone()
	else:
		push_warning("骨头对象池已满，无法获取更多骨头")
		return null

	bone.visible = true
	bone.process_mode = Node2D.PROCESS_MODE_INHERIT
	_active_bones.append(bone)
	return bone

func _return_bone_to_pool(bone: Node2D):
	if not is_instance_valid(bone) or not _active_bones.has(bone):
		return
	bone.visible = false
	bone.process_mode = Node2D.PROCESS_MODE_DISABLED
	if bone.has_method("return_managed"):
		bone.return_managed()
	_active_bones.erase(bone)
	_bone_pool.append(bone)

func start_attack():
	visible = true
	_recycle_all_active()
	for i in range(count):
		var bone_top = _get_bone_from_pool()
		var bone_bottom = _get_bone_from_pool()
		if bone_top == null or bone_bottom == null:
			break
		var rel_x = -i * space_x
		
		# 上排骨头
		bone_top.position = Vector2(rel_x, 0.0)
		bone_top.init({
			"start_x": 0.0, "start_y": 0.0,
			"type": bone_type, "height": bone_height,
			"x_velocity": 0.0, "y_velocity": 0.0,
			"width": 1.0, "angle": 0.0,
			"is_managed_by_parent": true
		})
		bone_top.start_attack()
		var top_half_h = (bone_top.top_h + bone_top.mid_h * bone_height + bone_top.bottom_h) * 0.5
		
		# 下排骨头
		bone_bottom.position = Vector2(rel_x, 0.0)
		bone_bottom.init({
			"start_x": 0.0, "start_y": 0.0,
			"type": bone_type, "height": bone_height,
			"x_velocity": 0.0, "y_velocity": 0.0,
			"width": 1.0, "angle": 0.0,
			"is_managed_by_parent": true
		})
		bone_bottom.start_attack()
		var bottom_half_h = (bone_bottom.top_h + bone_bottom.mid_h * bone_height + bone_bottom.bottom_h) * 0.5
		
		# 波浪偏移
		var wave_y_offset = sin(rel_x * wave_frequency + wave_offset) * wave_amplitude
		# 最终位置
		bone_top.position = Vector2(rel_x, -(space_h / 2 + top_half_h) + wave_y_offset)
		bone_bottom.position = Vector2(rel_x, space_h / 2 + bottom_half_h + wave_y_offset)
		
		bone_top.material = shader_1
		bone_bottom.material = shader_1
	set_process(true)

func _recycle_all_active():
	# 把当前激活的骨头全部放回池中
	for bone in _active_bones:
		_return_bone_to_pool(bone)
	_active_bones.clear()
	print("骨头已回收到对象池")

func _physics_process(delta: float) -> void:
	position += corridor_velocity * delta
	# 完全移出屏幕后回收整个长廊
	if is_out_of_screen():
		return_to_pool()

func is_out_of_screen() -> bool:
	var screen_rect = get_viewport().get_visible_rect().grow(200)
	return not screen_rect.has_point(global_position)

# 回收长廊自身
func return_to_pool():
	set_process(false)
	_recycle_all_active()
	visible = false
	corridor_velocity = Vector2.ZERO
	super.return_to_pool()
	print("骨头长廊已回收到对象池")

# 对象池重置回调（当长廊被取出复用时调用）
func reset():
	_recycle_all_active()
	if timer:
		timer.stop()
	visible = false
	corridor_velocity = Vector2.ZERO
	# 注意：不要清空 _bone_pool，保留已创建的骨头供下次使用
