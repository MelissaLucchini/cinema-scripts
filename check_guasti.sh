#!/bin/bash

# 1. Definiamo il file dei sensori
FILE_SENSORI="dati/sensori.log"

echo "=== VERIFICA INTEGRITÀ SENSORI (ORARIO DI CHIUSURA) ==="
echo "Analisi in corso alle ore: $(date +%H:%M)"

# 2. Cerchiamo i sensori che segnano presenza impropria
# grep "OCCUPATO": trova le righe incriminate
# cut -d'|' -f1: prende solo la prima parte (il nome del posto) prima del simbolo |
lista_guasti=$(grep "OCCUPATO" "$FILE_SENSORI" | cut -d'|' -f1)

# 3. Verifichiamo se abbiamo trovato qualcosa
# -z controlla se la variabile è vuota
if [ -z "$lista_guasti" ]; then
    echo "Tutti i sensori risultano correttamente LIBERI. Nessun intervento richiesto."
else
    echo "-------------------------------------------------------"
    echo "ATTENZIONE: Rilevati potenziali guasti hardware!"
    echo "I seguenti posti segnano OCCUPATO a sala vuota:"
    echo "$lista_guasti"
    echo "-------------------------------------------------------"
    echo "Inviare report al team di manutenzione."
fi

echo "=== FINE ANALISI ==="