extends CharacterBody2D

signal health_changed(new_health : int)
signal died

const SPEED = 300.0
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var hitbox_offset: Vector2
var alive : bool = true
var strength : int = 20
var max_health: int 
var health : int 
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword_sound: AudioStreamPlayer2D = $SwingSword
@onready var hit_box: Area2D = $HitBox
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var damage_cooldown: Timer = $DamageCooldown


func _ready() -> void:
	#load health from singleton
	health = PlayerStats.health
	max_health = PlayerStats.max_health
	#initialise hitbox offset
	hitbox_offset=hit_box.position
	
func _physics_process(_delta: float) -> void:
	#disable hitbox until an attack is triggered
	hit_box.monitoring = false
	
	if alive:
		if Input.is_action_just_pressed("attack") and not is_attacking:    # and not is_attacking == for not spamming spacebar
			attack()
			
		# skip movement(run) if player is attacking
		if is_attacking:
			velocity = Vector2.ZERO
			return
	
		process_movement()
		process_animation()
		move_and_slide()


# movement and animation:
	# Handle jump.
func process_movement()->void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO
	

	
	
func process_animation() -> void:
	if is_attacking:
		return
		
	if velocity != Vector2.ZERO:
		play_animation("run" , last_direction)
		
	else: 
		play_animation("idle" , last_direction)
	
	
	
func play_animation(prefix: String ,dir: Vector2) -> void:
	if dir.x != 0 :
		animated_sprite_2d.flip_h = dir.x < 0 
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y <0 : 
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y >0 : 
		animated_sprite_2d.play(prefix + "_down")
		
		
#attack
func attack() -> void:
	is_attacking = true
	hit_box.monitoring = true
	swing_sword_sound.play()
	play_animation("attack" , last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking =false



func update_hitbox_offset() -> void:
	var x: = hitbox_offset.x
	var y: = hitbox_offset.y
	
	match last_direction :
		Vector2.LEFT:
			hit_box.position = Vector2(-x,y)
		
		Vector2.RIGHT:
			hit_box.position = Vector2(x,y)
		
		Vector2.UP:
			hit_box.position = Vector2(y,-x)
			
		Vector2.DOWN:
			hit_box.position = Vector2(y,x)
		


func _on_hit_box_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Slime"):  # pta lage je ki attack sirf slime pe hua hai
		body.take_damage(strength, position )


func heal(amount : int) ->void:
	health += amount 
	if health >= max_health :
		health = max_health
	PlayerStats.health = health
	emit_signal("health_changed" , health)



func take_damage(amount : int)->void:
	if alive:
		if damage_cooldown.time_left > 0 :
			return
		take_damage_sound.play()
		health -= amount
		PlayerStats.health = health
		emit_signal("health_changed" , health)
		if health <= 0:
			die()
		#make player invincible for a short time = kyuki 3-4 enemies ek sath -30/-40 damage dedege toh unfair hojega toh timer laga diya damage ka 
		damage_cooldown.start()


func die()->void:
	animated_sprite_2d.play("dying")
	alive = false
	await animated_sprite_2d.animation_finished
	died.emit()
