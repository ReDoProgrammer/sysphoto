DELIMITER //
CREATE TRIGGER after_insert_task
AFTER INSERT ON tasks FOR EACH ROW
BEGIN
	DECLARE v_created_by varchar(100);
    DECLARE v_level varchar(50);
    
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM tasks WHERE id = NEW.id));
    SET v_level = (SELECT name FROM levels WHERE id = NEW.level_id);
    
    INSERT INTO project_logs(project_id,timestamp,content)
    VALUES(NEW.project_id,NEW.created_at,CONCAT('[',v_created_by,'] INSERT TASK [',v_level,'] with quantity: [',NEW.quantity,']'));
    
END; //
DELIMITER ;