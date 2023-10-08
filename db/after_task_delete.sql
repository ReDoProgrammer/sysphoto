DELIMITER //
CREATE TRIGGER after_task_deleted
AFTER DELETE ON tasks
FOR EACH ROW
BEGIN
	DECLARE v_level varchar(100);
    SET v_level = (SELECT name FROM levels WHERE id = OLD.level_id);
    
	INSERT INTO project_logs(project_id,timestamp,content)
    VALUES(OLD.project_id,OLD.deleted_at,CONCAT('[<span class="text-info fw-bold">',OLD.deleted_by,'</span>] <span class="text-danger">DELETE TASK </span>[',v_level,']'));
END; //
DELIMITER ;
