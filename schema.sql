-- Tabella Paziente
CREATE TABLE IF NOT EXISTS Paziente (
    CodiceFiscale CHAR(16) PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    Cognome VARCHAR(45) NOT NULL,
    DataNascita DATE NOT NULL,
    Citta VARCHAR(50),
    Via VARCHAR(100),
    Telefono VARCHAR(20),
    Email VARCHAR(50),
    Anamnesi TEXT
);

-- Tabella Professionista
CREATE TABLE IF NOT EXISTS Professionista (
    CodiceProfessionista INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    Cognome VARCHAR(45) NOT NULL,
    Telefono VARCHAR(20),
    Email VARCHAR(50),
    Specializzazioni VARCHAR(200),
    NumeroAlbo VARCHAR(30) NOT NULL UNIQUE
);

-- Tabella Fattura (con ImportoTotale denormalizzato)
CREATE TABLE IF NOT EXISTS Fattura (
    NumeroFattura INT AUTO_INCREMENT PRIMARY KEY,
    DataEmissione DATETIME NOT NULL,
    ImportoTotale DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    Stato VARCHAR(20) NOT NULL DEFAULT 'Emessa',
    MetodoPagamento VARCHAR(30)
);

-- Tabella Visita 
CREATE TABLE IF NOT EXISTS Visita (
    CodiceVisita INT AUTO_INCREMENT PRIMARY KEY,
    DataOra DATETIME NOT NULL,
    Durata INT NOT NULL COMMENT 'Durata in minuti',
    Stato VARCHAR(20) NOT NULL DEFAULT 'Prenotata',
    NoteCliniche TEXT,
    Paziente CHAR(16) NOT NULL,
    Professionista INT NOT NULL,
    Fattura INT NULL,
    CONSTRAINT FK_Visita_Paziente FOREIGN KEY (Paziente)
        REFERENCES Paziente(CodiceFiscale) ON UPDATE CASCADE,
    CONSTRAINT FK_Visita_Professionista FOREIGN KEY (Professionista)
        REFERENCES Professionista(CodiceProfessionista) ON UPDATE CASCADE,
    CONSTRAINT FK_Visita_Fattura FOREIGN KEY (Fattura)
        REFERENCES Fattura(NumeroFattura)
);

-- Tabella Prestazione
CREATE TABLE IF NOT EXISTS Prestazione (
    CodicePrestazione INT AUTO_INCREMENT PRIMARY KEY,
    Descrizione VARCHAR(100) NOT NULL,
    Tariffa DECIMAL(6,2) NOT NULL
);

-- Tabella Svolgimento (N:N tra Visita e Prestazione)
CREATE TABLE IF NOT EXISTS Svolgimento (
    Visita INT NOT NULL,
    Prestazione INT NOT NULL,
    PRIMARY KEY (Visita, Prestazione),
    CONSTRAINT FK_Svolgimento_Visita FOREIGN KEY (Visita)
        REFERENCES Visita(CodiceVisita) ON DELETE CASCADE,
    CONSTRAINT FK_Svolgimento_Prestazione FOREIGN KEY (Prestazione)
        REFERENCES Prestazione(CodicePrestazione) ON UPDATE CASCADE
);

-- Tabella CatalogoEsercizi
CREATE TABLE IF NOT EXISTS CatalogoEsercizi (
    CodiceEsercizio INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(80) NOT NULL,
    Descrizione TEXT,
    GruppoMuscolare VARCHAR(50)
);

-- Tabella Prescrizione
CREATE TABLE IF NOT EXISTS Prescrizione (
    CodicePrescrizione INT AUTO_INCREMENT PRIMARY KEY,
    DataInizio DATE NOT NULL,
    DataFine DATE NOT NULL,
    NoteCliniche TEXT,
    Paziente CHAR(16) NOT NULL,
    Professionista INT NOT NULL,
    CONSTRAINT CHK_Date_Prescrizione CHECK (DataInizio <= DataFine),
    CONSTRAINT FK_Prescrizione_Paziente FOREIGN KEY (Paziente)
        REFERENCES Paziente(CodiceFiscale) ON UPDATE CASCADE,
    CONSTRAINT FK_Prescrizione_Professionista FOREIGN KEY (Professionista)
        REFERENCES Professionista(CodiceProfessionista) ON UPDATE CASCADE
);

-- Tabella Voce Prescrizione
CREATE TABLE IF NOT EXISTS VocePrescrizione (
    Prescrizione INT NOT NULL,
    NumeroVoce INT NOT NULL,
    Serie INT NOT NULL,
    Ripetizioni INT NOT NULL,
    FrequenzaGiornaliera INT NOT NULL,
    IstruzioniSpecifiche TEXT,
    Esercizio INT NOT NULL,
    PRIMARY KEY (Prescrizione, NumeroVoce),
    CONSTRAINT FK_Voce_Prescrizione FOREIGN KEY (Prescrizione)
        REFERENCES Prescrizione(CodicePrescrizione) ON DELETE CASCADE,
    CONSTRAINT FK_Voce_Esercizio FOREIGN KEY (Esercizio)
        REFERENCES CatalogoEsercizi(CodiceEsercizio) ON UPDATE CASCADE
);

-- Tabella Monitoraggio Esercizio
CREATE TABLE IF NOT EXISTS MonitoraggioEsercizio (
    Prescrizione INT NOT NULL,
    NumeroVoce INT NOT NULL,
    DataEsecuzione DATETIME NOT NULL,
    ScalaVAS INT NOT NULL,
    Difficolta INT NOT NULL,
    NotePaziente TEXT,
    PRIMARY KEY (Prescrizione, NumeroVoce, DataEsecuzione),
    CONSTRAINT CHK_ScalaVAS CHECK (ScalaVAS BETWEEN 0 AND 10),
    CONSTRAINT CHK_Difficolta CHECK (Difficolta BETWEEN 1 AND 5),
    CONSTRAINT FK_Monitoraggio_Voce FOREIGN KEY (Prescrizione, NumeroVoce)
        REFERENCES VocePrescrizione (Prescrizione, NumeroVoce) ON DELETE CASCADE
);
