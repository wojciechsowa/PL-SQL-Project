/*-----IMPLEMENTACJA_ORACLE-----*/
CREATE TABLE Klient
(
    IDKlienta     NUMBER (5) NOT NULL,
    Imie          VARCHAR2 (50) NOT NULL,
    Nazwisko      VARCHAR2 (50) NOT NULL,
    Plec          VARCHAR2 (1) NOT NULL,
    Miasto        VARCHAR2 (50) NOT NULL,
    Ulica         VARCHAR2 (50) NOT NULL,
    NrUlicy       NUMBER (3) NOT NULL,
    NrDomu        NUMBER (2),
    Wyksztalcenie VARCHAR2 (50) NOT NULL,
    IDWojewodztwa NUMBER (2) NOT NULL
);
ALTER TABLE Klient ADD CONSTRAINT Check_Klient_Plec CHECK (UPPER(Plec) IN ('K', 'M')); --check sprawdzajacy poprawnosc symbolu plci
ALTER TABLE Klient ADD CONSTRAINT Check_Klient_Wyksztalcenie CHECK (LOWER(Wyksztalcenie) IN ('podstawowe', 'wy¿sze', 'zawodowe', 'œrednie')); --check sprawdzajacy poprawnosc podanego wyksztalcenia
ALTER TABLE Klient ADD CONSTRAINT Klient_PK PRIMARY KEY (IDKlienta); --klucz glowny tabeli Klient


CREATE TABLE Makler
(
    IDMaklera     NUMBER (5) NOT NULL,
    Imie          VARCHAR2 (50) NOT NULL,
    Nazwisko      VARCHAR2 (50) NOT NULL,
    Plec          VARCHAR2 (1) NOT NULL,
    Miasto        VARCHAR2 (50) NOT NULL,
    Ulica         VARCHAR2 (50) NOT NULL,
    NrUlicy       NUMBER (3) NOT NULL,
    NrDomu        NUMBER (2),
    IDWojewodztwa NUMBER (2) NOT NULL
);
ALTER TABLE Makler ADD CONSTRAINT Check_Makler_Plec CHECK (UPPER(Plec) IN ('K', 'M')); --check sprawdzajacy poprawnosc symbolu plci
ALTER TABLE Makler ADD CONSTRAINT Makler_PK PRIMARY KEY (IDMaklera); --klucz glowny tabeli Makler


CREATE TABLE SektorSpolka
(
    IDSektora   NUMBER (5) NOT NULL,
    OpisSektora VARCHAR2 (50) NOT NULL
);
ALTER TABLE SektorSpolka ADD CONSTRAINT SektorSpolka_PK PRIMARY KEY (IDSektora); --klucz glowny tabeli SektorSpolka


CREATE TABLE Spolka
(
    IDSpolki         NUMBER (5) NOT NULL,
    NazwaSpolki      VARCHAR2 (50) NOT NULL,
    NazwaIndeksu     VARCHAR2 (5) NOT NULL,
    WartoscNotowania NUMBER (5,2) NOT NULL,
    NazwiskoPrezesa  VARCHAR2 (50) NOT NULL,
    Miasto           VARCHAR2 (50) NOT NULL,
    RokZalozenia     NUMBER (4) NOT NULL,
    RokDebiutu       NUMBER (4) NOT NULL,
    IDSektora        NUMBER (5) NOT NULL
);
ALTER TABLE Spolka ADD CONSTRAINT Spolka_PK PRIMARY KEY (IDSpolki); --klucz glowny tabeli Spolka


CREATE TABLE Wojewodztwo
(
    IDWojewodztwa    NUMBER (2) NOT NULL,
    NazwaWojewodztwa VARCHAR2 (50) NOT NULL
);
ALTER TABLE Wojewodztwo ADD CONSTRAINT Wojewodztwo_PK PRIMARY KEY (IDWojewodztwa); --klucz glowny tabeli Wojewodztwo


CREATE TABLE Zlecenie
(
    IDZlecenia      NUMBER (6) NOT NULL,
    IDKlienta       NUMBER (5) NOT NULL,
    IDMaklera       NUMBER (5) NOT NULL,
    DataZlecenia    DATE NOT NULL,
    WartoscZlecenia NUMBER (9,2) NOT NULL
);
ALTER TABLE Zlecenie ADD CONSTRAINT Zlecenie_PK PRIMARY KEY (IDZlecenia); --klucz glowny tabeli Zlecenie


