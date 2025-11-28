-- DROP TABLES if exist
DROP TABLE IF EXISTS employees, keycard_logs, calls, alibis, evidence;

-- Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    role VARCHAR(50)
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 'Software Engineer'),
(2, 'Bob Smith', 'HR', 'HR Manager'),
(3, 'Clara Lee', 'Finance', 'Accountant'),
(4, 'David Kumar', 'Engineering', 'DevOps Engineer'),
(5, 'Eva Brown', 'Marketing', 'Marketing Lead'),
(6, 'Frank Li', 'Engineering', 'QA Engineer'),
(7, 'Grace Tan', 'Finance', 'CFO'),
(8, 'Henry Wu', 'Engineering', 'CTO'),
(9, 'Isla Patel', 'Support', 'Customer Support'),
(10, 'Jack Chen', 'HR', 'Recruiter');

-- Keycard Logs Table
CREATE TABLE keycard_logs (
    log_id INT PRIMARY KEY,
    employee_id INT,
    room VARCHAR(50),
    entry_time TIMESTAMP,
    exit_time TIMESTAMP
);

INSERT INTO keycard_logs VALUES
(1, 1, 'Office', '2025-10-15 08:00', '2025-10-15 12:00'),
(2, 2, 'HR Office', '2025-10-15 08:30', '2025-10-15 17:00'),
(3, 3, 'Finance Office', '2025-10-15 08:45', '2025-10-15 12:30'),
(4, 4, 'Server Room', '2025-10-15 08:50', '2025-10-15 09:10'),
(5, 5, 'Marketing Office', '2025-10-15 09:00', '2025-10-15 17:30'),
(6, 6, 'Office', '2025-10-15 08:30', '2025-10-15 12:30'),
(7, 7, 'Finance Office', '2025-10-15 08:00', '2025-10-15 18:00'),
(8, 8, 'Server Room', '2025-10-15 08:40', '2025-10-15 09:05'),
(9, 9, 'Support Office', '2025-10-15 08:30', '2025-10-15 16:30'),
(10, 10, 'HR Office', '2025-10-15 09:00', '2025-10-15 17:00'),
(11, 4, 'CEO Office', '2025-10-15 20:50', '2025-10-15 21:00'); -- killer

-- Calls Table
CREATE TABLE calls (
    call_id INT PRIMARY KEY,
    caller_id INT,
    receiver_id INT,
    call_time TIMESTAMP,
    duration_sec INT
);

INSERT INTO calls VALUES
(1, 4, 1, '2025-10-15 20:55', 45),
(2, 5, 1, '2025-10-15 19:30', 120),
(3, 3, 7, '2025-10-15 14:00', 60),
(4, 2, 10, '2025-10-15 16:30', 30),
(5, 4, 7, '2025-10-15 20:40', 90);

-- Alibis Table
CREATE TABLE alibis (
    alibi_id INT PRIMARY KEY,
    employee_id INT,
    claimed_location VARCHAR(50),
    claim_time TIMESTAMP
);

INSERT INTO alibis VALUES
(1, 1, 'Office', '2025-10-15 20:50'),
(2, 4, 'Server Room', '2025-10-15 20:50'), -- false alibi
(3, 5, 'Marketing Office', '2025-10-15 20:50'),
(4, 6, 'Office', '2025-10-15 20:50');

-- Evidence Table
CREATE TABLE evidence (
    evidence_id INT PRIMARY KEY,
    room VARCHAR(50),
    description VARCHAR(255),
    found_time TIMESTAMP
);

INSERT INTO evidence VALUES
(1, 'CEO Office', 'Fingerprint on desk', '2025-10-15 21:05'),
(2, 'CEO Office', 'Keycard swipe logs mismatch', '2025-10-15 21:10'),
(3, 'Server Room', 'Unusual access pattern', '2025-10-15 21:15');



-- --------------------------------------------------- --
-- Investigation Step 1: Identify Crime Details (Time & Location)
SELECT
  evidence_id AS 'Evidence ID',
  room AS 'Evidence Room',
  description AS 'Evidence Description',
  found_time AS 'Evidence Found Time'
