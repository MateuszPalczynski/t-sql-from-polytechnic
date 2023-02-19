USE BIBLIOTEKA
-- Zadanie 1
-- Przygotowaæ procedurê dodaj¹c¹ now¹ ksi¹¿kê do bazy danych. Niech przyjmuje dane autora, nazwê kategorii, wydawnictwa, tytu³ i rok wydania. 
-- Procedura powinna sprawdziæ czy dana kategoria istnieje, dany autor, dane wydawnictwo.

CREATE PROCEDURE NewBook

	@author_name nvarchar(15) = NULL,
	@author_lastname nvarchar(30) = NULL,
	@category_name nvarchar(46) = NULL,
	@publisher_name nvarchar(30) = NULL,
	@book_title nvarchar(255) = NULL,
	@publishing_year int = NULL

AS

	DECLARE @author_id int;
	DECLARE @author_count int;
	DECLARE @category_id int;
	DECLARE @category_count int;
	DECLARE @publisher_id int;
	DECLARE @publisher_count int;

BEGIN
	
	SELECT @author_count = COUNT(*) FROM Autorzy A WHERE A.imie = @author_name AND A.nazwisko = @author_lastname;
	SELECT @category_count = COUNT(*) FROM Kategorie K WHERE K.nazwa = @category_name;
	SELECT @publisher_count = COUNT(*) FROM Wydawnictwa W WHERE W.nazwa = @publisher_name;

	IF (@author_count = 0)
		BEGIN
			INSERT INTO Autorzy VALUES ((SELECT MAX(id_autor) + 1 FROM Autorzy), @author_name, @author_lastname);
		END
	IF (@category_count = 0)
		BEGIN
			INSERT INTO Kategorie VALUES ((SELECT MAX(id_kategoria) + 1 FROM Kategorie), @category_name);
		END
	IF (@publisher_count = 0)
		BEGIN
			INSERT INTO Wydawnictwa VALUES ((SELECT MAX(id_wydawnictwo) + 1 FROM Wydawnictwa), @publisher_name);
		END

	SELECT @author_id = A.id_autor FROM Autorzy A WHERE A.imie = @author_name AND A.nazwisko = @author_lastname;
	SELECT @category_id = K.id_kategoria FROM Kategorie K WHERE K.nazwa = @category_name;
	SELECT @publisher_id = W.id_wydawnictwo FROM Wydawnictwa W WHERE W.nazwa = @publisher_name; --nazwa wydawnictwa

	INSERT INTO Ksiazki VALUES((SELECT MAX(id_ksiazka) + 1 FROM Ksiazki), 0, @category_id, @book_title, '', @author_id, @publisher_id, @publishing_year);

END
GO

EXEC NewBook 'Sarah J.', 'Maas', 'Fantastyka', 'Jaguar', 'Dwór cierni i ró¿', 2012;

-- Zadanie 2
-- Zadbaæ aby zadanie 1 wykona³o siê jako pojedyncza transakcja

CREATE PROCEDURE NewBookTrans

	@author_name nvarchar(15) = NULL,
	@author_lastname nvarchar(30) = NULL,
	@category_name nvarchar(46) = NULL,
	@publisher_name nvarchar(30) = NULL,
	@book_title nvarchar(255) = NULL,
	@publishing_year int = NULL

AS

	DECLARE @author_id int;
	DECLARE @author_count int;
	DECLARE @category_id int;
	DECLARE @category_count int;
	DECLARE @publisher_id int;
	DECLARE @publisher_count int;

BEGIN

	BEGIN TRAN AddingBook
		BEGIN TRY
			SELECT @author_count = COUNT(*) FROM Autorzy A WHERE A.imie = @author_name AND A.nazwisko = @author_lastname;
			SELECT @category_count = COUNT(*) FROM Kategorie K WHERE K.nazwa = @category_name;
			SELECT @publisher_count = COUNT(*) FROM Wydawnictwa W WHERE W.nazwa = @publisher_name;

			IF (@author_count = 0)
				BEGIN
					INSERT INTO Autorzy VALUES ((SELECT MAX(id_autor) + 1 FROM Autorzy), @author_name, @author_lastname);
				END
			IF (@category_count = 0)
				BEGIN
					INSERT INTO Kategorie VALUES ((SELECT MAX(id_kategoria) + 1 FROM Kategorie), @category_name);
				END
			IF (@publisher_count = 0)
				BEGIN
					INSERT INTO Wydawnictwa VALUES ((SELECT MAX(id_wydawnictwo) + 1 FROM Wydawnictwa), @publisher_name);
				END

			SELECT @author_id = A.id_autor FROM Autorzy A WHERE A.imie = @author_name AND A.nazwisko = @author_lastname;
			SELECT @category_id = K.id_kategoria FROM Kategorie K WHERE K.nazwa = @category_name;
			SELECT @publisher_id = W.id_wydawnictwo FROM Wydawnictwa W WHERE W.nazwa = @publisher_name;

			INSERT INTO Ksiazki VALUES((SELECT MAX(id_ksiazka) + 1 FROM Ksiazki), 0, @category_id, @book_title, '', @author_id, @publisher_id, @publishing_year);
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
		END CATCH

