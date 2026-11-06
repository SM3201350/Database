-- Pazienti
INSERT INTO Paziente (CodiceFiscale, Nome, Cognome, DataNascita, Citta, Via, Telefono, Email, Anamnesi) VALUES
('RSSMRA85M01L424X', 'Mario', 'Rossi', '1985-01-15', 'Trieste', 'Via Fabio Severo 12', '3331112222', 'mario.rossi@email.it', 'Lombosciatalgia recidivante'),
('VRDLGI90A41L424Y', 'Luigia', 'Verdi', '1990-01-01', 'Trieste', 'Via Carducci 5', '3334445555', 'luigia.verdi@email.it', 'Distorsione caviglia dx grado II'),
('BNCLCU78D12L424Z', 'Luca', 'Bianchi', '1978-04-12', 'Gorizia', 'Corso Italia 45', '3337778888', 'luca.bianchi@email.it', 'Lesione cuffia dei rotatori');

-- Professionisti
INSERT INTO Professionista (Nome, Cognome, Telefono, Email, Specializzazioni, NumeroAlbo) VALUES
('Francesca', 'Fumagalli', '0406491111', 'fumagalli.francesca@email.it', 'Fisioterapia Neurologica, Riabilitazione Posturale', 'TS-98765'),
('Cristiano', 'Bruni', '0405582222', 'c.bruni@email.it', 'Osteopata, Massoterapista', 'TS-35476');

-- Catalogo Prestazioni Cliniche
INSERT INTO Prestazione (Descrizione, Tariffa) VALUES
('Prima Visita Fisiatrica e Valutazione Funzionale', 90.00),
('Seduta Rieducazione Motoria e Posturale', 55.00),
('Tecarterapia Distretto Singolo', 45.00),
('Massoterapia Distrettuale Decontratturante', 40.00);

-- Catalogo esercizi terapeutici domiciliari
INSERT INTO CatalogoEsercizi (Nome, Descrizione, GruppoMuscolare) VALUES
('Ponte Glutei (Bridge)', 'Sollevamento bacino da supino con ginocchia flesse', 'Glutei, Lombari'),
('Bird Dog Quadrupedia', 'Estensione alternata braccio-gamba controlaterale', 'Core, Stabilità colonna'),
('Pendolare di Codman', 'Circonduzione passiva braccio rilassato a busto flesso', 'Spalla'),
('Isometrica Quadrato dei Lombi', 'Contrazione isometrica laterale in decubito', 'Lombari');

-- Fatture emesse
INSERT INTO Fattura (DataEmissione, ImportoTotale, Stato, MetodoPagamento) VALUES
('2026-03-01 11:30:00', 95.00, 'Saldata', 'Bancomat POS'),
('2026-03-05 18:00:00', 55.00, 'Emessa', 'Bonifico');

-- Visite svolte
-- Visita 1: Mario Rossi con Andrea De Lorenzo (fatturata con Fattura 1)
INSERT INTO Visita (DataOra, Durata, Stato, NoteCliniche, Paziente, Professionista, Fattura) VALUES
('2026-03-01 10:30:00', 45, 'Effettuata', 'Paziente lamenta contrattura acuta L4-L5', 'RSSMRA85M01L424X', 1, 1);

-- Visita 2: Luigia Verdi con Andrea De Lorenzo (fatturata con Fattura 2)
INSERT INTO Visita (DataOra, Durata, Stato, NoteCliniche, Paziente, Professionista, Fattura) VALUES
('2026-03-05 17:00:00', 50, 'Effettuata', 'Recupero ROM flessione dorsale soddisfacente', 'VRDLGI90A41L424Y', 1, 2);

-- Visita 3: Luca Bianchi con Sylvio Barbon (da fatturare -> Fattura = NULL)
INSERT INTO Visita (DataOra, Durata, Stato, NoteCliniche, Paziente, Professionista, Fattura) VALUES
('2026-03-10 15:00:00', 60, 'Prenotata', 'Controllo mobilità articolare gleno-omerale', 'BNCLCU78D12L424Z', 2, NULL);

-- Prestazioni eseguiet nelle visite
-- Visita 1: Tecar (45€) + Massoterapia (40€) + sconto/totale fattura = 95.00€
INSERT INTO Svolgimento (Visita, Prestazione) VALUES
(1, 3),
(1, 4),
-- Visita 2: Rieducazione motoria (55€)
(2, 2);

-- Prescrizioni terapeutiche domiciliarie
INSERT INTO Prescrizione (DataInizio, DataFine, NoteCliniche, Paziente, Professionista) VALUES
('2026-03-01', '2026-03-21', 'Esercizi di decompressione discale e stabilizzazione core', 'RSSMRA85M01L424X', 1);

-- Voci della Prescrizione 
INSERT INTO VocePrescrizione (Prescrizione, NumeroVoce, Serie, Ripetizioni, FrequenzaGiornaliera, IstruzioniSpecifiche, Esercizio) VALUES
(1, 1, 3, 12, 2, 'Mantenere la contrazione in cima per 3 secondi senza inarcare la schiena', 1),
(1, 2, 3, 10, 1, 'Movimento lento e controllato, concentrarsi sulla respirazione', 2);

-- Diariio di monitoraggio
INSERT INTO MonitoraggioEsercizio (Prescrizione, NumeroVoce, DataEsecuzione, ScalaVAS, Difficolta, NotePaziente) VALUES
(1, 1, '2026-03-02 18:30:00', 4, 2, 'Esercizio eseguito bene, lieve indolenzimento a fine serie'),
(1, 1, '2026-03-03 18:45:00', 3, 2, 'Dolore sceso, stabilità migliorata'),
(1, 2, '2026-03-03 19:00:00', 5, 4, 'Difficoltà nel mantenere l equilibrio sul braccio sx');