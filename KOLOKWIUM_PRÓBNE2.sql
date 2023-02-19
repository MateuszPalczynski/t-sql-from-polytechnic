/* zad1
Utw�rz widok prezentuj�cy pracownik�w i ich pensj� wyliczon� dodatkowo jako
-skalowanie liniowe wzgledem min_salary, max_salary dla jego jobs 
(je�li ma min - warto�� 0, je�li max - warto�� 1, a reszta proporcjonalnie)
-skalowanie liniowe wzgl�dem min(salary), max_salary dla jego departamentu 
(je�li zarabia najmniej w departement - warto�� 0, je�li najwi�cej warto�� 1, reszta proporcjonalnie)
*/
USE HR

SELECT * FROM employees
SELECT * FROM jobs
SELECT * FROM departments

SELECT first_name, last_name, email, job_id, salary, 
       (salary - (SELECT min_salary FROM jobs WHERE job_id = employees.job_id)) / 
       (SELECT (max_salary - min_salary) FROM jobs WHERE job_id = employees.job_id) AS job_scale,
       (salary - (SELECT MIN(salary) FROM employees WHERE department_id = employees.department_id)) /
       (SELECT (MAX(salary) - MIN(salary)) FROM employees WHERE department_id = employees.department_id) AS department_scale
FROM employees;


/* zad2
Przygotuj procedur�, kt�ra podnosi wszystkie wide�ki min_salary i max_salary dla ca�ej firmy o okre�lony procent. 
Np. 10%. Ponadto je�li jaki� pracownik do tej pory zarabia mniej (salary) ni� wynosi min_salary - nale�y mu automatycznie podnie�� wynagrodzenie.

Przygotuj r�wnie� instrukcje wywo�uj�ce procedur� z podwy�kami o 20% (umownie o inflacje)
*/

CREATE PROCEDURE raise_salary_limits (
    @percent INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Raise min_salary and max_salary for all jobs
    UPDATE jobs
    SET min_salary = min_salary * (1 + (@percent / 100.0)),
        max_salary = max_salary * (1 + (@percent / 100.0))

    -- Raise salary for employees who currently earn less than min_salary for their job
    UPDATE e
    SET salary = j.min_salary
    FROM employees e
    JOIN jobs j ON e.job_id = j.job_id
    WHERE e.salary < j.min_salary
END


EXEC raise_salary_limits 20
/* zad3
Przygotuj funkcj� tabeleryczn�, kt�ra dla wskazanego employee_id zwraca tabel�
wszystkich employees podleg�ych pod danego employee (jest ich menagerem)

Na koniec zaprezuntuj wyniki dla najwy�szego w hierarchii menagera 
i wypisz salary jego pracownik�w sortuj�c ich po czasie zatrudnienia.
*/
CREATE FUNCTION get_subordinates (@manager_id INT)
RETURNS TABLE
AS
RETURN
    SELECT employee_id, first_name, last_name, job_id, salary, department_id, hire_date, manager_id
    FROM employees
    WHERE manager_id = @manager_id



SELECT first_name, last_name, salary, hire_date
FROM get_subordinates((SELECT MAX(manager_id) FROM employees))
ORDER BY hire_date



/* zad4
Firma obawia si� utraty wiedzy domenowej. Zablokuj w bazie mo�liwo�� zwolnienia (skasowania wpisu w employees) 
pracownika je�li jest on ostatnim pracownikiem z danym job_id za pomoc� triggera. W odpowiedzi wklej jedynie kod przygotowanego wyzwalacza.
*/


CREATE TRIGGER prevent_last_job_employee_deletion
ON employees
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @job_id INT;
    SELECT @job_id = job_id FROM deleted;
    IF (SELECT COUNT(*) FROM employees WHERE job_id = @job_id) = 1 
    BEGIN
    Print 'Cannot delete the last employee with this job';
    ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM employees
        WHERE employee_id IN (SELECT employee_id FROM deleted);
    END
END


select * from employees
delete from employees where employee_id = 206