# Bone.gd
extends ObjectPoolSupport

#region：预加载
@onready var top = $Top
@onready var mid = $Mid
@onready var bottom = $Bottom
@onready var area = $HurtBox
@onready var collision = $HurtBox/BoneCollision
#endregion：预加载

#region：动画参数
@export var debug_or_not: bool = false
var tween: Tween = null
var start_x: float				## 骨头的 x 坐标
var start_y: float				## 骨头的 y 坐标
var type: String					## 骨头的类型
var height: int					## 骨头的高度（按段计算，使用整数；0 表示只有 Top 和 Bottom 部分，没有 Mid 部分）
var x_velocity: float			## 骨头移动的 x 方向速度
var y_velocity: float			## 骨头移动的 y 方向速度
var width: float					## 骨头的宽度
var angle: float					## 骨头的角度
var top_h: float
var mid_h: float
var bottom_h: float
var box: RectangleShape2D
var can_attack: bool = false
var is_cache_completed = false
var state_timer: float = 0.0
var is_managed_by_parent: bool	## 是否由父节点统一管理

func _ready():
	top_h = top.texture.get_height()
	mid_h = mid.texture.get_height()
	bottom_h = bottom.texture.get_height()
	if collision and collision.shape == null:
		collision.shape = RectangleShape2D.new()

## 初始化参数
func init(config: Dictionary) -> void:
	start_x = config.get("start_x")
	start_y = config.get("start_y")
	type = config.get("type")
	height = max(config.get("height"), 0)
	x_velocity = config.get("x_velocity")
	y_velocity = config.get("y_velocity")
	width = config.get("width")
	angle = config.get("angle")
	is_managed_by_parent = config.get("is_managed_by_parent", false)
	is_cache_completed = true
	
	area.init(type)
	# 只在未被统一管理时设置全局坐标，防止坐标覆盖
	if not is_managed_by_parent:
		global_position = Vector2(start_x, start_y)
	velocity = Vector2.ZERO
	rotation = deg_to_rad(angle)
	scale.x = width
	can_attack = false
	visible = false
	state_timer = 0.0
	
	# 确保节点加载后更新外观
	if is_inside_tree():
		_update_appearance()
	else:
		call_deferred("_update_appearance")
	
	if not is_in_group("bone"):
		add_to_group("bone")
#endregion：动画参数

func _physics_process(delta: float) -> void:
	# 移动逻辑
	if is_in_camera_view(0.0):
		if can_attack:
			# 应用旋转后的速度
			var rotated_velocity = Vector2(x_velocity, y_velocity).rotated(rotation)
			velocity = rotated_velocity
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		# 只有未被管理时才自动回收
		if not is_managed_by_parent:
			return_to_pool()
	move_and_slide()

# 更新骨头外观和碰撞区域
func _update_appearance():
	if debug_or_not:
		queue_redraw()
	
	if not is_inside_tree() or not collision or collision.shape == null:
		return
	
	# 关掉 centered，让 (0,0) 就是左上角
	top.centered = false
	mid.centered = false
	bottom.centered = false
	var total_h = top_h + (mid_h * height) + bottom_h		# 计算总高度
	var top_left_y = -total_h * 0.5		# 计算左上角起点，骨头整体中心在 (0,0)
	# 依次放置三段
	top.position = Vector2(-top.texture.get_width() * 0.5, top_left_y)
	mid.position = Vector2(-mid.texture.get_width() * 0.5, top_left_y + top_h)
	bottom.position = Vector2(-bottom.texture.get_width() * 0.5, top_left_y + top_h + mid_h * height)
	mid.region_enabled = true		# 中段拉伸
	mid.region_rect = Rect2(0, 0, mid.texture.get_width(), mid_h * height)
	
	match type:
		"white":
			modulate = Color.WHITE
		
		"blue":
			modulate = Color.AQUA
		
		"orange":
			modulate = Color.ORANGE
	
	# 更新碰撞盒
	box = collision.shape
	var total_w = max(
		top.texture.get_width(), 
		mid.texture.get_width(), 
		bottom.texture.get_width()
	) * width
	# 设置碰撞形状大小
	box.size = Vector2(total_w, total_h)
	# 碰撞位置设置为 0
	collision.position = Vector2(0, 0)

#region：对象池支持部分重写
## 重置状态（用于对象池）
func reset():
	# 重置状态
	state_timer = 0.0
	visible = false
	velocity = Vector2.ZERO
	can_attack = false
	# 重置中段区域
	if mid:
		mid.region_enabled = false

func return_managed():
	is_managed_by_parent = false
	can_attack = false
	visible = false
	velocity = Vector2.ZERO
	if mid:
		mid.region_enabled = false
#endregion：对象池支持部分重写

#region：外部调用开始攻击
func start_attack():
	can_attack = true
	visible = true
	# 确保更新外观
	if is_inside_tree():
		_update_appearance()
	else:
		call_deferred("_update_appearance")
#endregion：外部调用开始攻击

func _draw() -> void:
	if box == null:
		return
	
	if debug_or_not:
		# 绘制中心点
		draw_circle(Vector2(-mid.texture.get_width(), 0), 5, Color.BLUE)
		# 绘制各部分位置标记
		draw_circle(top.position, 5, Color.GREEN)		# 顶部位置
		draw_circle(mid.position, 5, Color.YELLOW)		# 中段位置
		draw_circle(bottom.position, 5, Color.RED)		# 底部位置
