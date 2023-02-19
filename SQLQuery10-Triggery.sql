USE BIBLIOTEKA

--W bazie Biblioteka doda� trigger, kt�ry przy usuwaniu rekordu danego pracownika przenosi
--wszystkie wypo�yczenia z nim zwi�zane na pracownika kt�ry zosta� rekord wartownika 
--(czyli pracownika o ustalonej nazwie, kt�ry nie jest zwi�zany z �adn� faktyczn� osob�). 
--Je�li nie ma tego rekordu nale�y go w triggerze uruchomi�.

--CREATE TRIGGER nazwa
--ON [Tabela | Widok] 
--[FOR | AFTER | INSTEAD] [INSERT | UPDATE |  DELETE] 
--AS
--BEGIN
-- kod wyzwalacza
--END
SELECT * FROM Pracownicy
SELECT * FROM Wypozyczenia

DROP TRIGGER pousuwaniu

GO
CREATE TRIGGER pousuwaniu
ON Pracownicy
INSTEAD OF DELETE
AS
BEGIN
declare @id int;
declare @WARTOWNIK int;
SELECT @id=id_pracownik FROM deleted;

	IF NOT EXISTS (SELECT login FROM Pracownicy WHERE login='wartownik') 
		INSERT INTO Pracownicy VALUES ((SELECT MAX(Pracownicy.id_pracownik+1) FROM Pracownicy),'wartownik',123,2)

SELECT @WARTOWNIK=id_pracownik FROM Pracownicy WHERE login = 'wartownik';	

	UPDATE Wypozyczenia SET id_pracownik_wypozyczenie=@WARTOWNIK WHERE id_pracownik_wypozyczenie=@id
	UPDATE Wypozyczenia SET id_pracownik_oddanie=@WARTOWNIK WHERE id_pracownik_oddanie=@id

DELETE FROM Pracownicy WHERE id_pracownik=@id;

END
GO

DELETE from Pracownicy WHERE id_pracownik=29  
SELECT * FROM Pracownicy
SELECT * FROM Wypozyczenia WHERE id_pracownik_oddanie=32



USE hr
go
SELECT * FROM jobs

--zabroni� usuwania jobs
DROP TRIGGER BLOCK_DELETE_ON_JOBS

CREATE TRIGGER BLOCK_DELETE_ON_JOBS
	ON jobs
	INSTEAD OF DELETE 
	AS
	BEGIN
		declare @job_title varchar(40)
		declare @del_counter int
		SELECT @del_counter = COUNT(*) FROM deleted
		SELECT @job_title = job_title FROM deleted
		
		IF @del_counter > 1
			BEGIN 
				SELECT 'Pr�bujesz usun�� wiele rekord�w'
			END
		ELSE
			BEGIN
				SELECT 'Pr�bujesz usun�� jeden element - '+@job_title
			END
	END

DELETE FROM jobs WHERE jobs.job_id=8
DELETE FROM jobs where jobs.job_id IN (1,2,3)


