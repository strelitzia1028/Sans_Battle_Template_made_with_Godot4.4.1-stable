# ObjectPoolSupport.gd
extends CharacterBody2D
class_name ObjectPoolSupport

#region：屏幕检测
## margin 的单位是像素
## 正数 margin：扩大检测区域，在屏幕外创建缓冲区；
## 负数 margin：缩小检测区域，创建更严格的检测标准
func is_in_camera_view(margin: float = 150.0) -> bool:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return false
	
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_rect = Rect2(
		camera.global_position - viewport_size * camera.zoom / 2,
		viewport_size * camera.zoom
	)
	camera_rect = camera_rect.grow(margin)
	return camera_rect.has_point(global_position)
#endregion：屏幕检测

#region：对象池支持
## 重置状态
func reset():
	visible = false
	velocity = Vector2.ZERO

## 返回对象池
func return_to_pool():
	# 通过父节点访问对象池
	if get_parent() and get_parent().has_method("return_object"):
		get_parent().return_object(self)
	else:
		# 如果没有对象池，直接销毁
		queue_free()
#endregion：对象池支持
