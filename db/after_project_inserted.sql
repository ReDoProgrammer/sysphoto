DELIMITER //
CREATE TRIGGER  after_project_created
AFTER INSERT ON projects FOR EACH ROW
BEGIN
	DECLARE v_created_by varchar(100);
    DECLARE v_customer varchar(100);
    
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM projects WHERE id = NEW.id));
    SET v_customer = (SELECT acronym FROM customers WHERE id = NEW.customer_id);
    INSERT INTO project_logs(project_id,timestamp,content)
    VALUES(NEW.id,NEW.created_at,CONCAT('[<span class="text-info fw-bold">',v_created_by,'</span>] <span class="text-success">CREATE PROJECT FOR CUSTOMER</span> [<span class="text-primary">',v_customer,'</span>]'));
END; //
DELIMITER ;