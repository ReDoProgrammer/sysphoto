DELIMITER //
CREATE TRIGGER after_task_updated
AFTER UPDATE ON tasks FOR EACH ROW
BEGIN
    DECLARE v_content VARCHAR(250) DEFAULT '';
    DECLARE v_action VARCHAR(250) DEFAULT '';
    
    DECLARE v_old_level VARCHAR(100) DEFAULT '';
    DECLARE v_new_level VARCHAR(100) DEFAULT '';
    
    DECLARE v_old_status VARCHAR(100) DEFAULT '';
    DECLARE v_new_status VARCHAR(100) DEFAULT '';
    
    DECLARE v_old_emp VARCHAR(100) DEFAULT '';
    DECLARE v_new_emp VARCHAR(100) DEFAULT '';
  
  	SET v_new_level = (SELECT name FROM levels WHERE id = NEW.level_id); -- lay level hien tai

    SET v_content = CONCAT('[<span class="fw-bold text-info">',(SELECT acronym FROM users WHERE id = NEW.updated_by), '</span>]');
   
    
    -- description
    IF(OLD.description <> NEW.description) THEN
    	SET v_action = CONCAT('<span class="text-warning">CHANGE TASK DESCRIPTION</span> FROM [<span class="text-secondary">', OLD.description, '</span>] TO [<span class="text-primary">', NEW.description, '</span>],');
         SET v_content = CONCAT(v_content,' ',v_action);
    END IF;
    -- //end description
    
    -- task level
    IF(OLD.level_id <> NEW.level_id) THEN
        SET v_old_level = (SELECT name FROM levels WHERE id = OLD.level_id);
       
        SET v_action = CONCAT('<span class="text-warning">CHANGE TASK LEVEL</span> FROM [<span class="text-secondary">', v_old_level, '</span>] TO [<span class="text-primary">', v_new_level, '</span>],');
        SET v_content = CONCAT(v_content,' ',v_action);        
    END IF;
    -- //end task level
    
    -- status
    IF(OLD.status_id <> NEW.status_id) THEN
        SET v_old_status = (SELECT name FROM task_statuses WHERE id = OLD.status_id);
        SET v_new_status = (SELECT name FROM task_statuses WHERE id = NEW.status_id);
        
         SET v_action = CONCAT('<span class="text-warning">CHANGE TASK STATUS</span> FROM [<span class="text-secondary">', v_old_status, '</span>] TO [<span class="text-primary">', v_new_status, '</span>],');
        SET v_content = CONCAT(v_content,' ',v_action); 
    END IF;
    -- //end status
    
    -- EDITOR
    IF(OLD.editor_id <> NEW.editor_id) THEN
    	SET v_new_emp = (SELECT acronym FROM users WHERE id = NEW.editor_id);        
      	IF OLD.editor_id = 0 THEN -- neu truoc do chua co editor     		
            IF NEW.editor_assigned = 1 THEN -- neu la gan editor
            	SET v_action = CONCAT('<span class="text-warning">ASSIGN EDITOR</span> [<span class="text-warning">', v_new_emp, '</span>] ON TASK [<span class="text-primary">', v_new_level, '</span>],');        
                SET v_content = CONCAT(v_content,' ',v_action); 
            ELSE -- neu la editor get task
            	SET v_action = CONCAT('EDITOR: [<span class="fw-bold text-info">',v_new_emp, '</span>] <span class="text-success">GET TASK</span> [',v_new_level,']');
                SET v_content = v_action;
            END IF;            
     	ELSE -- neu truoc do co editor
        	IF NEW.editor_id = 0 THEN -- neu la huy editor
            	SET v_action = CONCAT('<span class="text-danger">UNASSIGN EDITOR</span> ON TASK [<span class="text-primary">', v_new_level, '</span>],');        
                SET v_content = CONCAT(v_content,' ',v_action); 
            ELSE -- thay sang editor khac
            	SET v_old_emp = (SELECT acronym FROM users WHERE id = OLD.editor_id);
                SET v_action = CONCAT('<span class="text-warning">CHANGE EDITOR</span> FROM [<span class="text-secondary">', v_old_emp, '</span>] TO [<span class="text-info">', v_new_emp, '</span>]  ON TASK [<span class="text-primary">', v_new_level, '</span>],');        
                SET v_content = CONCAT(v_content,' ',v_action); 
            END IF;      
      	END IF;       
    END IF; 
    -- //EDITOR
    
    
    -- QA
     IF(OLD.qa_id <> NEW.qa_id) THEN
    	SET v_new_emp = (SELECT acronym FROM users WHERE id = NEW.qa_id);        
      	IF OLD.qa_id = 0 THEN -- neu truoc do chua co QA     		
            IF NEW.qa_assigned = 1 THEN -- neu la gan QA
            	SET v_action = CONCAT('<span class="text-warning">ASSIGN QA</span> [<span class="text-warning">', v_new_emp, '</span>] ON TASK [<span class="text-primary">', v_new_level, '</span>],');        
                SET v_content = CONCAT(v_content,' ',v_action); 
            ELSE -- neu la QA get task
            	SET v_action = CONCAT('QA: [<span class="fw-bold text-info">',v_new_emp, '</span>] <span class="text-success">GET TASK</span> [',v_new_level,']');
                SET v_content = v_action;
            END IF;            
     	ELSE -- neu truoc do co QA
        	IF NEW.qa_id = 0 THEN -- neu la huy QA
            	SET v_action = CONCAT('<span class="text-danger">UNASSIGN QA</span> ON TASK [<span class="text-primary">', v_new_level, '</span>],');        
                SET v_content = CONCAT(v_content,' ',v_action); 
            ELSE -- thay doi QA
            	SET v_old_emp = (SELECT acronym FROM users WHERE id = OLD.qa_id);
                SET v_action = CONCAT('<span class="text-warning">CHANGE QA</span> FROM [<span class="text-secondary">', v_old_emp, '</span>] TO [<span class="text-info">', v_new_emp, '</span>]  ON TASK [<span class="text-primary">', v_new_level, '</span>],');        
                SET v_content = CONCAT(v_content,' ',v_action); 
            END IF;      
      	END IF;       
    END IF; 
    
    -- // QA
    	
    -- DC
    	IF NEW.dc_timestamp <> OLD.dc_timestamp THEN -- neu co tac dong cua DC
        	SET v_new_emp = (SELECT acronym FROM users WHERE id = NEW.dc_id);     
        	IF OLD.dc_id = 0 THEN -- DC nhan task            	
            	SET v_action = CONCAT('DC: [<span class="fw-bold text-info">',v_new_emp, '</span>] <span class="text-success">GET TASK</span> [',v_new_level,']');
                SET v_content = v_action;
            ELSE -- DC submit task hoac thay doi DC
            	IF OLD.dc_id <> NEW.dc_id THEN -- thay doi DC
                	SET v_old_emp = (SELECT acronym FROM users WHERE id = OLD.dc_id);    
                    SET v_action = CONCAT('<span class="text-warning">CHANGE DC</span> FROM [<span class="text-secondary">', v_old_emp, '</span>] TO [<span class="text-info">', v_new_emp, '</span>]  ON TASK [<span class="text-primary">', v_new_level, '</span>],'); 
                   	SET v_content = CONCAT(v_content,' ',v_action); 
                ELSE  -- DC submit hoac reject task
                	IF NEW.dc_submit = 1 THEN -- submit task
                    	SET v_action = CONCAT('DC: [<span class="fw-bold text-info">',v_new_emp, '</span>] <span class="text-success">SUBMIT TASK</span> [',v_new_level,']');               
                    ELSE -- reject task
                    	SET v_action = CONCAT('DC: [<span class="fw-bold text-info">',v_new_emp, '</span>] <span class="text-danger">REJECT TASK</span> [',v_new_level,']');  
                    END IF;
                     SET v_content = v_action;
                END IF;
            END IF;
        END IF;  
    -- //DC
    
    -- quantity
    IF(OLD.quantity <> NEW.quantity) THEN
        SET v_action = CONCAT('<span class="text-warning">CHANGE TASK QUANTITY</span> FROM [<span class="text-secondary">', OLD.quantity, '</span>] TO [<span class="text-primary">', NEW.quantity, '</span>],');
        SET v_content = CONCAT(v_content,' ',v_action); 
    END IF;
    -- //end quantity
    
    -- insert logs
    INSERT INTO project_logs(project_id, timestamp, content)
    VALUES(OLD.project_id, NEW.updated_at, v_content);
END; //
DELIMITER ;
