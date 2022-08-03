CREATE ROLE covid19_user WITH LOGIN PASSWORD 'covid19_pass';
GRANT ALL PRIVILEGES ON DATABASE covid19 TO covid19_user;

CREATE TABLE state (
    state_id INT NOT NULL,
    state_name varchar(100) NOT NULL,
    timestamp timestamp default current_timestamp,
    PRIMARY KEY (state_id)
);

ALTER TABLE state OWNER TO covid19_user;

CREATE TABLE IF NOT EXISTS department (
    department_id INT NOT NULL,
    department_name varchar(450) NOT NULL,
    state_id INT NOT NULL,
    timestamp timestamp default current_timestamp,
    PRIMARY KEY (department_id),
    CONSTRAINT fk_state FOREIGN KEY(state_id) REFERENCES state(state_id)
);

ALTER TABLE department OWNER TO covid19_user;

CREATE TABLE IF NOT EXISTS covid19_case (
    covid_case_id SERIAL,
    covid_case_csv_id INT NOT NULL,
    gender_id CHAR(2),
    age INT,
    symptoms_start_date DATE,
    registration_date DATE,
    death_date DATE,
    respiratory_assistance CHAR(2),
    registration_state_id INT NOT NULL,
    clasification varchar(50),
    residence_state_id INT NOT NULL,
    diagnosis_date DATE,
    residence_department_id INT,
    last_update DATE,
    timestamp timestamp default current_timestamp,
    PRIMARY KEY (covid_case_id),
    CONSTRAINT fk_state FOREIGN KEY(registration_state_id) REFERENCES state(state_id)
);

ALTER TABLE covid19_case OWNER TO covid19_user;

