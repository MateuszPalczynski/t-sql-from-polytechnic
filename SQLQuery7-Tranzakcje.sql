USE BIBLIOTEKA

--TRANZAKCJE

--zad1
--Przygotowaæ transakcjê, która
--dodaje nowego czytelnika
--przenosi wszystkie aktywne wypo¿yczenia innego u¿ytkownia na nowego u¿ytkownika
--kasuje tego innego u¿ytkownika

SELECT * FROM Wypozyczenia WHERE (id_czytelnik = 604)
SELECT * FROM Czytelnicy


BEGIN TRAN

INSERT INTO Czytelnicy(id_czytelnik, login, haslo, email, telefon, data_urodzenia) 
VALUES ((SELECT MAX(id_czytelnik+1) FROM Czytelnicy), 'MatSKI', '12345', 'b.d.', 'b.d.', '2000-04-28')

DECLARE @new_user_id INT= (SELECT MAX(id_czytelnik) FROM Czytelnicy);

UPDATE Wypozyczenia
SET id_czytelnik = @new_user_id
WHERE data_oddania IS NULL AND id_czytelnik = 400;

DELETE FROM Czytelnicy WHERE id_czytelnik = 400
COMMIT TRAN

--zad2
--Przygotowaæ transakcjê, która tworzy tabelê z danymi czytelników którzy 
--wypo¿yczyli dowoln¹ ksi¹¿kê ustalonego autora. Autora nale¿y traktowaæ jako cenzurowanego. 
--Jego dane osobowe w bazie nale¿y usun¹æ oraz skasowaæ dane opisuj¹ce jego ksia¿ki. 
--Nie nale¿y jednak kasowaæ wypo¿yczeñ, bo czêœæ jego ksi¹¿ek mo¿e powróciæ do biblioteki.

--zmieniæ usuwanie na wstawianie nulli
SELECT * FROM Czytelnicy_Censored_Author
SELECT * FROM Autorzy WHERE nazwisko = 'PAWUDAKRZSKI';
SELECT * FROM Ksiazki WHERE id_autor IN (SELECT id_autor FROM Autorzy WHERE nazwisko = 'PAWUDAKRZSKI');


BEGIN TRANSACTION;
DROP TABLE IF EXISTS Czytelnicy_Censored_Author 
-- Tworzenie tabeli tymczasowej z danymi czytelników, którzy wypo¿yczyli ksi¹¿ki ustalonego autora
DECLARE @author_name NVARCHAR(30) = 'PAWUDAKRZSKI'

SELECT Czytelnicy.*		--wszystkie kolumny
INTO Czytelnicy_Censored_Author
FROM Czytelnicy
INNER JOIN Wypozyczenia ON Czytelnicy.id_czytelnik = Wypozyczenia.id_czytelnik
INNER JOIN Ksiazki ON Wypozyczenia.id_ksiazka = Ksiazki.id_ksiazka
INNER JOIN Autorzy ON Ksiazki.id_autor = Autorzy.id_autor
WHERE Autorzy.nazwisko = @author_name;

-- Usuniêcie danych osobowych ustalonego autora z tabeli Autorzy
DELETE FROM Autorzy
WHERE nazwisko = @author_name;

-- Kasowanie danych opisuj¹cych ksi¹¿ki ustalonego autora z tabeli Ksiazki
DELETE FROM Ksiazki
WHERE id_autor IN (SELECT id_autor FROM Autorzy WHERE nazwisko = @author_name);

COMMIT TRAN;


--zad3
--Zmodyfikowaæ bazê danych tak aby by³a mo¿liwoœæ przypisania do ksi¹¿ki wiêcej ni¿ jednego autora

CREATE TABLE Autorzy_Ksiazki(
    id INT PRIMARY KEY IDENTITY(1,1),
    id_ksiazka INT NOT NULL,
    id_autor INT NOT NULL
);

--INSERT INTO Autorzy_Ksiazki(id_ksiazka, id_autor)
 --   SELECT id_ksiazka, id_autor FROM Ksiazki;

 