CREATE TABLE ZlecenieDetale
(
    IDZlecenia  NUMBER (6) NOT NULL,
    Pozycja     NUMBER (2) NOT NULL,
    IDSpolki    NUMBER (5) NOT NULL,
    TypZlecenia VARCHAR2 (15) NOT NULL,
    IloscAkcji  NUMBER (3) NOT NULL,
    CenaZakupu  NUMBER (6,2) NOT NULL
);
ALTER TABLE ZlecenieDetale ADD CONSTRAINT Check_ZlecenieDet_TypZlecenia CHECK (LOWER(TypZlecenia) IN ('kupno', 'sprzeda¿')); --check sprawdzajacy poprawnosc wprowadzonego typu zlecenia
ALTER TABLE ZlecenieDetale ADD CONSTRAINT ZlecenieDetale_PK PRIMARY KEY (Pozycja, IDZlecenia); --klucz glowny tabeli ZlecenieDetale


ALTER TABLE Klient ADD CONSTRAINT Klient_Wojewodztwo_FK FOREIGN KEY (IDWojewodztwa) REFERENCES Wojewodztwo (IDWojewodztwa); --klucz obcy w tabeli Klient

ALTER TABLE Makler ADD CONSTRAINT Makler_Wojewodztwo_FK FOREIGN KEY (IDWojewodztwa) REFERENCES Wojewodztwo (IDWojewodztwa); --klucz obcy w tabeli Makler

ALTER TABLE Spolka ADD CONSTRAINT Spolka_SektorSpolka_FK FOREIGN KEY (IDSektora) REFERENCES SektorSpolka (IDSektora); --klucz obcy w tabeli Spolka

ALTER TABLE ZlecenieDetale ADD CONSTRAINT ZlecenieDetale_Spolka_FK FOREIGN KEY (IDSpolki) REFERENCES Spolka (IDSpolki); --klucz obcy w tabeli ZlecenieDetale

ALTER TABLE ZlecenieDetale ADD CONSTRAINT ZlecenieDetale_Zlecenie_FK FOREIGN KEY (IDZlecenia) REFERENCES Zlecenie (IDZlecenia); --klucz obcy w tabeli ZlecenieDetale

ALTER TABLE Zlecenie ADD CONSTRAINT Zlecenie_Klient_FK FOREIGN KEY (IDKlienta) REFERENCES Klient (IDKlienta); --klucz obcy w tabeli Zlecenie

ALTER TABLE Zlecenie ADD CONSTRAINT Zlecenie_Makler_FK FOREIGN KEY (IDMaklera) REFERENCES Makler (IDMaklera); --klucz obcy w tabeli Zlecenie

INSERT INTO Wojewodztwo VALUES (1, 'dolnoœl¹skie');
INSERT INTO Wojewodztwo VALUES (2, 'kujawsko-pomorskie');
INSERT INTO Wojewodztwo VALUES (3, 'lubelskie');
INSERT INTO Wojewodztwo VALUES (4, 'lubuskie');
INSERT INTO Wojewodztwo VALUES (5, '³ódzkie');
INSERT INTO Wojewodztwo VALUES (6, 'ma³opolskie');
INSERT INTO Wojewodztwo VALUES (7, 'mazowieckie');
INSERT INTO Wojewodztwo VALUES (8, 'opolskie');
INSERT INTO Wojewodztwo VALUES (9, 'podkarpackie');
INSERT INTO Wojewodztwo VALUES (10, 'podlaskie');
INSERT INTO Wojewodztwo VALUES (11, 'pomorskie');
INSERT INTO Wojewodztwo VALUES (12, 'œl¹skie');
INSERT INTO Wojewodztwo VALUES (13, 'œwiêtokrzyskie');
INSERT INTO Wojewodztwo VALUES (14, 'warmiñsko-mazurskie');
INSERT INTO Wojewodztwo VALUES (15, 'wielkopolskie');
INSERT INTO Wojewodztwo VALUES (16, 'zachodnio-pomorskie'); 

