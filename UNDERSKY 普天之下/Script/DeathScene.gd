# DeathScene.gd
extends ColorRect

@export var spr_red: Texture = preload("res://Asset/heart/red.png")
@export var spr_blue: Texture = preload("res://Asset/heart/blue_down.png")
@onready var dead_heart = $DeadHeart
@onready var ani = $DeathAni

func _ready():
	dead_heart.global_position = Global.player_final_position
	dead_heart.texture = Global.player_final_texture
	match Global.player_final_texture:
		spr_red:
			ani.play("RedDie")
		
		spr_blue:
			ani.play("BlueDie")
	
	await ani.animation_finished
	await get_tree().create_timer(1.5).timeout
