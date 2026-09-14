# SansDialogueBox.gd
extends DialogueBox

@onready var popover = $Popover
@onready var select_audio = $Select
var state_timer: float = 0.0

func _process(delta: float) -> void:
	if Global.is_sans_talking:
		state_timer += delta
		if Input.is_action_just_pressed("select") and state_timer >= 1:
			select_audio.play(0.0)
			clear_last_dialogue()
			Global.is_sans_talking = false
			state_timer = 0.0

func _ready() -> void:
	popover.visible = false

## 显示文本的函数
func show_sans_text(text: String = "Default Text",
					text_offset: Vector2 = Vector2(-40.0, -10.0),
					clear_last: bool = true,
					show_per_char_time: float = 0.05,
					font_size_of_text: int = 20,
					label_rotation: float = 0.0,
					font_of_text: Resource = preload("res://Font/DTM-Sans.otf")):
	
	if clear_last:
		clear_last_dialogue()
	
	var new_dialogue = DialogueBox.Dialogue.new()
	dialogues.append(new_dialogue)
	current_dialogue = new_dialogue
	
	# 设置文本属性
	new_dialogue.content.text = ""
	new_dialogue.content.visible = true
	new_dialogue.content.position = popover.position + text_offset
	new_dialogue.content.rotation = label_rotation
	new_dialogue.content.add_theme_font_override("font", font_of_text)
	new_dialogue.content.add_theme_font_size_override("font_size", font_size_of_text)
	new_dialogue.content.add_theme_color_override("font_color", Color.BLACK)
	add_child(new_dialogue.content)
	
	# 显示气泡框
	popover.visible = true
	new_dialogue.full_text = text
	new_dialogue.current_char_index = 0
	
	# 配置定时器
	new_dialogue.timer.one_shot = false
	new_dialogue.timer.wait_time = show_per_char_time
	new_dialogue.timer.timeout.connect(_on_char_timer_timeout)
	add_child(new_dialogue.timer)
	new_dialogue.timer.start()

func clear_last_dialogue():
	super.clear_last_dialogue()
	# 清除后隐藏气泡框
	if dialogues.size() == 0:
		popover.visible = false

func clear_all_dialogue():
	super.clear_all_dialogue()
	popover.visible = false
	Global.is_sans_talking = false
