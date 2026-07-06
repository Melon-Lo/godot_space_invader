extends Node2D

@onready var start_button: TextureButton = $CanvasLayer/CenterContainer/StartButton
@onready var game_over: TextureRect = $CanvasLayer/CenterContainer/GameOver

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var score = 0

var row_enemies_count = 9
var column_enemies_count = 3
var total_enemies = 0


func _ready() -> void:
	start_button.show()
	game_over.hide()
	get_tree().paused = true


# 生成所有敵人
func spawn_all_enemies() -> void:
	for x in range(row_enemies_count):
		for y in range(column_enemies_count):
			var enemy_scene_instance = enemy_scene.instantiate()
			var pos = Vector2(x * (16 + 8) + 24, 16 * 4 + y * 16)
			add_child(enemy_scene_instance)
			enemy_scene_instance.start(pos)
			enemy_scene_instance.died.connect(_on_enemy_died)


# 敵人死亡
func _on_enemy_died(value) -> void:
	total_enemies -= 1
	score += value
	$CanvasLayer/UI.update_score(score)
	if total_enemies <= 0:
		get_tree().paused = true
		start_button.show()


# 點擊開始按鈕
func _on_start_button_pressed() -> void:
	start_button.hide()
	new_game()


# 新遊戲
func new_game() -> void:
	score = 0
	total_enemies = row_enemies_count * column_enemies_count
	$CanvasLayer/UI.update_score(score)
	$Player.start()
	spawn_all_enemies()
	get_tree().paused = false


func _on_player_died() -> void:
	get_tree().paused = true
	get_tree().call_group("enemies", "queue_free")
	game_over.show()
	await get_tree().create_timer(2.0).timeout
	game_over.hide()
	start_button.show()
