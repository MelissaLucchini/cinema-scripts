#!/bin/bash

# ==============================================================================
# 4. SICUREZZA ACCESSI
# Descrizione: Monitora il log degli accessi al servizio. Confronta gli utenti
#              che hanno effettuato il login con la lista dei dipendenti 
#              autorizzati. Se un utente non è in lista, lancia un alert.
# ==============================================================================

# --- CONFIGURAZIONE PERCORSI DINAMICI ---
# BASE_DIR rileva automaticamente la cartella principale del progetto
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")

LOG_ACCESSI="$BASE_DIR/dati/accessi_servizio.log"
AUTORIZZATI="$BASE_DIR/dati/dipendenti_autorizzati.txt"

echo "==============================================="
echo "   SISTEMA DI MONITORAGGIO ACCESSI CINEMA"
echo "   Data controllo: $(date)"
echo "==============================================="

# --- CONTROLLO ESISTENZA FILE ---
if [ ! -f "$LOG_ACCESSI" ] || [ ! -f "$AUTORIZZATI" ]; then
    echo "[ERRORE] File dei dati non trovati."
    echo "Cercato in: $LOG_ACCESSI"
    echo "E in: $AUTORIZZATI"
    exit 1
fi

echo "Analisi log in corso..."
echo "-----------------------------------------------"

# --- LOGICA DI FILTRO E ALLERTA ---
# Leggiamo il log riga per riga
# IFS="|" separa la data dal resto della riga
while IFS="|" read -r data_ora info_resto
do
    # Estraiamo il nome utente e l'IP usando awk
    # info_resto contiene: " Utente: nome | IP: ip"
    utente=$(echo "$info_resto" | awk -F'Utente: ' '{print $2}' | awk -F' |' '{print $1}')
    ip=$(echo "$info_resto" | awk -F'IP: ' '{print $2}')

    # Verifichiamo se l'utente è presente nella lista autorizzati (match esatto -w)
    if ! grep -qw "$utente" "$AUTORIZZATI"; then
        echo "[ ALERT SICUREZZA ]"
        echo "Data/Ora: $data_ora"
        echo "Utente NON autorizzato rilevato: $utente"
        echo "Provenienza IP: $ip"
        echo "-----------------------------------------------"
        
        # Opzionale: registra l'evento in un log di sicurezza dedicato
        echo "[$(date)] Tentativo non autorizzato: $utente da $ip" >> "$BASE_DIR/dati/user_bannati.log"
    fi
done < "$LOG_ACCESSI"

echo "Monitoraggio completato correttamente."