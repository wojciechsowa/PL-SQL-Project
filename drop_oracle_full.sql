/*-----DEINSTALACJA_ORACLE-----*/
ALTER TABLE Klient DROP CONSTRAINT Klient_Wojewodztwo_FK;

ALTER TABLE Makler DROP CONSTRAINT Makler_Wojewodztwo_FK;

ALTER TABLE Spolka DROP CONSTRAINT Spolka_SektorSpolka_FK;

ALTER TABLE ZlecenieDetale DROP CONSTRAINT ZlecenieDetale_Spolka_FK;

ALTER TABLE ZlecenieDetale DROP CONSTRAINT ZlecenieDetale_Zlecenie_FK;

ALTER TABLE Zlecenie DROP CONSTRAINT Zlecenie_Klient_FK;

ALTER TABLE Zlecenie DROP CONSTRAINT Zlecenie_Makler_FK;

DROP TABLE Wojewodztwo;
DROP TABLE SektorSpolka;
DROP TABLE Spolka;
DROP TABLE Makler;
DROP TABLE Klient;
DROP TABLE Zlecenie;
DROP TABLE ZlecenieDetale;

DROP PACKAGE pkg_projekt_gielda; 

DROP VIEW ranking_maklerzy_latest;
DROP VIEW ranking_klienci_latest;
DROP VIEW ranking_wojewodztwa_latest;
DROP VIEW ranking_wyksztalcenie_latest;
DROP VIEW ranking_spolki_latest;
DROP VIEW ranking_sektorow_latest;


DROP MATERIALIZED VIEW ranking_maklerzy;
DROP MATERIALIZED VIEW ranking_klienci;
DROP MATERIALIZED VIEW ranking_wojewodztwa;
DROP MATERIALIZED VIEW ranking_wyksztalcenie;
DROP MATERIALIZED VIEW ranking_spolki;
DROP MATERIALIZED VIEW ranking_sektorow;
DROP MATERIALIZED VIEW podsumowanie_zbiorcze;
