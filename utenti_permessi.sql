USE studio_riabilitativo;

-- 1. DEFINIZIONE DEI RUOLI APPLICATIVI
CREATE ROLE IF NOT EXISTS 'ruolo_segreteria';
CREATE ROLE IF NOT EXISTS 'ruolo_professionista';
CREATE ROLE IF NOT EXISTS 'ruolo_paziente';

-- 2. PRIVILEGI PER RUOLO SEGRETERIA
GRANT SELECT ON studio_riabilitativo.v_Segreteria_AgendaVisite TO 'ruolo_segreteria';
GRANT SELECT ON studio_riabilitativo.v_Segreteria_AnagraficaPazienti TO 'ruolo_segreteria';
GRANT SELECT ON studio_riabilitativo.v_Segreteria_StatoFatturazione TO 'ruolo_segreteria';

GRANT SELECT (CodiceFiscale, Nome, Cognome, DataNascita, Citta, Via, Telefono, Email),
      INSERT, UPDATE (Telefono, Email, Citta, Via) 
ON studio_riabilitativo.Paziente TO 'ruolo_segreteria';

GRANT SELECT, INSERT, UPDATE ON studio_riabilitativo.Visita TO 'ruolo_segreteria';
GRANT SELECT, INSERT, UPDATE ON studio_riabilitativo.Fattura TO 'ruolo_segreteria';
GRANT SELECT ON studio_riabilitativo.Prestazione TO 'ruolo_segreteria';
GRANT SELECT, INSERT ON studio_riabilitativo.Svolgimento TO 'ruolo_segreteria';

GRANT EXECUTE ON PROCEDURE studio_riabilitativo.sp_RegistraVisitaFattura TO 'ruolo_segreteria';
GRANT EXECUTE ON PROCEDURE studio_riabilitativo.sp_SaldaFattura TO 'ruolo_segreteria';

-- 3. PRIVILEGI PER RUOLO PROFESSIONISTA
GRANT SELECT ON studio_riabilitativo.v_Professionista_MiaAgenda TO 'ruolo_professionista';
GRANT SELECT ON studio_riabilitativo.v_Professionista_CartellaClinicaPazienti TO 'ruolo_professionista';
GRANT SELECT ON studio_riabilitativo.v_Professionista_PrescrizioniAttive TO 'ruolo_professionista';
GRANT SELECT ON studio_riabilitativo.v_Professionista_MonitoraggioPazienti TO 'ruolo_professionista';

GRANT SELECT ON studio_riabilitativo.Paziente TO 'ruolo_professionista';
GRANT SELECT, UPDATE (NoteCliniche, Stato) ON studio_riabilitativo.Visita TO 'ruolo_professionista';
GRANT SELECT, INSERT, UPDATE ON studio_riabilitativo.Prescrizione TO 'ruolo_professionista';
GRANT SELECT, INSERT, UPDATE ON studio_riabilitativo.VocePrescrizione TO 'ruolo_professionista';
GRANT SELECT ON studio_riabilitativo.MonitoraggioEsercizio TO 'ruolo_professionista';
GRANT SELECT ON studio_riabilitativo.CatalogoEsercizi TO 'ruolo_professionista';
GRANT SELECT ON studio_riabilitativo.Prestazione TO 'ruolo_professionista';
GRANT SELECT, INSERT ON studio_riabilitativo.Svolgimento TO 'ruolo_professionista';

-- 4. PRIVILEGI PER RUOLO PAZIENTE
GRANT SELECT ON studio_riabilitativo.v_MiaCartellaClinica TO 'ruolo_paziente';
GRANT SELECT ON studio_riabilitativo.v_MiePrescrizioniEsercizi TO 'ruolo_paziente';
GRANT SELECT ON studio_riabilitativo.v_MioDiarioClinico TO 'ruolo_paziente';
GRANT SELECT ON studio_riabilitativo.v_MieFatturePrestazioni TO 'ruolo_paziente';

GRANT INSERT ON studio_riabilitativo.MonitoraggioEsercizio TO 'ruolo_paziente';
GRANT SELECT (CodiceEsercizio, Nome, Descrizione, GruppoMuscolare) 
ON studio_riabilitativo.CatalogoEsercizi TO 'ruolo_paziente';

-- 5. UTENTI APPLICATIVI DI TEST (con password fittizie di collaudo)
CREATE USER IF NOT EXISTS 'segreteria1'@'localhost' IDENTIFIED BY 'TestPassSegr2026!';
CREATE USER IF NOT EXISTS 'dott_fumagalli'@'localhost' IDENTIFIED BY 'TestPassDoc2026!';
CREATE USER IF NOT EXISTS 'dott_bruni'@'localhost' IDENTIFIED BY 'TestPassDoc2026!';
CREATE USER IF NOT EXISTS 'paziente_app'@'localhost' IDENTIFIED BY 'TestPassPaz2026!';

-- 6. ASSEGNAZIONE DEI RUOLI
GRANT 'ruolo_segreteria' TO 'segreteria1'@'localhost';
GRANT 'ruolo_professionista' TO 'dott_fumagalli'@'localhost';
GRANT 'ruolo_paziente' TO 'paziente_app'@'localhost';

-- Mansioni combinate per il Dott. Bruni
GRANT 'ruolo_professionista', 'ruolo_segreteria' TO 'dott_bruni'@'localhost';

SET DEFAULT ROLE ALL TO 
    'segreteria1'@'localhost',
    'dott_fumagalli'@'localhost',
    'dott_bruni'@'localhost',
    'paziente_app'@'localhost';
