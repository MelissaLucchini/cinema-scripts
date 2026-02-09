#!/bin/bash

# 1. Definiamo i percorsi dei file
FILE_VENDITE="dati/vendite.csv"
FILE_SENSORI="dati/sensori.log"

echo "=== INIZIO CONTROLLO INCROCIATO SALA ==="

# 2. Leggiamo il file dei sensori riga per riga
# IFS="|" serve a dire a Bash che nel file log le colonne sono divise dal simbolo |
# Ora leggiamo: Sala | Posto | Stato
while IFS="|" read -r sala nome_posto stato_fisico
do
    # Cerchiamo nel CSV filtrando per sala E posto
    stato_legale=$(grep "$sala" "$FILE_VENDITE" | grep "$nome_posto" | cut -d',' -f3)
    
    if [ "$stato_fisico" == "OCCUPATO" ] && [ "$stato_legale" == "Libero" ]; then
        echo "[!] ALLERTA $sala: Il posto $nome_posto è abusivo!"
    fi

done < "$FILE_SENSORI"

echo "=== FINE CONTROLLO ==="