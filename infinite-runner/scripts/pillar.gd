extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

@onready var hitbox = $Hitbox
@onready var player = $"/root/Main/Player"
@onready var main = $"/root/Main"
@onready var collision = $Hitbox/CollisionPolygon2D

@onready var hit = $Hit
@onready var hit_sound = $HitSound
@onready var hit_sound_2 = $HitSound2
@onready var hit_sound_3 = $HitSound3

var hit_sounds = [hit_sound, hit_sound_2, hit_sound_3]
var sound = hit_sounds.size()

var active = false

func _ready():
	hitbox.body_entered.connect(_on_body_entered)
	player.player_died.connect(_on_player_died)

func set_active(value):
	active = value
	if active:
		sprite.play("idle")
		$Timer.start()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if player.is_attacking:
			hit_sounds = [hit_sound, hit_sound_2, hit_sound_3]
			sound = [hit_sound, hit_sound_2, hit_sound_3].pick_random()
			sound.play()
			player.frame_freeze(0.1, 0.1)
			set_modulate(Color(10,10,10,10))
			sprite.play('death')
			if randi_range(0, 100) < 30:
				main.add_temp(37)
			sprite.animation_finished.connect(_on_animation_finished)
		if not player.is_attacking and not player.is_dashing:
			player.die()

func _on_player_died():
	set_active(false)
	sprite.stop()

func _on_animation_finished():
	queue_free()


func _on_timer_timeout():
	collision.set_deferred("disabled", false)
