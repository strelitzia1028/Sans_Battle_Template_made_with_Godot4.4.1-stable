# OtherOptions.gd
extends Node2D

#region：预加载
@export var en_arial: Resource = preload("res://Font/arial.ttf")
@export var cn_hei_ti: Resource = preload("res://Font/simhei.ttf")
@export var menu_node: Node2D
@export var dialogue_box: Node2D
#endregion：预加载

#region：选项类 和 选项参数
class Option:
	var label: Label
	var placeholder: Label
	
	func _init():
		self.label = Label.new()
		self.placeholder = Label.new()

var options: Array[Option] = []
#endregion：选项类 和 选项参数

#region：初始化
func _ready() -> void:
	_initialize_options()
	update_labels()

## 初始化选项
func _initialize_options():
	add_option("调查哼着法语歌的 sky")
	add_option("告诉 sky 图不是你P的以请求原谅")
#endregion：初始化

#region：选项相关函数
## 获取指定行和列位置的选项索引
func get_option_index() -> int:
	if menu_node.current_menu_state == menu_node.MenuState.ACT:
		return 0
	elif menu_node.current_menu_state == menu_node.MenuState.MERCY:
		return 1
	else:
		return 0

## 添加选项
func add_option(name: String = "Default Name", option_position: Vector2 = Vector2(-230, -50)):
	var new_option = Option.new()
	options.append(new_option)
	new_option.label.text = name
	new_option.label.visible = false
	new_option.label.position = option_position
	new_option.label.add_theme_font_override("font", cn_hei_ti)
	new_option.label.add_theme_font_size_override("font_size", 20)
	add_child(new_option.label)
	
	new_option.placeholder.text = "*"
	new_option.placeholder.visible = false
	new_option.placeholder.position = new_option.label.position + Vector2(-20, 0)
	new_option.placeholder.add_theme_font_override("font", en_arial)
	new_option.placeholder.add_theme_font_size_override("font_size", 30)
	add_child(new_option.placeholder)

## 使用选项
func use_option(index: int = 0):
	if index >= 0 and index < options.size():
		if menu_node.current_menu_state == menu_node.MenuState.ACT:
			dialogue_box.show_text("Sky 生命值为 1，攻击力为 1\n\n" + "特殊能力：召唤力王 和 对敌精神回复")
		elif menu_node.current_menu_state == menu_node.MenuState.MERCY:
			dialogue_box.show_text("Sky 说它会考虑考虑的……")
		update_labels()

## 更新选项标签
func update_labels():
	var option_index = get_option_index()
	if Global.menu_or_not and menu_node.current_menu_state == menu_node.MenuState.ACT:
		for option in options:
			option.label.visible = false
			option.placeholder.visible = false
		
		if option_index >= 0 and option_index < options.size():
			options[option_index].label.visible = true
			options[option_index].placeholder.visible = true
	elif Global.menu_or_not and menu_node.current_menu_state == menu_node.MenuState.MERCY:
		if option_index >= 0 and option_index < options.size():
			options[option_index].label.visible = true
			options[option_index].placeholder.visible = true
	else:
		for option in options:
			option.label.visible = false
			option.placeholder.visible = false
#endregion：选项相关函数
