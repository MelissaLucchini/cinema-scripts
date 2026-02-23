#!/bin/bash

# --- CONFIGURAZIONE PERCORSI ---
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
FILE_VENDITE="$BASE_DIR/dati/vendite.csv"

if [ ! -f "$FILE_VENDITE" ]; then
    echo "[ERRORE] File non trovato."
    exit 1
fi

echo "--- RESET AGGRESSIVO DEL DATABASE ---"

# Creiamo un backup
cp "$FILE_VENDITE" "$FILE_VENDITE.bak"

# LOGICA: 
# Usiamo 'cut' e 'paste' o un 'awk' più potente per ricostruire le righe.
# Questo comando forza la colonna 3 a "Libero" e la colonna 4 a "0.00" 
# per tutte le righe tranne l'intestazione.

awk -F, 'BEGIN {OFS=","} NR==1 {print $0} NR>1 {$3="Libero"; $4="0.00"; print $0}' "$FILE_VENDITE" > "$FILE_VENDITE.tmp" && mv "$FILE_VENDITE.tmp" "$FILE_VENDITE"

echo "-------------------------------------------------------"
echo "[OK] Pulizia completata con successo."
echo "[OK] Ogni prezzo è stato azzerato a 0.00."
echo "-------------------------------------------------------"