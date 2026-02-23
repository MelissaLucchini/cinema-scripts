#!/bin/bash

# Percorsi dei file
LOG_ACCESSI="dati/accessi_servizio.log"
AUTORIZZATI="dati/dipendenti_autorizzati.txt"

echo "==============================================="
echo "   SISTEMA DI MONITORAGGIO ACCESSI CINEMA"
echo "   Data controllo: $(date)"
echo "==============================================="

# Controllo se i file esistono per evitare errori
if [ ! -f "$LOG_ACCESSI" ] || [ ! -f "$AUTORIZZATI" ]; then
    echo "Errore: File dei dati mancanti. Esegui prima i generatori Python."
    exit 1
fi

# Leggiamo il log riga per riga
# IFS="|" definisce come separare la data dal resto della riga
while IFS="|" read -r data_ora info_resto
do
    # Estraiamo il nome utente usando awk
    # info_resto contiene ad esempio: " Utente: hacker | IP: 95.10.22.33"
    utente=$(echo "$info_resto" | awk -F': ' '{print $2}' | awk '{print $1}')
    ip=$(echo "$info_resto" | awk -F'IP: ' '{print $2}')

    # Verifichiamo se l'utente estratto è presente nella lista autorizzati
    if ! grep -q "$utente" "$AUTORIZZATI"; then
        echo "[ ALERT SICUREZZA ]"
        echo "Data/Ora: $data_ora"
        echo "Utente NON autorizzato: $utente"
        echo "Indirizzo IP sospetto: $ip"
        echo "-----------------------------------------------"
    fi
done < "$LOG_ACCESSI"

echo "Monitoraggio completato."