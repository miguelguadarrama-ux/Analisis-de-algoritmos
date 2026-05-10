extends Node2D

func _ready():
	# Usamos el nombre que configuramos en el Autoload (pasos anteriores)
	# Si le pusiste MusicaGlobal, debe quedar así:
	MusicaGlobal.reproducir_exploracion()
