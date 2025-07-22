extends Node2D

const TILE_WIDTH: int = 128
const SPRITE: Texture2D = preload("res://assets/tiles-a.png")

@export_range(1, 20, 1, "suffix:tiles") var width: int = 3:
	set = _set_width

@export var one_way: bool = false:
	set = _set_one_way

@export var fall_time: float = -1
@export var respawn_delay: float = 2.5

var fall_timer: Timer
var respawn_timer: Timer
var start_global_position: Vector2

@onready var _rigid_body := %RigidBody2D
@onready var _sprites := %Sprites
@onready var _collision_shape := %CollisionShape2D
@onready var _area_collision_shape := %AreaCollisionShape2D
@onready var _animation_player := %AnimationPlayer


func _ready():
	start_global_position = global_position

	_recreate_sprites()

	# Setup timers
	fall_timer = Timer.new()
	fall_timer.one_shot = true
	fall_timer.timeout.connect(_fall)
	add_child(fall_timer)

	respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(_respawn)
	add_child(respawn_timer)


func _set_width(new_width):
	width = new_width
	if is_node_ready():
		_recreate_sprites()


func _set_one_way(new_one_way):
	one_way = new_one_way
	if is_node_ready():
		_recreate_sprites()


func _recreate_sprites():
	for c in _sprites.get_children():
		c.queue_free()

	_collision_shape.one_way_collision = one_way
	_collision_shape.shape.set_size(Vector2(width * TILE_WIDTH, TILE_WIDTH))
	_area_collision_shape.shape.set_size(
		Vector2(width * TILE_WIDTH, _area_collision_shape.shape.size[1])
	)

	var center: float = (width - 1) * TILE_WIDTH / 2.0

	for i in range(0, width):
		var new_sprite := Sprite2D.new()
		new_sprite.texture = SPRITE
		new_sprite.hframes = 12
		new_sprite.vframes = 3
		new_sprite.position = Vector2(i * TILE_WIDTH - center, 0)

		if one_way:
			if i == 0:
				new_sprite.frame_coords = Vector2i(5, 0) if width > 1 else Vector2i(8, 0)
			elif i == width - 1:
				new_sprite.frame_coords = Vector2i(7, 0)
			else:
				new_sprite.frame_coords = Vector2i(6, 0)
		else:
			new_sprite.frame_coords = Vector2i(10, 1)

		_sprites.add_child(new_sprite)

func _on_area_2d_body_entered(body):
	if not body.is_in_group("players"):
		return

	if fall_time > 0:
		fall_timer.start(fall_time)
		_animation_player.play("shake")
	elif fall_time == 0:
		_rigid_body.freeze = false


func _fall():
	print("⬇️ Platform falling!")
	_animation_player.stop()
	_rigid_body.freeze = false
	respawn_timer.start(respawn_delay)


func _fade_in():
	for sprite in _sprites.get_children():
		if sprite is Sprite2D:
			sprite.modulate.a = 0.0  # Start invisible
			var tween := create_tween()
			tween.tween_property(
				sprite, "modulate:a", 1.0, 0.75
			)

func _respawn():
	print("🔁 Respawning platform")
	
	_rigid_body.freeze = true
	_rigid_body.linear_velocity = Vector2.ZERO
	_rigid_body.angular_velocity = 0
	_rigid_body.rotation = 0
	_rigid_body.global_position = start_global_position

	_recreate_sprites()
	_fade_in()
