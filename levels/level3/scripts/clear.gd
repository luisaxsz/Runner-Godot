extends Label

func _ready():
	pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://levels/level4/scenes/level4.tscn")