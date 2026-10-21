extends Node3D

# Renderer look table.
#
# The Compatibility (OpenGL) renderer differs from Forward+ in two ways that
# are visible in this scene:
#
#  1. Shadow-casting lights are rendered as a separate additive pass in sRGB
#     space, so a lit surface ends up brighter and clips (godotengine/godot
#     #90259 - an intentional engine trade-off).
#  2. The background colour is written straight to the framebuffer: no
#     tonemap, no sRGB encode.
#
# The scene resource (scenes/Game.tscn) holds the *Compatibility* look, which
# is what the shipped desktop and web builds use. The AgX tonemap has the
# shoulder needed to keep the over-brightened lit areas from clipping, and
# the key light is dimmed to match. On Forward+ the original v1.0.0 look
# (Filmic tonemap, full-strength key light) is restored instead.
# See PLAN.md 5.3 / 5.4 / 7.4.
const SKY_COMPATIBILITY := Color(0.36862745, 0.70588237, 0.9019608)
const SKY_FORWARD_PLUS := Color(0.29052547, 0.5662663, 0.81195307)
const TONEMAP_COMPATIBILITY := Environment.TONE_MAPPER_AGX
const TONEMAP_FORWARD_PLUS := Environment.TONE_MAPPER_FILMIC
const LIGHT_ENERGY_COMPATIBILITY := 0.4
const LIGHT_ENERGY_FORWARD_PLUS := 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	GameState.State = GameState.EGameState.MAIN_MENU
	_apply_renderer_look()


func _apply_renderer_look() -> void:
	# get_rendering_device() is null on the Compatibility (OpenGL) renderer.
	var compatibility := RenderingServer.get_rendering_device() == null

	var env_node := $WorldEnvironment as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_color = SKY_COMPATIBILITY if compatibility else SKY_FORWARD_PLUS
		env.tonemap_mode = TONEMAP_COMPATIBILITY if compatibility else TONEMAP_FORWARD_PLUS

	var light := $DirectionalLight3D as DirectionalLight3D
	if light != null:
		light.light_energy = LIGHT_ENERGY_COMPATIBILITY if compatibility else LIGHT_ENERGY_FORWARD_PLUS