INSERT INTO Klient VALUES (1, 'Piotr', 'Biegañski', 'M', 'Warszawa', 'Niepodleg³oœci', 2, 5, 'œrednie', 7);
INSERT INTO Klient VALUES (2, 'Pawe³', 'Mitrowski', 'M', 'Poznañ', 'Solidarnoœci', 55, null, 'wy¿sze', 15);
INSERT INTO Klient VALUES (3, 'Szczepan', 'B¹k', 'M', 'Katowice', 'Pokojowa', 23, 7, 'zawodowe', 12);
INSERT INTO Klient VALUES (4, 'Janina', 'Olszewska', 'K', 'Opole', 'Zbrojna', 1, null, 'podstawowe', 8);
INSERT INTO Klient VALUES (5, 'Olga', 'Wo³czyñska', 'K', 'Szczecin', 'Skoœna', 88, 6, 'œrednie', 16);
INSERT INTO Klient VALUES (6, 'Mieczys³aw', 'Budnik', 'M', 'Ciechanów', 'Kolorowa', 56, 2, 'wy¿sze', 7);
INSERT INTO Klient VALUES (7, 'Beata', 'Zdanowska', 'K', 'Zielona Góra', 'Kwiatowa', 32, 9, 'wy¿sze', 4);
INSERT INTO Klient VALUES (8, 'Andrzej', 'Kwiatkowski', 'M', 'Marki', 'Za³amana', 9, null, 'wy¿sze', 7);
INSERT INTO Klient VALUES (9, 'Anna', 'Jopek', 'K', 'Przemyœl', 'D³uga', 34, 17, 'podstawowe', 9);
INSERT INTO Klient VALUES (10, 'Franciszek', '¯yto', 'M', 'Sopot', 'Piaskowa', 70, null, 'œrednie', 11);
INSERT INTO Klient VALUES (11, 'Jan', 'Czopek', 'M', 'Sierpc', 'Weso³a', 5, null, 'wy¿sze', 7);
INSERT INTO Klient VALUES (12, 'Marcelina', 'Woœko', 'K', 'Zamoœæ', 'Twarda', 34, null, 'zawodowe', 3);
INSERT INTO Klient VALUES (13, 'Remigiusz', 'Balcerak', 'M', 'Œwinoujœcie', 'Warszawska', 2, 12, 'wy¿sze', 16);
INSERT INTO Klient VALUES (14, 'Jacek', 'Michlewski', 'M', 'Witanów', 'Kolejowa', 16, null, 'podstawowe', 7);
INSERT INTO Klient VALUES (15, 'Krystyna', 'Dupczyk', 'K', 'Kraków', 'Wawelska', 125, null, 'œrednie', 6);
INSERT INTO Klient VALUES (16, '¯aneta', 'Kalejczyk', 'K', 'Bronisze', 'Targowa', 22, 1, 'wy¿sze', 7);
INSERT INTO Klient VALUES (17, 'Barbara', 'Krawiec', 'K', 'Bia³ystok', 'Graniczna', 83, null, 'podstawowe', 10);
INSERT INTO Klient VALUES (18, 'Krzysztof', 'Badura', 'M', '£ódŸ', 'Piotrkowska', 52, 6, 'œrednie', 5);
INSERT INTO Klient VALUES (19, 'Wojciech', 'Grzegorzak', 'M', 'Przasnysz', 'Wiejska', 99, 2, 'wy¿sze', 7);
INSERT INTO Klient VALUES (20, 'Micha³', 'Kupiec', 'M', 'Wroc³aw', 'Rynkowa', 67, null, 'œrednie', 1);

INSERT INTO Makler VALUES (1, 'Kazimierz', 'Tomkowski', 'M', 'Katowice', 'Górnicza', 5, 3, 12);
INSERT INTO Makler VALUES (2, 'Zbigniew', 'M³yn', 'M', 'Bydgoszcz', 'G³ówna', 15, 2, 2);
INSERT INTO Makler VALUES (3, 'Andrzej', 'Halicki', 'M', 'Gdañsk', 'Nadmorska', 45, 8, 11);
INSERT INTO Makler VALUES (4, 'Malwina', 'Puszczalska', 'K', 'Miko³ajki', 'Jeziorna', 22, null, 14);
INSERT INTO Makler VALUES (5, '¯aneta', 'Zegarmistrz', 'K', 'Szczecin', 'Stoczniowa', 87, null, 16);
INSERT INTO Makler VALUES (6, 'Tomasz', 'Kosiñski', 'M', 'P³oñsk', 'Kolorowa', 46, null, 7);
INSERT INTO Makler VALUES (7, 'Piotr', 'R¹czka', 'M', '¯yrardów', 'Bliska', 2, null, 7);
INSERT INTO Makler VALUES (8, 'Pawe³', 'Elektryk', 'M', 'E³k', 'Muzyczna', 21, 7, 14);
INSERT INTO Makler VALUES (9, 'Mieczys³aw', 'Skoczyñski', 'M', 'Olsztyn', 'Sportowa', 11, 11, 14);
INSERT INTO Makler VALUES (10, 'Krzysztof', 'Rzepa', 'M', '¯ory', 'Owocowa', 8, 23, 12);