END
GO

EXEC NewBookTrans 'Rebecca F.', 'Kuang', 'Fantastyka', 'Fabryka s³ów', 'Wojna makowa', 2018;

-- Zadanie 3
-- Przygotuj procedurê dodaj¹c¹ nowe wypo¿yczenie czytelnika rozpoznanego po loginie ksi¹¿ki 
-- wprowadzan¹ przez pracownika o ustalonym loginie. Zwróæ uwagê by u¿ytkownik nie przekroczy³ ustalonej liczby wypo¿yczeñ 7. 
-- Oraz poinformuj pracownika o liczbie wypo¿yczonych przez danego u¿ytkownikach obecnie ksi¹¿kach.

CREATE PROCEDURE NewCheckout

	@reader_login nvarchar(10) = NULL,
	@employee_login nvarchar(10) = NULL,
	@book_title nvarchar(255) = NULL

AS

	DECLARE @reader_id int;
	DECLARE @book_id int;
	DECLARE @employee_id_checkout int;
	DECLARE @book_reader_count int;
	DECLARE @checkout_date date;

BEGIN
	
	SELECT @reader_id = C.id_czytelnik FROM Czytelnicy C WHERE C.login = @reader_login;
	SELECT @book_id = K.id_ksiazka FROM Ksiazki K WHERE K.tytul = @book_title;
	SELECT @employee_id_checkout = P.id_pracownik FROM Pracownicy P WHERE P.login = @employee_login;
	SELECT @book_reader_count = COUNT(*) FROM Wypozyczenia W WHERE W.id_czytelnik = @reader_id AND W.data_oddania IS NULL;
	SELECT @checkout_date = CAST(GETDATE() AS date);

	IF(@book_reader_count < 7)
		BEGIN
			BEGIN TRAN AddingCheckout
				BEGIN TRY
					INSERT INTO Wypozyczenia 
					VALUES((SELECT MAX(id_wypozyczenie) + 1 FROM Wypozyczenia), @reader_id, @book_id, @checkout_date, @employee_id_checkout, NULL, NULL);
						PRINT 'Liczba wypo¿yczonych ksi¹¿ek: ';
						PRINT @book_reader_count + 1;
					COMMIT TRAN
				END TRY
				BEGIN CATCH
					ROLLBACK TRAN
				END CATCH
		END
	ELSE
		BEGIN
			PRINT 'Osi¹gniêto dopuszczaln¹ liczbê wypo¿yczeñ!';
			PRINT 'Liczba wypo¿yczonych ksi¹¿ek: ';
			PRINT @book_reader_count;
		END

END
GO

EXEC NewCheckout 'MikUDA', 'FraSKA', 'Wojna makowa';

SELECT * FROM Wypozyczenia WHERE id_ksiazka IN (SELECT id_ksiazka FROM Ksiazki WHERE tytul = 'Wojna makowa')

-- Zadanie 4
-- Przygotuj procedurê usuniêcia konta czytelnika, o ile oczywiœcie nie posiada on d³u¿nych ksi¹¿ek.

CREATE PROCEDURE DeleteUser

	@reader_login nvarchar(10) = NULL

AS

	DECLARE @reader_id int;
	DECLARE @book_reader_count int;

BEGIN

	SELECT @reader_id = C.id_czytelnik FROM Czytelnicy C WHERE C.login = @reader_login;
	SELECT @book_reader_count = COUNT(*) FROM Wypozyczenia W WHERE W.id_czytelnik = @reader_id AND W.data_oddania IS NULL;

	IF (@book_reader_count = 0)
		BEGIN
			BEGIN TRAN DeletingUser
				BEGIN TRY
					UPDATE Wypozyczenia SET id_czytelnik = NULL WHERE id_czytelnik = @reader_id;
					DELETE FROM Czytelnicy WHERE id_czytelnik = @reader_id; 
					COMMIT TRAN
				END TRY
				BEGIN CATCH
					ROLLBACK TRAN
				END CATCH
			PRINT 'Konto zosta³o poprawnie zamkniête.';
		END
	ELSE
		BEGIN
			PRINT 'Nie mo¿na zamkn¹æ konta - czytelnik posiada nieoddane ksi¹¿ki w liczbie: ';
			PRINT @book_reader_count;
		END
END
GO

EXEC DeleteUser 'MikUDA';
EXEC DeleteUser 'OliKLI';



