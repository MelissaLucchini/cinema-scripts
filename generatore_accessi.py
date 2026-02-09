import random
from datetime import datetime, timedelta

# Configurazione: chi sono quelli autorizzati
utenti_autorizzati = ["admin", "cassa1", "cassa2", "melissa"]
utenti_sospetti = ["hacker", "guest", "root", "utente_ignoto"]
ips_comuni = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
ips_esterni = ["95.10.22.33", "142.250.180.14", "203.0.113.5"]

def genera_log_accessi(numero_accessi=20):
    with open('dati/accessi_servizio.log', 'w') as f:
        start_time = datetime.now() - timedelta(hours=12)
        
        for i in range(numero_accessi):
            # Aggiungiamo qualche minuto tra un accesso e l'altro
            start_time += timedelta(minutes=random.randint(5, 45))
            timestamp = start_time.strftime("%Y-%m-%d %H:%M")
            
            # Decidiamo se l'accesso è autorizzato o un tentativo di intrusione
            if random.random() < 0.85:
                utente = random.choice(utenti_autorizzati)
                ip = random.choice(ips_comuni)
            else:
                utente = random.choice(utenti_sospetti)
                ip = random.choice(ips_esterni)
            
            f.write(f"{timestamp} | Utente: {utente} | IP: {ip}\n")

if __name__ == "__main__":
    genera_log_accessi()
    print("File 'accessi_servizio.log' generato con 20 accessi casuali!")