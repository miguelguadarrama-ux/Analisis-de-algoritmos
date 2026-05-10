extends CharacterBody2D

const speed = 100
var current_dir = "none"

func _ready():
	print("PLAYER CARGADO")
	get_tree().paused = false
	
	$AnimatedSprite2D.play("idle_front")
	
	call_deferred("restaurar_posicion")

func _physics_process(delta):
	player_movement(delta)

func player_movement(_delta):
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()

func play_anim(movement):
	var anim = $AnimatedSprite2D
	
	match current_dir:
		"right":
			anim.flip_h = false
			anim.play("right_walk" if movement == 1 else "idle_right")
		"left":
			anim.flip_h = false
			anim.play("left_walk" if movement == 1 else "idle_left")
		"down":
			anim.flip_h = true
			anim.play("front_walk" if movement == 1 else "idle_front")
		"up":
			anim.flip_h = true
			anim.play("back_walk" if movement == 1 else "idle_back")

func restaurar_posicion():
	print("Posición guardada:", Global.player_position)

	if Global.player_position != Vector2.ZERO:
		global_position = Global.player_position
		Global.player_position = Vector2.ZERO
		
		await get_tree().create_timer(0.5).timeout
		Global.puede_pelear = true
