-- Arthur Vieira Mariano - RM554742
-- Guilherme Henrique Maggiorini - RM554745
-- Ian Rossato Braga - RM554989

SET SERVEROUTPUT ON;
SET VERIFY OFF;

DROP TABLE "references" CASCADE CONSTRAINTS;
DROP TABLE tasks CASCADE CONSTRAINTS;
DROP TABLE weekly_plans CASCADE CONSTRAINTS;
DROP TABLE goals CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;
DROP TABLE roles CASCADE CONSTRAINTS;
DROP TABLE logs CASCADE CONSTRAINTS;
DROP SEQUENCE seq_logs_id;

DROP PACKAGE pkg_export;
DROP PACKAGE pkg_functions;
DROP PACKAGE pkg_inserts;

CREATE TABLE roles (
  id CHAR(24),
  name VARCHAR(50) NOT NULL,
  acronym VARCHAR(10) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT role_pk PRIMARY KEY (id),
  CONSTRAINT role_acronym_uq UNIQUE (acronym),
  CONSTRAINT role_name_uq UNIQUE (name)
);

CREATE TABLE users (
  id CHAR(24),
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL,
  password VARCHAR(100) NOT NULL,
  role_id CHAR(24) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT user_pk PRIMARY KEY (id),
  CONSTRAINT user_role_fk FOREIGN KEY (role_id) REFERENCES roles (id),
  CONSTRAINT user_email_uq UNIQUE (email)
);

CREATE TABLE goals (
    id CHAR(24),
    title VARCHAR2(500) NOT NULL,
    experience VARCHAR2(2000) NOT NULL,
    hours_per_day NUMBER NOT NULL,
    days_per_week NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    user_id CHAR(24) NOT NULL,
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

CREATE TABLE "references" (
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

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_logs_id';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

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

CREATE OR REPLACE FUNCTION generate_random_id RETURN CHAR IS
    v_id VARCHAR2(24);
    v_chars VARCHAR2(36) := 'abcdefghijklmnopqrstuvwxyz0123456789';
    v_random NUMBER;
BEGIN
    v_id := '';
    FOR i IN 1..24 LOOP
        v_random := TRUNC(DBMS_RANDOM.VALUE(1, 37));
        IF v_random < 1 THEN
            v_random := 1;
        ELSIF v_random > 36 THEN
            v_random := 36;
        END IF;
        v_id := v_id || SUBSTR(v_chars, v_random, 1);
    END LOOP;
    RETURN v_id;
END;
/

CREATE OR REPLACE PACKAGE pkg_inserts AS
    e_role_not_found EXCEPTION;
    e_user_not_found EXCEPTION;
    e_creator_not_found EXCEPTION;
    e_invalid_hours_per_day EXCEPTION;
    e_invalid_days_per_week EXCEPTION;
    e_goal_not_found EXCEPTION;
    e_invalid_date_range EXCEPTION;
    e_weekly_plan_not_found EXCEPTION;
    e_invalid_difficulty EXCEPTION;
    e_task_not_found EXCEPTION;
    e_invalid_link EXCEPTION;
    
    
    PROCEDURE insert_role(
        p_id IN CHAR,
        p_name IN VARCHAR2,
        p_acronym IN VARCHAR2
    );
    
    PROCEDURE insert_user(
        p_id IN CHAR,
        p_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password IN VARCHAR2,
        p_role_id IN CHAR
    );
    
    PROCEDURE insert_goal(
        p_id IN CHAR,
        p_title IN VARCHAR2,
        p_experience IN VARCHAR2,
        p_hours_per_day IN NUMBER,
        p_days_per_week IN NUMBER,
        p_user_id IN VARCHAR2,
        p_created_by IN CHAR
    );
    
    PROCEDURE insert_weekly_plan(
        p_id IN CHAR,
        p_week_start IN TIMESTAMP,
        p_week_end IN TIMESTAMP,
        p_weeks_to_complete IN NUMBER,
        p_ai_prompt IN VARCHAR2,
        p_ai_response IN CLOB,
        p_goal_id IN CHAR,
        p_created_by IN CHAR
    );
    
    PROCEDURE insert_task(
        p_id IN CHAR,
        p_title IN VARCHAR2,
        p_completed IN NUMBER,
        p_difficulty IN NUMBER,
        p_weekly_plan_id IN CHAR,
        p_created_by IN CHAR
    );
    
    PROCEDURE insert_reference(
        p_id IN CHAR,
        p_name IN VARCHAR2,
        p_description IN VARCHAR2,
        p_link IN VARCHAR2,
        p_task_id IN CHAR,
        p_created_by IN CHAR
    );
END pkg_inserts;
/

CREATE OR REPLACE PACKAGE BODY pkg_inserts AS
    
    PROCEDURE insert_role(
        p_id IN CHAR,
        p_name IN VARCHAR2,
        p_acronym IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO roles (id, name, acronym)
        VALUES (p_id, p_name, p_acronym);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Role inserido com sucesso: ' || p_name);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erro: Role com ID ou acronym já existe');
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir role: ' || SQLERRM);
            RAISE;
    END insert_role;
    
    PROCEDURE insert_user(
        p_id IN CHAR,
        p_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password IN VARCHAR2,
        p_role_id IN CHAR
    ) IS
        v_role_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_role_exists
        FROM roles
        WHERE id = p_role_id;
        
        IF v_role_exists = 0 THEN
            RAISE e_role_not_found;
        END IF;
        
        INSERT INTO users (id, name, email, password, role_id)
        VALUES (p_id, p_name, p_email, p_password, p_role_id);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Usuário inserido com sucesso: ' || p_name);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erro: Usuário com ID ou email já existe');
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir usuário: ' || SQLERRM);
            RAISE;
    END insert_user;
    
    PROCEDURE insert_goal(
        p_id IN CHAR,
        p_title IN VARCHAR2,
        p_experience IN VARCHAR2,
        p_hours_per_day IN NUMBER,
        p_days_per_week IN NUMBER,
        p_user_id IN VARCHAR2,
        p_created_by IN CHAR
    ) IS
        v_user_exists NUMBER;
        v_creator_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_user_exists
        FROM users
        WHERE id = p_user_id;
        
        SELECT COUNT(*) INTO v_creator_exists
        FROM users
        WHERE id = p_created_by;
        
        IF v_user_exists = 0 THEN
            RAISE e_user_not_found;
        END IF;
        
        IF v_creator_exists = 0 THEN
            RAISE e_creator_not_found;
        END IF;
        
        IF p_hours_per_day < 1 OR p_hours_per_day > 24 THEN
            RAISE e_invalid_hours_per_day;
        END IF;
        
        IF p_days_per_week < 1 OR p_days_per_week > 7 THEN
            RAISE e_invalid_days_per_week;
        END IF;
        
        INSERT INTO goals (id, title, experience, hours_per_day, days_per_week, user_id, created_by)
        VALUES (p_id, p_title, p_experience, p_hours_per_day, p_days_per_week, p_user_id, p_created_by);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Goal inserido com sucesso: ' || p_title);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir goal: ' || SQLERRM);
            RAISE;
    END insert_goal;
    
    PROCEDURE insert_weekly_plan(
        p_id IN CHAR,
        p_week_start IN TIMESTAMP,
        p_week_end IN TIMESTAMP,
        p_weeks_to_complete IN NUMBER,
        p_ai_prompt IN VARCHAR2,
        p_ai_response IN CLOB,
        p_goal_id IN CHAR,
        p_created_by IN CHAR
    ) IS
        v_goal_exists NUMBER;
        v_creator_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_goal_exists
        FROM goals
        WHERE id = p_goal_id;
        
        SELECT COUNT(*) INTO v_creator_exists
        FROM users
        WHERE id = p_created_by;
        
        IF v_goal_exists = 0 THEN
            RAISE e_goal_not_found;
        END IF;
        
        IF v_creator_exists = 0 THEN
            RAISE e_creator_not_found;
        END IF;
        
        IF p_week_end <= p_week_start THEN
            RAISE e_invalid_date_range;
        END IF;
        
        INSERT INTO weekly_plans (id, week_start, week_end, weeks_to_complete, ai_prompt, ai_response, goal_id, created_by)
        VALUES (p_id, p_week_start, p_week_end, p_weeks_to_complete, p_ai_prompt, p_ai_response, p_goal_id, p_created_by);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Weekly plan inserido com sucesso');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir weekly plan: ' || SQLERRM);
            RAISE;
    END insert_weekly_plan;
    
    PROCEDURE insert_task(
        p_id IN CHAR,
        p_title IN VARCHAR2,
        p_completed IN NUMBER,
        p_difficulty IN NUMBER,
        p_weekly_plan_id IN CHAR,
        p_created_by IN CHAR
    ) IS
        v_plan_exists NUMBER;
        v_creator_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_plan_exists
        FROM weekly_plans
        WHERE id = p_weekly_plan_id;
        
        SELECT COUNT(*) INTO v_creator_exists
        FROM users
        WHERE id = p_created_by;
        
        IF v_plan_exists = 0 THEN
            RAISE e_weekly_plan_not_found;
        END IF;
        
        IF v_creator_exists = 0 THEN
            RAISE e_creator_not_found;
        END IF;
        
        IF p_difficulty NOT IN (0, 1, 2) THEN
            RAISE e_invalid_difficulty;
        END IF;
        
        INSERT INTO tasks (id, title, completed, difficulty, weekly_plan_id, created_by)
        VALUES (p_id, p_title, p_completed, p_difficulty, p_weekly_plan_id, p_created_by);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Task inserida com sucesso: ' || p_title);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir task: ' || SQLERRM);
            RAISE;
    END insert_task;
    
    PROCEDURE insert_reference(
        p_id IN CHAR,
        p_name IN VARCHAR2,
        p_description IN VARCHAR2,
        p_link IN VARCHAR2,
        p_task_id IN CHAR,
        p_created_by IN CHAR
    ) IS
        v_task_exists NUMBER;
        v_creator_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_task_exists
        FROM tasks
        WHERE id = p_task_id;
        
        SELECT COUNT(*) INTO v_creator_exists
        FROM users
        WHERE id = p_created_by;
        
        IF v_task_exists = 0 THEN
            RAISE e_task_not_found;
        END IF;
        
        IF v_creator_exists = 0 THEN
            RAISE e_creator_not_found;
        END IF;
        
        IF NOT REGEXP_LIKE(p_link, '^https?://([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}(/.*)?$') THEN
            RAISE e_invalid_link;
        END IF;
        
        INSERT INTO "references" (id, name, description, link, task_id, created_by)
        VALUES (p_id, p_name, p_description, p_link, p_task_id, p_created_by);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Reference inserida com sucesso: ' || p_name);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir reference: ' || SQLERRM);
            RAISE;
    END insert_reference;
    
