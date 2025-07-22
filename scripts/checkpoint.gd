extends Area2D

@export var checkpoint_id: int = 3  # if you want multiple checkpoints

func _ready():
	add_to_group("checkpoints")  # helpful if you want to reset or manage them

func _on_body_entered(body):
	if body.is_in_group("players"):
		if body.has_method("set_checkpoint_position"):
			body.set_checkpoint_position(global_position)