INSERT INTO SektorSpolka VALUES (1, 'finanse');
INSERT INTO SektorSpolka VALUES (2, 'farmacja');
INSERT INTO SektorSpolka VALUES (3, 'handel');
INSERT INTO SektorSpolka VALUES (4, 'przemys³');
INSERT INTO SektorSpolka VALUES (5, 'telekomunikacja');
INSERT INTO SektorSpolka VALUES (6, 'wydobywczy');
INSERT INTO SektorSpolka VALUES (7, 'energetyka');
INSERT INTO SektorSpolka VALUES (8, 'us³ugi');
INSERT INTO SektorSpolka VALUES (9, 'budownictwo');
INSERT INTO SektorSpolka VALUES (10, 'IT');

INSERT INTO Spolka VALUES (1, 'BudMar', 'BMR', 24.50, 'Koziarski', 'Poznañ', 1990, 1999, 9);
INSERT INTO Spolka VALUES (2, 'HandlujMy', 'HDM', 6.95, 'Mazowiecki', 'Kraków', 1988, 2001, 3);
INSERT INTO Spolka VALUES (3, 'TelTom', 'TTM', 74.15, 'Tomaszewski', 'Katowice', 2000, 2008, 5);
INSERT INTO Spolka VALUES (4, 'CashMac', 'CMC', 34.68, 'Maækowiak', 'Bielsko-Bia³a', 2005, 2010, 1);
INSERT INTO Spolka VALUES (5, 'K³osFarm', 'KSF', 44.00, 'K³os', 'Warszawa', 1999, 2004, 2);
INSERT INTO Spolka VALUES (6, 'Przemol', 'PZO', 16.59, 'Olsztyñski', 'Opoczno', 2008, 2011, 4);
INSERT INTO Spolka VALUES (7, 'Wêglowiec', 'WGL', 8.25, 'Makowiecki', 'Otwock', 1996, 2002, 6);
INSERT INTO Spolka VALUES (8, 'EnerB', 'EEB', 34.92, 'Budzyñska', 'P³ock', 2003, 2009, 7);
INSERT INTO Spolka VALUES (9, 'P.H.U. Strza³a', 'STA', 66.70, 'Strza³a', 'Gdynia', 1992, 1998, 8);
INSERT INTO Spolka VALUES (10, 'MielSoft', 'MIS', 22.61, 'Mielcarz', 'Lublin', 1997, 2005, 10);
INSERT INTO Spolka VALUES (11, 'Januszpol', 'JNS', 5.20, 'Januszewicz', 'Grudzi¹dz', 2000, 2012, 1);
INSERT INTO Spolka VALUES (12, 'Cebul-Trans', 'CBT', 35.61, 'Cebula', 'Grodzisk Mazowiecki', 2002, 2006, 8);
INSERT INTO Spolka VALUES (13, 'MatiSoft', 'MTS', 24.99, 'Borek', 'Rzeszów', 2007, 2013, 10);
INSERT INTO Spolka VALUES (14, 'MarekBUD', 'MBD', 11.43, 'Mareczek', 'Mory', 2010, 2012, 9);
INSERT INTO Spolka VALUES (15, 'Energetika', 'ENE', 2.59, 'Malarz', 'Seroki-Wieœ', 1994, 1997, 7);

create or replace PACKAGE pkg_projekt_gielda IS
  FUNCTION losuj(dolnaGranica NUMERIC, gornaGranica NUMERIC) RETURN NUMERIC;
  FUNCTION gen_nr_zlec RETURN NUMERIC;
  FUNCTION los_id_klienta RETURN NUMERIC;
  FUNCTION los_id_spolki RETURN NUMERIC;
  FUNCTION los_id_maklera RETURN NUMERIC;
  FUNCTION los_liczbe_pozycji RETURN NUMERIC;
  FUNCTION los_typ_zlecenia RETURN VARCHAR2;
  FUNCTION los_ilosc_akcji RETURN NUMERIC;
  PROCEDURE generowanie_transakcji(data_fakt DATE DEFAULT SYSDATE);
  PROCEDURE gen_wiele_faktur(data_pocz DATE, data_konc DATE);
