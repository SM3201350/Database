USE studio_riabilitativo;

-- JOIN MULTIPLA (Cartella Clinica Integrata)
-- Ricostruisce l'intero percorso: Paziente -> Visita -> Professionista -> svolgimento -> Prestazione
SELECT
    p.CodiceFiscale,
    CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
    v.DataOra,
    CONCAT(pr.Nome, ' ', pr.Cognome) AS Professionista,
    pst.Descrizione AS PrestazioneErogata,
    pst.Tariffa
FROM Paziente p
INNER JOIN Visita v ON p.CodiceFiscale = v.Paziente
INNER JOIN Professionista pr ON v.Professionista = pr.CodiceProfessionista
INNER JOIN Svolgimento s ON v.CodiceVisita = s.Visita
INNER JOIN Prestazione pst ON s.Prestazione = pst.CodicePrestazione
ORDER BY v.DataOra DESC;


-- Aggregazione
-- Calcola Dolore medio (VAS) e difficoltà per Esercizio (considerando solo quelli svolti alemno 2 volte)
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


-- 




