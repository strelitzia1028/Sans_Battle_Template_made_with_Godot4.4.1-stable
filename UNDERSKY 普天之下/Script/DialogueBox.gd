# DialogueBox.gd
extends Node2D
class_name DialogueBox

@onready var speak_audio = $Speak

class Dialogue:
	var content: Label
	var placeholder: Label
	var full_text: String = ""
	var current_char_index: int = 0
	var is_finished: bool = false
	var timer: Timer
	
	func _init():
		self.content = Label.new()
		self.placeholder = Label.new()
		self.timer = Timer.new()

var dialogues: Array[Dialogue] = []
var current_dialogue: Dialogue = null

func _ready():
	# 确保有对话时 timer 可用
	if dialogues.size() > 0:
		current_dialogue = dialogues[0]

## 显示文本的函数
func show_text(	text: String = "Default Text",
				clear_last: bool = true,
				show_per_char_time: float = 0.05,
				font_size_of_text: int = 20,
				font_size_of_placeholder: int = 30,
				label_position: Vector2 = Vector2(-230.0, -40.0),
				label_rotation: float = 0.0,
				font_of_text: Resource = preload("res://Font/simhei.ttf"),
				font_of_placeholder: Resource = preload("res://Font/arial.ttf")):
	
	if clear_last:
		clear_last_dialogue()
	# 创建新对话
	var new_dialogue = Dialogue.new()
	dialogues.append(new_dialogue)
	current_dialogue = new_dialogue
	
	# 设置文本属性
	new_dialogue.content.text = ""
	new_dialogue.content.visible = true
	new_dialogue.content.position = label_position
	new_dialogue.content.rotation = label_rotation
	new_dialogue.content.add_theme_font_override("font", font_of_text)
	new_dialogue.content.add_theme_font_size_override("font_size", font_size_of_text)
	add_child(new_dialogue.content)
	
	new_dialogue.placeholder.text = "*"
	new_dialogue.placeholder.visible = true
	new_dialogue.placeholder.position = new_dialogue.content.position + Vector2(-20, 0)
	new_dialogue.placeholder.rotation = new_dialogue.content.rotation
	new_dialogue.placeholder.add_theme_font_override("font", font_of_placeholder)
	new_dialogue.placeholder.add_theme_font_size_override("font_size", font_size_of_placeholder)
	add_child(new_dialogue.placeholder)
	
	# 设置完整文本和定时器
	new_dialogue.full_text = text
	new_dialogue.current_char_index = 0
	
	# 配置定时器
	new_dialogue.timer.one_shot = false
	new_dialogue.timer.wait_time = show_per_char_time
	new_dialogue.timer.timeout.connect(_on_char_timer_timeout)
	add_child(new_dialogue.timer)
	new_dialogue.timer.start()

## 定时器回调，逐个显示字符
func _on_char_timer_timeout():
	if current_dialogue == null or dialogues.size() == 0:
		return
	
	# 检查是否还有字符需要显示
	if current_dialogue.current_char_index < current_dialogue.full_text.length():
		# 添加下一个字符
		current_dialogue.content.text += current_dialogue.full_text[current_dialogue.current_char_index]
		current_dialogue.current_char_index += 1
		
		# 播放音效（跳过空格）
		if current_dialogue.full_text[current_dialogue.current_char_index - 1] != " ":
			speak_audio.play(0.0)
	else:
		# 所有字符显示完毕，停止定时器
		current_dialogue.timer.stop()
		current_dialogue.is_finished = true

## 立即完成当前对话
func complete_current_dialogue():
	# 防止玩家操作过快，导致因 对话不存在 或 计时器无效 而出现报错
	if current_dialogue != null and current_dialogue.timer:
		if current_dialogue.timer.is_stopped() == false:
			current_dialogue.timer.stop()
			current_dialogue.content.text = current_dialogue.full_text
			current_dialogue.current_char_index = current_dialogue.full_text.length()
			current_dialogue.is_finished = true

func is_complete_current_dialogue() -> bool:
	if current_dialogue != null and current_dialogue.is_finished:
		return true
	else:
		return false

## 清除上一个对话
func clear_last_dialogue():
	if dialogues.size() > 0:
		var last_dialogue = dialogues[dialogues.size() - 1]
		
		# 停止并移除定时器
		if last_dialogue.timer:
			last_dialogue.timer.stop()
			remove_child(last_dialogue.timer)
			last_dialogue.timer.queue_free()
		
		# 移除文本和占位符
		if last_dialogue.content:
			remove_child(last_dialogue.content)
			last_dialogue.content.queue_free()
		
		if last_dialogue.placeholder:
			remove_child(last_dialogue.placeholder)
			last_dialogue.placeholder.queue_free()
		
		dialogues.remove_at(dialogues.size() - 1)
	
	# 如果没有对话了，重置当前对话
	if dialogues.size() == 0:
		current_dialogue = null

## 清除所有对话
func clear_all_dialogue():
	if dialogues.size() > 0:
		for dialogue in dialogues:
			if dialogue.timer:
				dialogue.timer.stop()
				remove_child(dialogue.timer)
				dialogue.timer.queue_free()
			
			if dialogue.content:
				remove_child(dialogue.content)
				dialogue.content.queue_free()
			
			if dialogue.placeholder:
				remove_child(dialogue.placeholder)
				dialogue.placeholder.queue_free()
			
			dialogues.remove_at(0)
