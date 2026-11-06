SELECT 
    f.NumeroFattura,
    f.DataEmissione,
    f.Stato AS StatoFattura,
    f.MetodoPagamento,
    f.ImportoTotale AS TotaleFiscaleFattura,
    CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
    p.CodiceFiscale,
    v.CodiceVisita,
    v.DataOra AS DataVisita,
    CONCAT(pr.Nome, ' ', pr.Cognome) AS Professionista,
    pst.Descrizione AS PrestazioneSvolta,
    pst.Tariffa AS TariffaPrestazione
FROM Fattura f
INNER JOIN Visita v ON f.NumeroFattura = v.Fattura
INNER JOIN Paziente p ON v.Paziente = p.CodiceFiscale
INNER JOIN Professionista pr ON v.Professionista = pr.CodiceProfessionista
LEFT JOIN Svolgimento s ON v.CodiceVisita = s.Visita
LEFT JOIN Prestazione pst ON s.Prestazione = pst.CodicePrestazione
WHERE f.NumeroFattura = @idFattura 
ORDER BY v.DataOra ASC, pst.CodicePrestazione ASC;