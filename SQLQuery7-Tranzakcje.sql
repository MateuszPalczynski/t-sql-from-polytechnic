USE BIBLIOTEKA

--TRANZAKCJE

--zad1
--Przygotowa� transakcj�, kt�ra
--dodaje nowego czytelnika
--przenosi wszystkie aktywne wypo�yczenia innego u�ytkownia na nowego u�ytkownika
--kasuje tego innego u�ytkownika

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
--Przygotowa� transakcj�, kt�ra tworzy tabel� z danymi czytelnik�w kt�rzy 
--wypo�yczyli dowoln� ksi��k� ustalonego autora. Autora nale�y traktowa� jako cenzurowanego. 
--Jego dane osobowe w bazie nale�y usun�� oraz skasowa� dane opisuj�ce jego ksia�ki. 
--Nie nale�y jednak kasowa� wypo�ycze�, bo cz�� jego ksi��ek mo�e powr�ci� do biblioteki.

--zmieni� usuwanie na wstawianie nulli
SELECT * FROM Czytelnicy_Censored_Author
SELECT * FROM Autorzy WHERE nazwisko = 'PAWUDAKRZSKI';
SELECT * FROM Ksiazki WHERE id_autor IN (SELECT id_autor FROM Autorzy WHERE nazwisko = 'PAWUDAKRZSKI');


BEGIN TRANSACTION;
DROP TABLE IF EXISTS Czytelnicy_Censored_Author 
-- Tworzenie tabeli tymczasowej z danymi czytelnik�w, kt�rzy wypo�yczyli ksi��ki ustalonego autora
DECLARE @author_name NVARCHAR(30) = 'PAWUDAKRZSKI'

SELECT Czytelnicy.*		--wszystkie kolumny
INTO Czytelnicy_Censored_Author
FROM Czytelnicy
INNER JOIN Wypozyczenia ON Czytelnicy.id_czytelnik = Wypozyczenia.id_czytelnik
INNER JOIN Ksiazki ON Wypozyczenia.id_ksiazka = Ksiazki.id_ksiazka
INNER JOIN Autorzy ON Ksiazki.id_autor = Autorzy.id_autor
WHERE Autorzy.nazwisko = @author_name;

-- Usuni�cie danych osobowych ustalonego autora z tabeli Autorzy
DELETE FROM Autorzy
WHERE nazwisko = @author_name;

-- Kasowanie danych opisuj�cych ksi��ki ustalonego autora z tabeli Ksiazki
DELETE FROM Ksiazki
WHERE id_autor IN (SELECT id_autor FROM Autorzy WHERE nazwisko = @author_name);

COMMIT TRAN;


--zad3
--Zmodyfikowa� baz� danych tak aby by�a mo�liwo�� przypisania do ksi��ki wi�cej ni� jednego autora

CREATE TABLE Autorzy_Ksiazki(
    id INT PRIMARY KEY IDENTITY(1,1),
    id_ksiazka INT NOT NULL,
    id_autor INT NOT NULL
);

--INSERT INTO Autorzy_Ksiazki(id_ksiazka, id_autor)
 --   SELECT id_ksiazka, id_autor FROM Ksiazki;

 