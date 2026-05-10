extends Node2D

# ================= UI =================
@onready var player_bar = get_node("CanvasLayer/UI_Barra/PlayerHP")
@onready var enemy_bar = get_node("CanvasLayer/UI_Barra/EnemyHP")
@onready var menu_principal = get_node("CanvasLayer/UI_Barra")
@onready var menu_ataques = get_node("CanvasLayer/MenuAtaques")
@onready var texto_batalla = get_node("CanvasLayer/UI_Barra/TextoBatalla")

@onready var atk1 = get_node("CanvasLayer/MenuAtaques/GridContainer/Ataque1")
@onready var atk2 = get_node("CanvasLayer/MenuAtaques/GridContainer/Ataque2")
@onready var atk3 = get_node("CanvasLayer/MenuAtaques/GridContainer/Ataque3")
@onready var atk4 = get_node("CanvasLayer/MenuAtaques/GridContainer/Ataque4")

@onready var jugador_sprite = get_node("CanvasLayer/Jugador")
@onready var enemigo_sprite = get_node("CanvasLayer/Enemigo")
@onready var fondo = get_node("CanvasLayer/Fondo")

@onready var exp_bar = get_node("CanvasLayer/UI_Barra/ExpBar")
@onready var exp_label = get_node("CanvasLayer/UI_Barra/ExpLabel")
@onready var levelup_text = get_node("CanvasLayer/LevelUpText")

@onready var menu_cambiar = get_node("CanvasLayer/MenuCambiar")

@onready var btn1 = get_node("CanvasLayer/MenuCambiar/VBoxContainer/Btn1")
@onready var btn2 = get_node("CanvasLayer/MenuCambiar/VBoxContainer/Btn2")
@onready var btn3 = get_node("CanvasLayer/MenuCambiar/VBoxContainer/Btn3")
@onready var btn4 = get_node("CanvasLayer/MenuCambiar/VBoxContainer/Btn4")
@onready var btn5 = get_node("CanvasLayer/MenuCambiar/VBoxContainer/Btn5")

@onready var efecto_jugador = get_node("CanvasLayer/EfectoJugador")
@onready var efecto_enemigo = get_node("CanvasLayer/EfectoEnemigo")

var botones_cambio = []

# ================= PLAYER =================
var player_hp = 100
var player_atk = 20

var habilidades = [
	{"nombre": "Script", "tipo": "daño", "mult": 1.0},
	{"nombre": "Bug", "tipo": "debuff"},
	{"nombre": "Sobrecarga", "tipo": "control", "mult": 0.5},
	{"nombre": "Root", "tipo": "ultimate", "mult": 2.0}
]

var personajes = []
var personaje_actual = 0

# ================= ENEMIGO =================
var enemy_hp = 100
var enemigo_habilidades = []

# ================= ESTADOS =================
var turno_activo = true
var stun_player = false

# ================= READY =================
func _ready():
	personajes.clear()

	for nombre in Global.equipo:
		if Global.base_personajes.has(nombre):
			personajes.append(Global.base_personajes[nombre])
			
	if personajes.size() == 0:
		push_error("No hay personajes en el equipo")
		return

	var p = personajes[personaje_actual]

	player_hp = p.get("hp_actual", p["hp"])
	player_atk = p["atk"]
	habilidades = p["habilidades"]
	
	player_bar.value = player_hp

	menu_principal.visible = true
	menu_ataques.visible = false

	actualizar_menu()

	if Global.enemigo_actual != {}:

		enemy_hp = Global.enemigo_actual.get("hp", 100)
		enemy_bar.value = enemy_hp

		# SPRITE ENEMIGO
		if Global.enemigo_actual.has("sprite"):
			var tex = load(Global.enemigo_actual["sprite"])
			if tex:
				enemigo_sprite.texture = tex

		# FONDO
		if Global.enemigo_actual.has("fondo"):
			var texf = load(Global.enemigo_actual["fondo"])
			if texf:
				fondo.texture = texf

		# HABILIDADES
		if Global.enemigo_actual.has("habilidades"):
			enemigo_habilidades = Global.enemigo_actual["habilidades"]

		mostrar_texto("¡Un " + Global.enemigo_actual.get("nombre","Enemigo") + " apareció!")
		
		configurar_barra_exp()
		actualizar_exp_ui()
		
		botones_cambio = [btn1, btn2, btn3, btn4, btn5]
		menu_cambiar.visible = false

		actualizar_menu_cambio()
		
		if p.has("sprite"):
			var tex = load(p["sprite"])
			if tex:
				jugador_sprite.texture = tex
	

