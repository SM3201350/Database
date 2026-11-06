USE studio_riabilitativo;

-- Indice per il calendario delle visite del professionista
-- Per estrarre l'agenda giornaliera del terapista
CREATE INDEX idx_Visita_Professionista_Data
ON Visita (Professionista, DataOra);

-- Indice per la cartella clinica del paziente
-- ottimizza il recupero della cronologia visite di un paziente
CREATE INDEX idx_Visita_Paziente
ON Visita (Paziente);

-- Indice monitoraggio temporale del dolore e difficoltà
CREATE INDEX idx_Monitoraggio_Data
ON MonitoraggioEsercizio (DataEsecuzione);

-- Indice per la ricerca delle prestazioni attive per paziente
CREATE INDEX idx_Prescrizione_Date
ON Prescrizione (Paziente, DataInizio, DataFine);