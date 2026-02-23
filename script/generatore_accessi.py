import random
import os
from datetime import datetime, timedelta

# Configurazione utenti e IP
utenti_autorizzati = ["admin", "cassa1", "cassa2", "melissa"]
utenti_sospetti = ["hacker", "guest", "root", "utente_ignoto"]
ips_comuni = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
ips_esterni = ["95.10.22.33", "142.250.180.14", "203.0.113.5"]

def genera_log_accessi(numero_accessi=20):
    # --- GESTIONE PERCORSI DINAMICI ---
    # Trova la cartella dove risiede questo script (script/)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # Risale alla cartella principale del progetto
    root_dir = os.path.dirname(script_dir)
    # Punta alla cartella dati/
    path_log = os.path.join(root_dir, 'dati', 'accessi_servizio.log')

    # Assicuriamoci che la cartella dati esista
    os.makedirs(os.path.dirname(path_log), exist_ok=True)

    with open(path_log, 'w') as f:
        start_time = datetime.now() - timedelta(hours=12)
        
        for i in range(numero_accessi):
            start_time += timedelta(minutes=random.randint(5, 45))
            timestamp = start_time.strftime("%Y-%m-%d %H:%M")
            
            if random.random() < 0.85:
                utente = random.choice(utenti_autorizzati)
                ip = random.choice(ips_comuni)
            else:
                utente = random.choice(utenti_sospetti)
                ip = random.choice(ips_esterni)
            
            f.write(f"{timestamp} | Utente: {utente} | IP: {ip}\n")

if __name__ == "__main__":
    genera_log_accessi()
    print("File 'accessi_servizio.log' generato con successo nella cartella dati!")