# ================= MENU =================
func actualizar_menu():
	atk1.text = habilidades[0]["nombre"]
	atk2.text = habilidades[1]["nombre"]
	atk3.text = habilidades[2]["nombre"]
	atk4.text = habilidades[3]["nombre"]

# ================= BOTON ATACAR =================
func _on_boton_atacar_pressed():
	if not turno_activo:
		return

	menu_principal.visible = false
	menu_ataques.visible = true

	mostrar_texto("Elige un ataque")

# ================= USAR ATAQUE =================
func usar_habilidad(index):
	if not turno_activo:
		return

	turno_activo = false

	var h = habilidades[index]

	var tipo = h.get("tipo", "daño")
	var mult = h.get("mult", 1.0)
	
	

	match tipo:
		"daño":
			await animar_ataque(jugador_sprite, 1)
			var dmg = int(player_atk * mult)
			enemy_hp -= dmg
			enemy_bar.value = enemy_hp
			await mostrar_texto("Usaste " + h["nombre"])
			
			await animar_golpe(enemigo_sprite)
			await animar_danio(enemigo_sprite)

		"ultimate":
			var dmg = int(player_atk * mult)
			enemy_hp -= dmg
			enemy_bar.value = enemy_hp
			await mostrar_texto("¡ULTIMATE!")

		_:
			await mostrar_texto("Usaste " + h["nombre"])

	menu_ataques.visible = false
	menu_principal.visible = true

	if enemy_hp > 0:
		await enemy_turn()
	else:
		await mostrar_texto("¡GANASTE!")
		
		Global.check_level_up()
		
		await animar_exp(50)
		
		var nombre = Global.enemigo_actual.get("nombre", "")

		if nombre != "":
			if nombre not in Global.personajes_desbloqueados:
				Global.personajes_desbloqueados.append(nombre)

			if nombre not in Global.equipo:
				Global.equipo.append(nombre)
				
			personajes.clear()

			for n in Global.equipo:
				if Global.base_personajes.has(n):
					personajes.append(Global.base_personajes[n])

			await mostrar_texto(nombre + " se unió a tu equipo!")

		if Global.npc_actual not in Global.npcs_derrotados:
			Global.npcs_derrotados.append(Global.npc_actual)

		get_tree().change_scene_to_file("res://scenes/mundo.tscn")

	turno_activo = true

# ================= IA ENEMIGO =================
func enemy_turn():
	await get_tree().create_timer(0.5).timeout

	if stun_player:
		await mostrar_texto("Estás aturdido")
		stun_player = false
		return

	var h = elegir_habilidad_enemigo()

	# SEGURIDAD TOTAL
	var tipo = h.get("tipo", "daño")
	var mult = h.get("mult", 1.0)
	var atk = Global.enemigo_actual.get("atk", 10)

	match tipo:
		"daño":
			await animar_ataque(enemigo_sprite, -1)
			var defensa = Global.get_player_stats()["def"]
			var dmg = int((atk * mult) * (100.0 / (100 + defensa)))
			
			var crit = randf() < 0.3 # 30%

			if crit:
				dmg *= 1.7
				await mostrar_texto("¡CRÍTICO DEL JEFE!")

			if dmg < 1:
				dmg = 1

			print("DAÑO ENEMIGO:", dmg)

			player_hp -= dmg
			player_bar.value = player_hp

			personajes[personaje_actual]["hp_actual"] = player_hp

			await mostrar_texto("El enemigo usó " + h.get("nombre","Ataque"))
			
			await animar_golpe(jugador_sprite)
			await animar_danio(jugador_sprite)

		"stun":
			var defensa = Global.get_player_stats()["def"]
			var dmg = int((atk * mult) - defensa)

			if dmg < 1:
				dmg = 1

			player_hp -= dmg
			player_bar.value = player_hp

			personajes[personaje_actual]["hp_actual"] = player_hp

			stun_player = true
			await efecto_stun(efecto_jugador)
			

			await mostrar_texto("¡Te aturdió!")

		"heal":
			var heal = int(enemy_hp * mult)
			enemy_hp += heal
			enemy_bar.value = enemy_hp
			await mostrar_texto("El enemigo se curó")

		_:
			var dmg = int(atk)
			player_hp -= dmg
			player_bar.value = player_hp
			await mostrar_texto("El enemigo atacó")

	# RESTAR USOS SEGURO
	if h.has("usos"):
		h["usos"] -= 1

	if player_hp <= 0:
		player_hp = 0
		player_bar.value = 0

		personajes[personaje_actual]["hp_actual"] = 0

		await mostrar_texto("¡" + personajes[personaje_actual]["nombre"] + " cayó!")

		await cambiar_personaje_auto()
		return
		
		await mostrar_texto("PERDISTE")

