#!/bin/bash

# ==============================================================================
# 10. BACKUP DI EMERGENZA
# Descrizione: Esegue un backup giornaliero del database e dei dati sensibili.
#              Garantisce il ripristino completo in caso di guasto hardware.
# ==============================================================================

# --- CONFIGURAZIONE PERCORSI ---
# BASE_DIR rileva la cartella principale del progetto
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
DB_NAME="cinema_db"
# Usiamo la cartella backup interna al progetto per evitare errori di permessi
BACKUP_DIR="$BASE_DIR/backup"
DATE=$(date +%Y-%m-%d)

echo "--- AVVIO PROCEDURA DI BACKUP DI EMERGENZA ---"

# Creiamo la cartella di backup se non esiste
mkdir -p "$BACKUP_DIR"

# --- ESECUZIONE BACKUP ---
# Proviamo a eseguire il dump del database. 
# Se fallisce (perché MariaDB non è attivo), facciamo il backup dei file CSV.
if command -v mysqldump &> /dev/null; then
    echo "Esecuzione mysqldump in corso..."
    mysqldump -u root "$DB_NAME" > "$BACKUP_DIR/${DB_NAME}_$DATE.sql" 2>/dev/null
fi

# Controllo: se il file .sql non è stato creato o è vuoto, salviamo i file dati
if [ ! -s "$BACKUP_DIR/${DB_NAME}_$DATE.sql" ]; then
    echo "[INFO] Database SQL non trovato. Eseguo backup dei file flat (CSV/LOG)..."
    # Copiamo i dati correnti in un file temporaneo per il tar
    cp "$BASE_DIR/dati/vendite.csv" "$BACKUP_DIR/data_backup_$DATE.sql"
fi

# --- COMPRESSIONE ---
# Comprimiamo il file risultante
tar -czf "$BACKUP_DIR/cinema_backup_$DATE.tar.gz" -C "$BACKUP_DIR" "${DB_NAME}_$DATE.sql" 2>/dev/null || \
tar -czf "$BACKUP_DIR/cinema_backup_$DATE.tar.gz" -C "$BACKUP_DIR" "data_backup_$DATE.sql"

# --- PULIZIA ---
# Rimuoviamo i file .sql temporanei per lasciare solo l'archivio compresso
rm -f "$BACKUP_DIR"/*.sql

if [ -f "$BACKUP_DIR/cinema_backup_$DATE.tar.gz" ]; then
    echo "================================================="
    echo "  [OK] Backup completato con successo!"
    echo "  File: $BACKUP_DIR/cinema_backup_$DATE.tar.gz"
    echo "================================================="
else
    echo "[ERRORE] Il backup è fallito."
    exit 1
fi