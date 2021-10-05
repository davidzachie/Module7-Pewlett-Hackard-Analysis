-- Creating tables for PH_EmployeeDB
CREATE TABLE departments (
	dept_no VARCHAR(4) NOT NULL,
	dept_name VARCHAR(40) NOT NULL,
	PRIMARY KEY (dept_no),
	UNIQUE (dept_name)
);

CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);

SELECT * FROM departments;

SELECT * FROM employees;

SELECT * FROM salaries;

SELECT * FROM titles;

SELECT * FROM dept_emp;

SELECT * FROM dept_manager;

-- 7.3.1 Query Dates

-- Retirement eligibility
SELECT first_name, last_name, birth_date
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

SELECT COUNT (DISTINCT emp_no)
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

SELECT first_name, last_name, birth_date
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT COUNT (DISTINCT emp_no)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');


-- Create New Tables

SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT * FROM retirement_info;

-- Export Data

-- Drop Table
DROP TABLE retirement_info;

-- Recreate retirement_info table with emp_no
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Check the table
SELECT * FROM retirement_info

-- 7.3.3 Joins in Action

-- Joining departments and dept_manager tables
-- Inner Join
SELECT departments.dept_name,
	dept_manager.emp_no,
    dept_manager.from_date,
    dept_manager.to_date
FROM departments INNER JOIN dept_manager ON departments.dept_no = dept_manager.dept_no;

-- Left Join
-- Joining retirement_info and dept_emp tables
SELECT retirement_info.emp_no,
	retirement_info.first_name,
	retirement_info.last_name,
	dept_emp.to_date
FROM retirement_info LEFT JOIN dept_emp ON retirement_info.emp_no = dept_emp.emp_no;

-- Use Aliases for Code Readability
SELECT ri.emp_no,
    ri.first_name,
	ri.last_name,
    de.to_date
FROM retirement_info as ri LEFT JOIN dept_emp as de ON ri.emp_no = de.emp_no;

SELECT d.dept_name,
	dm.emp_no,
	dm.from_date,
	dm.to_date
FROM departments as d INNER JOIN dept_manager as dm ON d.dept_no = dm.dept_no;

-- Use Left Join for retirement_info and dept_emp tables and create a table current_emp
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info as ri LEFT JOIN dept_emp as de ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

SELECT COUNT (emp_no)
FROM current_emp;


-- 7.3.4 Use Count, Group By, and Order By

-- Employee count by department number - How many employees per department were leaving
SELECT de.dept_no, COUNT ( ce.emp_no)
FROM current_emp as ce LEFT JOIN dept_emp as de ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- Create table dept_current_emp - Number of employees per department who were leaving
SELECT de.dept_no, COUNT ( ce.emp_no)
INTO dept_current_emp
FROM current_emp as ce LEFT JOIN dept_emp as de ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- 7.3.5 Create Additional Lists
-- List 1: Employee Information

SELECT * FROM salaries
ORDER BY to_date DESC;

-- Correct queery
SELECT e.emp_no, e.first_name, e.last_name, e.gender, s.salary, de.to_date
INTO emp_info
FROM employees as e 
INNER JOIN salaries as s ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	 AND (de.to_date = '9999-01-01')
ORDER BY e.emp_no;

SELECT * FROM emp_info;

-- Alternative way
SELECT e.emp_no, e.first_name, e.last_name, e.gender, s.salary, de.to_date, s.to_date
--INTO emp_info
FROM employees as e, salaries as s, dept_emp as de
WHERE e.emp_no = s.emp_no
	AND e.emp_no = de.emp_no
	AND (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
    AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (de.to_date = '9999-01-01')
ORDER BY e.emp_no;

-- List 2: Management
-- List of managers per department
SELECT dm.dept_no,
       d.dept_name,
       dm.emp_no,
       ce.last_name,
       ce.first_name,
       dm.from_date,
       dm.to_date
INTO manager_info
FROM dept_manager as dm
	INNER JOIN departments as d ON (dm.dept_no = d.dept_no)
	INNER JOIN current_emp as ce ON (ce.emp_no = dm.emp_no);
	
-- Alternative Query
SELECT dm.dept_no,
       d.dept_name,
       dm.emp_no,
       ce.last_name,
       ce.first_name,
       dm.from_date,
       dm.to_date
--INTO manager_info
FROM dept_manager as dm, departments as d, current_emp as ce
	WHERE dm.dept_no = d.dept_no
	AND ce.emp_no = dm.emp_no;

-- List 3: Department Retirees
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
-- INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);


-- 7.3.6 Create a Tailored List

select * from departments;

SELECT ri.emp_no, ri.first_name, ri.last_name, d.dept_name
-- INTO retire_sales
FROM retirement_info AS ri
INNER JOIN dept_emp AS de ON ri.emp_no = de.emp_no
INNER JOIN departments AS d ON d.dept_no = de.dept_no
WHERE d.dept_name = ('Sales');

SELECT ri.emp_no, ri.first_name, ri.last_name, d.dept_name
-- INTO retire_sales_dev
FROM retirement_info AS ri
INNER JOIN dept_emp AS de ON ri.emp_no = de.emp_no
INNER JOIN departments AS d ON d.dept_no = de.dept_no
WHERE d.dept_name in ('Sales', 'Development');



