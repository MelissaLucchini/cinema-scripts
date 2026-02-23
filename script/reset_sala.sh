#!/bin/bash

# ==============================================================================
# RESET POSTI CINEMA
# Descrizione: Svuota la sala rendendo tutti i posti "Libero" e il prezzo "0.00".
# ==============================================================================

# --- CONFIGURAZIONE PERCORSI ---
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
FILE_VENDITE="$BASE_DIR/dati/vendite.csv"

# Controllo se il file esiste
if [ ! -f "$FILE_VENDITE" ]; then
    echo "[ERRORE] File $FILE_VENDITE non trovato."
    exit 1
fi

echo "--- RESET DELLA SALA IN CORSO ---"

# Utilizziamo 'sed' per trasformare i dati:
# 1. 's/Venduto/Libero/g' -> Sostituisce lo stato
# 2. 's/[0-9]\.[0-9][0-9]$/0.00/' -> Sostituisce il prezzo finale con 0.00
# Operiamo direttamente sul file con l'opzione -i (in-place)

# Creiamo una copia di sicurezza prima del reset
cp "$FILE_VENDITE" "$FILE_VENDITE.bak"

# Eseguiamo la trasformazione (saltando l'intestazione)
sed -i '2,$s/Venduto/Libero/g' "$FILE_VENDITE"
sed -i '2,$s/,[0-9.]*$/,0.00/g' "$FILE_VENDITE"

echo "-------------------------------------------------------"
echo "[OK] Tutte le sedute sono ora LIBERE."
echo "[OK] Prezzi resettati a 0.00."
echo "Backup creato in: vendite.csv.bak"
echo "-------------------------------------------------------"