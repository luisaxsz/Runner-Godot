@tool
extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_zoom_changed()

func _zoom_changed():
	material.set_shader_parameter("y_zoom", get_viewport().global_canvas_transform.y.y)

func _on_item_rect_changed():
	material.set_shader_parameter("scale", scale)
