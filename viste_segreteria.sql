USE studio_riabilitativo;

-- -----------------------------------------------------------------------------
-- 1. AGENDA GENERALE DEGLI APPUNTAMENTI
-- Usata dalla segreteria per pianificare le visite e contattare i pazienti.
-- Esclude volutamente le NoteCliniche per riservatezza.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_Segreteria_AgendaVisite AS
SELECT 
    v.CodiceVisita,
    v.DataOra,
    v.Durata AS DurataMinuti,
    v.Stato AS StatoVisita,
    CONCAT(p.Nome, ' ', p.Cognome) AS Paziente,
    p.Telefono AS TelefonoPaziente,
    p.Email AS EmailPaziente,
    CONCAT(pr.Nome, ' ', pr.Cognome) AS Professionista,
    v.Fattura AS NumeroFatturaCollegata
FROM Visita v
INNER JOIN Paziente p ON v.Paziente = p.CodiceFiscale
INNER JOIN Professionista pr ON v.Professionista = pr.CodiceProfessionista
ORDER BY v.DataOra ASC;

-- -----------------------------------------------------------------------------
-- 2. ANAGRAFICA AMMINISTRATIVA PAZIENTI
-- Consente la consultazione e il contatto escludendo il campo sensibile Anamnesi.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_Segreteria_AnagraficaPazienti AS
SELECT 
    p.CodiceFiscale,
    p.Nome,
    p.Cognome,
    p.DataNascita,
    p.Citta,
    p.Via,
    p.Telefono,
    p.Email
FROM Paziente p;

-- -----------------------------------------------------------------------------
-- 3. MONITORAGGIO STATO FATTURE E INCASSI
-- Riepilogo dello stato contabile per emissione, saldo e solleciti.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_Segreteria_StatoFatturazione AS
SELECT 
    f.NumeroFattura,
    f.DataEmissione,
    f.ImportoTotale,
    f.Stato AS StatoFattura,
    f.MetodoPagamento,
    CONCAT(p.Nome, ' ', p.Cognome) AS Intestatario,
    p.CodiceFiscale,
    p.Telefono AS TelefonoPaziente
FROM Fattura f
INNER JOIN Visita v ON f.NumeroFattura = v.Fattura
INNER JOIN Paziente p ON v.Paziente = p.CodiceFiscale
GROUP BY 
    f.NumeroFattura, f.DataEmissione, f.ImportoTotale, 
    f.Stato, f.MetodoPagamento, p.Nome, p.Cognome, p.CodiceFiscale, p.Telefono
ORDER BY f.DataEmissione DESC;