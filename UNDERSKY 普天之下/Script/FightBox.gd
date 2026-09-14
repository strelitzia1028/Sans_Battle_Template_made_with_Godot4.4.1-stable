# FightBox.gd
extends ColorRect

@export var border: AnimatableBody2D

var change_speed: float

func _ready():
	change_speed = border.change_speed * 3

func _process(delta: float):
	match border.type:
		border.Type.SMALL:
			#size = Vector2(160, 160)
			size = size.move_toward(Vector2(160, 160), change_speed * delta)
			#position = Vector2(320, 220)
			position = position.move_toward(Vector2(320, 220), change_speed * delta)
		
		border.Type.MID:
			#size = Vector2(374, 160)
			size = size.move_toward(Vector2(374, 160), change_speed * delta)
			#position = Vector2(213, 220)
			position = position.move_toward(Vector2(213, 220), change_speed * delta)
		
		border.Type.LARGE:
			#size = Vector2(486, 194)
			size = size.move_toward(Vector2(486, 194), change_speed * delta)
			#position = Vector2(157, 203)
			position = position.move_toward(Vector2(157, 203), change_speed * delta)
