-- Arthur Vieira Mariano - RM554742
-- Guilherme Henrique Maggiorini - RM554745
-- Ian Rossato Braga - RM554989


DROP TABLE references CASCADE CONSTRAINTS;
DROP TABLE tasks CASCADE CONSTRAINTS;
DROP TABLE weekly_plans CASCADE CONSTRAINTS;
DROP TABLE goals CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;
DROP TABLE roles CASCADE CONSTRAINTS;
DROP TABLE logs CASCADE CONSTRAINTS;
DROP SEQUENCE seq_logs_id;


CREATE TABLE roles (
  id CHAR(24),
  name VARCHAR(50) NOT NULL,
  acronym VARCHAR(10) NOT NULL,
  CONSTRAINT role_pk PRIMARY KEY (id),
  CONSTRAINT role_acronym_uq UNIQUE (acronym),
  CONSTRAINT role_name_uq UNIQUE (name),
);

CREATE TABLE users (
  id CHAR(24),
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL,
  password VARCHAR(100) NOT NULL,
  role_id CHAR(24) NOT NULL,
  CONSTRAINT user_pk PRIMARY KEY (id),
  CONSTRAINT user_role_fk FOREIGN KEY (role_id) REFERENCES roles (id),
);

CREATE TABLE goals (
    id CHAR(24),
    title VARCHAR2(500) NOT NULL,
    experience VARCHAR2(2000) NOT NULL,
    hours_per_day NUMBER NOT NULL,
    days_per_week NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    user_id VARCHAR2(100) NOT NULL,
    created_by CHAR(24) NOT NULL,
    updated_by CHAR(24),
    CONSTRAINT goal_pk PRIMARY KEY (id),
    CONSTRAINT goal_user_fk FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT goal_created_by_fk FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT goal_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users (id)
);

CREATE TABLE weekly_plans (
    id CHAR(24),
    week_start TIMESTAMP NOT NULL,
    week_end TIMESTAMP NOT NULL,
    weeks_to_complete NUMBER NOT NULL,
    ai_prompt VARCHAR2(4000),
    ai_response CLOB,
    goal_id CHAR(24) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by CHAR(24) NOT NULL,
    updated_by CHAR(24),
    CONSTRAINT weekly_plan_pk PRIMARY KEY (id),
    CONSTRAINT weekly_plan_goal_fk FOREIGN KEY (goal_id) REFERENCES goals (id) ON DELETE CASCADE,
    CONSTRAINT weekly_plan_created_by_fk FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT weekly_plan_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users (id)
);

CREATE TABLE tasks (
    id CHAR(24),
    title VARCHAR2(500) NOT NULL,
    completed NUMBER(1) DEFAULT 0 NOT NULL,
    difficulty NUMBER DEFAULT 1 NOT NULL, -- 0= Easy, 1=Normal, 2=Hard
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    weekly_plan_id CHAR(24) NOT NULL,
    created_by CHAR(24) NOT NULL,
    updated_by CHAR(24),
    CONSTRAINT task_pk PRIMARY KEY (id),
    CONSTRAINT task_weekly_plan_fk FOREIGN KEY (weekly_plan_id) REFERENCES weekly_plans (id) ON DELETE CASCADE,
    CONSTRAINT chk_tasks_completed CHECK (completed IN (0, 1)),
    CONSTRAINT chk_tasks_difficulty CHECK (difficulty IN (0, 1, 2)),
    CONSTRAINT task_created_by_fk FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT task_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users (id)
);

CREATE TABLE references (
    id CHAR(24),
    name VARCHAR2(500) NOT NULL,
    description VARCHAR2(2000),
    link VARCHAR2(2000) NOT NULL,
    task_id CHAR(24) NOT NULL,
    created_by CHAR(24) NOT NULL,
    updated_by CHAR(24),
    CONSTRAINT reference_pk PRIMARY KEY (id),
    CONSTRAINT reference_task_fk FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
    CONSTRAINT reference_created_by_fk FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT reference_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users (id)
);

CREATE SEQUENCE seq_logs_id START WITH 1 INCREMENT BY 1;

CREATE TABLE logs (
    id NUMBER DEFAULT seq_logs_id.NEXTVAL PRIMARY KEY, 
    username VARCHAR(80) NOT NULL,
    operation VARCHAR(20) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    datetime TIMESTAMP NOT NULL,
    old_value VARCHAR2(4000),
    new_value VARCHAR2(4000)
);
