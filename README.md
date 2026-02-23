#  Digitalizzazione e Monitoraggio Cinema

##  Descrizione del Progetto

Questo progetto implementa la digitalizzazione completa di un cinema
tradizionalmente gestito in modo analogico.

L'obiettivo è trasformare la struttura in un sistema: - Automatizzato -
Sicuro - Data-driven - Scalabile

Il sistema integra hardware (sensori IoT), software server Linux e
script Bash per il monitoraggio in tempo reale, l'analisi dei dati e la
sicurezza.

------------------------------------------------------------------------

#  Architettura del Sistema

## 1 Infrastruttura Hardware

-   Ogni poltrona è dotata di un sensore di pressione
-   I sensori inviano dati tramite rete sulla porta **7777**
-   I dati vengono salvati nel file:

``` bash
/var/log/cinema/sensors.log
```

------------------------------------------------------------------------

## 2 Infrastruttura Software

Il sistema è basato su GNU/Linux e utilizza:

-   MariaDB → Gestione database (film, clienti, vendite)
-   NGINX → Web server per dashboard interna
-   OpenSSH → Amministrazione remota sicura
-   Script Bash → Automazione controlli e report
-   Flask → Sito web per vendita biglietti

------------------------------------------------------------------------

#  Problemi Risolti

##  1. Rilevamento Sedute Abusive

Confronto tra: - sensors.log (stato fisico) - vendite.csv (stato legale)

Se un posto risulta occupato ma non venduto → segnalazione errore.

##  2. Report Incasso Giornaliero

Script che: - Conta biglietti venduti - Somma prezzi - Genera report con
data automatica - Salva file in cartella backup

##  3. Manutenzione Sensori

Controllo automatico sensori durante orari di chiusura. Se un posto
risulta "OCCUPATO" a sala vuota → possibile guasto.

##  4. Sicurezza Accessi SSH

Monitoraggio di:

``` bash
/var/log/auth.log
```

Se troppi tentativi di accesso falliti → allarme sicurezza.

##  5. Creazione Sito Web

Applicazione Flask per: - Prenotazione posti - Aggiornamento database in
tempo reale - Interfaccia moderna per il personale

##  6. Analisi Affluenza Film

Query SQL per: - Calcolare percentuale occupazione - Identificare film
più redditizi - Supportare decisioni gestionali

##  7. Monitoraggio Porta 7777

Controllo che il server sia sempre in ascolto per i sensori. Se la porta
non è attiva: - Riavvio servizio - Log errore

code:

#!/bin/bash

PORT=7777

if ss -tuln | grep -q ":$PORT"; then
    echo "Port $PORT is active."
else
    echo "WARNING: Port $PORT is not listening!"
    systemctl restart sensor-service
fi

##  8. Rotazione e Pulizia Log

Script automatico che: - Comprimi log vecchi - Libera spazio su disco -
Previene crash del server

code:

#!/bin/bash

LOG_FILE="/var/log/cinema/sensors.log"
MAX_SIZE=5000000   # 5MB

FILE_SIZE=$(stat -c%s "$LOG_FILE")

if [ "$FILE_SIZE" -ge "$MAX_SIZE" ]; then
    TIMESTAMP=$(date +%Y-%m-%d)
    tar -czf "sensors_$TIMESTAMP.tar.gz" "$LOG_FILE"
    > "$LOG_FILE"
    echo "Log rotated successfully."
fi

##  9. Monitoraggio Errori Web

Analisi di:

``` bash
/var/log/nginx/error.log
```

Rilevazione errori 500/502 per prevenire interruzioni del servizio.


code: 

#!/bin/bash

ERROR_LOG="/var/log/nginx/error.log"
THRESHOLD=5

ERROR_COUNT=$(grep -E "500|502" "$ERROR_LOG" | wc -l)

if [ "$ERROR_COUNT" -gt "$THRESHOLD" ]; then
    echo "ALERT: High number of server errors detected."
fi

##  10. Backup di Emergenza

Backup giornaliero del database:

``` bash
mysqldump cinema_db > backup.sql
tar -czf cinema_backup_$(date +%Y-%m-%d).tar.gz backup.sql
```

Garantisce ripristino completo in caso di guasto.

Code:
#!/bin/bash

DB_NAME="cinema_db"
BACKUP_DIR="/backup"
DATE=$(date +%Y-%m-%d)

mysqldump -u root -p "$DB_NAME" > "$BACKUP_DIR/$DB_NAME_$DATE.sql"

tar -czf "$BACKUP_DIR/$DB_NAME_$DATE.tar.gz" \
"$BACKUP_DIR/$DB_NAME_$DATE.sql"

rm "$BACKUP_DIR/$DB_NAME_$DATE.sql"

echo "Backup completed successfully."


------------------------------------------------------------------------

#  Benefici del Sistema

✔ Eliminazione gestione cartacea\
✔ Riduzione errori umani\
✔ Monitoraggio in tempo reale\
✔ Maggiore sicurezza informatica\
✔ Analisi dati per decisioni strategiche\
✔ Sistema scalabile per più sale

------------------------------------------------------------------------

#  Possibili Estensioni Future

-   Sistema di pagamento online
-   Dashboard con grafici avanzati
-   Notifiche automatiche via email
-   Integrazione con app mobile
-   Backup remoto automatico

------------------------------------------------------------------------

#  Autore

Progetto sviluppato come sistema completo di digitalizzazione e
automazione per infrastruttura cinema basata su Linux.
