@tool
extends Node3D

var res: Array[MeshInstance3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	findByClass(self, "MeshInstance3D", res)
	for child in res:
		child.cast_shadow = 0

func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className) :
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)
