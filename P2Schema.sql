DROP TABLE IF EXISTS work_student, work_prof, grad_student,
                     project, professor, department CASCADE;

CREATE TABLE department (
    dno          INT PRIMARY KEY,
    dname        VARCHAR(50) NOT NULL UNIQUE,
    main_office  VARCHAR(50) NOT NULL,
    chair_ssn    CHAR(9)     NOT NULL UNIQUE
);

CREATE TABLE professor (
    ssn                CHAR(9) PRIMARY KEY CHECK (ssn ~ '^[0-9]{9}$'),
    name               VARCHAR(50) NOT NULL,
    age                INT CHECK (age > 0),
    gender             CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    rank               VARCHAR(30) NOT NULL
                       CHECK (rank IN ('Assistant Professor', 'Associate Professor', 'Full Professor')),
    research_specialty VARCHAR(50),
    dno                INT NOT NULL REFERENCES department(dno),
    UNIQUE (ssn, dno)
);

ALTER TABLE department
    ADD CONSTRAINT fk_department_chair
    FOREIGN KEY (chair_ssn, dno) REFERENCES professor(ssn, dno)
    DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE project (
    pno          INT PRIMARY KEY,
    sponsor_name VARCHAR(50)   NOT NULL,
    start_date   DATE          NOT NULL,
    end_date     DATE          NOT NULL,
    budget       NUMERIC(12,2) NOT NULL CHECK (budget >= 0),
    pi_ssn       CHAR(9)       NOT NULL REFERENCES professor(ssn),
    CHECK (end_date > start_date)
);

CREATE TABLE grad_student (
    ssn            CHAR(9) PRIMARY KEY CHECK (ssn ~ '^[0-9]{9}$'),
    name           VARCHAR(50) NOT NULL,
    age            INT CHECK (age > 0),
    gender         CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    degree_program VARCHAR(10) NOT NULL CHECK (degree_program IN ('M.S.', 'Ph.D.')),
    major_dno      INT NOT NULL REFERENCES department(dno),
    advisor_ssn    CHAR(9) REFERENCES grad_student(ssn)
                   ON DELETE SET NULL,
    CHECK (advisor_ssn <> ssn)
);

CREATE TABLE work_prof (
    ssn CHAR(9) REFERENCES professor(ssn),
    pno INT     REFERENCES project(pno) ON DELETE CASCADE,
    PRIMARY KEY (ssn, pno)
);

CREATE TABLE work_student (
    ssn CHAR(9) REFERENCES grad_student(ssn) ON DELETE CASCADE,
    pno INT     REFERENCES project(pno)      ON DELETE CASCADE,
    PRIMARY KEY (ssn, pno)
);

-- Sample data
BEGIN;

INSERT INTO department (dno, dname, main_office, chair_ssn) VALUES
(10, 'Computer Science', 'ET A-310', '111111111'),
(20, 'Mathematics',      'ST F-202', '444444444'),
(30, 'Physics',          'ST C-120', '777777777');

INSERT INTO professor (ssn, name, age, gender, rank, research_specialty, dno) VALUES
('111111111', 'Maria Lopez',    52, 'F', 'Full Professor',      'Databases',         10),
('222222222', 'James Chen',     45, 'M', 'Associate Professor', 'Machine Learning',  10),
('333333333', 'Aisha Patel',    38, 'F', 'Assistant Professor', 'Computer Security', 10),
('444444444', 'Robert Kim',     58, 'M', 'Full Professor',      'Number Theory',     20),
('555555555', 'Linda Nguyen',   41, 'F', 'Associate Professor', 'Statistics',        20),
('666666666', 'David Brown',    35, 'M', 'Assistant Professor', 'Applied Math',      20),
('777777777', 'Sarah Johnson',  49, 'F', 'Full Professor',      'Quantum Physics',   30),
('888888888', 'Michael Garcia', 44, 'M', 'Associate Professor', 'Astrophysics',      30);

INSERT INTO project (pno, sponsor_name, start_date, end_date, budget, pi_ssn) VALUES
(101, 'NSF',   '2024-09-01', '2027-08-31',  450000.00, '111111111'),
(102, 'NIH',   '2025-01-15', '2026-12-31',  300000.00, '222222222'),
(103, 'DOE',   '2023-06-01', '2026-05-31',  750000.00, '777777777'),
(104, 'DARPA', '2025-09-01', '2028-08-31', 1200000.00, '333333333');

INSERT INTO grad_student (ssn, name, age, gender, degree_program, major_dno, advisor_ssn) VALUES
('900000001', 'Kevin Park',     29, 'M', 'Ph.D.', 10, NULL),
('900000002', 'Emily Davis',    27, 'F', 'Ph.D.', 30, NULL),
('900000004', 'Priya Shah',     26, 'F', 'Ph.D.', 20, '900000001'),
('900000003', 'Carlos Ramirez', 25, 'M', 'M.S.',  10, '900000001'),
('900000005', 'Jason Lee',      23, 'M', 'M.S.',  20, '900000004'),
('900000006', 'Hannah Wilson',  24, 'F', 'M.S.',  30, '900000002');

INSERT INTO work_prof (ssn, pno) VALUES
('222222222', 101), ('333333333', 101),
('555555555', 102),
('888888888', 103), ('444444444', 103),
('111111111', 104), ('222222222', 104), ('666666666', 104);

INSERT INTO work_student (ssn, pno) VALUES
('900000001', 101), ('900000003', 101),
('900000001', 102), ('900000005', 102),
('900000002', 103), ('900000006', 103),
('900000004', 104), ('900000003', 104);

COMMIT;

SELECT (SELECT COUNT(*) FROM department)   AS departments,
       (SELECT COUNT(*) FROM professor)    AS professors,
       (SELECT COUNT(*) FROM project)      AS projects,
       (SELECT COUNT(*) FROM grad_student) AS students,
       (SELECT COUNT(*) FROM work_prof)    AS co_pis,
       (SELECT COUNT(*) FROM work_student) AS assistants;