# ================= IA =================
func elegir_habilidad_enemigo():
	var fase_2 = enemy_hp < (Global.enemigo_actual.get("hp",100) * 0.5)
	var mejor_habilidad = null
	var mejor_puntaje = -999

	var player_hp_actual = player_hp
	var enemy_hp_actual = enemy_hp

	for h in enemigo_habilidades:

		# evitar habilidades sin usos
		if h.has("usos") and h["usos"] <= 0:
			continue

		var tipo = h.get("tipo", "daño")
		var mult = h.get("mult", 1.0)
		var puntaje = 0

		match tipo:

			"daño":
				var dmg = int(Global.enemigo_actual.get("atk",10) * mult)

				# si puede matarte → prioridad alta
				if dmg >= player_hp_actual:
					puntaje += 100

				puntaje += dmg
				
				if fase_2:
					puntaje *= 1.5

			"stun":
				# si tienes mucha vida → conviene stun
				if player_hp_actual > 30:
					puntaje += 40

				# evitar stun si ya estás aturdido
				if stun_player:
					puntaje -= 50

			"heal":
				# curarse solo si está bajo
				if enemy_hp_actual < 40:
					puntaje += 80
				else:
					puntaje -= 20

			"ultimate":
				# usar ultimate si estás bajo o para rematar
				if player_hp_actual < 50:
					puntaje += 120
				else:
					puntaje += 30

			_:
				puntaje += 10

		# elegir mejor opción
		if puntaje > mejor_puntaje:
			mejor_puntaje = puntaje
			mejor_habilidad = h

	# fallback seguro
	if mejor_habilidad == null:
		return {"tipo":"daño","mult":1.0,"nombre":"Golpe"}

	return mejor_habilidad

# ================= BOTONES =================
func _on_ataque_1_pressed(): usar_habilidad(0)
func _on_ataque_2_pressed(): usar_habilidad(1)
func _on_ataque_3_pressed(): usar_habilidad(2)
func _on_ataque_4_pressed(): usar_habilidad(3)

# ================= TEXTO =================
func mostrar_texto(msg):
	texto_batalla.text = msg
	await get_tree().create_timer(1.0).timeout
	
func actualizar_exp_ui():
	exp_bar.max_value = Global.exp_max
	exp_bar.value = Global.experiencia
	exp_label.text = "EXP: " + str(Global.experiencia) + " / " + str(Global.exp_max)

func animacion_level_up():
	levelup_text.visible = true
	levelup_text.scale = Vector2(0.5, 0.5)

	for i in range(10):
		levelup_text.scale += Vector2(0.1, 0.1)
		await get_tree().create_timer(0.05).timeout

	await get_tree().create_timer(0.5).timeout

	levelup_text.visible = false

func animar_exp(cantidad):
	var objetivo = Global.experiencia + cantidad

	# subir barra animada
	while Global.experiencia < objetivo:
		Global.experiencia += 1
		actualizar_exp_ui()
		await get_tree().create_timer(0.02).timeout

	while Global.experiencia >= Global.exp_max:
		Global.experiencia -= Global.exp_max
		Global.nivel += 1
		Global.exp_max = int(Global.exp_max * 1.5)

		await animacion_level_up()

	actualizar_exp_ui()

	actualizar_color_exp()
	
func actualizar_color_exp():
	var ratio = float(Global.experiencia) / Global.exp_max

	var fill = exp_bar.get_theme_stylebox("fill")

	if fill == null:
		return

	if ratio < 0.5:
		fill.bg_color = Color(0.2, 0.6, 1)
	elif ratio < 0.8:
		fill.bg_color = Color(0.3, 1, 0.3)
	else:
		fill.bg_color = Color(1, 0.8, 0.2)
		
func configurar_barra_exp():
	# Fondo
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1)
	bg.corner_radius_top_left = 6
	bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6

	# Barra (fill)
	var fill = StyleBoxFlat.new()
	fill.bg_color = Color(0.2, 0.6, 1)
	fill.corner_radius_top_left = 6
	fill.corner_radius_top_right = 6
	fill.corner_radius_bottom_left = 6
	fill.corner_radius_bottom_right = 6

	exp_bar.add_theme_stylebox_override("background", bg)
	exp_bar.add_theme_stylebox_override("fill", fill)
	
