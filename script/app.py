import os
import re
from flask import Flask, render_template, request, redirect, url_for, flash
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'astra_cinemas_deep_space_secret'

# --- CONFIGURAZIONE PERCORSI ---
BASE_DIR = "/workspaces/cinema-scripts/dati"
CREDENTIALS_FILE = f"{BASE_DIR}/login_sito.log"
ACCESS_LOG = f"{BASE_DIR}/accessi_servizio.log"

# Assicuriamoci che le cartelle e i file esistano
os.makedirs(BASE_DIR, exist_ok=True)
for f in [CREDENTIALS_FILE, ACCESS_LOG]:
    if not os.path.exists(f):
        with open(f, 'w') as file: pass

# --- FUNZIONI DI SERVIZIO ---

def log_access(user, ip):
    """Registra l'attività nel log degli accessi per il controllo sicurezza"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    with open(ACCESS_LOG, "a") as f:
        f.write(f"{timestamp} | Utente: {user} | IP: {ip}\n")

def get_registered_users():
    """Recupera la lista degli utenti registrati dal database log"""
    users = {}
    with open(CREDENTIALS_FILE, "r") as f:
        for line in f:
            if ":" in line:
                u, p = line.strip().split(":", 1)
                users[u] = p
    return users

def valida_username(u):
    """Username: min 2 caratteri, solo alfanumerico, no spazi"""
    return bool(re.match(r"^[A-Za-z0-9]{2,}$", u))

def valida_password(p):
    """Password: min 5 char, 1 Maiusc, 1 minusc, 1 numero, 1 speciale (incl _)"""
    if len(p) < 5: return False
    if not re.search(r"[A-Z]", p): return False
    if not re.search(r"[a-z]", p): return False
    if not re.search(r"[0-9]", p): return False
    if not re.search(r"[!@#$%^&*(),.?\":{}|<>_]", p): return False
    return True

# --- ROTTE NAVIGAZIONE ASTRALE ---

@app.route('/')
def home():
    """Pagina di Login (Gate d'Accesso)"""
    return render_template('login.html')

@app.route('/registrati')
def registrati_page():
    """Pagina di Registrazione (Reclutamento)"""
    return render_template('registrati.html')

@app.route('/register_action', methods=['POST'])
def register_action():
    """Gestisce la creazione di nuovi profili piloti"""
    user = request.form.get('username', '').strip()
    pw = request.form.get('password', '').strip()
    
    # Controllo Username
    if not valida_username(user):
        flash("Identificativo non valido! Usa almeno 2 caratteri (solo lettere/numeri).")
        return redirect(url_for('registrati_page'))
    
    # Controllo Password
    if not valida_password(pw):
        flash("Chiave Astrale troppo debole! Includi Maiuscola, minuscola, numero e simbolo (es. _).")
        return redirect(url_for('registrati_page'))

    users = get_registered_users()
    
    # Controllo Utente già esistente
    if user in users:
        flash(f"L'utente '{user}' fa già parte della nostra flotta stellare! Prova a loggarti.")
        return redirect(url_for('registrati_page'))

    # Salvataggio nel file credenziali
    with open(CREDENTIALS_FILE, "a") as f:
        f.write(f"{user}:{pw}\n")
    
    flash("Registrazione completata! Benvenuto a bordo di AstraCinemas.")
    return redirect(url_for('home'))

@app.route('/login_action', methods=['POST'])
def login_action():
    """Gestisce l'accesso alla sala cinematografica"""
    user = request.form.get('username', '').strip()
    pw = request.form.get('password', '').strip()
    ip = request.remote_addr

    # Se l'utente non inserisce nulla -> logga come utente_ignoto
    if not user or not pw:
        log_access("utente_ignoto", ip)
        flash("Inserire le credenziali per superare il Gate.")
        return redirect(url_for('home'))

    users = get_registered_users()
    
    # Verifica credenziali
    if user in users and users[user] == pw:
        log_access(user, ip)
        return f"""
        <body style="background:#000; color:#fff; font-family:sans-serif; display:flex; 
                     justify-content:center; align-items:center; height:100vh; text-align:center;">
            <div>
                <h1 style="color:#be2edd; font-size:3em;">🚀 DECOLLO COMPLETATO</h1>
                <p style="font-size:1.5em;">Benvenuto in sala, <b>{user}</b>. La proiezione galattica sta per iniziare.</p>
                <a href="/" style="color:#4834d4; text-decoration:none;">Esci dalla sala</a>
            </div>
        </body>
        """
    else:
        # Fallimento -> logga come utente_ignoto (per il check_sicurezza.py)
        log_access("utente_ignoto", ip)
        flash("Accesso negato: Chiave errata o Pilota non riconosciuto.")
        return redirect(url_for('home'))

if __name__ == '__main__':
    # Avvio con debug attivo per aggiornamenti istantanei
    app.run(host='0.0.0.0', port=5000, debug=True)