END;
/
create or replace PACKAGE BODY PKG_PROJEKT_GIELDA AS

  FUNCTION losuj(dolnaGranica NUMERIC, gornaGranica NUMERIC) RETURN NUMERIC AS
    wynikLosowania NUMERIC DEFAULT 0;
    BEGIN 
      wynikLosowania := DBMS_RANDOM.VALUE(dolnaGranica, gornaGranica);
    RETURN wynikLosowania;
  END losuj;
  
  FUNCTION gen_nr_zlec RETURN NUMERIC AS
    ostatniIDZlecenia NUMERIC; 
    liczbaIstniejacychRekordow NUMERIC;
    BEGIN
      SELECT MAX(IDZlecenia) INTO ostatniIDZlecenia 
      FROM Zlecenie; 
      SELECT COUNT(IDZlecenia) INTO liczbaIstniejacychRekordow 
      FROM Zlecenie; 
  
      IF liczbaIstniejacychRekordow = 0 THEN 
        ostatniIDZlecenia := 0;
      END IF;
  
      ostatniIDZlecenia := ostatniIDZlecenia + 1;
  
      RETURN ostatniIDZlecenia;
  END gen_nr_zlec;

  FUNCTION los_id_klienta RETURN NUMERIC AS
    CURSOR cur_id_klientow IS SELECT IDKlienta FROM klient;
    TYPE klienci IS VARRAY(50) OF NUMERIC; 
    id_klientow klienci := klienci();
    wszyscyKlienci NUMERIC;
    indeksTablicy NUMERIC DEFAULT 1;
    wylosowanyIndeks NUMERIC;
    BEGIN
      SELECT COUNT(*) INTO wszyscyKlienci FROM klient;
  
      FOR i IN 1..wszyscyKlienci LOOP 
        id_klientow.EXTEND;
      END LOOP;
  
      FOR i IN cur_id_klientow LOOP
        id_klientow(indeksTablicy) := i.IDKlienta;
        indeksTablicy := indeksTablicy + 1;
      END LOOP;
  
      wylosowanyIndeks := losuj(1, id_klientow.COUNT);
  
      RETURN id_klientow(wylosowanyIndeks);
  END los_id_klienta;
  
  FUNCTION los_id_spolki RETURN NUMERIC AS
    CURSOR cur_id_spolek IS SELECT IDSpolki FROM spolka;
    TYPE spolki IS VARRAY(50) OF NUMERIC; 
    id_spolek spolki := spolki();
    wszystkieSpolki NUMERIC;
    indeksTablicy NUMERIC DEFAULT 1;
    wylosowanyIndeks NUMERIC;
    BEGIN
      SELECT COUNT(*) INTO wszystkieSpolki FROM spolka;
  
      FOR i IN 1..wszystkieSpolki LOOP 
        id_spolek.EXTEND;
      END LOOP;
  
      FOR i IN cur_id_spolek LOOP
        id_spolek(indeksTablicy) := i.IDSpolki;
        indeksTablicy := indeksTablicy + 1;
      END LOOP;
  
      wylosowanyIndeks := losuj(1, id_spolek.COUNT);
  
      RETURN id_spolek(wylosowanyIndeks);
  END los_id_spolki; 
  
  FUNCTION los_id_maklera RETURN NUMERIC AS
    CURSOR cur_id_maklerow IS SELECT IDMaklera FROM makler;
    TYPE maklerzy IS VARRAY(50) OF NUMERIC; 
    id_maklerow maklerzy := maklerzy();
    wszyscyMaklerzy NUMERIC;
    indeksTablicy NUMERIC DEFAULT 1;
    wylosowanyIndeks NUMERIC;
    BEGIN
      SELECT COUNT(*) INTO wszyscyMaklerzy FROM makler;
  
      FOR i IN 1..wszyscyMaklerzy LOOP 
        id_maklerow.EXTEND;
      END LOOP;
  
      FOR i IN cur_id_maklerow LOOP
        id_maklerow(indeksTablicy) := i.IDMaklera;
        indeksTablicy := indeksTablicy + 1;
      END LOOP;
  
      wylosowanyIndeks := losuj(1, id_maklerow.COUNT);
  
    RETURN id_maklerow(wylosowanyIndeks);
  END los_id_maklera;
  
  FUNCTION los_liczbe_pozycji RETURN NUMERIC AS
    BEGIN
    RETURN losuj(1, 10);
  END los_liczbe_pozycji;
  
  FUNCTION los_typ_zlecenia RETURN VARCHAR2 AS
    wynikLosowania NUMERIC;
    BEGIN
      wynikLosowania := losuj(0, 1);
  
      IF wynikLosowania = 1 THEN 
        RETURN 'kupno';
      ELSE RETURN 'sprzeda¿';
      END IF;
  END los_typ_zlecenia;
  
  FUNCTION los_ilosc_akcji RETURN NUMERIC AS
    BEGIN
      RETURN losuj(1, 250);
  END los_ilosc_akcji; 
  
  PROCEDURE generowanie_transakcji(data_fakt DATE DEFAULT SYSDATE) AS
    nr_zlec NUMERIC;
    iterator NUMERIC;
    liczba_pozycji NUMERIC;
    BEGIN 
    nr_zlec := gen_nr_zlec;
    iterator := 1;
    liczba_pozycji := los_liczbe_pozycji;
  
    INSERT INTO Zlecenie 
    VALUES 
    (
      nr_zlec,
      los_id_klienta(),
      los_id_maklera(),
      data_fakt,
      0
    );
  
    WHILE (iterator <= liczba_pozycji) LOOP 
      INSERT INTO ZlecenieDetale
      VALUES 
      (
        nr_zlec,
        iterator, 
        los_id_spolki,
        los_typ_zlecenia, 
        los_ilosc_akcji, 
        0
      );
      iterator := iterator + 1;
    END LOOP;
  END generowanie_transakcji;

  PROCEDURE gen_wiele_faktur(data_pocz DATE, data_konc DATE) AS
    liczba_faktur NUMERIC;
    iterator NUMERIC;
    data_poczatku DATE;
    BEGIN
    data_poczatku := data_pocz;
    WHILE (data_poczatku <= data_konc) LOOP
      iterator := 1;
      liczba_faktur := losuj(5, 15);
      WHILE iterator <= liczba_faktur LOOP
        generowanie_transakcji(data_poczatku);
        iterator := iterator + 1;
      END LOOP;
      data_poczatku := data_poczatku + 1;
    END LOOP;
  END gen_wiele_faktur;

