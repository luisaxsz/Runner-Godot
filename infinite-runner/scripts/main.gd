extends Node2D

signal game_over

@export var modifier = 1.0
@export var world_speed = 800
@export var level = 0

@onready var moving = $Environment/Moving
@onready var distance_label = $HUD/UI/Distance
@onready var temp_label = $HUD/UI/Temp
@onready var start_label = $HUD/UI/Start
@onready var player = $Player
@onready var ground = $Environment/Static/Ground
@onready var background = $Background
@onready var reflection = $Reflection

var platform = preload ("res://infinite-runner/scenes/platform.tscn")
var enemy = preload ("res://infinite-runner/scenes/enemy.tscn")
var destructible_enemy = preload ("res://infinite-runner/scenes/destructible_enemy.tscn")
var moving_enemy = preload ("res://infinite-runner/scenes/moving_enemy.tscn")

var rng = RandomNumberGenerator.new()
var last_platform_position = Vector2.ZERO
var next_spawn_time = 0
var distance = 0
var prev_distance = 1.0
var max_speed = 1500
var min_speed = 500
var start_temp = 37
var min_temp = 30
var temp = 37
var distance_calc = 0
var threshold = 100

var obstacle_types := [enemy, enemy,  enemy, enemy, enemy, destructible_enemy, destructible_enemy, destructible_enemy]
var platforms: Array
var last_obstacle
var screen_size: Vector2
var moving_enemy_heights := [600, 750]
var time = 0

func _ready():
	screen_size = get_window().size
	rng.randomize()
	player.player_died.connect(_on_player_died)
	ground.body_entered.connect(_on_ground_body_entered)

func _process(delta):

	time +=1
	if level == 1:
		reflection.set_visible(false)
	if level == 2:
		reflection.set_visible(true)
	if level == 3:
		level = 0

	if platforms.size() > 5:
		for plat in platforms:
			if plat.position.x > 3000:
				platforms.erase(plat)
	
	if distance - distance_calc > threshold:
		level += 1
		modifier = modifier + 0.05
		distance_calc += threshold
	
	if player.active:
		distance += 0.03 * world_speed * delta
		temp -= 0.5 * delta * modifier

	if temp < start_temp:
		var value = start_temp - temp
		player.is_hit(value)
		start_temp = temp

	if snapped(distance, 0) == prev_distance:
		prev_distance += 1
		if world_speed < max_speed:
			world_speed += 0.5
			#player.speed = world_speed

	# Spawn a new platform
	if time > next_spawn_time:
		_spawn_next_platform()
		_generate_obstacles()

	# Update the UI labels
	# distance_label.text = str(Engine.get_frames_per_second()) + "fps"
	distance_label.text = str(snapped(distance, 0)) + "m"
	temp_label.text = "temp: " + str(snapped(temp, 0)) + " ºC"

func _spawn_next_platform():
	if platforms.size() <= 5:
		var new_platform = platform.instantiate()
		platforms.append(new_platform)
		
		# Set position of new platform
		new_platform.position = Vector2(last_platform_position.x + 3859, 538)

		# Add platform to moving environment
		moving.add_child(new_platform)

		# Update last platform position and increase next spawn
		last_platform_position = new_platform.position
		next_spawn_time += world_speed /2

func _generate_obstacles():
	var obstacle_type = obstacle_types.pick_random()
	var obs_number
	var obstacle = obstacle_type.instantiate()

	if randi_range(1, 10) < 5:
		obs_number = 2
	else:
		obs_number = 1
	if not last_obstacle:
		var x: int = screen_size.x + distance + randi_range( - 100, 50)
		var y: int = 786
		last_obstacle = obstacle
		_add_obstacle(obstacle, x, y)

		if obs_number == 2:
			obstacle = obstacle_type.instantiate()
			_add_obstacle(obstacle, x + 80, y)
	if last_obstacle:
		var x: int = last_obstacle.position.x + randi_range(400*modifier, 750*modifier)
		var y: int = 786

		#Spawn Moving enemy
		if (randi_range(1, 10) < 2) and level > 0:
			_add_obstacle(moving_enemy.instantiate(), x, moving_enemy_heights.pick_random())

		last_obstacle = obstacle
		_add_obstacle(obstacle, x, y)
		if obs_number == 2:
			obstacle = obstacle_type.instantiate()
			_add_obstacle(obstacle, x + 80, y)

func _add_obstacle(obstacle, x, y):
	obstacle.position = Vector2i(x, y)
	moving.add_child(obstacle)

func _physics_process(delta):
	if not player.active:
		return

	#Move plataforms left
	moving.position.x -= world_speed * delta

func add_temp(value):
	temp = value
	start_temp = temp
	player.is_healed()

func speed():
	return world_speed

func _on_player_died():
	emit_signal("game_over")
	start_label.set_visible(true)
	start_label.text = start_label.text % snapped(distance, 0)

func _on_ground_body_entered(body):
	if body.is_in_group("player"):
		player.die()

func retry():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()