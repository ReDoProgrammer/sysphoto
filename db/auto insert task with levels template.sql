DELIMITER //

CREATE TRIGGER AutoInsertTask AFTER INSERT ON projects
FOR EACH ROW
BEGIN
    DECLARE v_project_id BIGINT;
    DECLARE v_levels VARCHAR(100);
    DECLARE v_created_by INT;
    
    SELECT MAX(id) INTO v_project_id FROM projects;
    SELECT levels INTO v_levels FROM projects WHERE id = v_project_id;
    SELECT created_by INTO v_created_by FROM projects WHERE id = v_project_id;

    SET @start = 1;
    SET @end = LOCATE(',', v_levels);
    
    -- Kiểm tra xem @end có rỗng hay không
    IF @end IS NOT NULL THEN
        WHILE @end > 0 DO
            INSERT INTO tasks (project_id, level_id,auto_gen, created_by)
            VALUES (v_project_id, SUBSTRING(v_levels, @start, @end - @start),1, v_created_by);
            SET @start = @end + 1;
            SET @end = LOCATE(',', v_levels, @start);
        END WHILE;
    END IF;

    -- Xử lý giá trị cuối cùng
    IF SUBSTRING(v_levels, @start) > 0 THEN
        INSERT INTO tasks (project_id, level_id,auto_gen, created_by)
        VALUES (v_project_id, SUBSTRING(v_levels, @start),1, v_created_by);
    END IF;
END;
//
DELIMITER ;
