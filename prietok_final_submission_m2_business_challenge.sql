CREATE DATABASE IF NOT EXISTS flights;
USE flights;

CREATE TABLE IF NOT EXISTS flight(
	flno INT,
    origin VARCHAR(20),
    destination VARCHAR(20),
    distance INT,
    departs TIME,
    arrives TIME,
    price REAL,
    PRIMARY KEY (flno) 
);

CREATE TABLE IF NOT EXISTS aircraft(
	aid INT,
    aname VARCHAR(20),
    cruisingrange INT,
    PRIMARY KEY (aid) 
);

CREATE TABLE IF NOT EXISTS employees(
	eid INT,
    ename VARCHAR(20),
    salary INT,
    PRIMARY KEY (eid) 
);

CREATE TABLE IF NOT EXISTS certified(
	eid INT,
    aid INT,
    PRIMARY KEY (eid,aid),
    FOREIGN KEY (eid) REFERENCES employees (eid),
    FOREIGN KEY (aid) REFERENCES aircraft (aid) 
);

INSERT INTO flight 
	(flno,
	origin,
	destination,
	distance,
	departs,
	arrives,
	price) VALUES 
(1,'Bangalore','Mangalore',360,'10:45:00','12:00:00',10000),
(2,'Bangalore','Delhi',5000,'12:15:00','04:30:00',25000),
(3,'Bangalore','Mumbai',3500,'02:15:00','05:25:00',30000),
(4,'Delhi','Mumbai',4500,'10:15:00','12:05:00',35000),
(5,'Delhi','Frankfurt',18000,'07:15:00','05:30:00',90000),
(6,'Bangalore','Frankfurt',19500,'10:00:00','07:45:00',95000),
(7,'Bangalore','Frankfurt',17000,'12:00:00','06:30:00',99000);

INSERT INTO aircraft (aid,aname,cruisingrange) values 
(123,'Airbus',1000),
(302,'Boeing',5000),
(306,'Jet01',5000),
(378,'Airbus380',8000),
(456,'Aircraft',500),
(789,'Aircraft02',800),
(951,'Aircraft03',1000);

INSERT INTO employees (eid,ename,salary) VALUES
(1,'Ajay',30000),
(2,'Ajith',85000),
(3,'Arnab',50000),
(4,'Harry',45000),
(5,'Ron',90000),
(6,'Josh',95000),
(7,'Ram',100000);

INSERT INTO certified (eid,aid) VALUES
(1,123),
(2,123),
(1,302),
(5,302),
(7,302),
(1,306),
(2,306),
(1,378),
(2,378),
(3,456),
(5,789),
(3,951),
(1,951),
(1,789);


-- Question 1: Find the names of aircraft such that all pilots certified to operate have salaries more that $80,000
SELECT DISTINCT aname from aircraft as a
	JOIN certified AS c ON a.aid = c.aid
    JOIN employees AS e ON e.eid = c.eid
WHERE e.salary > 80000 AND (a.aid = c.aid AND c.eid = e.eid);


-- Question 2: Find the names of employees whose salary is less than the price of the cheapest route from Banglore to Frankfurt
SELECT DISTINCT ename
FROM employees
WHERE salary < (SELECT MIN(price) FROM flight WHERE (origin = 'Bangalore' AND destination = 'Frankfurt'));

-- Question 3: For all aircraft with cruising range over 1,000 miles, find the name of the aircraft and the average salary of all pilots certified for this aircraft.
SELECT DISTINCT a.aid, aname, AVG(salary) 
FROM aircraft a,certified c,employees e
WHERE a.aid=c.aid
AND c.eid=e.eid
AND a.cruisingrange>1000
GROUP BY a.aid,a.aname;

-- Question 4: Identify the routes that can be piloted by every pilot who makes more than $70,000. (In other words, find the routes with distance less than the least cruising range of aircrafts driven by pilots who make more than $70,000.
SELECT DISTINCT f.origin, f.destination
FROM flight f
WHERE distance < 
		(SELECT MIN(distance)
		FROM (SELECT employees.ename, max(aircraft.cruisingrange) as distance 
			FROM employees, certified, aircraft
			WHERE employees.salary > 70000
			GROUP BY employees.ename) as temp);


-- Question 5: Print the names of pilots who can operate planes with cruising range greater than 3,000 miles but are not certified on any Boeing aircraft.
SELECT DISTINCT ename
FROM employees e
WHERE eid IN ((SELECT c.eid
				FROM certified c
				WHERE EXISTS (SELECT a.aid
								FROM aircraft a
                                WHERE a.aid = c.aid
                                AND a.cruisingrange>1000)
                                AND
                                NOT EXISTS (SELECT a1.aid
                                FROM aircraft a1
                                WHERE a1.aid = c.aid
                                AND a1.aname like 'boeing%')));
                                
-- Question 6: Compute the difference between the average salary of a pilot and the average salary of all employees (including pilots).
SELECT A.avg-B.avg
FROM (SELECT AVG(salary) AS avg
		FROM employees e
        WHERE e.eid IN (SELECT DISTINCT c.eid
						FROM certified c)) AS A,
	(SELECT AVG(salary) AS avg
    FROM employees) AS B;

-- Question 7: Print the name and salary of every non-pilot whose salary is more than the average salary for pilots.
SELECT ename, salary 
FROM employees e 
WHERE e.eid NOT IN ( SELECT DISTINCT c.eid FROM certified c ) AND e.salary > ( SELECT AVG (em.salary) FROM employees em WHERE em.eid IN ( SELECT DISTINCT ce.eid FROM certified ce ) );