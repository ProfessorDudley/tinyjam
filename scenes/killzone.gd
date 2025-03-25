extends Area3D

@export var player: player
@export var game_over_screen: GameOverScreen
var allowContinue: bool = false

func _on_body_entered(body: Node3D) -> void:
	GameState.State = GameState.EGameState.GAME_OVER
	game_over_screen.visible = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	game_over_screen.button.grab_focus()
	#$CanvasLayer/GameOver/GameOverAnimation.play("pulse")
