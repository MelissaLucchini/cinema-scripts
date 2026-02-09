import os

# Configurazioni percorsi
LOG_FILE = "/workspaces/cinema-scripts/dati/accessi_servizio.log"
TARGET_USER = "utente_ignoto"
THRESHOLD = 5

def analizza_accessi():
    if not os.path.exists(LOG_FILE):
        print(f"Errore: Il file {LOG_FILE} non esiste.")
        return

    consecutive_count = 0
    last_ip = None
    ip_bannati = set()

    with open(LOG_FILE, 'r') as file:
        for linea in file:
            linea = linea.strip()
            if not linea:
                continue

            # Parsing della linea (split semplice basato sul tuo esempio)
            # Esempio: 2026-02-03 00:32 | Utente: utente_ignoto | IP: 95.10.22.33
            try:
                parti = linea.split(" | ")
                utente = parti[1].replace("Utente: ", "").strip()
                ip_attuale = parti[2].replace("IP: ", "").strip()
            except IndexError:
                continue # Salta linee formattate male

            if utente == TARGET_USER:
                # Se è lo stesso IP di prima o il primo che incontriamo
                if ip_attuale == last_ip or last_ip is None:
                    consecutive_count += 1
                    last_ip = ip_attuale
                else:
                    # L'utente è sempre ignoto ma l'IP è cambiato (reset e riparte da 1)
                    consecutive_count = 1
                    last_ip = ip_attuale
                
                # Controllo soglia
                if consecutive_count >= THRESHOLD:
                    if ip_attuale not in ip_bannati:
                        print(f"[ALERT] Rilevati {THRESHOLD} accessi consecutivi! BANNATO IP: {ip_attuale}")
                        ip_bannati.add(ip_attuale)
            else:
                # Se l'utente NON è ignoto, resetta tutto il countdown
                consecutive_count = 0
                last_ip = None

    if not ip_bannati:
        print("Analisi completata: nessun comportamento sospetto rilevato.")

if __name__ == "__main__":
    analizza_accessi()