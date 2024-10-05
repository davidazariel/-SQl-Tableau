# Employees Analysis 

## Table of Contents

- [SQL Overview](#sql)
- [Tableau Overview](#tableau)

## Project Overview
The project involves analyzing employee data from various perspectives, using SQL queries to extract relevant insights, which are then integrated into Tableau for visualization and further analysis. Here's a breakdown of the key aspects:

## SQL
#### 1. Employee Gender Breakdown by Year
```sql
SELECT year(from_date) as calendar_year, gender, COUNT(e.emp_no) as num_of_employees
FROM t_dept_emp de JOIN t_employees e ON de.emp_no = e.emp_no
WHERE year(from_date) >= 1990
GROUP BY calendar_year, gender
ORDER BY calendar_year
;
```
The first query calculates the number of male and female employees from 1990 onwards, grouping the results by year and gender. This provides a historical view of gender distribution in the company.


#### 2. Average Annual Employee Salary
```sql
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
```
This query retrieves the department, gender, and employment period for employees, calculating whether they were active in a particular calendar year. It also includes data for department managers. The goal is to visualize salary trends over time, segmented by gender and department.

#### 3. Number of Managers per Department
```sql
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
```
This query identifies department managers, their gender, and their tenure. It flags managers who are currently active. This data can be used to analyze management demographics and trends in leadership roles.

#### 4. Average Employee Salary (Since 1990)
```sql
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
```
This query calculates the average salary of employees by gender and department for each year, up to 2002. It provides a granular view of how compensation varies across departments and genders. A stored procedure is created to filter employee salaries within a specified range. The procedure takes two parameters, p_less_salary and p_more_salary, and returns the average salary of employees within the range of $50.000 & $90.000, grouped by gender and department. This dynamic query allows for flexible analysis of salary distributions.

## Tableau
Once these queries are run, their outputs are integrated via excel into Tableau to visualize trends, such as:
#### 1. A Breakdown Between Male and Female Employees
![image](https://github.com/user-attachments/assets/36f34aaf-c739-4827-806f-8d53f84924d9)


#### 2. Average Annual Employee Salary
![image](https://github.com/user-attachments/assets/9b2c4a37-becc-497c-9afc-551db4f0900b)


#### 3. Number of Managers per Department
![image](https://github.com/user-attachments/assets/6b57c0a8-5841-4916-bf94-d28eb876bacc)


#### 4. Average Employee Salary (Since 1990)
![image](https://github.com/user-attachments/assets/0859b60c-c817-4f1e-b928-c1e2154cf8ad)


#### 5. Dashboard
![image](https://github.com/user-attachments/assets/fc62e601-9455-4637-b204-743ada7487b2)

This allows for comprehensive insights into employee demographics, salary structures, and management roles.



























