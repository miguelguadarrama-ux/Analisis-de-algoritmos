extends Node

var puede_pelear = true

var enemigo_actual = {}
var player_position = Vector2.ZERO

var npc_actual = ""
var npcs_derrotados = []

var nivel = 1
var experiencia = 0
var exp_max = 100

var stats_base = {
	"hp": 100,
	"atk": 20,
	"def": 10
}

var equipo = ["Lovelace"] 
var personajes_desbloqueados = ["Lovelace"]

var base_personajes = {
	"Lovelace": {
		"nombre": "Lovelace",
		"hp": 100,
		"hp_actual": 100,
		"spd": 15,
		"atk": 20,
		"sprite": "res://LovelaceEspaldas.png",
		"habilidades": [
			{"nombre": "Script", "tipo": "daño", "mult": 1.0},
			{"nombre": "Bug", "tipo": "debuff"},
			{"nombre": "Sobrecarga", "tipo": "control", "mult": 0.5},
			{"nombre": "Root", "tipo": "ultimate", "mult": 2.0}
		]
	},
	"Volt": {
	"nombre": "Volt",
	"hp": 110,
	"hp_actual": 100,
	"spd": 12,
	"atk": 22,
	"sprite": "res://VoltEspaldas.png",
	"habilidades": [
		{"nombre": "Voltaje de Prueba", "tipo": "daño", "mult": 1.0},
		{"nombre": "Pulso Eléctrico", "tipo": "stun", "mult": 0.7},
		{"nombre": "Dron Asistente", "tipo": "daño", "mult": 0.4},
		{"nombre": "Tormenta de Circuitos", "tipo": "ultimate", "mult": 2.0}
	]
	},
	"Edi": {
	"nombre": "Edi",
	"hp": 150,
	"hp_actual": 100,
	"spd": 8,
	"atk": 16,
	"sprite": "res://EdiEspaldas.png",
	"habilidades": [
		{"nombre": "Impacto de Mazo", "tipo": "daño", "mult": 1.0},
		{"nombre": "Cimentación Reforzada", "tipo": "defensa"},
		{"nombre": "Análisis Estructural", "tipo": "debuff"},
		{"nombre": "Megaestructura Sísmica", "tipo": "ultimate", "mult": 1.5}
	]
},	
	"Viktor": {
		"nombre": "Viktor",
		"hp": 120,
		"hp_actual": 100,
		"spd": 14,
		"atk": 25,
		"sprite": "res://ViktorEspaldas.png",
		"habilidades": [
			{"nombre": "Golpe", "tipo": "daño", "mult": 1.0},
			{"nombre": "Corrosivo", "tipo": "daño", "mult": 1.8},
			{"nombre": "Impulso", "tipo": "debuff"},
			{"nombre": "Exterminio", "tipo": "ultimate", "mult": 2.5}
		]
	},
	
	"Leo": {
	"nombre": "Leo",
	"hp": 130,
	"hp_actual": 100,
	"spd": 11,
	"atk": 18,
	"sprite": "res://LeoEspaldas.png",
	"habilidades": [
		{"nombre": "Reacción Ácida", "tipo": "daño", "mult": 1.0},
		{"nombre": "Suero Restaurador", "tipo": "heal", "mult": 0.3},
		{"nombre": "Inhibidor Enzimático", "tipo": "debuff"},
		{"nombre": "Protocolo de Emergencia", "tipo": "ultimate", "mult": 0.6}
	]
	},
}

func calcular_stat(base, factor):
	return int(base * (1 + (factor * (nivel - 1))))
	
func get_player_stats():
	return {
		"hp": calcular_stat(stats_base["hp"], 0.30),
		"atk": calcular_stat(stats_base["atk"], 0.20),
		"def": calcular_stat(stats_base["def"], 0.15)
	}
	
func check_level_up():
	while experiencia >= exp_max:
		experiencia -= exp_max
		nivel += 1
		exp_max = int(exp_max * 1.5)
		print("SUBISTE A NIVEL ", nivel)