END PKG_PROJEKT_GIELDA;
/
CREATE OR REPLACE TRIGGER ins_zlecenie_detale 
BEFORE INSERT ON ZlecenieDetale 
FOR EACH ROW 
BEGIN 
  SELECT WartoscNotowania INTO :NEW.CenaZakupu 
  FROM Spolka 
  WHERE IDSpolki = :NEW.IDSpolki;
  
  UPDATE Zlecenie 
  SET WartoscZlecenia = WartoscZlecenia + :NEW.IloscAkcji * :NEW.CenaZakupu
  WHERE IDZlecenia = :NEW.IDZlecenia;
END;
/
CREATE OR REPLACE VIEW ranking_maklerzy_latest AS
	SELECT Imie || ' ' || Nazwisko AS "Imie i nazwisko", 
		   Miasto AS "Miasto", 
		   SUM(WartoscZlecenia) AS "Wartosc zlecenia", 
		   COUNT(IDZlecenia) AS "Ilosc zlecen", 
		   ROUND(AVG(WartoscZlecenia), 2) AS "Srednia wartosc zlecenia"
	FROM Makler 
	JOIN Zlecenie
		ON Makler.IDMaklera = Zlecenie.IDMaklera 
	WHERE DataZlecenia >= (SYSDATE - 30) 
	AND DataZlecenia <= SYSDATE
	GROUP BY Imie, Nazwisko, Miasto
	ORDER BY 3 DESC;
/
CREATE OR REPLACE VIEW ranking_klienci_latest AS
	SELECT Imie || ' ' || Nazwisko AS "Imie i Nazwisko", 
		   Miasto AS "Miasto", 
		   SUM(WartoscZlecenia) AS "Wartosc zlecen", 
		   COUNT(IDZlecenia) AS "Liczba zlecen",
		   ROUND(AVG(WartoscZlecenia), 2) "Srednia wartosc zlecenia"
	FROM Klient 
	JOIN Zlecenie 
		ON Klient.IDKlienta = Zlecenie.IDKlienta
	WHERE DataZlecenia >= (SYSDATE - 30) 
	AND DataZlecenia <= SYSDATE
	GROUP BY Imie, Nazwisko, Miasto
	ORDER BY "Wartosc zlecen" DESC;
/
CREATE OR REPLACE VIEW ranking_wojewodztwa_latest AS
	SELECT NazwaWojewodztwa AS "Wojewodztwo", 
		   COUNT(Zlecenie.IDKlienta) AS "Liczba zlecen" 
	FROM (Zlecenie 
	JOIN Klient 
		ON Zlecenie.IDKlienta = Klient.IDKlienta) 
	JOIN Wojewodztwo 
		ON Wojewodztwo.IDWojewodztwa = Klient.IDWojewodztwa 
	WHERE DataZlecenia >= (SYSDATE - 30) 
	AND DataZlecenia <= SYSDATE
	GROUP BY NazwaWojewodztwa 
	ORDER BY "Liczba zlecen" DESC;
