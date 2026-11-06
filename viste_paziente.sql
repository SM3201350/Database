USE studio_riabilitativo;

-- 1. Cartella clinica e visite del paziente
CREATE OR REPLACE VIEW v_MiaCartellaClinica AS
SELECT 
    p.CodiceFiscale,
    CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
    p.Anamnesi,
    v.CodiceVisita,
    v.DataOra AS DataVisita,
    v.Durata AS DurataMinuti,
    v.Stato AS StatoVisita,
    v.NoteCliniche AS RefertoVisita,
    CONCAT(pr.Nome, ' ', pr.Cognome) AS ProfessionistaCurante,
    pr.Specializzazioni
FROM Paziente p
INNER JOIN Visita v ON p.CodiceFiscale = v.Paziente
INNER JOIN Professionista pr ON v.Professionista = pr.CodiceProfessionista;

-- 2. Prescrizioni ed esercizi assegnati
-- NOTA: pr.Paziente AS CodiceFiscale è INDISPENSABILE per consentire il WHERE da Python
CREATE OR REPLACE VIEW v_MiePrescrizioniEsercizi AS
SELECT 
    pr.Paziente AS CodiceFiscale,
    pr.CodicePrescrizione,
    pr.DataInizio,
    pr.DataFine,
    pr.NoteCliniche AS NotePrescrizioneMedico,
    CONCAT(prof.Nome, ' ', prof.Cognome) AS MedicoPrescrittore,
    vp.NumeroVoce,
    ce.Nome AS NomeEsercizio,
    ce.GruppoMuscolare,
    vp.Serie,
    vp.Ripetizioni,
    vp.FrequenzaGiornaliera,
    vp.IstruzioniSpecifiche
FROM Prescrizione pr
INNER JOIN Professionista prof ON pr.Professionista = prof.CodiceProfessionista
INNER JOIN VocePrescrizione vp ON pr.CodicePrescrizione = vp.Prescrizione
INNER JOIN CatalogoEsercizi ce ON vp.Esercizio = ce.CodiceEsercizio;

-- 3. Diario di monitoraggio domiciliare
CREATE OR REPLACE VIEW v_MioDiarioClinico AS
SELECT 
    pr.Paziente AS CodiceFiscale,
    m.DataEsecuzione,
    pr.CodicePrescrizione,
    ce.Nome AS Esercizio,
    m.ScalaVAS,
    m.Difficolta,
    m.NotePaziente
FROM MonitoraggioEsercizio m
INNER JOIN VocePrescrizione vp ON m.Prescrizione = vp.Prescrizione 
                               AND m.NumeroVoce = vp.NumeroVoce
INNER JOIN CatalogoEsercizi ce ON vp.Esercizio = ce.CodiceEsercizio
INNER JOIN Prescrizione pr ON vp.Prescrizione = pr.CodicePrescrizione
ORDER BY m.DataEsecuzione DESC;

-- 4. Fatture e prestazioni del paziente
CREATE OR REPLACE VIEW v_MieFatturePrestazioni AS
SELECT 
    v.Paziente AS CodiceFiscale,
    f.NumeroFattura,
    f.DataEmissione,
    f.Stato AS StatoFattura,
    f.MetodoPagamento,
    f.ImportoTotale AS TotaleFattura,
    v.CodiceVisita,
    v.DataOra AS DataVisita,
    pst.Descrizione AS PrestazioneErogata,
    pst.Tariffa AS QuotaPrestazione
FROM Fattura f
INNER JOIN Visita v ON f.NumeroFattura = v.Fattura
INNER JOIN Svolgimento s ON v.CodiceVisita = s.Visita
INNER JOIN Prestazione pst ON s.Prestazione = pst.CodicePrestazione
ORDER BY f.DataEmissione DESC, v.DataOra DESC;