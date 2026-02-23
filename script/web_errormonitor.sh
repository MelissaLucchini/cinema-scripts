#!/bin/bash

# ==============================================================================
# 9. MONITORAGGIO ERRORI WEB
# Descrizione: Analizza i log del server alla ricerca di errori critici (500/502).
#              Previene interruzioni prolungate del servizio rilevando anomalie.
# ==============================================================================

# --- CONFIGURAZIONE PERCORSI ---
# BASE_DIR rileva automaticamente la cartella principale del progetto
BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")

# In un sistema reale useresti: /var/log/nginx/error.log
# Nel tuo progetto usiamo il log locale gestito da Flask
ERROR_LOG="$BASE_DIR/dati/login_sito.log"

# Numero massimo di errori consentiti prima di lanciare l'allarme
THRESHOLD=5

echo "--- ANALISI INTEGRITÀ WEB SERVER ---"

# --- CONTROLLO ESISTENZA FILE ---
if [ ! -f "$ERROR_LOG" ]; then
    echo "[ERRORE] File di log non trovato in: $ERROR_LOG"
    exit 1
fi

# --- CONTEGGIO ERRORI ---
# grep -E: usa espressioni regolari per cercare 500 o 502
# wc -l: conta le linee trovate
ERROR_COUNT=$(grep -E "500|502" "$ERROR_LOG" | wc -l)

echo "Errori critici rilevati: $ERROR_COUNT (Soglia: $THRESHOLD)"

# --- LOGICA DI ALLERTA ---
if [ "$ERROR_COUNT" -gt "$THRESHOLD" ]; then 
    echo "================================================="
    echo "  [ALERT] RILEVATO NUMERO ELEVATO DI ERRORI!"
    echo "  Il servizio web potrebbe essere instabile."
    echo "  Data: $(date)"
    echo "================================================="
    
    # Opzionale: registra l'alert nel log di servizio
    echo "[$(date)] ALERT: Superata soglia errori web ($ERROR_COUNT)" >> "$BASE_DIR/dati/accessi_servizio.log"
else
    echo "[OK] Il server web sta rispondendo correttamente."
fi