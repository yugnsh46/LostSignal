extends CharacterBody2D


const KNOCKBACK_FORCE : int = 100
const SPEED : int = 100
var is_alive: bool =true
var target = null
var health: int = 100
var strength: int =10
var target_in_range : bool =false
const DROP_CHANCE :float = 1.0
var health_pickup_scene = preload("res://scenes/health_pickup.tscn")


 # this is method to link vaeriable with that node hold ctrl key and drag and drop
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar
@onready var attack_timer: Timer = $AttackTimer 



func _physics_process(delta: float) -> void:
	if is_alive and target:
		_attack(delta)
	




func _attack(delta : float) -> void:    # we use _funcname because only to call for that particular script but without _ we use it for everywhere to call here eg _attack is for slime only and take_damage is for slime and player script as well 
	var direction = (target.position - position).normalized()
	position += direction *SPEED * delta   # multiply by delta to make independent of frame rate
	animated_sprite_2d.play("attack")
	
	
	
func take_damage(damage : int , attacker_position: Vector2) ->void:
	health -= damage
	health_bar.update_health(health)
	if health<=0:
		_die()
	else :
		take_damage_sound.play()
		#knockback
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * KNOCKBACK_FORCE

		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position" , target_position, 0.5)
	



func _die() -> void:
	is_alive=false
	animated_sprite_2d.play("die")
	
	
	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()
#disable collison = slime removed
	$CollisionShape2D.set_deferred("disabled",true)
	$sight/CollisionShape2D.set_deferred("disabled",true)
	$HitBox/CollisionShape2D.set_deferred("disabled",true)
	#drop health pickup
	if randf() <= DROP_CHANCE:
		drop_item()


func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player" :
		target = body
		



func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive :
		target = null
		animated_sprite_2d.play("idle")


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = true
		body.take_damage(strength)
		attack_timer.start()
		
		
func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = false
		body.take_damage(strength)
		attack_timer.stop()
	
	

func _on_attack_timer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(strength)
		
		

func drop_item():
	var drop = health_pickup_scene.instantiate()
	drop.position = position
	var level_root = get_parent().get_parent()
	var items_node = level_root.get_node("Items")
	items_node.call_deferred("add_child" , drop) 
