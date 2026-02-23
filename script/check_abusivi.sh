#!/bin/bash
# ------------------------------------------------------------------
# Progetto: Digitalizzazione Cinema
# 1. Rilevamento Sedute Abusive
# ------------------------------------------------------------------

# Determiniamo la cartella principale del progetto (cinema-scripts)
# Questo permette di eseguire lo script da qualsiasi posizione
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")

# Definiamo i percorsi completi basati sulla root del progetto
FILE_VENDITE="$BASE_DIR/dati/vendite.csv"
FILE_SENSORI="$BASE_DIR/dati/sensori.log"

echo "=== INIZIO CONTROLLO INCROCIATO SALA ==="
echo "Analisi dati in: $BASE_DIR/dati"

# Verifica se i file esistono prima di procedere
if [[ ! -f "$FILE_SENSORI" ]]; then
    echo "ERRORE: Il file $FILE_SENSORI non esiste."
    exit 1
fi

# Leggiamo il file dei sensori riga per riga
# IFS="|" separa Sala | Posto | Stato
while IFS="|" read -r sala nome_posto stato_fisico
do
    # Cerchiamo nel CSV filtrando per sala E posto
    # Usiamo grep -F per match esatto e evitiamo errori se il file è vuoto
    stato_legale=$(grep "$sala" "$FILE_VENDITE" 2>/dev/null | grep "$nome_posto" | cut -d',' -f3)
    
    if [ "$stato_fisico" == "OCCUPATO" ] && [ "$stato_legale" == "Libero" ]; then
        echo "[!] ALLERTA $sala: Il posto $nome_posto è abusivo!"
    fi

done < "$FILE_SENSORI"

echo "=== FINE CONTROLLO ==="