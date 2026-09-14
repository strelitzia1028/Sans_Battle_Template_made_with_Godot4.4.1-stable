# Border.gd
extends AnimatableBody2D

#region：预加载
@onready var border_line = $BorderLine
@onready var collision_line = $CollisionLine
@onready var mask = $SubViewportContainer/SubViewport/Mask
#endregion：预加载

#region：动画参数
@export var change_speed: float = 300.0
enum Type {SMALL, MID, LARGE}
@export var type: Type = Type.SMALL

# 目标点
@export var border_zs: Vector2 = Vector2(-80.0, -80.0)	## 左上方边界点（目标）
@export var border_zx: Vector2 = Vector2(-80.0, 80.0)		## 左下方边界点（目标）
@export var border_yx: Vector2 = Vector2(80.0, 80.0)		## 右下方边界点（目标）
@export var border_ys: Vector2 = Vector2(80.0, -80.0)		## 右上方边界点（目标）
@export var collision_zs: Vector2 = Vector2(-77.0, -77.0)
@export var collision_zx: Vector2 = Vector2(-77.0, 77.0)
@export var collision_yx: Vector2 = Vector2(77.0, 77.0)
@export var collision_ys: Vector2 = Vector2(77.0, -77.0)

# 即时点
@export var border_zs_instant: Vector2 = Vector2(0.0, 0.0)		## 左上方边界点（即时）
@export var border_zx_instant: Vector2 = Vector2(0.0, 0.0)		## 左上方边界点（即时）
@export var border_yx_instant: Vector2 = Vector2(0.0, 0.0)		## 左上方边界点（即时）
@export var border_ys_instant: Vector2 = Vector2(0.0, 0.0)		## 左上方边界点（即时）
@export var collision_zs_instant: Vector2 = Vector2(-77.0, -77.0)
@export var collision_zx_instant: Vector2 = Vector2(-77.0, 77.0)
@export var collision_yx_instant: Vector2 = Vector2(77.0, 77.0)
@export var collision_ys_instant: Vector2 = Vector2(77.0, -77.0)
#endregion：动画参数

#region：初始化
func _ready() -> void:
	type = Type.SMALL
	border_line.points = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
#endregion：初始化

#region：动画
# 为了防止角色在边界框改变大小时穿到框外，这里不能使用 _process()，因为它不和物理处理同步
func _physics_process(delta: float) -> void:
	match type:
		Type.SMALL:
			set_border_points(80.0, 80.0)
			set_collision_points(77.0, 77.0)
		
		Type.MID:
			set_border_points(187.0, 80.0)
			set_collision_points(184.0, 77.0)
		
		Type.LARGE:
			set_border_points(243.0, 96.0)
			set_collision_points(240.0, 93.0)
	
	set_point(0, border_zs_instant, collision_zs_instant)
	set_point(1, border_zx_instant, collision_zx_instant)
	set_point(2, border_yx_instant, collision_yx_instant)
	set_point(3, border_ys_instant, collision_ys_instant)
	set_point(4, border_zs_instant + Vector2(-2.5, 0), collision_zs_instant)
	
	border_zs_instant = border_zs_instant.move_toward(border_zs, change_speed * delta)
	border_zx_instant = border_zx_instant.move_toward(border_zx, change_speed * delta)
	border_yx_instant = border_yx_instant.move_toward(border_yx, change_speed * delta)
	border_ys_instant = border_ys_instant.move_toward(border_ys, change_speed * delta)
	collision_zs_instant = collision_zs_instant.move_toward(collision_zs, change_speed * delta)
	collision_zx_instant = collision_zx_instant.move_toward(collision_zx, change_speed * delta)
	collision_yx_instant = collision_yx_instant.move_toward(collision_yx, change_speed * delta)
	collision_ys_instant = collision_ys_instant.move_toward(collision_ys, change_speed * delta)
#endregion：动画

#region：设置函数
func set_process_state(enabled: bool):
	set_process(enabled)
	mask.set_process(enabled)

func set_point(index: int, border_position: Vector2, collision_position: Vector2) -> void:
	if index < border_line.points.size():
		var border_points = border_line.points
		border_points.set(index, border_position)
		border_line.points = border_points
	
	if index < collision_line.polygon.size():
		var collision_points = collision_line.polygon
		collision_points.set(index, collision_position)
		collision_line.polygon = collision_points

## 设置边界线的顶点，需要传入第一象限的点坐标
func set_border_points(x: float, y: float):
	border_zs = Vector2(-x, -y)
	border_zx = Vector2(-x, y)
	border_yx = Vector2(x, y)
	border_ys = Vector2(x, -y)

## 设置碰撞线的顶点，需要传入第一象限的点坐标
func set_collision_points(x: float, y: float):
	collision_zs = Vector2(-x, -y)
	collision_zx = Vector2(-x, y)
	collision_yx = Vector2(x, y)
	collision_ys = Vector2(x, -y)
#endregion：设置函数

func _on_small_pressed() -> void:
	set_process_state(true)
	type = Type.SMALL

func _on_mid_pressed() -> void:
	set_process_state(true)
	type = Type.MID

func _on_large_pressed() -> void:
	set_process_state(true)
	type = Type.LARGE
