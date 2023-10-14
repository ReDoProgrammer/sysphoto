DELIMITER //
CREATE TRIGGER after_task_inserted
AFTER INSERT ON tasks FOR EACH ROW
BEGIN
	DECLARE v_created_by varchar(100);
    DECLARE v_level varchar(50);
    DECLARE v_content varchar(5000);
    
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM tasks WHERE id = NEW.id));
    SET v_level = (SELECT name FROM levels WHERE id = NEW.level_id);
    
    SET v_content = CONCAT('[<span class="fw-bold text-info">',v_created_by,'</span>] ');
    IF NEW.cc_id > 0 THEN
    	SET v_content = CONCAT( v_content,'<span class="text-success">INSERT CC TASK</span> [<span class="fw-bold">',v_level,'</span>] with quantity: [',NEW.quantity,']');
    ELSE
    	SET v_content = CONCAT(v_content,'<span class="text-success">INSERT TASK</span> [<span class="fw-bold">',v_level,'</span>] with quantity: [',NEW.quantity,']');
    END IF;
    
    INSERT INTO project_logs(project_id,task_id,timestamp,content)
    VALUES(NEW.project_id,NEW.id,NEW.created_at,v_content);
    
END; //
DELIMITER ;