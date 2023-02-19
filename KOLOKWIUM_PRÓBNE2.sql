/* zad1
Utwórz widok prezentuj¹cy pracowników i ich pensjê wyliczon¹ dodatkowo jako
-skalowanie liniowe wzgledem min_salary, max_salary dla jego jobs 
(jeœli ma min - wartoœæ 0, jeœli max - wartoœæ 1, a reszta proporcjonalnie)
-skalowanie liniowe wzglêdem min(salary), max_salary dla jego departamentu 
(jeœli zarabia najmniej w departement - wartoœæ 0, jeœli najwiêcej wartoœæ 1, reszta proporcjonalnie)
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
Przygotuj procedurê, która podnosi wszystkie wide³ki min_salary i max_salary dla ca³ej firmy o okreœlony procent. 
Np. 10%. Ponadto jeœli jakiœ pracownik do tej pory zarabia mniej (salary) ni¿ wynosi min_salary - nale¿y mu automatycznie podnieœæ wynagrodzenie.

Przygotuj równie¿ instrukcje wywo³uj¹ce procedurê z podwy¿kami o 20% (umownie o inflacje)
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
Przygotuj funkcjê tabeleryczn¹, która dla wskazanego employee_id zwraca tabelê
wszystkich employees podleg³ych pod danego employee (jest ich menagerem)

Na koniec zaprezuntuj wyniki dla najwy¿szego w hierarchii menagera 
i wypisz salary jego pracowników sortuj¹c ich po czasie zatrudnienia.
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
Firma obawia siê utraty wiedzy domenowej. Zablokuj w bazie mo¿liwoœæ zwolnienia (skasowania wpisu w employees) 
pracownika jeœli jest on ostatnim pracownikiem z danym job_id za pomoc¹ triggera. W odpowiedzi wklej jedynie kod przygotowanego wyzwalacza.
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