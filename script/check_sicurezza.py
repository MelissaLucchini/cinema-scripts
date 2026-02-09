def analizza_log(/workspaces/cinema-scripts/dati/acce):
    # Configurazioni
    UTENTE_SOSPETTO = "utente_ignoto"
    SOGLIA_BAN = 5
    
    ip_corrente = None
    contatore_consecutivi = 0
    ip_bannati = set()

    try:
        with open(file_path, 'r') as file:
            for riga in file:
                # Pulizia riga e splitting dei dati
                parti = riga.strip().split(' | ')
                if len(parti) < 3:
                    continue
                
                utente = parti[1].split(': ')[1]
                ip = parti[2].split(': ')[1]

                # Logica di controllo
                if utente == UTENTE_SOSPETTO:
                    if ip == ip_corrente:
                        contatore_consecutivi += 1
                    else:
                        # Se l'IP cambia, ricomincio il conteggio per il nuovo IP
                        ip_corrente = ip
                        contatore_consecutivi = 1
                    
                    # Verifica condizione di ban
                    if contatore_consecutivi >= SOGLIA_BAN:
                        ip_bannati.add(ip)
                else:
                    # Se interviene un altro utente, la sequenza si rompe
                    ip_corrente = None
                    contatore_consecutivi = 0

        return ip_bannati

    except FileNotFoundError:
        print("Errore: Il file accessi_servizio.log non esiste.")
        return set()

# Esecuzione
bannati = analizza_log('accessi_servizio.log')

if bannati:
    print(f"⚠️ IP Bannati per eccesso di accessi consecutivi ({len(bannati)}):")
    for ip in bannati:
        print(f" - {ip}")
else:
    print("✅ Nessun utente ignoto ha superato la soglia di 5 accessi consecutivi.")