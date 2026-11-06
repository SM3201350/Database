CREATE DATABASE IF NOT EXISTS studio_riabilitativo;
USE studio_riabilitativo;

-- pulizia preventiva
source drop_tabelle.sql;

-- creazione delle tabelle
source schema.sql;

-- creazione indici secondari B-Tree
source indici.sql

-- definizione dei trigger
source trigger.sql;

-- popolamento con istanze significative e casi prova
source dati_test.sql;

-- Stored Procedures
source procedure.sql;

-- viste per Segreteria, Professionista Paziente
source viste_segreteria.sql;
source viste_Professionista.sql;
source viste_paziente.sql;

-- creazioni ruoli, utenti applicativi e privilegi
source utenti_permessi.sql;

-- Test del report fiscale
SET @idFattura = 1;
source stampa_fattura.sql;