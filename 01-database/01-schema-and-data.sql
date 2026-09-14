-- =============================================================================
-- Company database - schema + sample data
-- Auto-executed once, on first-ever container startup (empty data volume),
-- by the official MySQL image's docker-entrypoint-initdb.d mechanism.
-- =============================================================================

USE company;

-- -----------------------------------------------------------------------------
-- departments
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    department_id   INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location        VARCHAR(100) NOT NULL,
    budget          DECIMAL(12, 2) NOT NULL DEFAULT 0.00
);

-- -----------------------------------------------------------------------------
-- employees
-- -----------------------------------------------------------------------------
CREATE TABLE employees (
    employee_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    hire_date       DATE NOT NULL,
    job_title       VARCHAR(100) NOT NULL,
    salary          DECIMAL(10, 2) NOT NULL,
    department_id   INT,
    manager_id      INT,
    status          ENUM('active', 'on_leave', 'terminated') NOT NULL DEFAULT 'active',
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
        ON DELETE SET NULL
);

CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_last_name ON employees(last_name);

-- -----------------------------------------------------------------------------
-- projects
-- -----------------------------------------------------------------------------
CREATE TABLE projects (
    project_id      INT AUTO_INCREMENT PRIMARY KEY,
    project_name    VARCHAR(150) NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE,
    budget          DECIMAL(12, 2) NOT NULL,
    department_id   INT,
    CONSTRAINT fk_project_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE SET NULL
);

-- -----------------------------------------------------------------------------
-- employee_projects (many-to-many junction table)
-- -----------------------------------------------------------------------------
CREATE TABLE employee_projects (
    employee_id     INT NOT NULL,
    project_id      INT NOT NULL,
    role            VARCHAR(100) NOT NULL,
    hours_allocated INT NOT NULL DEFAULT 0 CHECK (hours_allocated >= 0),
    PRIMARY KEY (employee_id, project_id),
    CONSTRAINT fk_ep_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ep_project
        FOREIGN KEY (project_id) REFERENCES projects(project_id)
        ON DELETE CASCADE
);

-- =============================================================================
-- Sample data
-- =============================================================================

INSERT INTO departments (department_name, location, budget) VALUES
    ('Engineering',  'Cairo',      2500000.00),
    ('Data',         'Giza',       1800000.00),
    ('Sales',        'Alexandria',  900000.00),
    ('HR',           'Cairo',       400000.00);

INSERT INTO employees (first_name, last_name, email, hire_date, job_title, salary, department_id, manager_id, status) VALUES
    ('Ahmed',   'Fathy',    'ahmed.fathy@company.test',   '2019-03-01', 'Engineering Director', 45000.00, 1, NULL, 'active'),
    ('Mona',    'Kamal',    'mona.kamal@company.test',    '2020-06-15', 'Senior Backend Engineer', 28000.00, 1, 1, 'active'),
    ('Youssef', 'Adel',     'youssef.adel@company.test',  '2021-01-10', 'Backend Engineer', 21000.00, 1, 2, 'active'),
    ('Laila',   'Hassan',   'laila.hassan@company.test',  '2018-11-20', 'Data Engineering Lead', 40000.00, 2, NULL, 'active'),
    ('Omar',    'Salah',    'omar.salah@company.test',    '2021-09-05', 'Data Engineer', 22000.00, 2, 4, 'active'),
    ('Sara',    'Ibrahim',  'sara.ibrahim@company.test',  '2022-02-14', 'Data Analyst', 17000.00, 2, 4, 'active'),
    ('Karim',   'Nabil',    'karim.nabil@company.test',   '2017-05-01', 'Sales Director', 38000.00, 3, NULL, 'active'),
    ('Nour',    'Tarek',    'nour.tarek@company.test',    '2020-08-22', 'Account Executive', 19000.00, 3, 7, 'active'),
    ('Hana',    'Reda',     'hana.reda@company.test',     '2023-01-05', 'Account Executive', 16000.00, 3, 7, 'on_leave'),
    ('Tarek',   'Mostafa',  'tarek.mostafa@company.test', '2016-09-12', 'HR Director', 36000.00, 4, NULL, 'active'),
    ('Dina',    'Samir',    'dina.samir@company.test',    '2022-07-01', 'HR Specialist', 15000.00, 4, 10, 'active'),
    ('Amr',     'Gamal',    'amr.gamal@company.test',     '2019-12-01', 'Backend Engineer', 23000.00, 1, 2, 'terminated');

INSERT INTO projects (project_name, start_date, end_date, budget, department_id) VALUES
    ('Customer Portal Revamp',   '2023-01-15', '2023-08-30', 350000.00, 1),
    ('Realtime Analytics Pipeline', '2023-03-01', NULL, 500000.00, 2),
    ('Sales CRM Migration',      '2022-11-01', '2023-04-01', 220000.00, 3),
    ('Employee Self-Service Portal', '2023-05-01', NULL, 120000.00, 4),
    ('Internal Search Tool',     '2022-06-01', '2022-12-15', 90000.00, 1);

INSERT INTO employee_projects (employee_id, project_id, role, hours_allocated) VALUES
    (2, 1, 'Tech Lead', 400),
    (3, 1, 'Developer', 350),
    (12, 1, 'Developer', 200),
    (4, 2, 'Lead Engineer', 450),
    (5, 2, 'Pipeline Engineer', 400),
    (6, 2, 'Analyst', 250),
    (7, 3, 'Project Sponsor', 100),
    (8, 3, 'Migration Lead', 300),
    (10, 4, 'Sponsor', 80),
    (11, 4, 'Coordinator', 220),
    (2, 5, 'Developer', 150),
    (3, 5, 'Developer', 150);
