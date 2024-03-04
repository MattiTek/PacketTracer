/* Creazione Tabelle - Schema Logico */

DROP DATABASE IF EXISTS societa_calcio;

CREATE DATABASE societa_calcio;
USE societa_calcio; 

CREATE TABLE Contratto(
    idContratto INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    dataInizio DATE NOT NULL,
    dataScadenza DATE NOT NULL,
    ingaggio INT NOT NULL,
    idGiocatore INT NOT NULL,
    FOREIGN KEY(idGiocatore) REFERENCES Giocatore(idGiocatore),
    idSquadra INT NOT NULL,
    FOREIGN KEY(idSquadra) REFERENCES Squadra(idSquadra),
    percentuale_possesso INT NOT NULL,
    titolore BOOLEAN NOT NULL
);

CREATE TABLE Giocatore(
    idGiocatore INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
    ruolo VARCHAR(30) NOT NULL
);

CREATE TABLE Squadra(
    idSquadra INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    denominazione VARCHAR(30) NOT NULL
);

INSERT INTO Contratto (dataInizio, dataScadenza, ingaggio, idGiocatore, idSquadra) VALUES
('2021-07-01', '2023-06-30', 5000000, 1, 1),  -- Contratto di Cristiano Ronaldo con la Juventus
('2021-07-01', '2022-06-30', 2000000, 2, 1),  -- Contratto di Gianluigi Buffon con la Juventus
('2021-07-01', '2024-01-05', 3000000, 3, 2),  -- Contratto di Zlatan Ibrahimović con il Milan
('2021-07-01', '2024-01-20', 1000000, 4, 3),  -- Contratto di Lionel Messi con l'Inter
('2021-08-01', '2024-01-30', 4000000, 1, 3);

INSERT INTO Giocatore (nome, cognome, ruolo) VALUES
('Cristiano', 'Ronaldo', 'Attaccante'),  -- Giocatore della Juventus
('Gianluigi', 'Buffon', 'Portiere'),      -- Giocatore della Juventus
('Zlatan', 'Ibrahimovic', 'Attaccante'),  -- Giocatore del Milan
('Lionel', 'Messi', 'Attaccante'), -- Giocatore dell'Inter
('Lautaro', 'Martinez', 'Attaccante'); --Giocatore dell'Inter


INSERT INTO Squadra (denominazione) VALUES
('Juventus'),
('Milan'),
('Inter'),
('Roma');


-- per ogni squadra, visualizzare il codice della squadra e il numero dei giocatori con contratto in corso;
SELECT s.denominazione as 'Squadra',  COUNT(*) as 'Giocatori in corso'
    FROM squadra s, contratto c
    WHERE s.idSquadra = c.idSquadra AND c.dataScadenza > CURDATE()
    GROUP BY s.idSquadra;

SELECT s.denominazione, g.cognome, g.nome, c.dataScadenza
    FROM squadra s, contratto c, giocatore g
    WHERE s.idSquadra = c.idSquadra AND c.idGiocatore = g.idGiocatore
    ORDER BY s.denominazione, g.cognome, g.nome;

-- denominazione delle squadre che hanno piu' di 30 giocatori con contratto in corso;
SELECT s.denominazione as 'Nome squadra', COUNT(*) as 'Numero contratti'
    FROM squadra s, contratto c
    WHERE c.idSquadra = s.idSquadra AND c.dataScadenza > '2020-01-01'
    GROUP BY s.idSquadra
    HAVING COUNT(*) >= 2;

-- dato il codice di un giocatore, fornire l'elenco delle squadre (denominazione, data inizio, data scadenza) con le quali ha avuto o ha contratti, cioe' la carriera del giocatore;
SELECT s.denominazione, c.dataInizio, c.dataScadenza, g.nome, g.cognome 
    FROM squadra s, contratto c, giocatore g
    WHERE c.idSquadra = s.idSquadra AND g.idGiocatore = c.idGiocatore AND g.idGiocatore = 1
    ORDER BY g.cognome;

--  cognome, nome e ruolo dei giocatori attualmente svincolati;
SELECT g.cognome, g.nome, g.ruolo
    FROM contratto c, giocatore g
    WHERE c.idGiocatore = g.idGiocatore AND c.dataScadenza < CURDATE();

--  cognome, nome e ruolo dei giocatori attualmente svincolati; #2
SELECT g.cognome, g.nome, g.ruolo
    FROM giocatore g LEFT JOIN contratto c ON g.idGiocatore = c.idGiocatore
    WHERE c.dataScadenza < CURDATE() OR c.idGiocatore IS NULL;

-- elenco dei giocatori (cognome, nome e squadra dove giocano) attualmente in comproprieta';
temp = (SELECT g.idGiocatore, g.cognome, g.nome
    FROM giocatore g, squadra s, contratto c
    WHERE g.idGiocatore = c.idGiocatore AND s.idSquadra = c.idSquadra 
    GROUP BY c.idGiocatore 
    HAVING COUNT(*) > 1)

SELECT temp.cognome, temp.nome, s.denominazione as 'Squadra in cui gioca'
    FROM contratto c,
        (SELECT g.idGiocatore, g.cognome, g.nome
            FROM giocatore g, squadra s, contratto c
            WHERE g.idGiocatore = c.idGiocatore AND s.idSquadra = c.idSquadra 
            GROUP BY c.idGiocatore 
            HAVING COUNT(*) > 1)temp, 
                                squadra s 
    WHERE c.idGiocatore = temp.idGiocatore AND s.idSquadra = c.idSquadra AND c.dataScadenza > CURDATE() AND c.titolore = true;

-- cognome, nome del giocatore e denominazione della squadra che attualmente ha in corso il contratto con l'ingaggio piu' alto;
SELECT g.cognome, g.nome, s.denominazione, MAX(ingaggio) as 'Ingaggio piu alto' 
    FROM giocatore g, squadra s, contratto c
    WHERE s.idSquadra = c.idSquadra AND c.idGiocatore = g.idGiocatore AND c.dataScadenza > CURDATE();

