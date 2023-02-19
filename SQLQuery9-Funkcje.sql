USE BIBLIOTEKA
--Przygotowaæ funkcjê, która dla id_autora, id_kategorii oraz tytu³u tworzy ³¹czny napis:
--"Kategoria - Autor: tytu³". Uwaga funkcja musi dokonaæ podmiany id_autora i id_kategorii na w³aœciwe napisy.

/*
CREATE FUNCTION Kwadrat 
(
	@liczba int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @wynik int;
	-- Add the T-SQL statements to compute the return value here
	SELECT @wynik=@liczba*@liczba;
	-- Return the result of the function
	RETURN @wynik;
END			*/

GO
CREATE FUNCTION cat_aut_tit
(	
	@id_autor int,
	@id_kategoria int,
	@tytul nvarchar(30)
)
RETURNS varchar(80)
AS
BEGIN
DECLARE @wynik varchar(80);	--"Kategoria - Autor: tytu³"
DECLARE @kategoria varchar(15);
DECLARE @autor_imie varchar(15);
DECLARE @autor_nazwisko varchar(20);

SELECT @kategoria = Kategorie.nazwa FROM Kategorie WHERE id_kategoria = @id_kategoria;
SELECT @autor_imie = Autorzy.imie FROM Autorzy WHERE id_autor = @id_autor;
SELECT @autor_nazwisko = Autorzy.nazwisko FROM Autorzy WHERE id_autor = @id_autor;
--Kategorie.nazwa FROM Kategorie WHERE id_kategoria = @id_kategoria
--Autorzy.imie, Autorzy.nazwisko FROM Autorzy WHERE id_autor = @id_autor
SELECT @wynik = (@kategoria + ' - '+ @autor_imie + '  ' + @autor_nazwisko +': ' + @tytul);
RETURN @wynik;

END
GO

SELECT dbo.cat_aut_tit(463, 35, 'Bia³e kruki')

--Przygotowaæ funkcjê która zwraca top 3 najczêœciej wypo¿yczanych autorów w podanym roku.
DROP FUNCTION year_TOP3

GO
CREATE FUNCTION year_TOP3
(
	@year int
)
RETURNS TABLE
AS
RETURN 
    SELECT TOP 3 
        A.imie + ' ' + A.nazwisko AS Autor, 
        COUNT(W.id_ksiazka) as Iloœæ_wypo¿yczeñ
    FROM Autorzy A
    JOIN Ksiazki K ON A.id_autor = K.id_autor
    JOIN Wypozyczenia W ON K.id_ksiazka = W.id_ksiazka
    WHERE YEAR(W.data_wypozyczenia) = @year
    GROUP BY A.imie, A.nazwisko
    ORDER BY Iloœæ_wypo¿yczeñ DESC

GO

SELECT dbo.year_TOP3(1980)

