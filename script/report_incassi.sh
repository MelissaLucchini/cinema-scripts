#!/bin/bash

# 1. Definiamo i file e i percorsi
FILE_VENDITE="dati/vendite.csv"
# Creiamo un nome file che contiene la data di oggi, es: report_2026-02-03.txt
DATA_OGGI=$(date +%Y-%m-%d)
FILE_REPORT="backup/report_$DATA_OGGI.txt"

echo "--- GENERAZIONE REPORT INCASSI IN CORSO ---"

# 2. Sommiamo i prezzi usando 'awk'
# awk è un comando di Linux nato apposta per gestire file a colonne (come i CSV)
# -F',' specifica che il separatore è la virgola
# 'NR > 1' dice di non leggere la prima riga
# '{sum += $3}' dice di aggiungere il valore della terza colonna alla variabile 'sum'
totale_incasso=$(awk -F',' 'NR > 1 {sum += $4} END {print sum}' $FILE_VENDITE)

# 3. Contiamo i biglietti venduti usando 'grep' e '-c' (count)
numero_biglietti=$(grep -c "Venduto" $FILE_VENDITE)

# 4. Creiamo il file di report finale
{
    echo "==============================="
    echo "   REPORT CINEMA ASTRA"
    echo "   Data: $(date)"
    echo "==============================="
    echo "Biglietti staccati: $numero_biglietti"
    echo "Incasso Totale: € $totale_incasso"
    echo "==============================="
} > "$FILE_REPORT"

# Mostriamo il risultato anche a video per comodità
cat "$FILE_REPORT"

echo "Report salvato con successo in $FILE_REPORT"