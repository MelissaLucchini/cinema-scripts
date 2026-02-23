#!/bin/bash

# ==============================================================================
# ASTRA CINEMAS - DISASTER RECOVERY SYSTEM
# Descrizione: Crea un backup compresso della cartella dati e lo salva in 'backup'
# ==============================================================================

# --- CONFIGURAZIONE PERCORSI ---
# Directory dello script (script/)
BASE_DIR=$(dirname "$(readlink -f "$0")")
# Directory sorgente (/workspaces/cinema-scripts/dati)
SOURCE_DIR=$(dirname "$BASE_DIR")/dati
# Directory di destinazione (/workspaces/cinema-scripts/backup)
BACKUP_DIR=$(dirname "$BASE_DIR")/backup

# Nome del file: backup_cinema_YYYYMMDD_HHMMSS.tar.gz
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="backup_cinema_$TIMESTAMP.tar.gz"

# --- ESECUZIONE ---

# 1. Creazione directory di backup se non esiste
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "[INFO] Creazione directory backup: $BACKUP_DIR"
fi

echo "--- INIZIO PROCEDURA BACKUP ---"

# 2. Compressione della cartella dati
# -c: crea, -z: comprimi (gzip), -f: specifica il file
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$(dirname "$SOURCE_DIR")" dati

# 3. Verifica esito
if [ $? -eq 0 ]; then
    echo "-------------------------------------------------------"
    echo "[OK] Backup completato con successo!"
    echo "[FILE] $BACKUP_DIR/$BACKUP_NAME"
    echo "[DATA] $(date)"
    echo "-------------------------------------------------------"
else
    echo "[ERRORE] Il backup è fallito. Controllare i permessi del disco."
    exit 1
fi

# 4. Opzionale: Mantieni solo gli ultimi 7 backup (pulizia automatica)
# find "$BACKUP_DIR" -name "backup_cinema_*.tar.gz" -mtime +7 -delete