func _on_boton_cambiar_pressed():
	if not turno_activo:
		return

	if personajes.size() <= 1:
		mostrar_texto("No tienes más personajes")
		return

	menu_principal.visible = false
	menu_ataques.visible = false
	menu_cambiar.visible = true

func actualizar_menu_cambio():
	for i in range(botones_cambio.size()):
		if i < personajes.size():
			var p = personajes[i]
			botones_cambio[i].text = p.get("nombre", "???")
			botones_cambio[i].visible = true
		else:
			botones_cambio[i].visible = false

func cambiar_a_personaje(index):
	if index >= personajes.size():
		return
		
	personajes[personaje_actual]["hp_actual"] = player_hp

	var p = personajes[index]

	personaje_actual = index
	player_hp = p.get("hp_actual", p["hp"])
	player_atk = p["atk"]
	habilidades = p["habilidades"]

	player_bar.value = player_hp
	actualizar_menu()
	

	print("CAMBIANDO A:", p["nombre"])

	if p.has("sprite"):
		var ruta = p["sprite"]
		print("RUTA SPRITE:", ruta)

		var tex = load(ruta)

		if tex != null:
			jugador_sprite.texture = tex
			print("SPRITE CAMBIADO OK")
		else:
			print("ERROR: textura NULL")

	else:
		print("ERROR: personaje sin sprite")

	menu_cambiar.visible = false
	menu_principal.visible = true

	await mostrar_texto("¡Adelante " + p.get("nombre","Aliado") + "!")

	turno_activo = false
	await enemy_turn()
	turno_activo = true
	
	if personajes[personaje_actual]["hp_actual"] <= 0:
		mostrar_texto("Este personaje está debilitado")
	return
	
func _on_Btn1_pressed(): cambiar_a_personaje(0)
func _on_Btn2_pressed(): cambiar_a_personaje(1)
func _on_Btn3_pressed(): cambiar_a_personaje(2)
func _on_Btn4_pressed(): cambiar_a_personaje(3)
func _on_Btn5_pressed(): cambiar_a_personaje(4)

func cambiar_personaje_auto():
	for i in range(personajes.size()):
		if personajes[i].get("hp_actual", personajes[i]["hp"]) > 0:
			
			personaje_actual = i
			
			var p = personajes[i]

			player_hp = p["hp_actual"]
			player_atk = p["atk"]
			habilidades = p["habilidades"]

			player_bar.value = player_hp
			actualizar_menu()

			# cambiar sprite
			if p.has("sprite"):
				var tex = load(p["sprite"])
				if tex:
					jugador_sprite.texture = tex

			await mostrar_texto("¡Adelante " + p["nombre"] + "!")
			return

	await mostrar_texto("TODOS TUS PERSONAJES CAYERON")
	get_tree().change_scene_to_file("res://scenes/mundo.tscn")
	
func animar_danio(sprite):
	sprite.modulate = Color(1, 0.3, 0.3) # rojo

	await get_tree().create_timer(0.1).timeout

	sprite.modulate = Color(1,1,1) # normal

func animar_golpe(sprite):
	var original_pos = sprite.position

	for i in range(5):
		sprite.position.x += randf_range(-5, 5)
		sprite.position.y += randf_range(-5, 5)
		await get_tree().create_timer(0.02).timeout

	sprite.position = original_pos

func animar_ataque(sprite, direccion):
	var original_pos = sprite.position

	sprite.position.x += 40 * direccion
	await get_tree().create_timer(0.1).timeout

	sprite.position = original_pos
	
func efecto_stun(sprite):
	sprite.visible = true
	sprite.modulate = Color(1,1,0) # amarillo

	for i in range(3):
		sprite.rotation += 0.5
		await get_tree().create_timer(0.1).timeout

	sprite.visible = false
	sprite.rotation = 0
	
func efecto_buff(sprite):
	sprite.visible = true
	sprite.modulate = Color(0.3,0.6,1) # azul

	for i in range(3):
		sprite.scale += Vector2(0.1,0.1)
		await get_tree().create_timer(0.1).timeout

	sprite.visible = false
	sprite.scale = Vector2(1,1)
	
func efecto_debuff(sprite):
	sprite.visible = true
	sprite.modulate = Color(1,0.3,0.3) # rojo

	await get_tree().create_timer(0.5).timeout

	sprite.visible = false
