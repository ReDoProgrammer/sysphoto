DELIMITER //
CREATE TRIGGER after_project_instruction_updated
AFTER UPDATE ON project_instructions
FOR EACH ROW
BEGIN
	DECLARE v_content varchar(255) DEFAULT '';
    DECLARE v_actioner varchar(50);
	IF NEW.content <> OLD.content THEN
     	SET v_actioner = (SELECT acronym FROM users WHERE id = NEW.updated_by);
    	SET v_content = CONCAT('[<span class="fw-bold text-info">',v_actioner,'</span>] <span class="text-warning">CHANGE INSTRUCTION</span> FROM [<span class="text-secondary">',OLD.content,'</span>] TO [<span class="text-info">',NEW.content,'</span>],');     
         INSERT INTO project_logs(project_id,timestamp,content)
         VALUES(OLD.project_id,NEW.updated_at,v_content);
    END IF;
END; //
DELIMITER ;