DELIMITER //
CREATE TRIGGER after_cc_inserted
AFTER INSERT ON ccs FOR EACH ROW
BEGIN
	DECLARE v_created_by varchar(100);    
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM tasks WHERE id = NEW.id));
    
    INSERT INTO project_logs(project_id,timestamp,content)
    VALUES(NEW.project_id,NEW.created_at,CONCAT('[<span class="fw-bold text-info">',v_created_by,'</span>] <span class="text-success">CREATE NEW CC</span> FROM [<span class="text-warning">',DATE_FORMAT(NEW.start_date, '%d/%m/%Y %H:%i'),'</span>] TO [<span class="text-warning">',DATE_FORMAT(NEW.end_date, '%d/%m/%Y %H:%i'),'</span>]'));
    
END; //
DELIMITER ;