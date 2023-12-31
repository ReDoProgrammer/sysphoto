DELIMITER //
CREATE TRIGGER after_project_instruction_updated
AFTER UPDATE ON project_instructions
FOR EACH ROW
BEGIN
	DECLARE v_actions varchar(255) DEFAULT '';
    DECLARE v_content text DEFAULT '';
    DECLARE v_actioner varchar(50);
    DECLARE v_role varchar(100) DEFAULT '';
    
	IF NEW.content <> OLD.content THEN
     	SET v_actioner = (SELECT acronym FROM users WHERE id = NEW.updated_by);
        SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.updated_by));
    	SET v_actions = CONCAT(v_role,' [<span class="fw-bold text-info">',v_actioner,'</span>] <span class="text-warning">CHANGE INSTRUCTION</span> <a href="javascript:void(0)" onClick="ViewContent(',NEW.id,')">View detail</a>,');     
        SET v_content = CONCAT('<span class="text-secondary">FROM:</span><br/><hr>',OLD.content,'<span class="mt-3 text-secondary">TO:</span><hr/>',NEW.content);
        INSERT INTO project_logs(project_id,timestamp,action,content)
        VALUES(OLD.project_id,NEW.updated_at,v_actions,v_content);
    END IF;
END; //
DELIMITER ;