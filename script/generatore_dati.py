import random
import os

# Configurazione: 2 sale da 50 posti l'una 
sale = ["Sala_1", "Sala_2"]
file_sala = ['A', 'B', 'C', 'D', 'E'] # 5 file
posti_per_fila = range(1, 11) # 10 posti

def genera_dati():
    # --- GESTIONE PERCORSI DINAMICI ---
    # Otteniamo la cartella dove si trova questo script (cinema-scripts/script)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # Risaliamo alla cartella principale (cinema-scripts)
    root_dir = os.path.dirname(script_dir)
    # Definiamo il percorso della cartella dati
    data_dir = os.path.join(root_dir, "dati")
    
    # Percorsi completi dei file
    path_vendite = os.path.join(data_dir, 'vendite.csv')
    path_sensori = os.path.join(data_dir, 'sensori.log')

    # Creiamo la cartella dati se non esiste (sicurezza extra)
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)

    # Creiamo/Puliamo i file usando i percorsi assoluti
    with open(path_vendite, 'w') as f_v, open(path_sensori, 'w') as f_s:
        f_v.write("Sala,Posto,Stato,Prezzo\n")
        
        guasti_totali = 0
        
        for sala in sale:
            for fila in file_sala:
                for n in posti_per_fila:
                    nome_posto = f"{fila}{n}"
                    
                    # 1. Logica Vendite (70% venduti)
                    venduto = random.random() < 0.7
                    stato_v = "Venduto" if venduto else "Libero"
                    prezzo = "8.50" if venduto else "0.00"
                    f_v.write(f"{sala},{nome_posto},{stato_v},{prezzo}\n")
                    
                    # 2. Logica Sensori
                    sorte = random.random()
                    if stato_v == "Venduto":
                        # Quasi tutti seduti, raramente qualcuno è in bagno/ritardo
                        stato_s = "OCCUPATO" if sorte < 0.95 else "LIBERO"
                    else:
                        # Se il posto è libero, può esserci un abusivo o un guasto
                        if sorte < 0.02: # 2% di probabilità abusivo
                            stato_s = "OCCUPATO"
                        elif sorte < 0.05 and guasti_totali < 2: # MAX 2 GUASTI in tutto il cinema
                            stato_s = "OCCUPATO"
                            guasti_totali += 1
                        else:
                            stato_s = "LIBERO"
                    
                    f_s.write(f"{sala}|{nome_posto}|{stato_s}\n")

if __name__ == "__main__":
    genera_dati()
    print("Dati multisala generati con successo nella cartella 'dati'!")