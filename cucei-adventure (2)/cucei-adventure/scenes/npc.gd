extends Node2D

@export var id_npc = "npc_1"

@export var enemigo_data = {
	"nombre": "Viktor",
	"hp": 90,
	"atk": 14,
	"spd": 18,
	"sprite": "res://enemigos/viktor.png",
	"fondo": "res://fondos/tema1.png",
	"habilidades": [
		{"nombre": "Golpe", "tipo": "daño", "mult": 1.0, "usos": 15},
		{"nombre": "Fuerte", "tipo": "daño", "mult": 1.5, "usos": 5}
	]
}

func _ready():
	# Desaparece si ya fue derrotado
	if id_npc in Global.npcs_derrotados:
		queue_free()

func _on_area_2d_body_entered(body):
	if not Global.puede_pelear:
		return
		
	if body.name == "player":
		
		Global.puede_pelear = false
		
		Global.player_position = body.global_position
		Global.npc_actual = id_npc
		Global.enemigo_actual = enemigo_data
		
		call_deferred("cambiar_a_batalla")

func cambiar_a_batalla():
	get_tree().change_scene_to_file("res://scenes/batalla.tscn")
