DELIMITER //
CREATE TRIGGER  after_insert_project 
AFTER INSERT ON projects FOR EACH ROW
BEGIN
	DECLARE v_created_by varchar(100);
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM projects WHERE id = NEW.id));
    
    INSERT INTO project_logs(project_id,timestamp,content)
    VALUES(NEW.id,NEW.created_at,CONCAT('[',v_created_by,'] ','CREATE PROJECT' ));
END; //
DELIMITER ;