FROM evidence
WHERE
  room = 'CEO Office'
ORDER BY
  found_time;

-- Investigation Step 2: Analyze Keycard Logs and Identify Suspect
SELECT
  k.log_id AS 'Log ID',
  k.employee_id AS 'Employee ID',
  e.name AS 'Employee Name',
  k.entry_time AS 'Entry Time',
  k.exit_time AS 'Exit Time',
  CASE
    WHEN k.entry_time BETWEEN '2025-10-15 20:45:00' AND '2025-10-15 21:15:00' THEN 'Yes'
    WHEN k.exit_time BETWEEN '2025-10-15 20:45:00' AND '2025-10-15 21:15:00' THEN 'Yes'
    ELSE 'No'
  END AS 'Present During Crime'
FROM keycard_logs k
JOIN employees e
  ON e.employee_id = k.employee_id
WHERE
  k.room = 'CEO Office'
ORDER BY
  k.entry_time;

-- Investigation Step 3: Verify Alibi and Check Communications
SELECT
  a.alibi_id AS 'Alibi ID',
  a.employee_id AS 'Employee ID',
  e.name,
  a.claimed_location AS 'Claimed Location',
  a.claim_time AS 'Claimed Time',
  k.room AS 'Actual Room',
  k.entry_time AS 'Actual Entry Time',
  k.exit_time AS 'Actual Exit Time',
  CASE
    WHEN k.room = 'CEO Office' THEN 'Contradicted'
    WHEN k.room IS NULL THEN 'No Evidence'
    ELSE 'Matches'
  END AS 'Alibi Match'
FROM alibis a
JOIN employees e
  ON e.employee_id = a.employee_id
LEFT JOIN keycard_logs k
  ON k.employee_id = a.employee_id
  AND k.room = 'CEO Office'
  AND (
    k.entry_time BETWEEN '2025-10-15 20:45:00' AND '2025-10-15 21:15:00'
    OR k.exit_time BETWEEN '2025-10-15 20:45:00' AND '2025-10-15 21:15:00'
  )
WHERE
  a.claim_time BETWEEN '2025-10-15 20:30:00' AND '2025-10-15 21:30:00';
  
-- Investigation Step 4: Investigate suspicious calls made around the time
SELECT
  c.call_id AS 'Call ID',
  c.call_time AS 'Call Time',
  c.duration_sec AS 'Call Duration (Seconds)',
  c.caller_id AS 'Caller ID',
  caller.name AS 'Caller Name',
  c.receiver_id AS 'Receiver ID',
  receiver.name AS 'Receiver Name'
FROM calls c
LEFT JOIN employees caller
  ON caller.employee_id = c.caller_id
LEFT JOIN employees receiver
  ON receiver.employee_id = c.receiver_id
WHERE
  c.call_time BETWEEN '2025-10-15 20:50:00' AND '2025-10-15 21:00:00'
ORDER BY
  c.call_time;
  
-- Investigation Step 5: Match evidence with movements and claims
SELECT
  ev.evidence_id AS 'Evidence ID',
  ev.description AS 'Evidence Description',
  ev.found_time AS 'Evidence Found Time',
  k.employee_id AS 'Employee ID',
  e.name AS 'Employee Name',
  k.entry_time AS 'Entry Time',
  k.exit_time AS 'Exit Time'
FROM evidence ev
JOIN keycard_logs k
  ON k.room = ev.room
JOIN employees e
  ON e.employee_id = k.employee_id
WHERE
  ev.room = 'CEO Office'
  AND k.entry_time BETWEEN '2025-10-15 20:50:00' AND '2025-10-15 21:20:00'
ORDER BY
  ev.found_time,
  e.name;
  
