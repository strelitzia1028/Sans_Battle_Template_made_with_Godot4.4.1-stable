# HP.gd
extends CanvasLayer
@onready var hp_bar = $HPBar
@onready var kr_bar = $KRBar
@onready var under_bar = $UnderBar
@onready var label = $Label
@onready var label_num = $LabelNum

func _ready():
	hp_bar.max_value = Global.max_hp
	kr_bar.max_value = Global.max_hp
	under_bar.max_value = Global.max_hp
	label_num.add_theme_font_size_override("font_size", 20)
	label_num.add_theme_font_override("font", preload("res://Font/8bitoperator_jve.ttf"))
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_font_override("font", preload("res://Font/8bitoperator_jve.ttf"))
	_update()

func _process(delta: float) -> void:
	if Global.kr <= 0:
		return
	
	Global.kr_timer += delta
	if Global.kr >= 30:
		if Global.kr_timer >= 0.5:
			Global.kr_timer = 0.0
			Global.kr = max(Global.kr - 1, 0)
			_update()
	elif Global.kr >= 20:
		if Global.kr_timer >= 1.0:
			Global.kr_timer = 0.0
			Global.kr = max(Global.kr - 1, 0)
			_update()
	elif Global.kr >= 10:
		if Global.kr_timer >= 2.0:
			Global.kr_timer = 0.0
			Global.kr = max(Global.kr - 1, 0)
			_update()
	elif Global.kr > 0:
		if Global.kr_timer >= 4.0:
			Global.kr_timer = 0.0
			Global.kr = max(Global.kr - 1, 0)
			_update()

func _update():
	hp_bar.value = Global.hp
	kr_bar.value = Global.hp + Global.kr
	kr_bar.visible = Global.kr > 0
	label.text = "HP" + "                            " + "KR"
	label_num.text = str(min(Global.hp + Global.kr, Global.max_hp)) + " / " + str(Global.max_hp)
	if Global.kr > 0:
		label_num.modulate = Color.MAGENTA
	else:
		label_num.modulate = Color.WHITE
	#print("HP：", hp_bar.value, "|", "KR：", kr_bar.value - hp_bar.value)
