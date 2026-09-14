# ObjectPool.gd
extends Node2D
class_name ObjectPool

#region：参数
# 对象池配置
@export var object_scene: PackedScene	## 要池化的对象场景
@export var initial_size: int = 20		## 初始池大小
@export var max_size: int = 20			## 最大池大小

# 对象池状态
@export var available_objects: Array = []		## 可用对象列表
@export var active_objects: Array = []			## 正在使用的对象列表
#endregion：参数

#region：调试
var debug_timer: float = 0.0
@export var debug_or_not: bool = false

func _process(delta: float) -> void:
	if debug_or_not:
		debug_timer += delta
		if debug_timer >= 0.5:
			print(get_pool_status())
			debug_timer = 0.0
#endregion：调试

#region：预加载
func _ready():
	# 预创建初始对象
	for i in range(initial_size):
		var obj = create_new_object()
		available_objects.append(obj)
#endregion：预加载

#region：对象池函数
## 创建新对象
func create_new_object() -> Node:
	var obj = object_scene.instantiate()
	add_child(obj)
	obj.visible = false
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	return obj

## 从池中获取对象
func get_object() -> Node:
	var obj: Node
	
	if available_objects.size() > 0:
		# 从可用池中取出对象
		obj = available_objects.pop_back()
	elif active_objects.size() < max_size:
		# 如果未达上限，则创建新对象
		obj = create_new_object()
	else:
		# 如果池已满，则不提供对象
		return null
	
	# 准备对象以供使用
	obj.visible = true
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	active_objects.append(obj)
	return obj

## 将对象返回池中
func return_object(obj: Node):
	# 确保对象有效且在活动列表中
	if not is_instance_valid(obj) or not active_objects.has(obj):
		return
	
	# 重置对象状态
	obj.visible = false
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	
	# 如果对象有重置方法，调用它
	if obj.has_method("reset"):
		obj.reset()
	
	# 从活动列表移除并添加到可用池
	active_objects.erase(obj)
	available_objects.append(obj)

## 获取池状态（调试用）
func get_pool_status() -> String:
	return "可用: %d, 使用中: %d, 总数: %d" % [
		available_objects.size(), 
		active_objects.size(),
		get_child_count()
	]

## 清空对象池
func clear_pool():
	for obj in available_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	
	for obj in active_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	
	available_objects.clear()
	active_objects.clear()
#endregion：对象池函数
