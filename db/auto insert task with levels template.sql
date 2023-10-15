DELIMITER //

CREATE TRIGGER AutoInsertTask 
AFTER INSERT ON projects
FOR EACH ROW
BEGIN
    DECLARE v_levels VARCHAR(100);
    DECLARE v_created_by INT;
    
    SELECT levels INTO v_levels FROM projects WHERE id = NEW.id;
    SELECT created_by INTO v_created_by FROM projects WHERE id = NEW.id;

    SET @start = 1;
    SET @end = LOCATE(',', v_levels);
    
    -- Kiểm tra xem @end có rỗng hay không
    IF @end IS NOT NULL THEN
        WHILE @end > 0 DO
            INSERT INTO tasks (project_id, level_id,auto_gen, created_by)
            VALUES (NEW.id, SUBSTRING(v_levels, @start, @end - @start),1, v_created_by);
            SET @start = @end + 1;
            SET @end = LOCATE(',', v_levels, @start);
        END WHILE;
    END IF;

    -- Xử lý giá trị cuối cùng
    IF SUBSTRING(v_levels, @start) > 0 THEN
        INSERT INTO tasks (project_id, level_id,auto_gen, created_by)
        VALUES (NEW.id, SUBSTRING(v_levels, @start),1, v_created_by);
    END IF;
END;
//
DELIMITER ;
