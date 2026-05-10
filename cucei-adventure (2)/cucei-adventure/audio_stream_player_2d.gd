extends AudioStreamPlayer


var track_exploracion = preload("res://musica/Unlocking_the_Archives.mp3")
var track_batalla = preload("res://musica/Unlocking_the_Archives.mp3")
func reproducir_exploracion():
	# Solo cambia la música si no está sonando ya (para evitar que se reinicie)
	if stream != track_exploracion:
		stream = track_exploracion
		play()

func reproducir_batalla():
	if stream != track_batalla:
		stream = track_batalla
		play()

func detener_musica():
	stop()