/
CREATE OR REPLACE VIEW ranking_wyksztalcenie_latest AS
	SELECT Wyksztalcenie, 
		   COUNT(Zlecenie.IDKlienta) AS "Liczba zlecen" 
	FROM Zlecenie 
	JOIN Klient
		ON Zlecenie.IDKlienta = Klient.IDKlienta 
	WHERE DataZlecenia >= (SYSDATE - 30) 
	AND DataZlecenia <= SYSDATE 
	GROUP BY Wyksztalcenie
	ORDER BY "Liczba zlecen" DESC;
/
CREATE OR REPLACE VIEW ranking_spolki_latest AS
	SELECT NazwaSpolki AS "Nazwa spolki", 
		   NazwaIndeksu AS "Nazwa indeksu",
		   OpisSektora AS "Sektor",
		   EXTRACT(YEAR FROM SYSDATE) - RokDebiutu AS "Staz gieldowy",
		   WartoscNotowania AS "Wartosc notowania",
		   TypZlecenia AS "Typ zlecenia",
		   COUNT(ZlecenieDetale.IDSpolki) AS "Liczba wystapien" 
	FROM Spolka
	JOIN ZlecenieDetale
		ON Spolka.IDSpolki = ZlecenieDetale.IDSpolki 
	JOIN SektorSpolka
		ON Spolka.IDSektora = SektorSpolka.IDSektora
	JOIN Zlecenie 
		ON Zlecenie.IDZlecenia = ZlecenieDetale.IDZlecenia
	WHERE DataZlecenia >= (SYSDATE - 30) 
	AND DataZlecenia <= SYSDATE
	GROUP BY NazwaSpolki, NazwaIndeksu, OpisSektora, EXTRACT(YEAR FROM SYSDATE) - RokDebiutu, WartoscNotowania, TypZlecenia
	ORDER BY "Liczba wystapien" DESC;
/
CREATE OR REPLACE VIEW ranking_sektorow_latest AS
	SELECT OpisSektora AS "Opis sektora", 
		   TypZlecenia AS "Typ zlecenia", 
		   COUNT(ZlecenieDetale.IDSpolki) AS "Liczba wystapien"
	FROM Spolka 
	JOIN SektorSpolka 
		ON Spolka.IDSektora = SektorSpolka.IDSektora
	JOIN ZlecenieDetale 
		ON Spolka.IDSpolki = ZlecenieDetale.IDSpolki
	JOIN Zlecenie 
		ON ZlecenieDetale.IDZlecenia = Zlecenie.IDZlecenia 
	WHERE DataZlecenia >= (SYSDATE - 30) 
	AND DataZlecenia <= SYSDATE
	GROUP BY OpisSektora, TypZlecenia
	ORDER BY "Liczba wystapien" DESC;
/
CREATE MATERIALIZED VIEW ranking_maklerzy AS
	SELECT Imie || ' ' || Nazwisko AS "Imie i Nazwisko", 
		   Miasto AS "Miasto", 
		   SUM(WartoscZlecenia) AS "Wartosc zlecen", 
		   COUNT(IDZlecenia) AS "Liczba zlecen", 
		   ROUND(AVG(WartoscZlecenia), 2) AS "Srednia wartosc zlecenia" 
	FROM Makler 
	JOIN Zlecenie
		ON Makler.IDMaklera = Zlecenie.IDMaklera 
	GROUP BY Imie, Nazwisko, Miasto
	ORDER BY "Wartosc zlecen" DESC;
/
CREATE MATERIALIZED VIEW ranking_klienci AS
	SELECT Imie || ' ' || Nazwisko AS "Imie i Nazwisko", 
		   Miasto AS "Miasto", 
		   SUM(WartoscZlecenia) AS "Wartosc zlecen", 
		   COUNT(IDZlecenia) AS "Liczba zlecen",
		   ROUND(AVG(WartoscZlecenia), 2) AS "Srednia wartosc zlecenia"
	FROM Klient 
	JOIN Zlecenie 
		ON Klient.IDKlienta = Zlecenie.IDKlienta
	GROUP BY Imie, Nazwisko, Miasto
	ORDER BY "Wartosc zlecen" DESC;
/
CREATE MATERIALIZED VIEW ranking_wojewodztwa AS
	SELECT NazwaWojewodztwa AS "Wojewodztwo", 
		   COUNT(Zlecenie.IDKlienta) AS "Liczba zlecen" 
	FROM (Zlecenie 
	JOIN Klient 
		ON Zlecenie.IDKlienta = Klient.IDKlienta) 
	JOIN Wojewodztwo 
		ON Wojewodztwo.IDWojewodztwa = Klient.IDWojewodztwa 
	GROUP BY NazwaWojewodztwa 
	ORDER BY "Liczba zlecen" DESC;
