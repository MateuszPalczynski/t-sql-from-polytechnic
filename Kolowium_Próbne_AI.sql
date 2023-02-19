USE hr

--Napisz zapytanie SQL, które utworzy widok zawieraj¹cy œrednie wynagrodzenie pracowników dzia³u 
--(department) oraz liczbê pracowników w dziale.
SELECT * FROM departments
SELECT * FROM employees
SELECT * FROM jobs

CREATE VIEW
	SELECT
        department_name, 
        COUNT(employee_id) as Iloœæ_pracowników,
		AVG(salary)
    FROM departments d
    JOIN employees e ON e.department_id = d.department_id
    GROUP BY department_name

--Napisz procedurê , która bêdzie przyjmowaæ jako parametry imiê, nazwisko oraz wynagrodzenie, 
--a nastêpnie bêdzie aktualizowaæ wynagrodzenie dla pracownika o podanych danych o ile mieœci siê w wide³kach z tabeli jobs.

CREATE PROCEDURE raise_salary_name (
    @salary money,
	@fname char(30),
	@lname char(30)

)
AS
BEGIN
DECLARE @id int;
DECLARE @job_id int;
SELECT @id = employee_id FROM employees WHERE (first_name =  @fname AND last_name = @lname) 
SELECT @job_id = job_id FROM employees WHERE (first_name =  @fname AND last_name = @lname) 
	
	IF (@salary > (SELECT min_salary FROM jobs WHERE job_id = @job_id) AND @salary < (SELECT max_salary FROM jobs WHERE job_id = @job_id))
	UPDATE e
    SET salary = @salary
    FROM employees e
    WHERE employee_id = @id
	ELSE
	PRINT 'Podane wynagrodzenie nie mieœci siê w normach firmy (i w g³owie)'

END

EXEC raise_salary_name 5000, 'Jennifer', 'Whalen'



--Napisz funkcjê która przyjmuje jako parametr nazwê dzia³u i zwraca najwy¿sze wynagrodzenie w dziale.

CREATE FUNCTION Get_Max_Salary (@department_name char(50))
RETURNS money
AS
BEGIN
  DECLARE @max_salary money;
  SELECT @max_salary = MAX(salary)
  FROM employees
  JOIN departments
  ON employees.department_id = departments.department_id
  WHERE department_name = @department_name;
  RETURN @max_salary;
END;




--Napisz trigger ,który bêdzie sprawdza³, czy wprowadzana pensja pracownika jest wiêksza ni¿ œrednie wynagrodzenie w dziale, 
--w którym pracuje. Jeœli tak, to trigger powinien wyœwietliæ komunikat "Niez³a pensiunia!", w przeciwnym przypadku - "Tak sobie o zarabia :/"
--(ma dzia³aæ na INSERT)

GO
CREATE TRIGGER on_salary
ON Employees
AFTER INSERT --OR INSERT
AS
BEGIN
declare @salary money;
declare	@dep_id int;
SELECT @salary = salary FROM inserted
SELECT @dep_id = job_id FROM inserted

BEGIN
	IF @salary > (SELECT AVG(salary) FROM employees WHERE department_id = @dep_id)
		PRINT 'Niez³a pensiunia!';
	ELSE
		PRINT 'Tak sobie o zarabia :/';
	END
END
GO