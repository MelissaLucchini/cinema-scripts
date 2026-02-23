import os
import csv
from flask import Flask, render_template, request, redirect, url_for, flash
from datetime import datetime

# Se la cartella templates è dentro 'script', Flask la trova così:
app = Flask(__name__)
app.secret_key = 'astracinemas_exclusive_galactic_key'

# --- CONFIGURAZIONE PERCORSI DATI (Assoluti per sicurezza) ---
BASE_DIR = "/workspaces/cinema-scripts/dati"
CREDENTIALS_FILE = os.path.join(BASE_DIR, "login_sito.log")
ACCESS_LOG = os.path.join(BASE_DIR, "accessi_servizio.log")
SALES_FILE = os.path.join(BASE_DIR, "vendite.csv")

# Assicuriamoci che la cartella dati esista
os.makedirs(BASE_DIR, exist_ok=True)

def get_posti_occupati(sala_richiesta):
    occupati = []
    if os.path.exists(SALES_FILE):
        with open(SALES_FILE, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader, None) # Salta intestazione
            for row in reader:
                if len(row) >= 3:
                    if row[0].strip() == sala_richiesta and row[2].strip() == "Venduto":
                        occupati.append(row[1].strip())
    return occupati

@app.route('/')
def home():
    return render_template('login.html')

@app.route('/login_action', methods=['POST'])
def login_action():
    user = request.form.get('username', '').strip()
    pw = request.form.get('password', '').strip()
    ip = request.remote_addr
    
    users = {}
    if os.path.exists(CREDENTIALS_FILE):
        with open(CREDENTIALS_FILE, "r", encoding='utf-8') as f:
            for line in f:
                if ":" in line:
                    u, p = line.strip().split(":", 1)
                    users[u] = p

    if user in users and users[user] == pw:
        with open(ACCESS_LOG, "a", encoding='utf-8') as f:
            f.write(f"{datetime.now()} | Login Success: {user} | IP: {ip}\n")
        return redirect(url_for('dashboard'))
    else:
        with open(ACCESS_LOG, "a", encoding='utf-8') as f:
            f.write(f"{datetime.now()} | Login Failed: {user if user else 'ignoto'} | IP: {ip}\n")
        flash("Identità non riconosciuta nel database della Flotta.")
        return redirect(url_for('home'))

@app.route('/dashboard')
def dashboard():
    films = [
        {"id": 1, "titolo": "First Man", "img": "https://m.media-amazon.com/images/M/MV5BYmIzYmViN2UtMDRhYy00OTMwLWI5YzctMTQxYzg2ODMwMTIwXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg"},
        {"id": 2, "titolo": "Guardiani della Galassia 2", "img": "https://m.media-amazon.com/images/M/MV5BNjM0NTc0NzItM2FlYS00YzEwLWE0YmUtNTA2ZWIzODc2OTgxXkEyXkFqcGdeQXVyNTgwNzIyNzg@._V1_.jpg"}
    ]
    return render_template('dashboard.html', films=films)

@app.route('/sala/<int:num_sala>')
def sala(num_sala):
    sala_id = f"Sala_{num_sala}"
    film = "First Man" if num_sala == 1 else "Guardiani della Galassia 2"
    occupati = get_posti_occupati(sala_id)
    
    # Griglia 5x10 (A1..E10)
    file_lettere = ['A', 'B', 'C', 'D', 'E']
    mappa_posti = [f"{l}{n}" for l in file_lettere for n in range(1, 11)]
    
    return render_template('sala.html', sala=sala_id, film=film, posti=mappa_posti, occupati=occupati)

@app.route('/compra', methods=['POST'])
def compra():
    sala_id = request.form.get('sala')
    posto = request.form.get('posto')
    
    if not posto:
        flash("Seleziona una coordinata di atterraggio (posto)!")
        return redirect(request.referrer)

    # --- LOGICA SOVRASCRITTURA (NO DOPPIONI) ---
    righe_aggiornate = []
    intestazione = ["Sala", "Posto", "Stato", "Prezzo"]
    
    if os.path.exists(SALES_FILE):
        with open(SALES_FILE, 'r', newline='', encoding='utf-8') as f:
            reader = csv.reader(f)
            intestazione = next(reader, intestazione)
            for row in reader:
                # Se la riga è quella acquistata, la modifichiamo
                if len(row) >= 2 and row[0] == sala_id and row[1] == posto:
                    row[2] = "Venduto"
                    row[3] = "8.50"
                righe_aggiornate.append(row)

        # Riscriviamo tutto il file da zero (sovrascrivendo i vecchi dati)
        with open(SALES_FILE, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(intestazione)
            writer.writerows(righe_aggiornate)
    
    return render_template('conferma.html', sala=sala_id, posto=posto)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)