/
CREATE MATERIALIZED VIEW ranking_wyksztalcenie AS
	SELECT Wyksztalcenie AS "Wyksztalcenie", 
		   COUNT(Zlecenie.IDKlienta) AS "Liczba zlecen" 
	FROM Zlecenie 
	JOIN Klient
		ON Zlecenie.IDKlienta = Klient.IDKlienta 
	GROUP BY Wyksztalcenie
	ORDER BY "Liczba zlecen" DESC;
/
CREATE MATERIALIZED VIEW ranking_spolki AS
	SELECT NazwaSpolki AS "Nazwa spolki", 
		   NazwaIndeksu AS "Nazwa indeksu",
		   OpisSektora AS "Sektor",
		   WartoscNotowania AS "Wartosc notowania",
		   TypZlecenia AS "Typ zlecenia",
		   COUNT(ZlecenieDetale.IDSpolki) AS "Liczba wystapien" 
	FROM Spolka
	JOIN ZlecenieDetale
		ON Spolka.IDSpolki = ZlecenieDetale.IDSpolki 
	JOIN SektorSpolka
		ON Spolka.IDSektora = SektorSpolka.IDSektora
	GROUP BY NazwaSpolki, NazwaIndeksu, OpisSektora, WartoscNotowania, TypZlecenia
	ORDER BY "Liczba wystapien" DESC;
/
CREATE MATERIALIZED VIEW ranking_sektorow AS
	SELECT OpisSektora AS "Opis sektora", 
		   TypZlecenia AS "Typ zlecenia", 
		   COUNT(ZlecenieDetale.IDSpolki) AS "Liczba wystapien"
	FROM Spolka 
	JOIN SektorSpolka 
		ON Spolka.IDSektora = SektorSpolka.IDSektora
	JOIN ZlecenieDetale 
		ON Spolka.IDSpolki = ZlecenieDetale.IDSpolki 
	GROUP BY OpisSektora, TypZlecenia
	ORDER BY "Liczba wystapien" DESC;
/
CREATE MATERIALIZED VIEW podsumowanie_zbiorcze AS
	SELECT NazwaSpolki, NazwaIndeksu, 
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 1 THEN 1 ELSE 0 END) AS "Styczeñ", 
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 2 THEN 1 ELSE 0 END) AS "Luty",
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 3 THEN 1 ELSE 0 END) AS "Marzec",
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 4 THEN 1 ELSE 0 END) AS "Kwiecieñ",
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 5 THEN 1 ELSE 0 END) AS "Maj",
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 6 THEN 1 ELSE 0 END) AS "Czerwiec", 
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 7 THEN 1 ELSE 0 END) AS "Lipiec",
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 8 THEN 1 ELSE 0 END) AS "Sierpieñ", 
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 9 THEN 1 ELSE 0 END) AS "Wrzesieñ",
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 10 THEN 1 ELSE 0 END) AS "PaŸdziernik",
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 11 THEN 1 ELSE 0 END) AS "Listopad",
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 12 THEN 1 ELSE 0 END) AS "Grudzieñ",
		   COUNT(*) AS "£¹cznie" 
	FROM Spolka 
	JOIN ZlecenieDetale 
		ON Spolka.IDSpolki = ZlecenieDetale.IDSpolki 
	JOIN Zlecenie 
		ON ZlecenieDetale.IDZlecenia = Zlecenie.IDZlecenia 
	GROUP BY NazwaSpolki, NazwaIndeksu

	UNION 

	SELECT null, 'Razem', 
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 1 THEN 1 ELSE 0 END), 
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 2 THEN 1 ELSE 0 END),
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 3 THEN 1 ELSE 0 END),
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 4 THEN 1 ELSE 0 END),
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 5 THEN 1 ELSE 0 END),
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 6 THEN 1 ELSE 0 END), 
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 7 THEN 1 ELSE 0 END),
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 8 THEN 1 ELSE 0 END), 
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 9 THEN 1 ELSE 0 END),
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 10 THEN 1 ELSE 0 END),
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 11 THEN 1 ELSE 0 END),
		   SUM(CASE EXTRACT(MONTH FROM DataZlecenia) WHEN 12 THEN 1 ELSE 0 END),
		   COUNT(*)
	FROM Spolka 
	JOIN ZlecenieDetale 
		ON Spolka.IDSpolki = ZlecenieDetale.IDSpolki 
	JOIN Zlecenie 
		ON ZlecenieDetale.IDZlecenia = Zlecenie.IDZlecenia;

