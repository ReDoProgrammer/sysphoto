DELIMITER //
CREATE TRIGGER after_project_updated
AFTER UPDATE ON projects
FOR EACH ROW
BEGIN
	DECLARE v_actioner  varchar(100);
    DECLARE v_content varchar(255) DEFAULT '';
    
    DECLARE v_old_customer varchar(50);
    DECLARE v_new_customer varchar(50);
    
    DECLARE v_old_status varchar(20);
    DECLARE v_new_status varchar(20);
    
    DECLARE v_old_templates varchar(200);
    DECLARE v_new_templates varchar(200);
    
    DECLARE v_old_combo varchar(50);
    DECLARE v_new_combo varchar(50);
    
    DECLARE v_changed BOOLEAN DEFAULT FALSE;

    DECLARE v_role varchar(100) DEFAULT '';
    
    SET v_actioner = (SELECT acronym FROM users WHERE id = NEW.updated_by);
    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.updated_by));
    SET v_content = CONCAT(v_role,' [<span class="fw-bold text-info">',v_actioner,'</span>]');
    
       -- name
    	IF NEW.name <> OLD.name THEN
        	SET v_changed = TRUE;
        	SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE NAME</span> FROM [<span class="text-secondary">',OLD.name,'</span>] TO [<span class="text-info">',NEW.name,'</span>],');            
        END IF;
    -- //name
    
    -- customer
    	IF OLD.customer_id <> NEW.customer_id THEN
        	 SET v_changed = TRUE;
        	SET v_old_customer = (SELECT acronym FROM customers WHERE id = OLD.customer_id);
        	SET v_new_customer = (SELECT acronym FROM customers WHERE id = NEW.customer_id);
            SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE CUSTOMER</span> FROM [<span class="text-secondary">',v_old_customer,'</span>] TO [<span class="text-info">',v_new_customer,'</span>],');
           
        END IF;
    -- //customer
    
    -- description 
    	IF NEW.description <> OLD.description THEN
        	SET v_changed = TRUE;
        	SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE DESCRIPTION</span><a href="javascript:void(0)" onClick="ViewContent(\'', OLD.description,'TO: <hr/>', NEW.description,'\')">View detail</a> ,');            
        END IF;
    -- //description
    
    -- status
    	IF NEW.status_id <> OLD.status_id THEN
        	SET v_changed = TRUE;
        	SET v_old_status = (SELECT name FROM project_statuses WHERE id = OLD.status_id);
        	SET v_new_status = (SELECT name FROM project_statuses WHERE id = NEW.status_id);
            SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE STATUS</span> FROM [<span class="text-secondary">',v_old_status,'</span>] TO [<span class="text-info">',v_new_status,'</span>],');            
        END IF;
    -- //status
    
    -- START DATE
    	IF NEW.start_date <> OLD.start_date THEN
        	SET v_changed = TRUE;
        	SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE START DATE</span> FROM [<span class="text-secondary">',DATE_FORMAT(OLD.start_date,'%d/%m/%Y %H:%i'),'</span>] TO [<span class="text-info">',DATE_FORMAT(NEW.start_date,'%d/%m/%Y %H:%i'),'</span>],');            
        END IF;
    -- //START DATE
    
        -- END DATE
    	IF NEW.end_date <> OLD.end_date THEN
        	SET v_changed = TRUE;
        	SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE END DATE</span> FROM [<span class="text-secondary">',DATE_FORMAT(OLD.end_date,'%d/%m/%Y %H:%i'),'</span>] TO [<span class="text-info">',DATE_FORMAT(NEW.end_date,'%d/%m/%Y %H:%i'),'</span>],');            
        END IF;
    -- //END DATE
    
    -- templates
    	IF NEW.levels <> OLD.levels THEN
        	SET v_changed = TRUE;
        	IF LENGTH(NEW.levels) = 0 THEN -- huy ap dung template
            	SET v_old_templates = (SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM levels WHERE FIND_IN_SET(id, OLD.levels) > 0);
                SET v_content = CONCAT(v_content,' <span class="text-danger">CANCEL TEMPLATES</span> [',v_old_templates,'],');                
            ELSE
            	IF LENGTH(OLD.levels) = 0 THEN -- ap template
                	SET v_new_templates = (SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM levels WHERE FIND_IN_SET(id, NEW.levels) > 0);
                	SET v_content = CONCAT(v_content,' <span class="text-info">APPLY TEMPLATES</span> [',v_new_templates,'],');
                ELSE -- thay doi template
                	SET v_old_templates = (SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM levels WHERE FIND_IN_SET(id, OLD.levels) > 0);
                    SET v_new_templates = (SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM levels WHERE FIND_IN_SET(id, NEW.levels) > 0);
                    SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE TEMPLATES</span> FROM [<span class="text-secondary">',v_old_templates,'</span>] TO [<span class="text-info">',v_new_templates,'</span>],');
                END IF;
            END IF;
        END IF;
    -- //templates
    
    -- combo
    	IF OLD.combo_id <> NEW.combo_id THEN
        	SET v_changed = TRUE;
        	IF NEW.combo_id = 0 THEN -- neu la huy combo
            	SET v_old_combo = (SELECT name FROM comboes WHERE id = OLD.combo_id);
            	SET v_content = CONCAT(v_content,' <span class="text-danger">CANCEL COMBO</span> [',v_old_combo,'],');
            ELSE -- thay doi combo
            	IF OLD.combo_id =0 THEN -- neu truoc do chua co combo
                	SET v_new_combo = (SELECT name FROM comboes WHERE id = NEW.combo_id);
                    SET v_content = CONCAT(v_content,' <span class="text-success">APPLY COMBO</span> [',v_new_combo,'],');
                ELSE -- thay doi combo 1 sang combo 2
                	SET v_old_combo = (SELECT name FROM comboes WHERE id = OLD.combo_id);
                    SET v_new_combo = (SELECT name FROM comboes WHERE id = NEW.combo_id);
                    SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE COMBO</span> FROM [<span class="text-secondary">',v_old_combo,'</span>] TO [<span class="text-info">',v_new_combo,'</span>],');
                END IF;
            END IF;
        END IF;
    -- //combo
    
    -- priority
    	IF NEW.priority <> OLD.priority THEN
        	SET v_changed = TRUE;
        	IF NEW.priority = 1 THEN 
            	SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE PRIORITY</span> TO [<span class="text-danger">URGEN</span>],');
            ELSE
            	SET v_content = CONCAT(v_content,' <span class="text-warning">CHANGE PRIORITY</span> TO [<span class="text-secondary">NORMAL</span>],');
            END IF;            
        END IF;
    -- //priority
    
    
    IF v_changed = TRUE THEN
    		SET v_content = (SELECT TRIM(TRAILING ',' FROM v_content));
             INSERT INTO project_logs(project_id,timestamp,content)
             VALUES(OLD.id,NEW.updated_at,v_content);
    END IF;

    
END; //
DELIMITER ;
