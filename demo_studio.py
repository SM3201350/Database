import mysql.connector
from mysql.connector import Error

# Configurazione della connessione al database
DB_CONFIG = {
    "host": "localhost",
    "user": "studente",      
    "password": "password123",
    "database": "studio_riabilitativo"
}

def get_connection():
    """Stabilisce e restituisce una connessione al DBMS."""
    return mysql.connector.connect(**DB_CONFIG)

# =============================================================================
# 1. AREA SEGRETERIA
# =============================================================================
def menu_segreteria():
    print("\n--- [SEGRETERIA] AGENDA GENERALE VISITE ---")
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Interrogazione dello schema esterno (Vista Segreteria)
        query = """
            SELECT CodiceVisita, DataOra, DurataMinuti, StatoVisita, 
                   Paziente, TelefonoPaziente, Professionista
            FROM v_Segreteria_AgendaVisite
            ORDER BY DataOra ASC;
        """
        cursor.execute(query)
        visite = cursor.fetchall()
        
        if not visite:
            print("Nessuna visita presente in agenda.")
        else:
            print(f"{'ID':<4} | {'Data e Ora':<19} | {'Durata':<6} | {'Paziente':<20} | {'Telefono':<12} | {'Professionista':<20} | {'Stato':<10}")
            print("-" * 105)
            for v in visite:
                dt_str = v['DataOra'].strftime('%Y-%m-%d %H:%M') if v['DataOra'] else ""
                print(f"{v['CodiceVisita']:<4} | {dt_str:<19} | {v['DurataMinuti']:<6} | {v['Paziente']:<20} | {v['TelefonoPaziente']:<12} | {v['Professionista']:<20} | {v['StatoVisita']:<10}")
                
        cursor.close()
        conn.close()
    except Error as e:
        print(f"Errore DBMS: {e}")

# =============================================================================
# 2. AREA PROFESSIONISTA & TRANSAZIONI ACID
# =============================================================================
def registra_visita_e_fattura():
    print("\n--- [PROFESSIONISTA/CASSA] REGISTRAZIONE VISITA & TRANSAZIONE FATTURA ---")
    codice_visita = input("Inserisci il Codice della Visita da registrare e fatturare (es. 3): ").strip()
    if not codice_visita.isdigit():
        print("Codice visita non valido.")
        return

    codice_visita = int(codice_visita)
    conn = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Invocazione della Stored Procedure transazionale
        # Parametri: IN p_CodiceVisita, OUT p_NumeroFattura, OUT p_ImportoAggiornato
        print(f"Invocazione stored procedure 'sp_RegistraVisitaFattura' per visita #{codice_visita}...")
        args = [codice_visita, 0, 0.0]
        result = cursor.callproc("sp_RegistraVisitaFattura", args)
        conn.commit()

        num_fattura = result[1]
        importo_totale = result[2]
        print(f"Transazione completata con successo (COMMIT)!")
        print(f"-> Assegnata alla Fattura #{num_fattura} | Importo totale aggiornato: {importo_totale:.2f} €")

        # Stampa di verifica con query parametrizzata sicura contro SQL Injection
        cursor_report = conn.cursor(dictionary=True)
        query_report = """
            SELECT f.NumeroFattura, f.DataEmissione, f.Stato AS StatoFattura, f.ImportoTotale,
                   CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
                   pst.Descrizione AS Prestazione, pst.Tariffa
            FROM Fattura f
            INNER JOIN Visita v ON f.NumeroFattura = v.Fattura
            INNER JOIN Paziente p ON v.Paziente = p.CodiceFiscale
            LEFT JOIN Svolgimento s ON v.CodiceVisita = s.Visita
            LEFT JOIN Prestazione pst ON s.Prestazione = pst.CodicePrestazione
            WHERE f.NumeroFattura = %s;
        """
        cursor_report.execute(query_report, (num_fattura,))
        righe = cursor_report.fetchall()
        
        print("\nRiepilogo contabile della fattura generata:")
        for r in righe:
            print(f"   [Fattura {r['NumeroFattura']}] {r['Paziente']} - Voce: {r['Prestazione']} ({r['Tariffa']} €)")

        cursor_report.close()
        cursor.close()
    except Error as e:
        print(f"Errore transazionale intercettato dal DBMS (ROLLBACK automatico): {e}")
    finally:
        if conn and conn.is_connected():
            conn.close()

