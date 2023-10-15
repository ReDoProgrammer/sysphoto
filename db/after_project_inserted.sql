DELIMITER //
CREATE TRIGGER  after_project_inserted
AFTER INSERT ON projects FOR EACH ROW
BEGIN
	DECLARE v_created_by varchar(100);
    DECLARE v_customer varchar(100);
    DECLARE v_role varchar(100) DEFAULT '';
    
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM projects WHERE id = NEW.id));
    SET v_customer = (SELECT acronym FROM customers WHERE id = NEW.customer_id);
    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.created_by));
    
    INSERT INTO project_logs(project_id,timestamp,action)
    VALUES(NEW.id,NEW.created_at,CONCAT(v_role,' [<span class="text-info fw-bold">',v_created_by,'</span>] <span class="text-success">CREATE PROJECT FOR CUSTOMER</span> [<span class="text-primary">',v_customer,'</span>]'));
END; //
DELIMITER ;