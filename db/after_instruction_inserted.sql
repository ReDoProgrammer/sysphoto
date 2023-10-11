 DELIMITER //
 CREATE TRIGGER after_instruction_inserted
 AFTER INSERT ON project_instructions
 FOR EACH ROW
 BEGIN 
 	DECLARE v_ins_count INT DEFAULT 0;
    DECLARE v_actioner varchar(100);
    DECLARE v_content text DEFAULT '';
    SET v_ins_count = (SELECT COUNT(id) FROM project_instructions WHERE project_id = NEW.project_id and id < NEW.id);
    IF v_ins_count > 0 THEN
    	SET v_actioner = (SELECT acronym FROM users WHERE id = NEW.created_by);
        SET v_content = CONCAT('[<span class="fw-bold text-info">', v_actioner, '</span>] <span class="text-success">INSERT NEW INSTRUCTION</span> <a href="javascript:void(0)" onClick="ViewContent(\'', NEW.content, '\')">View detail</a>');

    	INSERT INTO project_logs(project_id,timestamp,content)
        VALUES(NEW.project_id,NEW.created_at,v_content);
    END IF;
 END; //
 DELIMITER ;