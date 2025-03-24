class_name GameOverScreen
extends PanelContainer

@export var player: player
@onready var button: Button = $HBoxContainer/MainMenuButton

func _process(delta: float) -> void:
	$HBoxContainer/Label2.text = str(player.score)


func _on_main_menu_pressed() -> void:
	visible = false
	ButtonSfx.play()
	get_tree().call_deferred("reload_current_scene")

func _unhandled_input(event: InputEvent) -> void:
	if GameState.State == GameState.EGameState.GAME_OVER:
		if Input.is_action_just_pressed("Pause") or Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
			visible = false
			ButtonSfx.play()
			get_tree().call_deferred("reload_current_scene")
