USE hr
--Zadanie 1 (View)
--Utw�rz widok zawieraj�cy podsumowanie min, �redniej i maksymalnej pensji w ka�dej z lokalizacji firmy
CREATE VIEW summary AS 
SELECT locations.location_id, AVG(employees.salary) as Mean, MIN(employees.salary) as Minimum, MAX(employees.salary) as Maximum
FROM locations
JOIN departments ON departments.location_id = locations.location_id 
JOIN employees ON departments.department_id = employees.department_id
GROUP BY locations.location_id

--Zadanie 2 (Trigger)
--Napisz wyzwalacz, kt�ry uniemo�liwi wstawienie nowego pracownika z warto�ci� pensji przekraczaj�c� wide�ki zdefiniowane w tabeli jobs
SELECT * FROM jobs
SELECT * FROM employees
CREATE TRIGGER wstawianie
ON employees
INSTEAD OF INSERT
AS
BEGIN
DECLARE @min_salary int;
DECLARE @max_salary int;
DECLARE @jobID int;
DECLARE @salary int;
DECLARE @employee_id int;
DECLARE @first_name char;
DECLARE @last_name char;
DECLARE @email char;
DECLARE @phone_number int;
DECLARE @hire_date date;
DECLARE @job_id int;
DECLARE @manager_id int;
DECLARE @department_id int;

    SELECT @jobID = job_id, @salary = salary, @employee_id = employee_id, @first_name = first_name, @email = email, @phone_number = phone_number,
	@hire_date = hire_date, @manager_id = manager_id, @department_id = department_id, @job_id = job_id FROM INSERTED; 
	SELECT @min_salary = min_salary FROM jobs WHERE jobs.job_id = @jobID;
	SELECT @max_salary = max_salary FROM jobs WHERE jobs.job_id = @jobID;
	
    IF @salary BETWEEN @min_salary AND @max_salary
    INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
	VALUES (@employee_id, @first_name, @last_name, @email, @phone_number, @hire_date, @job_id, @salary, @manager_id, @department_id);
	ELSE
		THROW 51000, 'can not insert - salary is not appropriate', 1;
END;

SELECT * FROM employees
SELECT * FROM jobs
SET IDENTITY_INSERT employees ON
INSERT INTO employees (employee_id ,first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES(207 ,'Stefan', 'Kisielewski', 'abc',123, '2023-01-09', 2, 8500, 101, 5)

--Zadanie 3 (Procedure)
--Przygotuj procedur� zwalniaj�c� dla menad�er�w. Niech spe�nia nast�puj�ce regu�y

/*+dzia�a jedynie dla menad�er�w (os�b zarz�dzaj�cych innymi - wed�ug relacji employees-employees). Dla pozosta�ych mo�e nie dzia�a� lub zwraca� b��d
+usuwa rekord z tabeli employees
+odnajduje pracownika podleg�ego kasowanemu rekordowi, kt�ry jest najstarszy sta�em (hire_date) i uznaje go za przejmuj�cego obowi�zki
+kandydatowi temu nale�y zmieni� jobs na job poprzedniego menad�era. Podnie�� jego salary do min_salary dla jego nowego jobs
+zmieni� menager_id pozosta�ym podopiecznym kasowanego rekordu na kandydata. */

CREATE PROCEDURE terminate_manager (@manager_id INT)
AS
BEGIN
    DECLARE @new_manager_id INT;
    DECLARE @new_job_id INT;

    --Check if the input employee_id is a manager
    IF NOT EXISTS (SELECT employee_id FROM employees WHERE employee_id = @manager_id AND manager_id IS NOT NULL)
    BEGIN
        RAISERROR ('Input employee is not a manager', 16, 1);
        RETURN
    END

    --Find the longest-tenured subordinate of the terminated manager
    SET @new_manager_id = (SELECT TOP 1 employee_id FROM employees WHERE manager_id = @manager_id ORDER BY hire_date);

    --Update the new manager's job and salary
    SET @new_job_id = (SELECT job_id FROM employees WHERE employee_id = @manager_id);
    UPDATE employees SET job_id = @new_job_id, salary = (SELECT min_salary FROM jobs WHERE job_id = @new_job_id) WHERE employee_id = @new_manager_id;

    --Update the manager_id for the terminated manager's remaining subordinates
    UPDATE employees SET manager_id = @new_manager_id WHERE manager_id = @manager_id;

    --Delete the terminated manager's record from the employees table
    DELETE FROM employees WHERE employee_id = @manager_id;
END


--Zadanie 4 (View+Trigger)
--Utworzy� widok w kt�rym w wierszach sk�adowane s� pary region_name i country_name. Country_name oczywi�cie w tym widoku b�dzie unikatowe. 
--Utworzy� trigger na insert na tym widoku kt�ry dzia�a nast�puj�co:
/*  je�li region i kraju nie ma - tworzy oba wpisy i ��czy je w relacji
	je�li region istnieje, ale kraju nie ma - wyszukuje region_id i tworzy z nim wpis w tabeli countries
	je�li region nieistnieje, ale kraj istnieje - tworzy nowy region i wstawia jego id w odpowiedni record w countries
	je�li oba istniej� ko�czy si� b��dem lub komunikatem.*/
CREATE VIEW region_country AS
SELECT region_name, country_name FROM countries JOIN regions ON countries.region_id = regions.region_id
go

SELECT * FROM countries

SELECT * FROM region_country

CREATE TRIGGER tr_region_country_view
ON region_country_view
AFTER INSERT
AS
BEGIN
    DECLARE @region_name VARCHAR(25) = (SELECT region_name FROM inserted);
    DECLARE @country_name VARCHAR(40) = (SELECT country_name FROM inserted);
    DECLARE @region_id INT;

    IF NOT EXISTS (SELECT region_name FROM regions WHERE region_name = @region_name)
    BEGIN
        IF NOT EXISTS (SELECT country_name FROM countries WHERE country_name = @country_name)
        BEGIN
            INSERT INTO regions (region_name) VALUES (@region_name);
            SET @region_id = SCOPE_IDENTITY();
            INSERT INTO countries (country_name, region_id) VALUES (@country_name, @region_id);
        END
        ELSE
        BEGIN
            SET @region_id = (SELECT region_id FROM regions WHERE region_name = @region_name);
            INSERT INTO countries (country_name, region_id) VALUES (@country_name, @region_id);
        END
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT country_name FROM countries WHERE country_name = @country_name)
        BEGIN
            INSERT INTO regions (region_name) VALUES (@region_name);
            SET @region_id = SCOPE_IDENTITY();
            UPDATE countries SET region_id = @region_id WHERE country_name = @country_name;
        END
        ELSE
        BEGIN
            RAISERROR ('Region and country already exist', 16, 1);
        END
    END
END



CREATE TRIGGER region
ON region_country
INSTEAD OF INSERT
AS
BEGIN
DECLARE	@region_name varchar(40);
DECLARE	@country_name varchar(40);
	SELECT @region_name = region_name, @country_name = country_name  FROM INSERTED;

	IF @region_name IS NULL AND @country_name IS NULL
		BEGIN
			INSERT INTO region_country (region_name, country_name) VALUES (@region_name, @country_name)
		END
	IF @region_name IS NULL
		BEGIN
			
		END
	IF @country_name IS NULL
		BEGIN
		
		END
	ELSE
		SELECT 'Podane dane ju� istniej�'
	 
END