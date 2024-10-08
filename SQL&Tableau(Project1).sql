-- A Breakdown Between Male and Female Employees
SELECT year(from_date) as calendar_year, gender, COUNT(e.emp_no) as num_of_employees
FROM t_dept_emp de JOIN t_employees e ON de.emp_no = e.emp_no
WHERE year(from_date) >= 1990
GROUP BY calendar_year, gender
ORDER BY calendar_year
;

-- Average Annual Employee Salary
SELECT 
    td.dept_name,
    te.gender,
    tdm.emp_no,
    tdm.from_date,
    tdm.to_date,
    ee.calendar_year,
    CASE
        WHEN
            YEAR(from_date) <= ee.calendar_year
                AND YEAR(to_date) >= ee.calendar_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) ee
		CROSS JOIN
    t_dept_manager tdm
        JOIN
    t_departments td ON tdm.dept_no = td.dept_no
        JOIN
    t_employees te ON te.emp_no = tdm.emp_no
ORDER BY tdm.emp_no , calendar_year;

-- Numbers of Managers per Department
SELECT 
    a.dept_name,
    a.gender,
    a.emp_no,
    a.from_date,
    a.to_date,
    CASE
        WHEN to_date >= '2024-01-01' THEN 1
        ELSE 0
    END AS currently_active
FROM
    (SELECT 
        d.dept_name, e.gender, e.emp_no, dm.from_date, dm.to_date
    FROM
        employees e
    CROSS JOIN dept_manager dm
    JOIN departments d ON dm.dept_no = d.dept_no
    JOIN employees ee ON dm.emp_no = ee.emp_no) a
ORDER BY emp_no DESC;
    
SELECT 
    te.gender,
    td.dept_name,
    ROUND(AVG(ts.salary), 2) AS avg_salary,
    YEAR(ts.from_date) AS calendar_year
FROM
    t_employees te
        JOIN
    t_salaries ts ON te.emp_no = ts.emp_no
        JOIN
    t_dept_emp tde ON tde.emp_no = ts.emp_no
        JOIN
    t_departments td ON td.dept_no = tde.dept_no
GROUP BY te.gender , td.dept_name , calendar_year
HAVING calendar_year <= 2002
ORDER BY tde.dept_no;

--Average Employee Salary (Since 1990)
DELIMITER $$
CREATE PROCEDURE filter_salary(IN p_less_salary FLOAT, IN p_more_salary FLOAT)
DETERMINISTIC NO SQL READS SQL DATA
SELECT te.gender, td.dept_name, AVG(salary) as avg_salary
FROM 
t_salaries ts
JOIN 
t_employees te ON ts.emp_no = te.emp_no
JOIN
t_dept_emp tde ON tde.emp_no = te.emp_no
JOIN
t_departments td ON td.dept_no = tde.dept_no
WHERE ts.salary BETWEEN p_less_salary AND p_more_salary
GROUP BY te.gender, td.dept_no
;
END $$
DELIMITER ;

CALL filter_salary(50000,90000);



