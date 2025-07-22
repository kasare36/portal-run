extends Area2D

@export var checkpoint_id: int = 3  # if you want multiple checkpoints

func _ready():
	add_to_group("checkpoints")  # helpful if you want to reset or manage them
