@tool
class_name Coin
extends Area2D

@export var texture: Texture2D = _initial_texture:
	set = _set_texture

@export var tint: Color = Color.WHITE:
	set = _set_tint

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _initial_texture: Texture2D = %Sprite2D.texture
@onready var _coin_sound: AudioStreamPlayer2D = $CoinSound


func _set_texture(new_texture: Texture2D):
	if not is_node_ready():
		await ready
	texture = new_texture
	if texture != null:
		_sprite.texture = texture
	else:
		_sprite.texture = _initial_texture
	notify_property_list_changed()


func _set_tint(new_tint: Color):
	tint = new_tint
	if is_node_ready():
		modulate = tint


func _ready():
	_set_tint(tint)


func _on_body_entered(_body):
	Global.collect_coin()

	# Instantly hide the coin so it looks like it disappears
	visible = false
	collision_layer = 0
	collision_mask = 0

	if _coin_sound:
		_coin_sound.play()
		await _coin_sound.finished

	queue_free()
