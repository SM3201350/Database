USE studio_riabilitativo;

DROP PROCEDURE IF EXISTS sp_RegistraVisitaFattura;

DELIMITER $$
CREATE PROCEDURE sp_RegistraVisitaFattura (
    IN p_CodiceVisita INT,
    OUT p_NumeroFattura INT,
    OUT p_ImportoAggiornato DECIMAL(8,2)
)
BEGIN
    DECLARE v_Paziente CHAR(16);
    DECLARE v_CostoVisita DECIMAL(8,2) DEFAULT 0.00;
    DECLARE v_FatturaAperta INT DEFAULT NULL;
    DECLARE v_FatturaGiaAssegnata INT DEFAULT NULL;

    -- Gestione Errori: in caso di eccezione fa ROLLBACK immediato
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Controlli Preliminari sulla visita
    SELECT Paziente, Fattura
    INTO v_paziente, v_FatturaGiaAssegnata
    FROM Visita
    WHERE CodiceVisita = p_CodiceVisita;

    IF v_Paziente IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Visita non trovata.';
    END IF;

    IF v_FatturaGiaAssegnata IS NOT NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Errore: Questa visita è già inserita in una fattura.';
    END IF;

    -- Calcolo del totale per le prestazioni svolte in questa specifica visita
    SELECT IFNULL(SUM(pr.Tariffa), 0.00) INTO v_CostoVisita
    FROM Svolgimento s
    INNER JOIN Prestazione pr ON s.Prestazione = pr.CodicePrestazione
    WHERE s.Visita = p_CodiceVisita;

    -- Apertura transazione
    START TRANSACTION;

    -- Cerca se esiste già una fattura aperta ('In corso') del paziente
    SELECT MAX(f.NumeroFattura) INTO v_FatturaAperta
    FROM Fattura f
    INNER JOIN Visita v ON f.NumeroFattura = v.Fattura
    WHERE v.Paziente = v_Paziente
        AND f.Stato = 'In Corso';

    IF v_FatturaAperta IS NULL THEN
        -- Caso A: non c'è una fattura aperta -> la creo con il costo della prima visita
        INSERT INTO Fattura (DataEmissione, ImportoTotale, Stato, MetodoPagamento)
        VALUES (NOW(), v_CostoVisita, 'In Corso', NULL);

        SET p_NumeroFattura = LAST_INSERT_ID();
        SET p_ImportoAggiornato = v_CostoVisita;
    ELSE
        -- Caso B: C'è una fattura aperta:aggiorniamo il costo della nuova visita
        UPDATE Fattura
        SET ImportoTotale = ImportoTotale + v_CostoVisita
        WHERE NumeroFattura = v_FatturaAperta;

        SET p_NumeroFattura = v_FatturaAperta;

        SELECT ImportoTotale INTO p_ImportoAggiornato
        FROM Fattura WHERE NumeroFattura = p_NumeroFattura;
    END IF;

    -- Aggiorno la visita collegandola alla fattura
    UPDATE Visita
    SET Fattura = p_NumeroFattura, Stato = 'Effettuata'
    WHERE CodiceVisita = p_CodiceVisita;

    COMMIT;
END $$

DELIMITER ;


-- Quando il cliente paga si esegue una procedura per chiudere la fattura
DROP PROCEDURE IF EXISTS sp_SaldaFattura;

DELIMITER $$
CREATE PROCEDURE sp_SaldaFattura (
    IN p_NumeroFattura INT,
    IN p_MetodoPagamento VARCHAR(30)
)

BEGIN
    UPDATE Fattura
    SET Stato = 'Saldata', MetodoPagamento = p_MetodoPagamento
    WHERE NumeroFattura = p_NumeroFattura AND Stato = 'In Corso';
END $$

DELIMITER ;