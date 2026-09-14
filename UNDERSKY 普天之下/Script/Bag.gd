# Bag.gd
extends Node2D

#region：预加载
@export var en_arial: Resource = preload("res://Font/arial.ttf")
@export var cn_hei_ti: Resource = preload("res://Font/simhei.ttf")
@export var menu_node: Node2D
@export var dialogue_box: Node2D
#endregion：预加载

#region：背包类 和 背包参数
class Item:
	var id: int
	var name: String
	var heal_up: int
	var effect: String
	var label: Label
	var placeholder: Label
	
	func _init(id, name, heal_up, effect):
		self.id = id
		self.name = name
		self.heal_up = heal_up
		self.effect = effect
		self.label = Label.new()
		self.placeholder = Label.new()

var items: Array[Item] = []
var lines: Array[int] = []		# 行索引数组
var columns: Array[int] = []	# 列索引数组
const MAX_LINES: int = 3		# 最大行数
const MAX_COLUMNS: int = 3		# 最大列数
#endregion：背包类 和 背包参数

#region：初始化
func _ready() -> void:
	for i in range(1, MAX_LINES + 1):
		lines.append(i)
	for i in range(1, MAX_COLUMNS + 1):
		columns.append(i)
	_initialize_items()
	update_labels()

## 初始化背包中的物品
func _initialize_items():
	add_item(1, "怪物糖果", 10, "治愈 10 HP", 3)
	add_item(2, "蜘蛛甜甜圈", 12, "治愈 12 HP", 3)
	add_item(3, "奶油糖果派", 99, "治愈 所有 HP", 1)
	add_item(4, "绷带", 5, "治愈 5 HP", 2)
#endregion：初始化

#region：背包相关函数
## 获取指定行和列位置的物品索引
func get_item_index(line: int, column: int) -> int:
	return (line - 1) * columns.size() + (column - 1)

## 向背包中添加物品
func add_item(	id: int = 0,
				name: String = "Default Name",
				heal_up: int = 0,
				effect: String = "Default Effect",
				times: int = 1	):
	
	for i in range(times):
		var new_item = Item.new(id, name, heal_up, effect)
		items.append(new_item)
		new_item.label.text = name
		new_item.label.visible = false
		new_item.label.add_theme_font_override("font", cn_hei_ti)
		new_item.label.add_theme_font_size_override("font_size", 20)
		add_child(new_item.label)
		
		new_item.placeholder.text = "*"
		new_item.placeholder.visible = false
		new_item.placeholder.add_theme_font_override("font", en_arial)
		new_item.placeholder.add_theme_font_size_override("font_size", 30)
		add_child(new_item.placeholder)

## 使用物品，该函数自带 update_labels() 的调用，无需额外操作
func use_item(index: int = 0, remove_after_use: bool = true):
	if index >= 0 and index < items.size():
		if remove_after_use:
			# 移除并更新物品标签
			Global.hp += items[index].heal_up
			dialogue_box.show_text("%s 被使用\n\n" % items[index].name + items[index].effect)
			remove_child(items[index].label)
			items[index].label.queue_free()
			
			remove_child(items[index].placeholder)
			items[index].placeholder.queue_free()
			
			# 重新排序物品
			items.remove_at(index)
			reorganize_items()
		
		update_labels()

## 重新排序物品数组（移除空位）
func reorganize_items():
	# 临时数组，用于重新排序
	var temp_items: Array[Item] = []
	for line_index in lines:
		for column_index in columns:
			var item_index = get_item_index(line_index, column_index)
			if item_index >= 0 and item_index < items.size():
				temp_items.append(items[item_index])
	
	# 用重新排序后的数组替换原数组
	items = temp_items

## 更新物品标签
func update_labels():
	if Global.menu_or_not and menu_node.current_menu_state == menu_node.MenuState.ITEM:
		for item in items:
			item.label.visible = false
			item.placeholder.visible = false
		
		for line_index in lines:
			for column_index in columns:
				# 计算网格位置对应的物品索引
				var item_index = get_item_index(line_index, column_index)
				if item_index >= 0 and item_index < items.size():
					items[item_index].label.position = \
					Vector2(-430 + (200 * column_index), -140 + (90 * line_index))
					items[item_index].label.visible = true
					
					items[item_index].placeholder.position = \
					items[item_index].label.position + Vector2(-20, 0)
					items[item_index].placeholder.visible = true
	else:
		for item in items:
			item.label.visible = false
			item.placeholder.visible = false
#endregion：背包相关函数
