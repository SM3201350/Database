USE studio_riabilitativo;

-- -----------------------------------------------------------------------------
-- 1. AGENDA PERSONALE DEL TERAPISTA / MEDICO
-- Mostra solo le visite assegnate al professionista collegato.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_Professionista_MiaAgenda AS
SELECT 
    v.CodiceVisita,
    v.DataOra,
    v.Durata,
    v.Stato AS StatoVisita,
    CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
    p.CodiceFiscale,
    p.Telefono,
    v.NoteCliniche
FROM Visita v
INNER JOIN Paziente p ON v.Paziente = p.CodiceFiscale
ORDER BY v.DataOra ASC;


-- -----------------------------------------------------------------------------
-- 2. CARTELLA CLINICA E STORICO DELLE PRESTAZIONI EROGATE
-- Accesso completo all'anamnesi e alle terapie svolte per i soli pazienti in carico.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_Professionista_CartellaClinicaPazienti AS
SELECT 
    p.CodiceFiscale,
    CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
    p.DataNascita,
    p.Anamnesi,
    v.CodiceVisita,
    v.DataOra AS DataVisita,
    v.NoteCliniche AS DiarioVisita,
    pst.Descrizione AS PrestazioneEseguita
FROM Visita v
INNER JOIN Paziente p ON v.Paziente = p.CodiceFiscale
LEFT JOIN Svolgimento s ON v.CodiceVisita = s.Visita
LEFT JOIN Prestazione pst ON s.Prestazione = pst.CodicePrestazione
ORDER BY p.Cognome ASC, v.DataOra DESC;

-- -----------------------------------------------------------------------------
-- 3. PIANO DI PRESCRIZIONI ED ESERCIZI ASSEGNATI DAL PROFESSIONISTA
-- Dettaglio del programma domiciliare prescritto ai pazienti.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_Professionista_PrescrizioniAttive AS
SELECT 
    pr.CodicePrescrizione,
    pr.Paziente AS CodiceFiscalePaziente,
    CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
    pr.DataInizio,
    pr.DataFine,
    pr.NoteCliniche AS ObiettivoClinico,
    vp.NumeroVoce,
    ce.Nome AS Esercizio,
    ce.GruppoMuscolare,
    vp.Serie,
    vp.Ripetizioni,
    vp.FrequenzaGiornaliera,
    vp.IstruzioniSpecifiche
FROM Prescrizione pr
INNER JOIN Paziente p ON pr.Paziente = p.CodiceFiscale
INNER JOIN VocePrescrizione vp ON pr.CodicePrescrizione = vp.Prescrizione
INNER JOIN CatalogoEsercizi ce ON vp.Esercizio = ce.CodiceEsercizio
ORDER BY pr.DataInizio DESC, vp.NumeroVoce ASC;

-- -----------------------------------------------------------------------------
-- 4. MONITORAGGIO DEL DOLORE (VAS) E ADERENZA TERAPEUTICA
-- Mostra i riscontri inseriti dai pazienti per gli esercizi prescritti dal medico.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_Professionista_MonitoraggioPazienti AS
SELECT 
    m.DataEsecuzione,
    CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
    ce.Nome AS Esercizio,
    m.ScalaVAS,
    m.Difficolta,
    m.NotePaziente,
    pr.CodicePrescrizione
FROM MonitoraggioEsercizio m
INNER JOIN VocePrescrizione vp ON m.Prescrizione = vp.Prescrizione 
                               AND m.NumeroVoce = vp.NumeroVoce
INNER JOIN CatalogoEsercizi ce ON vp.Esercizio = ce.CodiceEsercizio
INNER JOIN Prescrizione pr ON vp.Prescrizione = pr.CodicePrescrizione
INNER JOIN Paziente p ON pr.Paziente = p.CodiceFiscale
ORDER BY m.DataEsecuzione DESC;