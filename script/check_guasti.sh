#!/bin/bash

# ==============================================================================
# 3. MANUTENZIONE SENSORI
# Descrizione: Esegue un controllo automatico dei sensori durante gli orari di 
#              chiusura. Se un posto risulta "OCCUPATO" quando la sala è vuota,
#              viene segnalato come potenziale guasto hardware.
# ==============================================================================

# --- CONFIGURAZIONE PERCORSI ---
# BASE_DIR rileva automaticamente la cartella principale (cinema-scripts)
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
FILE_SENSORI="$BASE_DIR/dati/sensori.log"

echo "=== VERIFICA INTEGRITÀ SENSORI (ORARIO DI CHIUSURA) ==="
echo "Analisi in corso alle ore: $(date +%H:%M)"
echo "File sorgente: $FILE_SENSORI"

# --- CONTROLLO ESISTENZA FILE ---
if [ ! -f "$FILE_SENSORI" ]; then
    echo "[ERRORE] Il file dei sensori non è stato trovato in: $FILE_SENSORI"
    exit 1
fi

# --- RICERCA ANOMALIE ---
# 2. Cerchiamo i sensori che segnano presenza impropria (Punto 3 del README)
# grep "OCCUPATO": trova le righe dove il sensore è attivo
# cut -d'|' -f1,2: estrae Sala e Posto (es. Sala_1|A1)
lista_guasti=$(grep "OCCUPATO" "$FILE_SENSORI" | cut -d'|' -f1,2)

# --- REPORT FINALE ---
# -z controlla se la variabile è vuota (nessun OCCUPATO trovato)
if [ -z "$lista_guasti" ]; then
    echo "-------------------------------------------------------"
    echo "RISULTATO: Tutti i sensori risultano correttamente LIBERI."
    echo "Nessun intervento di manutenzione richiesto."
    echo "-------------------------------------------------------"
else
    echo "-------------------------------------------------------"
    echo "ATTENZIONE: Rilevati potenziali guasti hardware!"
    echo "I seguenti posti segnano OCCUPATO a sala vuota:"
    echo "$lista_guasti" | sed 's/|/ - Posto: /g'
    echo "-------------------------------------------------------"
    echo "AZIONE: Inviare report tecnico al team di manutenzione."
fi

echo "=== FINE ANALISI ==="