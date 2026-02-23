#!/bin/bash

# ==============================================================================
# 8. ROTAZIONE E PULIZIA LOG
# Descrizione: Comprime i log vecchi se superano i 5MB per liberare spazio 
#              e prevenire il crash del server dovuto a disco pieno.
# ==============================================================================

# --- CONFIGURAZIONE PERCORSI ---
# BASE_DIR rileva automaticamente la cartella principale del progetto
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
LOG_FILE="$BASE_DIR/dati/sensori.log"
BACKUP_DIR="$BASE_DIR/backup"
MAX_SIZE=5000000 # Soglia di 5MB in Byte

echo "--- AVVIO PROTOCOLLO ROTAZIONE LOG ---"

# --- CONTROLLO ESISTENZA FILE ---
if [ ! -f "$LOG_FILE" ]; then
    echo "[ERRORE] Il file log non esiste in: $LOG_FILE"
    echo "Assicurati di aver lanciato 'generatore_dati.py' prima."
    exit 1
fi

# --- VERIFICA DIMENSIONE ---
# 'stat -c%s' estrae la dimensione del file in byte
FILE_SIZE=$(stat -c%s "$LOG_FILE")

echo "Stato attuale: $FILE_SIZE byte / $MAX_SIZE byte (limite)"

# --- LOGICA DI ROTAZIONE ---
if [ "$FILE_SIZE" -ge "$MAX_SIZE" ]; then 
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
    
    echo "[!] Soglia superata. Compressione in corso..."

    # Crea un pacchetto compresso (.tar.gz) nella cartella backup
    # -c: crea, -z: comprime (gzip), -f: specifica il nome file
    tar -czf "$BACKUP_DIR/sensors_$TIMESTAMP.tar.gz" -C "$BASE_DIR/dati" "sensori.log"

    # Svuota il file originale mantenendo i permessi
    # Il simbolo '>' resetta il contenuto del file a 0 byte
    > "$LOG_FILE" 

    echo "[OK] Log ruotato con successo in: $BACKUP_DIR/sensors_$TIMESTAMP.tar.gz"
else
    echo "[INFO] Dimensione log nella norma. Nessuna azione necessaria."
fi