import os

# --- CONFIGURAZIONE PERCORSI ---
BASE_DIR = "/workspaces/cinema-scripts/dati"
LOG_ACCESSI = os.path.join(BASE_DIR, "accessi_servizio.log")
LOG_SITO = os.path.join(BASE_DIR, "login_sito.log") # Struttura user:pass
BANNED_FILE = os.path.join(BASE_DIR, "user_bannati.log")

def analizza_trusted():
    # 1. Carichiamo la Blacklist degli IP
    bannati = set()
    if os.path.exists(BANNED_FILE):
        with open(BANNED_FILE, 'r') as f:
            bannati = {linea.strip() for linea in f if linea.strip()}

    # 2. Carichiamo gli utenti TRUSTED dal log del sito (user:pass)
    utenti_trusted = set()
    if os.path.exists(LOG_SITO):
        with open(LOG_SITO, 'r') as f:
            for linea in f:
                if ":" in linea:
                    # Estraiamo solo lo username prima dei due punti
                    username = linea.split(":")[0].strip()
                    utenti_trusted.add(username)

    print(f"=== MONITORAGGIO SICUREZZA: TRUSTED USERS CHECK ===")
    
    if not os.path.exists(LOG_ACCESSI):
        print(f"Errore: {LOG_ACCESSI} non trovato.")
        return

    # 3. Analisi del log degli accessi al servizio
    with open(LOG_ACCESSI, 'r') as f:
        for linea in f:
            try:
                # Parsing: 2026-02-23 10:45 | Utente: nome | IP: ip
                parti = linea.strip().split(" | ")
                timestamp = parti[0]
                utente_log = parti[1].split(": ")[1]
                ip_log = parti[2].split(": ")[1]

                # --- LOGICA DI ACCESSO PRIORITARIA ---
                
                # REGOLE TRUSTED (Ignora blacklist)
                if utente_log in utenti_trusted:
                    status = "[TRUSTED - OK]"
                    messaggio = f"Utente '{utente_log}' verificato (Accesso garantito nonostante IP)."
                
                # REGOLA BLACKLIST (Solo per non-trusted)
                elif ip_log in bannati:
                    status = "[ACCESSO NEGATO]"
                    messaggio = f"IP {ip_log} in blacklist e utente non riconosciuto."
                
                # REGOLA UTENTE IGNOTO (Non trusted e IP non bannato)
                else:
                    status = "[SOSPETTO]"
                    utente_log = "UTENTE IGNOTO"
                    messaggio = "Login non presente nel database del sito."

                print(f"{timestamp} | {status} {utente_log} -> {messaggio}")

            except Exception:
                continue

if __name__ == "__main__":
    analizza_trusted()