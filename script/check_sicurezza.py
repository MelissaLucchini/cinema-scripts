import os

# Percorsi
LOG_FILE = "/workspaces/cinema-scripts/dati/accessi_servizio.log"
BANNED_FILE = "/workspaces/cinema-scripts/dati/user_bannati.log"
TARGET_USER = "utente_ignoto"
THRESHOLD = 5

def carica_ip_bannati():
    if not os.path.exists(BANNED_FILE): return set()
    with open(BANNED_FILE, 'r') as f:
        return set(linea.strip() for linea in f if linea.strip())

def banna_ip(ip):
    with open(BANNED_FILE, 'a') as f:
        f.write(f"{ip}\n")

def analizza():
    bannati = carica_ip_bannati()
    consecutive_ignoto = 0
    last_ip = None

    if not os.path.exists(LOG_FILE): return

    with open(LOG_FILE, 'r') as f:
        for linea in f:
            try:
                # Parsing riga: Data | Utente: nome | IP: ip
                parti = linea.strip().split(" | ")
                utente = parti[1].split(": ")[1]
                ip_attuale = parti[2].split(": ")[1]
            except: continue

            # REGOLA: Se IP è bannato
            if ip_attuale in bannati:
                if utente == TARGET_USER:
                    print(f"[ALERT] Accesso NEGATO per {ip_attuale}: IP bannato e utente ignoto.")
                    consecutive_ignoto = 0 # Reset per cambio contesto
                    continue
                else:
                    print(f"[WARNING] IP {ip_attuale} è in blacklist, ma l'utente '{utente}' è autorizzato. Accesso permesso.")
            
            # LOGICA COUNTDOWN
            if utente == TARGET_USER:
                if ip_attuale == last_ip or last_ip is None:
                    consecutive_ignoto += 1
                else:
                    consecutive_ignoto = 1
                last_ip = ip_attuale

                if consecutive_ignoto >= THRESHOLD:
                    print(f"[BAN] Rilevati {THRESHOLD} login ignoti di fila. Banno IP: {ip_attuale}")
                    banna_ip(ip_attuale)
                    bannati.add(ip_attuale)
                    consecutive_ignoto = 0
            else:
                consecutive_ignoto = 0
                last_ip = None

if __name__ == "__main__":
    analizza()