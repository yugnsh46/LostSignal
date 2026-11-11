extends CanvasLayer

const HEART_SIZE : int  = 20 # total 5 hearts each of health 20
var player 
const HEART_FULL = preload("res://assests/images/UI/Heart_full.png")
const HEART_HALF = preload("res://assests/images/UI/Heart_half.png")
const HEART_EMPTY = preload("res://assests/images/UI/Heart_last.png")


@onready var hearts_container: HBoxContainer = $Hearts
@onready var fade_overlay: ColorRect = $FadeOverlay

func set_player (p) -> void:
	player =p
	if player:
		player.health_changed.connect(_update_health)
		_update_health(player.health)


func _update_health(new_health : int) -> void:
	var hearts = hearts_container.get_children()
	var max_hearts = len(hearts)
	var full = int(new_health/ HEART_SIZE)
	var half = 1 if (new_health % HEART_SIZE) > 0 else 0
	var empty = max_hearts - (full+half)

	#update full hearts:
	for i in full:
		hearts[i].texture = HEART_FULL
	#update full hearts:
	if half :
		hearts[full].texture = HEART_HALF
	#update empty hearts
	for i in empty:
		hearts[len(hearts) - 1 -i ].texture  = HEART_EMPTY
		


func fade(to_alpha : float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay , "modulate:a" , to_alpha , 1.5)
	await tween.finished