-- Investigation Step 6: Combining all findings
-- CTE 1: people who entered the CEO Office during the crime window
WITH present AS (
  SELECT DISTINCT
    employee_id
  FROM keycard_logs
  WHERE
    room = 'CEO Office'
    AND entry_time BETWEEN '2025-10-15 20:45:00' AND '2025-10-15 21:15:00'
),
-- CTE 2: people whose alibi time overlaps the crime window AND whose keycard shows they were actually in the CEO Office
alibi_fail AS (
  SELECT DISTINCT
    a.employee_id
  FROM alibis a
  JOIN keycard_logs k
    ON k.employee_id = a.employee_id
  WHERE
    k.room = 'CEO Office'
    AND a.claim_time BETWEEN '2025-10-15 20:30:00' AND '2025-10-15 21:30:00'
),
-- CTE 3: people involved in calls close to the time of the murder (20:50-21:00)
calls_cte AS (
  SELECT DISTINCT
    caller_id AS employee_id
  FROM calls
  WHERE
    call_time BETWEEN '2025-10-15 20:50:00' AND '2025-10-15 21:00:00'
  UNION
  SELECT DISTINCT
    receiver_id AS employee_id
  FROM calls
  WHERE
    call_time BETWEEN '2025-10-15 20:50:00' AND '2025-10-15 21:00:00'
),
-- CTE 4: people whose keycard matches the timing of evidence found in CEO Office
evidence_link AS (
  SELECT DISTINCT
    k.employee_id
  FROM evidence ev
  JOIN keycard_logs k
    ON k.room = ev.room
  WHERE
    ev.room = 'CEO Office'
    AND ev.found_time BETWEEN '2025-10-15 20:50:00' AND '2025-10-15 21:30:00'
)

-- Final result:
-- We select the employee who appears in ALL FOUR CTE lists.
-- That means: present at crime + lied + had call + linked to evidence.
SELECT
  e.name AS 'Killer'
FROM employees e
JOIN present p
  ON p.employee_id = e.employee_id
JOIN alibi_fail a
  ON a.employee_id = e.employee_id
JOIN calls_cte c
  ON c.employee_id = e.employee_id
JOIN evidence_link l
  ON l.employee_id = e.employee_id
LIMIT 1; 
  
-- Guiding Question: Who entered the CEO’s Office close to the time of the murder?
SELECT
    k.employee_id,
    e.name,
    k.entry_time,
    k.exit_time
FROM
    keycard_logs AS k
JOIN
    employees AS e ON k.employee_id = e.employee_id
WHERE
    k.room = 'CEO Office'
    AND k.entry_time BETWEEN '2025-10-15 20:45:00' AND '2025-10-15 21:15:00'; -- Extended time window
    
-- Guiding Question: Who claimed to be somewhere else but was not?
SELECT
    e.name,
    k.room AS actual_location_by_keycard,
    k.entry_time,
    a.claimed_location AS claimed_alibi_location,
    a.claim_time
FROM
    employees AS e
JOIN
    keycard_logs AS k ON e.employee_id = k.employee_id
JOIN
    alibis AS a ON e.employee_id = a.employee_id
WHERE
    e.employee_id = 4
    AND k.entry_time = '2025-10-15 20:50:00'; -- Time of suspect's entry to crime scene

-- Guiding Question: Who made or received calls around 20:50–21:00?
SELECT
    e_caller.name AS caller,
    e_receiver.name AS receiver,
    c.call_time,
    c.duration_sec
FROM
    calls AS c
JOIN
    employees AS e_caller ON c.caller_id = e_caller.employee_id
LEFT JOIN
    employees AS e_receiver ON c.receiver_id = e_receiver.employee_id
WHERE
    c.caller_id = 4 OR c.receiver_id = 4
    AND c.call_time BETWEEN '2025-10-15 20:30:00' AND '2025-10-15 21:05:00';
    
-- Guiding Question: What evidence was found at the crime scene?
SELECT
    description,
    room,
    found_time
FROM
    evidence
WHERE
    room IN ('CEO Office', 'Server Room');
    
-- Guiding Question: Which suspect’s movements, alibi, and call activity don’t add up?
SELECT
    e.name AS killer
FROM
    employees AS e
WHERE
    e.employee_id = 4; -- The suspect identified in all prior steps
    
