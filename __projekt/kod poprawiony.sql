CREATE TABLE IF NOT EXISTS `Pracownicy` (
  `idPracownicy` INT NOT NULL AUTO_INCREMENT,
  `Imie` VARCHAR(45) NULL,
  `Nazwisko` VARCHAR(45) NULL,
  `Adres` VARCHAR(45) NULL,
  `PESEL` INT(11) NULL,
  `idFunkcja` INT(1) NULL,
  PRIMARY KEY (`idPracownicy`));
  
  CREATE TABLE IF NOT EXISTS `Funkcja` (
  `Nazwa` VARCHAR(45) NULL,
  `idFunkcji` VARCHAR(45) NULL,
  INDEX `fk_Funkcja_Pracownicy1_idx` (`idFunkcji` ASC) VISIBLE,
  CONSTRAINT `fk_Funkcja_Pracownicy1`
    FOREIGN KEY (`idFunkcji`)
    REFERENCES `Pracownicy` (`idFunkcja`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
    CREATE TABLE IF NOT EXISTS `Wierzytelnosci` (
  `idSprawy` INT NOT NULL AUTO_INCREMENT,
  `Nazwa_wierzytelnosci` VARCHAR(45) NULL,
  `Sprzedawca` VARCHAR(45) NULL,
  `Dluznik_nazwisko` VARCHAR(45) NULL,
  `Dłużnik_imie` VARCHAR(45) NULL,
  `PESEL_dłuznika` VARCHAR(45) NULL,
  `Adres_dłuznika` VARCHAR(45) NULL,
  `Nr_kontaktowy` INT(11) NULL,
  `adres_email` VARCHAR(45) NULL,
  `NIP` INT NULL,
  `REGON` INT NULL,
  `Wartość` INT NULL,
  `Wartość_początkowa` INT NULL,
  `1wezwanie` DATE NULL,
  `2wezwanie` DATE NULL,
  `monit` INT(1) ZEROFILL NULL,
  `data_pozyskania` DATE NULL,
  PRIMARY KEY (`idSprawy`));
  
  CREATE TABLE IF NOT EXISTS `Agenci` (
  `idAgent` INT NOT NULL,
  `Wierzytelnosci_idSprawy` INT NOT NULL,
  INDEX `fk_Agenci_Pracownicy1_idx` (`idAgent` ASC) VISIBLE,
  INDEX `fk_Agenci_Wierzytelnosci1_idx` (`Wierzytelnosci_idSprawy` ASC) VISIBLE,
  CONSTRAINT `fk_Agenci_Pracownicy1`
    FOREIGN KEY (`idAgent`)
    REFERENCES `Pracownicy` (`idPracownicy`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Agenci_Wierzytelnosci1`
    FOREIGN KEY (`Wierzytelnosci_idSprawy`)
    REFERENCES `Wierzytelnosci` (`idSprawy`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
    CREATE TABLE IF NOT EXISTS `do_sadu` (
  `idspraw` INT NOT NULL AUTO_INCREMENT,
  `reprezentant_firmy` INT NULL,
  `data_rozprawy` DATE NULL,
  PRIMARY KEY (`idspraw`),
  INDEX `fk_do_sadu_Agenci1_idx` (`reprezentant_firmy` ASC) VISIBLE,
  CONSTRAINT `fk_do_sadu_Wierzytelnosci1`
    FOREIGN KEY (`idspraw`)
    REFERENCES `Wierzytelnosci` (`idSprawy`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_do_sadu_Agenci1`
    FOREIGN KEY (`reprezentant_firmy`)
    REFERENCES `Agenci` (`idAgent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
INSERT INTO `Funkcja` (`Nazwa`, `idFunkcji`) VALUES ('agent', '1');
INSERT INTO `Funkcja` (`Nazwa`, `idFunkcji`) VALUES ('wozny', '2');
INSERT INTO `Funkcja` (`Nazwa`, `idFunkcji`) VALUES ('prezes', '3');
INSERT INTO `Funkcja` (`Nazwa`, `idFunkcji`) VALUES ('stazysta', '4');
INSERT INTO `Funkcja` (`Nazwa`, `idFunkcji`) VALUES ('recepcjonista', '5');
INSERT INTO `Funkcja` (`Nazwa`, `idFunkcji`) VALUES ('sekretarka', '6');


INSERT INTO `Wierzytelnosci` (`idSprawy`, `Nazwa_wierzytelnosci`, `Sprzedawca`, `Dluznik_nazwisko`, `Dłużnik_imie`, `PESEL_dłuznika`, `Adres_dłuznika`, `Nr_kontaktowy`, `adres_email`, `NIP`, `REGON`, `Wartość`, `Wartość_początkowa`, `1wezwanie`, `2wezwanie`, `monit`, `data_pozyskania`) VALUES (1, 'Budex', 'P4 SP Z.O.O.', 'Ogórek', 'Jarosław', '9701020930', 'Wilcza 54   01-100 Warszawa', 48793420420, 'ogorek.jaroslaw@gmail.com', 1010101010, 123456789, 4000, 3700, '2020-02-14', NULL, NULL, '2020-02-01');
INSERT INTO `Agenci` (`idAgent`, `Wierzytelnosci_idSprawy`) VALUES (1, 1);
INSERT INTO `do_sadu` (`idspraw`, `reprezentant_firmy`, `data_rozprawy`) VALUES (1, 1, NULL);

delimiter $

CREATE PROCEDURE ListaPracownikow (IN idFunkcja int)
BEGIN
  SELECT * FROM PRACOWNICY 
  WHERE idFunkcja = idFunkcji;
  END $
DELIMITER ;



DELIMITER $
CREATE FUNCTION sprawy_sadowe()
RETURNS integer
BEGIN
DECLARE ilosc INT;
select count(*) into @ilosc from wierzytelnosci where monit = "1";
return @ilosc;
END $
DELIMITER ;



DELIMITER $$
CREATE TRIGGER błędny_rekord 
BEFORE INSERT ON wierzytelnosci
FOR EACH ROW 
BEGIN   
IF monit > 0 
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MONIT NIE JEST WYSYŁANY PRZED WEZWANIAMI'; 
END IF; 
END
$$



DELIMITER $$
CREATE TRIGGER odpowiednia_data 
BEFORE INSERT ON wierzytelnosci
FOR EACH ROW 
BEGIN   
IF 1wezwanie > 2wezwanie 
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BŁĄD-PROSZĘ POPRAWIĆ DATY'; 
END IF; 
END
$$
