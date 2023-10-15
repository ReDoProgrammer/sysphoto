DELIMITER //
CREATE TRIGGER after_cc_inserted
AFTER INSERT ON ccs FOR EACH ROW
BEGIN
	DECLARE v_created_by varchar(100); 
    DECLARE v_role varchar(100) DEFAULT '';
     
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM tasks WHERE id = NEW.id));
    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.created_by));
    
    INSERT INTO project_logs(project_id,cc_id,timestamp,content)
    VALUES(NEW.project_id,NEW.id,NEW.created_at,CONCAT(v_role,' [<span class="fw-bold text-info">',v_created_by,'</span>] <span class="text-success">CREATE NEW CC</span> FROM [<span class="text-warning">',DATE_FORMAT(NEW.start_date, '%d/%m/%Y %H:%i'),'</span>] TO [<span class="text-warning">',DATE_FORMAT(NEW.end_date, '%d/%m/%Y %H:%i'),'</span>]'));
    
END; //
DELIMITER ;