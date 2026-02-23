import random

# Configurazione: 2 sale da 50 posti l'una 
sale = ["Sala_1", "Sala_2"]
file_sala = ['A', 'B', 'C', 'D', 'E'] # 5 file
posti_per_fila = range(1, 11) # 10 posti

def genera_dati():
    # Creiamo/Puliamo i file
    with open('dati/vendite.csv', 'w') as f_v, open('dati/sensori.log', 'w') as f_s:
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
    print("Dati multisala generati! (Massimo 2 guasti hardware inseriti)")