USE studio_riabilitativo;

-- Tabella di Audit per monitorare le modifiche allo stato delle fatture
CREATE TABLE IF NOT EXISTS AuditFattura (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    NumeroFattura INT NOT NULL,
    VecchioStato VARCHAR(20),
    NuovoStato VARCHAR(20),
    DataModifica DATETIME NOT NULL,
    UtenteModifica VARCHAR(50) NOT NULL
);

DELIMITER $$

-- Controllo Integrità: Impedisce l'inserimento di una prescrizione con date incoerenti
CREATE TRIGGER trg_CheckDatePrescrizione
BEFORE INSERT ON Prescrizione
FOR EACH ROW
BEGIN
    IF NEW.DataFine < NEW.DataInizio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: La DataFine non può precedere la DataInizio.';
    END IF;
END $$

-- Tracciamento Audit: Registra automaticamente ogni cambio di stato della fattura
CREATE TRIGGER trg_AuditStatoFattura
AFTER UPDATE ON Fattura
FOR EACH ROW
BEGIN
    IF OLD.Stato <> NEW.Stato THEN 
        INSERT INTO AuditFattura (NumeroFattura, VecchioStato, NuovoStato, DataModifica, UtenteModifica)
        VALUES (OLD.NumeroFattura, OLD.Stato, NOW(), USER());
    END IF;
END $$

DELIMITER ;