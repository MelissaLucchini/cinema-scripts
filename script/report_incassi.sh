#!/bin/bash

# ==============================================================================
# 2. REPORT INCASSO GIORNALIERO
# Descrizione: Script che conta i biglietti venduti, somma i prezzi e genera
#              un report automatico salvandolo nella cartella di backup.
# ==============================================================================

# --- CONFIGURAZIONE PERCORSI DINAMICI ---
# BASE_DIR rileva automaticamente la cartella principale del progetto
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
FILE_VENDITE="$BASE_DIR/dati/vendite.csv"
BACKUP_DIR="$BASE_DIR/backup"

# Creiamo un nome file che contiene la data attuale
DATA_OGGI=$(date +%Y-%m-%d)
FILE_REPORT="$BACKUP_DIR/report_$DATA_OGGI.txt"

echo "--- GENERAZIONE REPORT INCASSI IN CORSO ---"

# --- CONTROLLO ESISTENZA CARTELLE E FILE ---
# Crea la cartella backup se manca
mkdir -p "$BACKUP_DIR"

if [ ! -f "$FILE_VENDITE" ]; then
    echo "[ERRORE] File vendite non trovato in: $FILE_VENDITE"
    exit 1
fi

# --- ELABORAZIONE DATI ---
# 2. Sommiamo i prezzi usando 'awk' (Punto 2 del README)
# -F',' specifica il separatore CSV
# NR > 1 salta l'intestazione
# sum += $4 somma la quarta colonna (Prezzo)
totale_incasso=$(awk -F',' 'NR > 1 {sum += $4} END {printf "%.2f", sum}' "$FILE_VENDITE")

# 3. Contiamo i biglietti venduti usando 'grep' e '-c' (count)
numero_biglietti=$(grep -c "Venduto" "$FILE_VENDITE")

# --- GENERAZIONE FILE REPORT ---
# Usiamo le parentesi graffe per reindirizzare tutto l'output nel file
{
    echo "==============================================="
    echo "          REPORT GIORNALIERO ASTRA"
    echo "          Data: $(date '+%d/%m/%Y %H:%M')"
    echo "==============================================="
    echo " Biglietti totali venduti: $numero_biglietti"
    echo " Incasso totale calcolato: € $totale_incasso"
    echo "==============================================="
    echo " Stato: Elaborazione completata con successo."
} > "$FILE_REPORT"

# Mostriamo il risultato a video
cat "$FILE_REPORT"

echo ""
echo "[OK] Report salvato correttamente in: $FILE_REPORT"