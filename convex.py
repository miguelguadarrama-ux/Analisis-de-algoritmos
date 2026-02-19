import pandas as pd
import matplotlib.pyplot as plt
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
import math

# --- CLASE PUNTO ---
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

# --- FUNCIONES AUXILIARES ---
def orientacion(a, b, c):
    val = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    if abs(val) < 1e-9: return 0 # Colineales
    return 1 if val > 0 else -1  # 1: CCW (Izquierda), -1: CW (Derecha)

def distancia_cuadrada(p1, p2):
    return (p1.x - p2.x)**2 + (p1.y - p2.y)**2

def punto_mas_izquierdo(puntos):
    min_idx = 0
    for i in range(1, len(puntos)):
        if puntos[i].x < puntos[min_idx].x:
            min_idx = i
        elif puntos[i].x == puntos[min_idx].x:
            if puntos[i].y < puntos[min_idx].y:
                min_idx = i
    return min_idx

# --- EL ALGORITMO QUE PIDIÓ EL PROFE (JARVIS) ---
def convex_hull_jarvis(puntos, log_widget):
    if len(puntos) < 3: return puntos

    hull = []
    start_idx = punto_mas_izquierdo(puntos)
    p_idx = start_idx

    while True:
        hull.append(puntos[p_idx])
        q_idx = (p_idx + 1) % len(puntos)

        for r_idx in range(len(puntos)):
            if r_idx == p_idx: continue
            
            o = orientacion(puntos[p_idx], puntos[q_idx], puntos[r_idx])
            
            # Mensaje para el log
            if o == 1:
                q_idx = r_idx
                log_widget.insert(tk.END, f"Giro Izquierda: Nuevo candidato ({puntos[q_idx].x}, {puntos[q_idx].y})\n")
            elif o == 0:
                # Si son colineales, elegir el más lejano
                if distancia_cuadrada(puntos[p_idx], puntos[r_idx]) > distancia_cuadrada(puntos[p_idx], puntos[q_idx]):
                    q_idx = r_idx
                    log_widget.insert(tk.END, f"Colineal: Tomando el más lejano ({puntos[q_idx].x}, {puntos[q_idx].y})\n")

        p_idx = q_idx
        log_widget.insert(tk.END, f"--> Punto aceptado para la envolvente.\n")
        log_widget.see(tk.END)
        
        if p_idx == start_idx: break
    return hull

# --- INTERFAZ GRÁFICA ---
class ConvexHullApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Algoritmo - Convex Hull")
        self.root.geometry("500x600")

        tk.Button(root, text="Cargar CSV y Ejecutar", command=self.ejecutar, 
                  bg="#2196F3", fg="white", font=("Arial", 10, "bold"), pady=10).pack(pady=10)

        self.txt_log = scrolledtext.ScrolledText(root, width=55, height=25)
        self.txt_log.pack(padx=10, pady=10)

    def ejecutar(self):
        ruta = filedialog.askopenfilename(filetypes=[("CSV", "*.csv")])
        if not ruta: return
        
        try:
            df = pd.read_csv(ruta)
            pts = [Point(row.x, row.y) for i, row in df.iterrows()]
            self.txt_log.delete(1.0, tk.END)

            # Llamamos al algoritmo manual
            resultado_hull = convex_hull_jarvis(pts, self.txt_log)

            # Graficar
            x_vals = [p.x for p in pts]
            y_vals = [p.y for p in pts]
            hx = [p.x for p in resultado_hull] + [resultado_hull[0].x]
            hy = [p.y for p in resultado_hull] + [resultado_hull[0].y]

            plt.figure("Resultado ")
            plt.plot(x_vals, y_vals, 'o', color='gray', alpha=0.5)
            plt.plot(hx, hy, 'r-o', lw=2, label="Envolvente Jarvis")
            plt.title("Convex Hull calculado paso a paso")
            plt.legend()
            plt.show()

        except Exception as e:
            messagebox.showerror("Error", str(e))

if __name__ == "__main__":
    root = tk.Tk()
    app = ConvexHullApp(root)
    root.mainloop()