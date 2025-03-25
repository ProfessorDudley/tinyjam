extends CanvasLayer

#func _ready() -> void:
	#$MainMenu/MainContainer/PlayButton.grab_focus()
	#ButtonSfx.play()
	#get_tree().paused = false
	#GameState.State = GameState.EGameState.IN_GAME

#func _unhandled_input(event: InputEvent) -> void:
	#if GameState.State == GameState.EGameState.IN_GAME && Input.is_action_just_pressed("Pause"):
		## Pause Game
		#PauseSfx.play()
		#get_tree().paused = true
		#$PausePanel.visible = true
		#GameState.State = GameState.EGameState.PAUSED
		#$PausePanel/PauseAnimation.play("pulse")
	#elif GameState.State == GameState.EGameState.PAUSED && event.is_pressed():
		## Unpause Game
		#PauseSfx.play()
		#get_tree().paused = false
		#$PausePanel.visible = false
		#GameState.State = GameState.EGameState.IN_GAME
		#$PausePanel/PauseAnimation.stop()
	