END pkg_inserts;
/

CREATE OR REPLACE PACKAGE pkg_functions AS
    FUNCTION convert_goal_to_json(p_goal_id IN CHAR) RETURN CLOB;
    FUNCTION calculate_goal_compatibility(
        p_user_id IN CHAR,
        p_goal_id IN CHAR
    ) RETURN CLOB;
    FUNCTION escape_json_string(p_string IN VARCHAR2) RETURN VARCHAR2;
END pkg_functions;
/

CREATE OR REPLACE PACKAGE BODY pkg_functions AS
    
    FUNCTION escape_json_string(p_string IN VARCHAR2) RETURN VARCHAR2 IS
        v_result VARCHAR2(4000);
    BEGIN
        IF p_string IS NULL THEN
            RETURN 'null';
        END IF;
        
        v_result := p_string;
        v_result := REPLACE(v_result, '\', '\\');
        v_result := REPLACE(v_result, '"', '\"');
        v_result := REPLACE(v_result, CHR(10), '\n');
        v_result := REPLACE(v_result, CHR(13), '\r');
        v_result := REPLACE(v_result, CHR(9), '\t');
        
        RETURN '"' || v_result || '"';
    END escape_json_string;
    
    FUNCTION convert_goal_to_json(p_goal_id IN CHAR) RETURN CLOB IS
        v_json CLOB := '';
        v_goal_title VARCHAR2(500);
        v_goal_experience VARCHAR2(2000);
        v_goal_hours_per_day NUMBER;
        v_goal_days_per_week NUMBER;
        v_goal_created_at TIMESTAMP;
        v_user_name VARCHAR2(150);
        v_user_email VARCHAR2(150);
        v_goal_exists NUMBER;
        v_task_count NUMBER := 0;
        v_plan_count NUMBER := 0;
        v_ref_count NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO v_goal_exists
        FROM goals
        WHERE id = p_goal_id;
        
        IF v_goal_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Goal não encontrado com ID: ' || p_goal_id);
            RETURN '{"error": "Goal não encontrado", "goal_id": "' || p_goal_id || '"}';
        END IF;
        
        BEGIN
            SELECT g.title, g.experience, g.hours_per_day, g.days_per_week, 
                   g.created_at, u.name, u.email
            INTO v_goal_title, v_goal_experience, v_goal_hours_per_day, 
                 v_goal_days_per_week, v_goal_created_at, v_user_name, v_user_email
            FROM goals g
            JOIN users u ON g.user_id = u.id
            WHERE g.id = p_goal_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('ERRO: Dados do goal não encontrados');
                RETURN '{"error": "Dados do goal não encontrados", "goal_id": "' || p_goal_id || '"}';
            WHEN TOO_MANY_ROWS THEN
                DBMS_OUTPUT.PUT_LINE('ERRO: Múltiplos goals encontrados com o mesmo ID');
                RETURN '{"error": "Múltiplos goals encontrados", "goal_id": "' || p_goal_id || '"}';
        END;
        
        v_json := '{';
        v_json := v_json || '"goal": {';
        v_json := v_json || '"id": "' || p_goal_id || '",';
        v_json := v_json || '"title": ' || escape_json_string(v_goal_title) || ',';
        v_json := v_json || '"experience": ' || escape_json_string(v_goal_experience) || ',';
        v_json := v_json || '"hours_per_day": ' || v_goal_hours_per_day || ',';
        v_json := v_json || '"days_per_week": ' || v_goal_days_per_week || ',';
        v_json := v_json || '"created_at": "' || TO_CHAR(v_goal_created_at, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",';
        v_json := v_json || '"user": {';
        v_json := v_json || '"name": ' || escape_json_string(v_user_name) || ',';
        v_json := v_json || '"email": ' || escape_json_string(v_user_email);
        v_json := v_json || '},';
        
        v_json := v_json || '"weekly_plans": [';
        
        FOR plan_rec IN (
            SELECT id, week_start, week_end, weeks_to_complete, ai_prompt
            FROM weekly_plans
            WHERE goal_id = p_goal_id
            ORDER BY week_start
        ) LOOP
            v_plan_count := v_plan_count + 1;
            IF v_plan_count > 1 THEN
                v_json := v_json || ',';
            END IF;
            
            v_json := v_json || '{';
            v_json := v_json || '"id": "' || plan_rec.id || '",';
            v_json := v_json || '"week_start": "' || TO_CHAR(plan_rec.week_start, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",';
            v_json := v_json || '"week_end": "' || TO_CHAR(plan_rec.week_end, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",';
            v_json := v_json || '"weeks_to_complete": ' || plan_rec.weeks_to_complete || ',';
            v_json := v_json || '"ai_prompt": ' || escape_json_string(plan_rec.ai_prompt) || ',';
            
            v_json := v_json || '"tasks": [';
            v_task_count := 0;
            
            FOR task_rec IN (
                SELECT t.id, t.title, t.completed, t.difficulty,
                       CASE t.difficulty 
                           WHEN 0 THEN 'Easy'
                           WHEN 1 THEN 'Normal'
                           WHEN 2 THEN 'Hard'
                       END AS difficulty_name
                FROM tasks t
                WHERE t.weekly_plan_id = plan_rec.id
                ORDER BY t.created_at
            ) LOOP
                v_task_count := v_task_count + 1;
                IF v_task_count > 1 THEN
                    v_json := v_json || ',';
                END IF;
                
                v_json := v_json || '{';
                v_json := v_json || '"id": "' || task_rec.id || '",';
                v_json := v_json || '"title": ' || escape_json_string(task_rec.title) || ',';
                v_json := v_json || '"completed": ' || CASE WHEN task_rec.completed = 1 THEN 'true' ELSE 'false' END || ',';
                v_json := v_json || '"difficulty": ' || task_rec.difficulty || ',';
                v_json := v_json || '"difficulty_name": ' || escape_json_string(task_rec.difficulty_name);
                
                v_json := v_json || ', "references": [';
                v_ref_count := 0;
                FOR ref_rec IN (
                    SELECT name, description, link
                    FROM "references"
                    WHERE task_id = task_rec.id
                ) LOOP
                    v_ref_count := v_ref_count + 1;
                    IF v_ref_count > 1 THEN
                        v_json := v_json || ',';
                    END IF;
                    v_json := v_json || '{';
                    v_json := v_json || '"name": ' || escape_json_string(ref_rec.name) || ',';
                    v_json := v_json || '"description": ' || escape_json_string(ref_rec.description) || ',';
                    v_json := v_json || '"link": ' || escape_json_string(ref_rec.link);
                    v_json := v_json || '}';
                END LOOP;
                v_json := v_json || ']';
                v_json := v_json || '}';
            END LOOP;
            
            v_json := v_json || ']';
            v_json := v_json || '}';
        END LOOP;
        
        v_json := v_json || ']';
        v_json := v_json || '}';
        v_json := v_json || '}';
        
        RETURN v_json;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Erro inesperado na conversão JSON: ' || SQLERRM);
            RETURN '{"error": "Erro inesperado na conversão", "message": "' || SQLERRM || '"}';
    END convert_goal_to_json;
    
    FUNCTION calculate_goal_compatibility(
        p_user_id IN CHAR,
        p_goal_id IN CHAR
    ) RETURN CLOB IS
        v_user_exists NUMBER;
        v_goal_exists NUMBER;
        v_user_experience VARCHAR2(2000);
        v_goal_experience VARCHAR2(2000);
        v_user_hours_per_day NUMBER;
        v_goal_hours_per_day NUMBER;
        v_user_days_per_week NUMBER;
        v_goal_days_per_week NUMBER;
        v_compatibility_score NUMBER := 0;
        v_experience_match NUMBER := 0;
        v_availability_match NUMBER := 0;
        v_json_result CLOB;
        v_keywords_count NUMBER := 0;
        v_total_keywords NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO v_user_exists
        FROM users
        WHERE id = p_user_id;
        
        IF v_user_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Usuário não encontrado');
            RETURN '{"error": "Usuário não encontrado", "user_id": "' || p_user_id || '", "compatibility": 0}';
        END IF;
        
        SELECT COUNT(*) INTO v_goal_exists
        FROM goals
        WHERE id = p_goal_id;
        
        IF v_goal_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Goal não encontrado');
            RETURN '{"error": "Goal não encontrado", "goal_id": "' || p_goal_id || '", "compatibility": 0}';
        END IF;
        
        BEGIN
            SELECT experience, hours_per_day, days_per_week
            INTO v_user_experience, v_user_hours_per_day, v_user_days_per_week
            FROM goals
            WHERE user_id = p_user_id
            ORDER BY created_at DESC
            FETCH FIRST 1 ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_user_experience := '';
                v_user_hours_per_day := 0;
                v_user_days_per_week := 0;
        END;
        
        BEGIN
            SELECT experience, hours_per_day, days_per_week
            INTO v_goal_experience, v_goal_hours_per_day, v_goal_days_per_week
            FROM goals
            WHERE id = p_goal_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('ERRO: Dados do goal não encontrados');
                RETURN '{"error": "Dados do goal não encontrados", "compatibility": 0}';
        END;
        
        DECLARE
            v_goal_words VARCHAR2(4000);
            v_user_words VARCHAR2(4000);
        BEGIN
            v_goal_experience := LOWER(REGEXP_REPLACE(v_goal_experience, '[^a-zA-Z0-9\s]', ' '));
            v_user_experience := LOWER(REGEXP_REPLACE(v_user_experience, '[^a-zA-Z0-9\s]', ' '));
            
            FOR word_match IN (
                SELECT DISTINCT REGEXP_SUBSTR(v_goal_experience, '[a-z]{4,}', 1, LEVEL) AS keyword
                FROM DUAL
                CONNECT BY REGEXP_SUBSTR(v_goal_experience, '[a-z]{4,}', 1, LEVEL) IS NOT NULL
            ) LOOP
                IF word_match.keyword IS NOT NULL THEN
                    v_total_keywords := v_total_keywords + 1;
                    IF REGEXP_LIKE(v_user_experience, '(^|\s)' || word_match.keyword || '(\s|$)') THEN
                        v_keywords_count := v_keywords_count + 1;
                    END IF;
                END IF;
            END LOOP;
            
            IF v_total_keywords > 0 THEN
                v_experience_match := (v_keywords_count / v_total_keywords) * 40;
            ELSE
                v_experience_match := 20;
            END IF;
        END;
        
        DECLARE
            v_hours_match NUMBER;
            v_days_match NUMBER;
        BEGIN
            IF v_goal_hours_per_day > 0 THEN
                v_hours_match := LEAST(ABS(v_user_hours_per_day - v_goal_hours_per_day) / v_goal_hours_per_day, 1);
                v_hours_match := (1 - v_hours_match) * 30;
            ELSE
                v_hours_match := 15;
            END IF;
            
            IF v_goal_days_per_week > 0 THEN
                v_days_match := LEAST(ABS(v_user_days_per_week - v_goal_days_per_week) / v_goal_days_per_week, 1);
                v_days_match := (1 - v_days_match) * 30;
            ELSE
                v_days_match := 15;
            END IF;
            
            v_availability_match := v_hours_match + v_days_match;
        END;
        
        v_compatibility_score := ROUND(v_experience_match + v_availability_match, 2);
        v_compatibility_score := GREATEST(0, LEAST(100, v_compatibility_score));
        
        v_json_result := '{';
        v_json_result := v_json_result || '"user_id": "' || p_user_id || '",';
        v_json_result := v_json_result || '"goal_id": "' || p_goal_id || '",';
        v_json_result := v_json_result || '"compatibility_score": ' || v_compatibility_score || ',';
        v_json_result := v_json_result || '"experience_match": ' || ROUND(v_experience_match, 2) || ',';
        v_json_result := v_json_result || '"availability_match": ' || ROUND(v_availability_match, 2) || ',';
        v_json_result := v_json_result || '"keywords_matched": ' || v_keywords_count || ',';
        v_json_result := v_json_result || '"total_keywords": ' || v_total_keywords || ',';
        v_json_result := v_json_result || '"recommendation": ';
        
        IF v_compatibility_score >= 80 THEN
            v_json_result := v_json_result || '"Alta compatibilidade - Recomendado"';
        ELSIF v_compatibility_score >= 60 THEN
            v_json_result := v_json_result || '"Compatibilidade moderada - Considerar"';
        ELSIF v_compatibility_score >= 40 THEN
            v_json_result := v_json_result || '"Compatibilidade baixa - Requer ajustes"';
        ELSE
            v_json_result := v_json_result || '"Compatibilidade muito baixa - Não recomendado"';
        END IF;
        
        v_json_result := v_json_result || '}';
        
        RETURN v_json_result;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Erro inesperado no cálculo de compatibilidade: ' || SQLERRM);
            RETURN '{"error": "Erro inesperado", "message": "' || SQLERRM || '", "compatibility": 0}';
    END calculate_goal_compatibility;
    
END pkg_functions;
/

CREATE OR REPLACE PACKAGE pkg_export AS
    PROCEDURE export_dataset_to_json(
        p_output OUT CLOB
    );
END pkg_export;
/

CREATE OR REPLACE PACKAGE BODY pkg_export AS
    
    FUNCTION escape_json_string(p_string IN VARCHAR2) RETURN VARCHAR2 IS
        v_result VARCHAR2(4000);
    BEGIN
        IF p_string IS NULL THEN
            RETURN 'null';
        END IF;
        
        v_result := p_string;
        v_result := REPLACE(v_result, '\', '\\');
        v_result := REPLACE(v_result, '"', '\"');
        v_result := REPLACE(v_result, CHR(10), '\n');
        v_result := REPLACE(v_result, CHR(13), '\r');
        v_result := REPLACE(v_result, CHR(9), '\t');
        
        RETURN '"' || v_result || '"';
    END escape_json_string;
    
    PROCEDURE export_dataset_to_json(
        p_output OUT CLOB
    ) IS
        v_json CLOB;
        v_role_count NUMBER := 0;
        v_user_count NUMBER := 0;
        v_goal_count NUMBER := 0;
        v_plan_count NUMBER := 0;
        v_task_count NUMBER := 0;
        v_ref_count NUMBER := 0;
    BEGIN
        v_json := '{';
        v_json := v_json || '"export_date": "' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",';
        v_json := v_json || '"dataset": {';
        
        v_json := v_json || '"roles": [';
        FOR role_rec IN (
            SELECT id, name, acronym
            FROM roles
            ORDER BY name
        ) LOOP
            v_role_count := v_role_count + 1;
            IF v_role_count > 1 THEN
                v_json := v_json || ',';
            END IF;
            
            v_json := v_json || '{';
            v_json := v_json || '"id": "' || role_rec.id || '",';
            v_json := v_json || '"name": ' || escape_json_string(role_rec.name) || ',';
            v_json := v_json || '"acronym": ' || escape_json_string(role_rec.acronym);
            v_json := v_json || '}';
        END LOOP;
        v_json := v_json || '],';
        
        v_json := v_json || '"users": [';
        FOR user_rec IN (
            SELECT u.id, u.name, u.email, u.role_id, r.name AS role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            ORDER BY u.name
        ) LOOP
            v_user_count := v_user_count + 1;
            IF v_user_count > 1 THEN
                v_json := v_json || ',';
            END IF;
            
            v_json := v_json || '{';
            v_json := v_json || '"id": "' || user_rec.id || '",';
            v_json := v_json || '"name": ' || escape_json_string(user_rec.name) || ',';
            v_json := v_json || '"email": ' || escape_json_string(user_rec.email) || ',';
            v_json := v_json || '"role": {';
            v_json := v_json || '"id": "' || user_rec.role_id || '",';
            v_json := v_json || '"name": ' || escape_json_string(user_rec.role_name);
            v_json := v_json || '}';
            v_json := v_json || '}';
        END LOOP;
        v_json := v_json || '],';
        
        v_json := v_json || '"goals": [';
        FOR goal_rec IN (
            SELECT g.id, g.title, g.experience, g.hours_per_day, g.days_per_week,
                   g.created_at, g.user_id, u.name AS user_name
            FROM goals g
            JOIN users u ON g.user_id = u.id
            ORDER BY g.created_at DESC
        ) LOOP
            v_goal_count := v_goal_count + 1;
            IF v_goal_count > 1 THEN
                v_json := v_json || ',';
            END IF;
            
            v_json := v_json || '{';
            v_json := v_json || '"id": "' || goal_rec.id || '",';
            v_json := v_json || '"title": ' || escape_json_string(goal_rec.title) || ',';
            v_json := v_json || '"experience": ' || escape_json_string(goal_rec.experience) || ',';
            v_json := v_json || '"hours_per_day": ' || goal_rec.hours_per_day || ',';
            v_json := v_json || '"days_per_week": ' || goal_rec.days_per_week || ',';
            v_json := v_json || '"created_at": "' || TO_CHAR(goal_rec.created_at, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",';
            v_json := v_json || '"user": {';
            v_json := v_json || '"id": "' || goal_rec.user_id || '",';
            v_json := v_json || '"name": ' || escape_json_string(goal_rec.user_name);
            v_json := v_json || '}';
            
            v_json := v_json || ', "weekly_plans": [';
            v_plan_count := 0;
            FOR plan_rec IN (
                SELECT id, week_start, week_end, weeks_to_complete
                FROM weekly_plans
                WHERE goal_id = goal_rec.id
                ORDER BY week_start
            ) LOOP
                v_plan_count := v_plan_count + 1;
                IF v_plan_count > 1 THEN
                    v_json := v_json || ',';
                END IF;
                
                v_json := v_json || '{';
                v_json := v_json || '"id": "' || plan_rec.id || '",';
                v_json := v_json || '"week_start": "' || TO_CHAR(plan_rec.week_start, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",';
                v_json := v_json || '"week_end": "' || TO_CHAR(plan_rec.week_end, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') || '",';
                v_json := v_json || '"weeks_to_complete": ' || plan_rec.weeks_to_complete;
                
                v_json := v_json || ', "tasks": [';
                v_task_count := 0;
                FOR task_rec IN (
                    SELECT id, title, completed, difficulty
                    FROM tasks
                    WHERE weekly_plan_id = plan_rec.id
                    ORDER BY created_at
                ) LOOP
                    v_task_count := v_task_count + 1;
                    IF v_task_count > 1 THEN
                        v_json := v_json || ',';
                    END IF;
                    
                    v_json := v_json || '{';
                    v_json := v_json || '"id": "' || task_rec.id || '",';
                    v_json := v_json || '"title": ' || escape_json_string(task_rec.title) || ',';
                    v_json := v_json || '"completed": ' || CASE WHEN task_rec.completed = 1 THEN 'true' ELSE 'false' END || ',';
                    v_json := v_json || '"difficulty": ' || task_rec.difficulty;
                    
                    v_json := v_json || ', "references": [';
                    v_ref_count := 0;
                    FOR ref_rec IN (
                        SELECT name, description, link
                        FROM "references"
                        WHERE task_id = task_rec.id
                    ) LOOP
                        v_ref_count := v_ref_count + 1;
                        IF v_ref_count > 1 THEN
                            v_json := v_json || ',';
                        END IF;
                        v_json := v_json || '{';
                        v_json := v_json || '"name": ' || escape_json_string(ref_rec.name) || ',';
                        v_json := v_json || '"description": ' || escape_json_string(ref_rec.description) || ',';
                        v_json := v_json || '"link": ' || escape_json_string(ref_rec.link);
                        v_json := v_json || '}';
                    END LOOP;
                    v_json := v_json || ']';
                    v_json := v_json || '}';
                END LOOP;
                v_json := v_json || ']';
                v_json := v_json || '}';
            END LOOP;
            v_json := v_json || ']';
            v_json := v_json || '}';
        END LOOP;
        v_json := v_json || ']';
        
        v_json := v_json || '},';
        v_json := v_json || '"statistics": {';
        v_json := v_json || '"total_roles": ' || v_role_count || ',';
        v_json := v_json || '"total_users": ' || v_user_count || ',';
        v_json := v_json || '"total_goals": ' || v_goal_count || ',';
        v_json := v_json || '"total_weekly_plans": ' || v_plan_count || ',';
        v_json := v_json || '"total_tasks": ' || v_task_count || ',';
        v_json := v_json || '"total_references": ' || v_ref_count;
        v_json := v_json || '}';
        v_json := v_json || '}';
        
        p_output := v_json;
        
        DBMS_OUTPUT.PUT_LINE('Dataset exportado com sucesso!');
        DBMS_OUTPUT.PUT_LINE('Total de registros: ' || (v_role_count + v_user_count + v_goal_count));
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao exportar dataset: ' || SQLERRM);
            p_output := '{"error": "' || SQLERRM || '"}';
            RAISE;
    END export_dataset_to_json;
    
END pkg_export;
/

CREATE OR REPLACE TRIGGER trg_roles_audit
    AFTER INSERT OR UPDATE OR DELETE ON roles
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_old_value VARCHAR2(4000);
    v_new_value VARCHAR2(4000);
    v_username VARCHAR2(80);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_value := 'ID: ' || :NEW.id || ', Name: ' || :NEW.name || ', Acronym: ' || :NEW.acronym;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_value := 'ID: ' || :OLD.id || ', Name: ' || :OLD.name || ', Acronym: ' || :OLD.acronym;
        v_new_value := 'ID: ' || :NEW.id || ', Name: ' || :NEW.name || ', Acronym: ' || :NEW.acronym;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_value := 'ID: ' || :OLD.id || ', Name: ' || :OLD.name || ', Acronym: ' || :OLD.acronym;
    END IF;
    
    v_username := USER;
    
    INSERT INTO logs (username, operation, table_name, datetime, old_value, new_value)
    VALUES (v_username, v_operation, 'roles', CURRENT_TIMESTAMP, v_old_value, v_new_value);
END;
/

CREATE OR REPLACE TRIGGER trg_users_audit
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_old_value VARCHAR2(4000);
    v_new_value VARCHAR2(4000);
    v_username VARCHAR2(80);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_value := 'ID: ' || :NEW.id || ', Name: ' || :NEW.name || ', Email: ' || :NEW.email || ', Role: ' || :NEW.role_id;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_value := 'ID: ' || :OLD.id || ', Name: ' || :OLD.name || ', Email: ' || :OLD.email;
        v_new_value := 'ID: ' || :NEW.id || ', Name: ' || :NEW.name || ', Email: ' || :NEW.email;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_value := 'ID: ' || :OLD.id || ', Name: ' || :OLD.name || ', Email: ' || :OLD.email;
    END IF;
    
    v_username := USER;
    
    INSERT INTO logs (username, operation, table_name, datetime, old_value, new_value)
    VALUES (v_username, v_operation, 'users', CURRENT_TIMESTAMP, v_old_value, v_new_value);
END;
/

CREATE OR REPLACE TRIGGER trg_goals_before_update
    BEFORE UPDATE ON goals
    FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_goals_audit
    AFTER INSERT OR UPDATE OR DELETE ON goals
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_old_value VARCHAR2(4000);
    v_new_value VARCHAR2(4000);
    v_username VARCHAR2(80);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_value := 'ID: ' || :NEW.id || ', Title: ' || SUBSTR(:NEW.title, 1, 100) || ', User: ' || :NEW.user_id;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_value := 'ID: ' || :OLD.id || ', Title: ' || SUBSTR(:OLD.title, 1, 100);
        v_new_value := 'ID: ' || :NEW.id || ', Title: ' || SUBSTR(:NEW.title, 1, 100);
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_value := 'ID: ' || :OLD.id || ', Title: ' || SUBSTR(:OLD.title, 1, 100);
    END IF;
    
    v_username := USER;
    
    INSERT INTO logs (username, operation, table_name, datetime, old_value, new_value)
    VALUES (v_username, v_operation, 'goals', CURRENT_TIMESTAMP, v_old_value, v_new_value);
END;
/

CREATE OR REPLACE TRIGGER trg_weekly_plans_audit
    AFTER INSERT OR UPDATE OR DELETE ON weekly_plans
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_old_value VARCHAR2(4000);
    v_new_value VARCHAR2(4000);
    v_username VARCHAR2(80);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_value := 'ID: ' || :NEW.id || ', Goal: ' || :NEW.goal_id || ', Weeks: ' || :NEW.weeks_to_complete;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_value := 'ID: ' || :OLD.id || ', Goal: ' || :OLD.goal_id;
        v_new_value := 'ID: ' || :NEW.id || ', Goal: ' || :NEW.goal_id || ', Weeks: ' || :NEW.weeks_to_complete;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_value := 'ID: ' || :OLD.id || ', Goal: ' || :OLD.goal_id;
    END IF;
    
    v_username := USER;
    
    INSERT INTO logs (username, operation, table_name, datetime, old_value, new_value)
    VALUES (v_username, v_operation, 'weekly_plans', CURRENT_TIMESTAMP, v_old_value, v_new_value);
END;
/

CREATE OR REPLACE TRIGGER trg_tasks_audit
    AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_old_value VARCHAR2(4000);
    v_new_value VARCHAR2(4000);
    v_username VARCHAR2(80);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_value := 'ID: ' || :NEW.id || ', Title: ' || SUBSTR(:NEW.title, 1, 100) || ', Completed: ' || :NEW.completed;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_value := 'ID: ' || :OLD.id || ', Title: ' || SUBSTR(:OLD.title, 1, 100) || ', Completed: ' || :OLD.completed;
        v_new_value := 'ID: ' || :NEW.id || ', Title: ' || SUBSTR(:NEW.title, 1, 100) || ', Completed: ' || :NEW.completed;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_value := 'ID: ' || :OLD.id || ', Title: ' || SUBSTR(:OLD.title, 1, 100);
    END IF;
    
    v_username := USER;
    
    INSERT INTO logs (username, operation, table_name, datetime, old_value, new_value)
    VALUES (v_username, v_operation, 'tasks', CURRENT_TIMESTAMP, v_old_value, v_new_value);
END;
/

CREATE OR REPLACE TRIGGER trg_references_audit
    AFTER INSERT OR UPDATE OR DELETE ON "references"
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(20);
    v_old_value VARCHAR2(4000);
    v_new_value VARCHAR2(4000);
    v_username VARCHAR2(80);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_value := 'ID: ' || :NEW.id || ', Name: ' || SUBSTR(:NEW.name, 1, 100) || ', Task: ' || :NEW.task_id;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_value := 'ID: ' || :OLD.id || ', Name: ' || SUBSTR(:OLD.name, 1, 100);
        v_new_value := 'ID: ' || :NEW.id || ', Name: ' || SUBSTR(:NEW.name, 1, 100) || ', Link: ' || SUBSTR(:NEW.link, 1, 100);
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_value := 'ID: ' || :OLD.id || ', Name: ' || SUBSTR(:OLD.name, 1, 100);
    END IF;
    
    v_username := USER;
    
    INSERT INTO logs (username, operation, table_name, datetime, old_value, new_value)
    VALUES (v_username, v_operation, 'references', CURRENT_TIMESTAMP, v_old_value, v_new_value);
END;
/

BEGIN
    pkg_inserts.insert_role(generate_random_id(), 'Administrador', 'ADM');
    pkg_inserts.insert_role(generate_random_id(), 'Desenvolvedor', 'DEV');
    pkg_inserts.insert_role(generate_random_id(), 'Designer UX/UI', 'DSG');
    pkg_inserts.insert_role(generate_random_id(), 'Analista de Dados', 'ANL');
    pkg_inserts.insert_role(generate_random_id(), 'Gerente de Projetos', 'GPR');
    pkg_inserts.insert_role(generate_random_id(), 'Especialista em IA', 'IA');
    pkg_inserts.insert_role(generate_random_id(), 'Product Manager', 'PM');
    pkg_inserts.insert_role(generate_random_id(), 'DevOps Engineer', 'DOE');
    pkg_inserts.insert_role(generate_random_id(), 'Cybersecurity', 'CS');
    pkg_inserts.insert_role(generate_random_id(), 'Cloud Architect', 'CA');
    pkg_inserts.insert_role(generate_random_id(), 'Scrum Master', 'SM');
    pkg_inserts.insert_role(generate_random_id(), 'Data Scientist', 'DS');
END;
/

DECLARE
    v_role_adm CHAR(24);
    v_role_dev CHAR(24);
    v_role_dsg CHAR(24);
    v_role_anl CHAR(24);
    v_role_gpr CHAR(24);
    v_role_ia CHAR(24);
    v_role_pm CHAR(24);
    v_role_doe CHAR(24);
    v_role_cs CHAR(24);
    v_role_ca CHAR(24);
    v_role_sm CHAR(24);
    v_role_ds CHAR(24);
    v_user_adm CHAR(24);
    v_user_dev CHAR(24);
    v_user_dsg CHAR(24);
    v_user_anl CHAR(24);
    v_user_gpr CHAR(24);
    v_user_ia CHAR(24);
    v_user_pm CHAR(24);
    v_user_doe CHAR(24);
    v_user_cs CHAR(24);
    v_user_ca CHAR(24);
    v_user_sm CHAR(24);
    v_user_ds CHAR(24);
BEGIN
    SELECT id INTO v_role_adm FROM roles WHERE acronym = 'ADM' AND ROWNUM = 1;
    SELECT id INTO v_role_dev FROM roles WHERE acronym = 'DEV' AND ROWNUM = 1;
    SELECT id INTO v_role_dsg FROM roles WHERE acronym = 'DSG' AND ROWNUM = 1;
    SELECT id INTO v_role_anl FROM roles WHERE acronym = 'ANL' AND ROWNUM = 1;
    SELECT id INTO v_role_gpr FROM roles WHERE acronym = 'GPR' AND ROWNUM = 1;
    SELECT id INTO v_role_ia FROM roles WHERE acronym = 'IA' AND ROWNUM = 1;
    SELECT id INTO v_role_pm FROM roles WHERE acronym = 'PM' AND ROWNUM = 1;
    SELECT id INTO v_role_doe FROM roles WHERE acronym = 'DOE' AND ROWNUM = 1;
    SELECT id INTO v_role_cs FROM roles WHERE acronym = 'CS' AND ROWNUM = 1;
    SELECT id INTO v_role_ca FROM roles WHERE acronym = 'CA' AND ROWNUM = 1;
    SELECT id INTO v_role_sm FROM roles WHERE acronym = 'SM' AND ROWNUM = 1;
    SELECT id INTO v_role_ds FROM roles WHERE acronym = 'DS' AND ROWNUM = 1;
    
    v_user_adm := generate_random_id();
    v_user_dev := generate_random_id();
    v_user_dsg := generate_random_id();
    v_user_anl := generate_random_id();
    v_user_gpr := generate_random_id();
    v_user_ia := generate_random_id();
    v_user_pm := generate_random_id();
    v_user_doe := generate_random_id();
    v_user_cs := generate_random_id();
    v_user_ca := generate_random_id();
    v_user_sm := generate_random_id();
    v_user_ds := generate_random_id();
    
    pkg_inserts.insert_user(v_user_adm, 'Ana Silva', 'ana.silva@skillmate.com', 'pass123', v_role_adm);
    pkg_inserts.insert_user(v_user_dev, 'Carlos Mendes', 'carlos.mendes@skillmate.com', 'pass123', v_role_dev);
    pkg_inserts.insert_user(v_user_dsg, 'Mariana Costa', 'mariana.costa@skillmate.com', 'pass123', v_role_dsg);
    pkg_inserts.insert_user(v_user_anl, 'João Santos', 'joao.santos@skillmate.com', 'pass123', v_role_anl);
    pkg_inserts.insert_user(v_user_gpr, 'Fernanda Lima', 'fernanda.lima@skillmate.com', 'pass123', v_role_gpr);
    pkg_inserts.insert_user(v_user_ia, 'Ricardo Alves', 'ricardo.alves@skillmate.com', 'pass123', v_role_ia);
    pkg_inserts.insert_user(v_user_pm, 'Juliana Rocha', 'juliana.rocha@skillmate.com', 'pass123', v_role_pm);
    pkg_inserts.insert_user(v_user_doe, 'Pedro Oliveira', 'pedro.oliveira@skillmate.com', 'pass123', v_role_doe);
    pkg_inserts.insert_user(v_user_cs, 'Larissa Ferreira', 'larissa.ferreira@skillmate.com', 'pass123', v_role_cs);
    pkg_inserts.insert_user(v_user_ca, 'Bruno Souza', 'bruno.souza@skillmate.com', 'pass123', v_role_ca);
    pkg_inserts.insert_user(v_user_sm, 'Camila Martins', 'camila.martins@skillmate.com', 'pass123', v_role_sm);
    pkg_inserts.insert_user(v_user_ds, 'Gabriel Pereira', 'gabriel.pereira@skillmate.com', 'pass123', v_role_ds);
    
    DECLARE
        v_goal1 CHAR(24) := generate_random_id();
        v_goal2 CHAR(24) := generate_random_id();
        v_goal3 CHAR(24) := generate_random_id();
        v_goal4 CHAR(24) := generate_random_id();
        v_goal5 CHAR(24) := generate_random_id();
        v_goal6 CHAR(24) := generate_random_id();
        v_goal7 CHAR(24) := generate_random_id();
        v_goal8 CHAR(24) := generate_random_id();
        v_goal9 CHAR(24) := generate_random_id();
        v_goal10 CHAR(24) := generate_random_id();
        v_goal11 CHAR(24) := generate_random_id();
        v_goal12 CHAR(24) := generate_random_id();
    BEGIN
        pkg_inserts.insert_goal(v_goal1, 'Dominar Machine Learning e Deep Learning para aplicações empresariais',
            'Tenho experiência básica em Python e estatística. Trabalho com análise de dados há 2 anos e quero migrar para área de IA. Preciso aprender frameworks como TensorFlow, PyTorch e entender modelos de redes neurais.',
            4, 5, v_user_anl, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal2, 'Tornar-se Cloud Architect certificado em AWS e Azure',
            'Sou desenvolvedor backend com 5 anos de experiência. Já trabalho com Docker e Kubernetes, mas preciso dominar arquiteturas cloud nativas, serverless e multi-cloud. Objetivo é obter certificações AWS Solutions Architect e Azure Architect.',
            3, 6, v_user_dev, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal3, 'Especializar-se em Design Thinking e prototipação avançada',
            'Designer gráfico há 3 anos, migrando para UX/UI. Preciso aprender metodologias de pesquisa com usuários, criação de personas, wireframes, prototipação em Figma e testes de usabilidade. Foco em produtos SaaS e mobile.',
            5, 4, v_user_dsg, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal4, 'Dominar análise preditiva e visualização de dados avançada',
            'Analista de dados júnior, conheço SQL e Excel avançado. Quero evoluir para Data Scientist, aprendendo Python para análise, bibliotecas como Pandas e Scikit-learn, e ferramentas como Tableau e Power BI para dashboards executivos.',
            4, 5, v_user_anl, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal5, 'Certificar-se como Scrum Master e Product Owner',
            'Gerente de projetos tradicional há 4 anos. Preciso migrar para metodologias ágeis. Objetivo é obter certificação Scrum Master (PSM) e Product Owner (PSPO), além de dominar ferramentas como Jira e técnicas de estimativa ágil.',
            2, 5, v_user_gpr, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal6, 'Desenvolver chatbots e sistemas de NLP para atendimento',
            'Desenvolvedor full-stack com conhecimento em APIs REST. Quero criar soluções de IA conversacional usando OpenAI GPT, processamento de linguagem natural e integração com sistemas de CRM. Foco em automação de atendimento ao cliente.',
            6, 4, v_user_ia, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal7, 'Tornar-se Product Manager especializado em produtos digitais',
            'Analista de negócios com 3 anos de experiência. Preciso aprender estratégia de produto, roadmap, métricas de produto (KPIs), A/B testing, e como trabalhar com equipes de desenvolvimento. Objetivo é liderar produtos SaaS.',
            3, 5, v_user_pm, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal8, 'Dominar pipelines de CI/CD e infraestrutura como código',
            'Sysadmin migrando para DevOps. Conheço Linux e scripts bash. Preciso aprender GitLab CI, Jenkins, Terraform, Ansible, monitoramento com Prometheus e Grafana. Foco em automação completa de deploy e infraestrutura.',
            5, 5, v_user_doe, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal9, 'Especializar-se em segurança de aplicações web e cloud',
            'Desenvolvedor com interesse em segurança. Quero aprender OWASP Top 10, testes de penetração, análise de vulnerabilidades, segurança em APIs, e compliance (LGPD, GDPR). Objetivo é trabalhar como Security Engineer.',
            4, 4, v_user_cs, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal10, 'Arquitetar soluções cloud escaláveis e resilientes',
            'Arquiteto de software com 7 anos de experiência. Preciso evoluir para cloud-native, aprendendo padrões de arquitetura (microservices, event-driven), serverless, containers, service mesh, e otimização de custos cloud.',
            3, 6, v_user_ca, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal11, 'Tornar-se Agile Coach e facilitador de transformação digital',
            'Scrum Master há 2 anos. Quero evoluir para Agile Coach, aprendendo técnicas de coaching, facilitação de workshops, transformação organizacional, e frameworks como SAFe e LeSS. Foco em ajudar empresas na transição ágil.',
            2, 5, v_user_sm, v_user_adm);
        
        pkg_inserts.insert_goal(v_goal12, 'Dominar Machine Learning para análise de dados empresariais',
            'Estatístico com conhecimento em R. Preciso migrar para Python, aprender algoritmos de ML (regressão, classificação, clustering), deep learning básico, e como implementar modelos em produção. Foco em dados de negócio.',
            5, 5, v_user_ds, v_user_adm);
        
        DECLARE
            v_plan1 CHAR(24) := generate_random_id();
            v_plan2 CHAR(24) := generate_random_id();
            v_plan3 CHAR(24) := generate_random_id();
            v_plan4 CHAR(24) := generate_random_id();
            v_plan5 CHAR(24) := generate_random_id();
            v_plan6 CHAR(24) := generate_random_id();
            v_plan7 CHAR(24) := generate_random_id();
            v_plan8 CHAR(24) := generate_random_id();
            v_plan9 CHAR(24) := generate_random_id();
            v_plan10 CHAR(24) := generate_random_id();
        BEGIN
            pkg_inserts.insert_weekly_plan(v_plan1, TIMESTAMP '2024-01-01 00:00:00', TIMESTAMP '2024-01-07 23:59:59',
                12, 'Criar plano de aprendizado semanal para Machine Learning', 'Plano focado em fundamentos de ML.',
                v_goal1, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan2, TIMESTAMP '2024-01-08 00:00:00', TIMESTAMP '2024-01-14 23:59:59',
                12, 'Aprofundar em Deep Learning', 'Estudar redes neurais e TensorFlow.', v_goal1, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan3, TIMESTAMP '2024-01-15 00:00:00', TIMESTAMP '2024-01-21 23:59:59',
                16, 'Plano de estudos AWS', 'Cobrir serviços fundamentais da AWS.', v_goal2, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan4, TIMESTAMP '2024-01-22 00:00:00', TIMESTAMP '2024-01-28 23:59:59',
                16, 'Arquitetura Azure e Multi-Cloud', 'Estudar serviços Azure e estratégias multi-cloud.', v_goal2, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan5, TIMESTAMP '2024-02-01 00:00:00', TIMESTAMP '2024-02-07 23:59:59',
                8, 'Fundamentos de Design Thinking', 'Aprender metodologias de pesquisa com usuários.', v_goal3, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan6, TIMESTAMP '2024-02-08 00:00:00', TIMESTAMP '2024-02-14 23:59:59',
                10, 'Python para Análise de Dados', 'Dominar Pandas e Scikit-learn para análise preditiva.', v_goal4, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan7, TIMESTAMP '2024-02-15 00:00:00', TIMESTAMP '2024-02-21 23:59:59',
                6, 'Preparação para Certificação Scrum Master', 'Estudar framework Scrum e práticas ágeis.', v_goal5, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan8, TIMESTAMP '2024-02-22 00:00:00', TIMESTAMP '2024-02-28 23:59:59',
                8, 'Desenvolvimento de Chatbots com OpenAI', 'Aprender integração com GPT e processamento de linguagem natural.', v_goal6, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan9, TIMESTAMP '2024-03-01 00:00:00', TIMESTAMP '2024-03-07 23:59:59',
                10, 'Pipelines CI/CD com GitLab e Jenkins', 'Configurar pipelines de integração e deploy contínuo.', v_goal8, v_user_adm);
            
            pkg_inserts.insert_weekly_plan(v_plan10, TIMESTAMP '2024-03-08 00:00:00', TIMESTAMP '2024-03-14 23:59:59',
                12, 'Arquitetura Microservices e Serverless', 'Aprender padrões de arquitetura cloud-native e serverless.', v_goal10, v_user_adm);
            
            DECLARE
                v_task1 CHAR(24) := generate_random_id();
                v_task2 CHAR(24) := generate_random_id();
                v_task3 CHAR(24) := generate_random_id();
                v_task4 CHAR(24) := generate_random_id();
                v_task5 CHAR(24) := generate_random_id();
                v_task6 CHAR(24) := generate_random_id();
                v_task7 CHAR(24) := generate_random_id();
                v_task8 CHAR(24) := generate_random_id();
                v_task9 CHAR(24) := generate_random_id();
                v_task10 CHAR(24) := generate_random_id();
                v_task11 CHAR(24) := generate_random_id();
                v_task12 CHAR(24) := generate_random_id();
            BEGIN
                pkg_inserts.insert_task(v_task1, 'Assistir curso introdutório de Machine Learning', 0, 0, v_plan1, v_user_adm);
                pkg_inserts.insert_task(v_task2, 'Instalar e configurar ambiente Python', 1, 0, v_plan1, v_user_adm);
                pkg_inserts.insert_task(v_task3, 'Estudar conceitos de regressão linear e classificação', 0, 1, v_plan1, v_user_adm);
                pkg_inserts.insert_task(v_task4, 'Implementar primeira rede neural com TensorFlow', 0, 2, v_plan2, v_user_adm);
                pkg_inserts.insert_task(v_task5, 'Estudar arquiteturas de redes neurais convolucionais', 0, 1, v_plan2, v_user_adm);
                pkg_inserts.insert_task(v_task6, 'Configurar conta AWS e explorar console', 1, 0, v_plan3, v_user_adm);
                pkg_inserts.insert_task(v_task7, 'Criar primeira instância EC2 e configurar segurança', 0, 1, v_plan3, v_user_adm);
                pkg_inserts.insert_task(v_task8, 'Estudar serviços fundamentais do Azure', 0, 1, v_plan4, v_user_adm);
                pkg_inserts.insert_task(v_task9, 'Aprender técnicas de entrevista com usuários', 0, 1, v_plan5, v_user_adm);
                pkg_inserts.insert_task(v_task10, 'Criar personas e mapas de empatia', 0, 0, v_plan5, v_user_adm);
                pkg_inserts.insert_task(v_task11, 'Dominar manipulação de dados com Pandas', 0, 1, v_plan6, v_user_adm);
                pkg_inserts.insert_task(v_task12, 'Implementar modelo preditivo com Scikit-learn', 0, 2, v_plan6, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'Coursera - Machine Learning', 
                    'Curso completo de ML', 'https://www.coursera.org/learn/machine-learning', v_task1, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'Python.org Tutorial', 
                    'Tutorial oficial do Python', 'https://docs.python.org/3/tutorial/', v_task2, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'Scikit-learn Documentation', 
                    'Documentação oficial do Scikit-learn', 'https://scikit-learn.org/stable/', v_task3, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'TensorFlow Tutorials', 
                    'Tutoriais oficiais do TensorFlow', 'https://www.tensorflow.org/tutorials', v_task4, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'Deep Learning Book', 
                    'Livro sobre Deep Learning', 'https://www.deeplearningbook.org/', v_task5, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'AWS Getting Started Guide', 
                    'Guia de início rápido da AWS', 'https://aws.amazon.com/getting-started/', v_task6, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'AWS EC2 Documentation', 
                    'Documentação do Amazon EC2', 'https://docs.aws.amazon.com/ec2/', v_task7, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'Microsoft Azure Learn', 
                    'Plataforma de aprendizado do Azure', 'https://learn.microsoft.com/azure/', v_task8, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'IDEO Design Thinking Toolkit', 
                    'Kit de ferramentas de Design Thinking', 'https://www.ideou.com/pages/design-thinking', v_task9, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'Figma Design System', 
                    'Guia de sistemas de design no Figma', 'https://www.figma.com/design-systems/', v_task10, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'Pandas Documentation', 
                    'Documentação oficial do Pandas', 'https://pandas.pydata.org/docs/', v_task11, v_user_adm);
                pkg_inserts.insert_reference(generate_random_id(), 'Scikit-learn User Guide', 
                    'Guia do usuário do Scikit-learn', 'https://scikit-learn.org/stable/user_guide.html', v_task12, v_user_adm);
            END;
        END;
    END;
END;
/

COMMIT;

-- ============================================
-- TESTES DAS FUNCTIONS E PROCEDURES
-- ============================================

PROMPT ============================================
PROMPT Iniciando testes...
PROMPT ============================================

DECLARE
    v_test_goal_id CHAR(24);
    v_test_user_id CHAR(24);
    v_json_result CLOB;
    v_export_result CLOB;
    v_role_id CHAR(24);
    v_test_task_id CHAR(24);
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 1: Função convert_goal_to_json ===');
    BEGIN
        SELECT id INTO v_test_goal_id FROM goals WHERE ROWNUM = 1;
        v_json_result := pkg_functions.convert_goal_to_json(v_test_goal_id);
        
        IF LENGTH(v_json_result) > 100 THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: Função retornou JSON válido');
            DBMS_OUTPUT.PUT_LINE('Tamanho do JSON: ' || LENGTH(v_json_result) || ' caracteres');
            DBMS_OUTPUT.PUT_LINE('Primeiros 200 caracteres: ' || SUBSTR(v_json_result, 1, 200));
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALHOU: JSON muito curto ou inválido');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 2: Função convert_goal_to_json com ID inválido ===');
    BEGIN
        v_json_result := pkg_functions.convert_goal_to_json('invalid_id_123456789012');
        
        IF v_json_result LIKE '%error%' THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: Função tratou erro corretamente');
            DBMS_OUTPUT.PUT_LINE('Resultado: ' || SUBSTR(v_json_result, 1, 100));
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALHOU: Deveria retornar erro');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 3: Função calculate_goal_compatibility ===');
    BEGIN
        SELECT id INTO v_test_user_id FROM users WHERE ROWNUM = 1;
        SELECT id INTO v_test_goal_id FROM goals WHERE ROWNUM = 1;
        
        v_json_result := pkg_functions.calculate_goal_compatibility(v_test_user_id, v_test_goal_id);
        
        IF v_json_result LIKE '%compatibility_score%' THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: Função retornou resultado válido');
            DBMS_OUTPUT.PUT_LINE('Resultado: ' || SUBSTR(v_json_result, 1, 200));
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALHOU: Resultado inválido');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 4: Função calculate_goal_compatibility com IDs inválidos ===');
    BEGIN
        v_json_result := pkg_functions.calculate_goal_compatibility('invalid_user_123', 'invalid_goal_123');
        
        IF v_json_result LIKE '%error%' THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: Função tratou erro corretamente');
            DBMS_OUTPUT.PUT_LINE('Resultado: ' || SUBSTR(v_json_result, 1, 100));
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALHOU: Deveria retornar erro');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 5: Procedure export_dataset_to_json ===');
    BEGIN
        pkg_export.export_dataset_to_json(v_export_result);
        
        IF LENGTH(v_export_result) > 500 THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: Procedure exportou dataset válido');
            DBMS_OUTPUT.PUT_LINE('Tamanho do JSON: ' || LENGTH(v_export_result) || ' caracteres');
            DBMS_OUTPUT.PUT_LINE('Primeiros 200 caracteres: ' || SUBSTR(v_export_result, 1, 200));
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALHOU: Dataset muito pequeno ou inválido');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 6: Procedure insert_user com role inválido ===');
    BEGIN
        pkg_inserts.insert_user(generate_random_id(), 'Teste User', 'teste@test.com', 'pass123', 'invalid_role_id');
        DBMS_OUTPUT.PUT_LINE('FALHOU: Deveria ter lançado exceção');
    EXCEPTION
        WHEN pkg_inserts.e_role_not_found THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: Exceção e_role_not_found lançada corretamente');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: Exceção incorreta: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 7: Procedure insert_goal com horas inválidas ===');
    BEGIN
        SELECT id INTO v_test_user_id FROM users WHERE ROWNUM = 1;
        SELECT id INTO v_role_id FROM roles WHERE ROWNUM = 1;
        
        pkg_inserts.insert_goal(
            generate_random_id(),
            'Teste Goal',
            'Experiência teste',
            25,
            5,
            v_test_user_id,
            v_test_user_id
        );
        DBMS_OUTPUT.PUT_LINE('FALHOU: Deveria ter lançado exceção');
    EXCEPTION
        WHEN pkg_inserts.e_invalid_hours_per_day THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: Exceção e_invalid_hours_per_day lançada corretamente');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: Exceção incorreta: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 8: Procedure insert_reference com link inválido ===');
    BEGIN
        SELECT id INTO v_test_user_id FROM users WHERE ROWNUM = 1;
        SELECT id INTO v_test_task_id FROM tasks WHERE ROWNUM = 1;
        
        pkg_inserts.insert_reference(
            generate_random_id(),
            'Teste Reference',
            'Descrição teste',
            'link-invalido-sem-http',
            v_test_task_id,
            v_test_user_id
        );
        DBMS_OUTPUT.PUT_LINE('FALHOU: Deveria ter lançado exceção');
    EXCEPTION
        WHEN pkg_inserts.e_invalid_link THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: Exceção e_invalid_link lançada corretamente');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: Exceção incorreta: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE 9: Função generate_random_id ===');
    BEGIN
        v_test_goal_id := generate_random_id();
        
        IF LENGTH(v_test_goal_id) = 24 AND REGEXP_LIKE(v_test_goal_id, '^[a-z0-9]{24}$') THEN
            DBMS_OUTPUT.PUT_LINE('PASSOU: ID gerado corretamente');
            DBMS_OUTPUT.PUT_LINE('ID gerado: ' || v_test_goal_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALHOU: ID inválido - Tamanho: ' || LENGTH(v_test_goal_id));
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('FALHOU: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('LOGS DE AUDITORIA');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    FOR log_rec IN (
        SELECT username, operation, table_name, TO_CHAR(datetime, 'DD/MM/YYYY HH24:MI:SS') as data_hora, 
              old_value, new_value
        FROM logs 
        ORDER BY datetime DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Usuário: ' || log_rec.username || ' | Operação: ' || log_rec.operation || ' | Tabela: ' || log_rec.table_name || ' | Data: ' || log_rec.data_hora);
        IF log_rec.old_value IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  Anterior: ' || log_rec.old_value);
        END IF;
        IF log_rec.new_value IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  Novo: ' || log_rec.new_value);
        END IF;
        DBMS_OUTPUT.PUT_LINE('---');
    END LOOP;
    
END;
/
