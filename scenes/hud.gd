extends CanvasLayer

func _ready() -> void:
	$MainMenu/MainContainer/PlayButton.grab_focus()
func _on_play_button_pressed() -> void:
	ButtonSfx.play()
	get_tree().paused = false
	GameState.State = GameState.EGameState.IN_GAME
	$MainMenu.visible = false
	$"MainMenu/menu-shadow".visible = false
	$ScoreLabel.visible = true
	$Credits.visible = false

func _on_quit_button_pressed() -> void:
	ButtonSfx.play()
	AudioPlayer.stop()
	await get_tree().create_timer(0.4).timeout
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if GameState.State == GameState.EGameState.IN_GAME && Input.is_action_just_pressed("Pause"):
		# Pause Game
		PauseSfx.play()
		get_tree().paused = true
		$PausePanel.visible = true
		GameState.State = GameState.EGameState.PAUSED
		$PausePanel/PauseAnimation.play("pulse")
	elif GameState.State == GameState.EGameState.PAUSED && event.is_pressed():
		# Unpause Game
		PauseSfx.play()
		get_tree().paused = false
		$PausePanel.visible = false
		GameState.State = GameState.EGameState.IN_GAME
		$PausePanel/PauseAnimation.stop()


func _on_controls_button_pressed() -> void:
	ButtonSfx.play()
	$MainMenu/MainContainer.visible = false
	$MainMenu/ControlsContainer. visible = true
	$MainMenu/ControlsContainer/Button.grab_focus()
	