# =============================================================================
# 3. AREA PAZIENTE
# =============================================================================
def portale_paziente():
    print("\n--- [PORTALE PAZIENTE] ACCESSO CARTELLA & ESERCIZI ---")
    cf_paziente = input("Inserisci il Codice Fiscale del paziente (es. RSSMRA85M01L424X): ").strip()
    
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # 1. Consultazione Cartella Clinica tramite Vista
        query_cartella = """
            SELECT Paziente, Anamnesi, CodiceVisita, DataVisita, StatoVisita, 
                   RefertoVisita, ProfessionistaCurante
            FROM v_MiaCartellaClinica
            WHERE CodiceFiscale = %s
            ORDER BY DataVisita DESC;
        """
        cursor.execute(query_cartella, (cf_paziente,))
        visite = cursor.fetchall()

        if not visite:
            print("Nessuna cartella clinica trovata per il codice fiscale inserito.")
            cursor.close()
            conn.close()
            return

        print(f"\nPaziente: {visite[0]['Paziente']}")
        print(f"Anamnesi: {visite[0]['Anamnesi']}")
        print("\nStorico Visite e Referti:")
        for v in visite:
            dt = v['DataVisita'].strftime('%Y-%m-%d %H:%M') if v['DataVisita'] else ""
            print(f" - [{dt}] Dr. {v['ProfessionistaCurante']} | Stato: {v['StatoVisita']} | Referto: {v['RefertoVisita']}")

        # 2. Consultazione Esercizi Prescritti
        query_esercizi = """
            SELECT CodicePrescrizione, NomeEsercizio, GruppoMuscolare, Serie, Ripetizioni, 
                   FrequenzaGiornaliera, IstruzioniSpecifiche, NumeroVoce
            FROM v_MiePrescrizioniEsercizi
            WHERE CodiceFiscale = %s;
        """
        cursor.execute(query_esercizi, (cf_paziente,))
        esercizi = cursor.fetchall()

        print("\nPiano Esercizi Riabilitativi Domiciliari:")
        for es in esercizi:
            print(f" - [Prescr. #{es['CodicePrescrizione']} - Voce {es['NumeroVoce']}] {es['NomeEsercizio']} ({es['GruppoMuscolare']}) | {es['Serie']} serie x {es['Ripetizioni']} rip. ({es['FrequenzaGiornaliera']}v al giorno)")
            print(f"   Istruzioni: {es['IstruzioniSpecifiche']}")

        # 3. Registrazione Diario Clinico (MonitoraggioEsercizio)
        scelta = input("\nVuoi registrare un'esecuzione nel diario domiciliare? (s/n): ").strip().lower()
        if scelta == 's':
            prescr_id = int(input("Numero Prescrizione: ").strip())
            voce_id = int(input("Numero Voce: ").strip())
            vas = int(input("Intensità del dolore su Scala VAS (0-10): ").strip())
            difficolta = int(input("Difficoltà percepita (1-5): ").strip())
            note = input("Note / sensazioni personali: ").strip()

            insert_query = """
                INSERT INTO MonitoraggioEsercizio 
                (Prescrizione, NumeroVoce, DataEsecuzione, ScalaVAS, Difficolta, NotePaziente)
                VALUES (%s, %s, NOW(), %s, %s, %s);
            """
            cursor.execute(insert_query, (prescr_id, voce_id, vas, difficolta, note))
            conn.commit()
            print("Feedback registrato con successo nel database dello studio!")

        cursor.close()
        conn.close()
    except Error as e:
        print(f"Errore DBMS: {e}")

# =============================================================================
# 4. REPORT STATISTICO AGGREGATO (QUERY NON BANALE CON HAVING)
# =============================================================================
def statistiche_cliniche():
    print("\n--- [DIREZIONE CLINICA] MONITORAGGIO MEDIO DOLORE E DIFFICOLTÀ PER ESERCIZIO ---")
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Esecuzione della query complessa con GROUP BY e HAVING (slide De Lorenzo)
        query = """
            SELECT
                ce.Nome AS Esercizio,
                ce.GruppoMuscolare,
                COUNT(*) AS NumeroEsecuzioni,
                ROUND(AVG(m.ScalaVAS), 2) AS MediaDoloreVAS,
                ROUND(AVG(m.Difficolta), 2) AS MediaDifficolta
            FROM CatalogoEsercizi ce
            INNER JOIN VocePrescrizione vp ON ce.CodiceEsercizio = vp.Esercizio
            INNER JOIN MonitoraggioEsercizio m ON vp.Prescrizione = m.Prescrizione 
                                               AND vp.NumeroVoce = m.NumeroVoce
            GROUP BY ce.CodiceEsercizio, ce.Nome, ce.GruppoMuscolare
            HAVING COUNT(*) >= 2;
        """
        cursor.execute(query)
        stats = cursor.fetchall()
        
        print(f"{'Esercizio':<25} | {'Gruppo':<15} | {'N. Esecuzioni':<14} | {'VAS Medio':<10} | {'Difficoltà':<10}")
        print("-" * 85)
        for s in stats:
            print(f"{s['Esercizio']:<25} | {s['GruppoMuscolare']:<15} | {s['NumeroEsecuzioni']:<14} | {s['MediaDoloreVAS']:<10} | {s['MediaDifficolta']:<10}")
            
        cursor.close()
        conn.close()
    except Error as e:
        print(f"Errore DBMS: {e}")

# =============================================================================
# MAIN LOOP
# =============================================================================
def main():
    while True:
        print("\n==================================================")
        print(" GESTIONALE STUDIO RIABILITATIVO - DEMO ESAME")
        print("==================================================")
        print("1. [Segreteria] Visualizza Agenda Visite")
        print("2. [Clinica/Cassa] Esegui Stored Procedure Fatturazione")
        print("3. [Paziente] Cartella Personale ed Inserimento Diario")
        print("4. [Direzione] Report Aggregato Aderenza ed Esercizi (HAVING)")
        print("5. Esci")
        scelta = input("Seleziona un'opzione (1-5): ").strip()

        if scelta == "1":
            menu_segreteria()
        elif scelta == "2":
            registra_visita_e_fattura()
        elif scelta == "3":
            portale_paziente()
        elif scelta == "4":
            statistiche_cliniche()
        elif scelta == "5":
            print("Chiusura applicativo.")
            break
        else:
            print("Scelta non valida, riprova.")

if __name__ == "__main__":
    main()