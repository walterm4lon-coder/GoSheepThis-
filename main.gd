extends Node

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var last_label: Label = $CanvasLayer/LastLabel
@onready var best_label: Label = $CanvasLayer/BestLabel

var elapsed := 0.0
var timer_running := false
var last_time := -1.0
var best_time := -1.0

const SAVE_PATH := "user://best_time.save"


func _ready() -> void:
	player.moved.connect(_on_player_moved)
	_load_best_time()
	_update_labels()
	for collectible in get_tree().get_nodes_in_group("collectible"):
		collectible.collected.connect(_on_collectible_collected)


func _process(delta: float) -> void:
	if timer_running:
		elapsed += delta
	_update_labels()


func _on_player_moved() -> void:
	elapsed = 0.0
	timer_running = true


func _on_collectible_collected() -> void:
	last_time = elapsed
	timer_running = false
	if best_time < 0.0 or last_time < best_time:
		best_time = last_time
		_save_best_time()
	elapsed = 0.0
	player.reset_to_start()


func _update_labels() -> void:
	time_label.text = "Time: %s" % _format_time(elapsed)
	last_label.text = "Last: %s" % (_format_time(last_time) if last_time >= 0.0 else "--:--.--")
	best_label.text = "Best: %s" % (_format_time(best_time) if best_time >= 0.0 else "--:--.--")


func _format_time(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := int(t) % 60
	var ms := int((t - int(t)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, ms]


func _save_best_time() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_float(best_time)


func _load_best_time() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			best_time = f.get_float()
