import os, sys
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1') # El secreto de Matuwall para el diseño moderno
from gi.repository import Gtk, GdkPixbuf, Adw, Gdk, GLib

DIR = sys.argv[1] if len(sys.argv) > 1 else "."

# --- EL ESTILO VISUAL ROBADO DE MATUWALL ---
CSS = b"""
window.background {
    background-color: rgba(15, 18, 22, 0.85); /* Fondo de cristal oscuro */
    border-radius: 15px;
    border: 1px solid rgba(255, 255, 255, 0.05);
}
.wall-card {
    background-color: rgba(255, 255, 255, 0.04); /* Fondo de tarjeta Matuwall */
    border-radius: 14px;
    padding: 8px;
    transition: all 0.2s ease-in-out;
}
.wall-card:hover {
    background-color: rgba(255, 255, 255, 0.12); /* Efecto hover */
    border: 1px solid rgba(255, 255, 255, 0.25);
}
"""

def on_activate(app):
    # Cargar el CSS
    css_provider = Gtk.CssProvider()
    css_provider.load_from_data(CSS)
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(), 
        css_provider, 
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    # Crear la ventana estilo "Panel Flotante"
    win = Adw.ApplicationWindow(application=app)
    win.set_decorated(False) # Quita la barra de título (hace que flote)
    win.set_default_size(900, 550)
    
    # Permitir cerrar con la tecla Escape (como es flotante, no tiene la X)
    key_controller = Gtk.EventControllerKey.new()
    key_controller.connect("key-pressed", on_key_pressed, win)
    win.add_controller(key_controller)
    
    scrolled = Gtk.ScrolledWindow()
    scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
    win.set_content(scrolled)
    
    flowbox = Gtk.FlowBox()
    flowbox.set_valign(Gtk.Align.START)
    flowbox.set_max_children_per_line(4)
    flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
    
    # Espaciados exactos de Matuwall (GRID_PADDING = 16)
    flowbox.set_margin_top(16)
    flowbox.set_margin_bottom(16)
    flowbox.set_margin_start(16)
    flowbox.set_margin_end(16)
    flowbox.set_column_spacing(16)
    flowbox.set_row_spacing(16)
    
    scrolled.set_child(flowbox)
    
    valid_exts = ('.png', '.jpg', '.jpeg', '.webp')
    
    for filename in sorted(os.listdir(DIR)):
        if filename.lower().endswith(valid_exts):
            filepath = os.path.join(DIR, filename)
            try:
                # Miniaturas con aspecto apaisado (Landscape ratio)
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(filepath, 200, 112, False)
                picture = Gtk.Picture.new_for_pixbuf(pixbuf)
                
                # Crear la tarjeta
                btn = Gtk.Button()
                btn.set_child(picture)
                btn.add_css_class("wall-card") # Aplicar el estilo de tarjeta
                
                btn.connect("clicked", on_click, filepath, app)
                flowbox.append(btn)
            except Exception:
                pass
                
    win.present()

def on_key_pressed(controller, keyval, keycode, state, win):
    if keyval == Gdk.KEY_Escape:
        win.get_application().quit()
        return True
    return False

def on_click(btn, filepath, app):
    with open("/tmp/selected_wall", "w") as f:
        f.write(filepath)
    app.quit()

# Usamos Adw.Application para habilitar las características modernas
app = Adw.Application(application_id='com.hyperzen.galeria')
app.connect('activate', on_activate)
app.run(None)
