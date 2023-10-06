DELIMITER //
CREATE TRIGGER after_update_task
AFTER UPDATE ON tasks FOR EACH ROW
BEGIN
    DECLARE v_content VARCHAR(250) DEFAULT '';
    DECLARE v_actioner VARCHAR(50);
    
    DECLARE v_old_level VARCHAR(100) DEFAULT '';
    DECLARE v_new_level VARCHAR(100) DEFAULT '';
    
    DECLARE v_old_status VARCHAR(100) DEFAULT '';
    DECLARE v_new_status VARCHAR(100) DEFAULT '';
    
    DECLARE v_old_emp VARCHAR(100) DEFAULT '';
    DECLARE v_new_emp VARCHAR(100) DEFAULT '';
  
    SET v_actioner = (SELECT acronym FROM users WHERE id = NEW.updated_by);    
    
    -- name
    IF(OLD.name <> NEW.name) THEN
        SET v_content = CONCAT(v_actioner, ' CHANGE TASK NAME FROM [', OLD.name, '] TO [', NEW.name, ']');
    END IF;
    -- //end name
    
    -- description
    IF(OLD.description <> NEW.description) THEN
        CASE WHEN LENGTH(v_content) = 0 THEN
            SET v_content = CONCAT(v_actioner, ' CHANGE DESCRIPTION FROM [', OLD.description, '] TO [', NEW.description, ']');
        ELSE
            SET v_content = CONCAT(v_content, ', CHANGE DESCRIPTION FROM [', OLD.description, '] TO [', NEW.description, ']');
        END CASE;
    END IF;
    -- //end description
    
    -- task level
    IF(OLD.level_id <> NEW.level_id) THEN
        SET v_old_level = (SELECT name FROM levels WHERE id = OLD.level_id);
        SET v_new_level = (SELECT name FROM levels WHERE id = NEW.level_id);
        
        CASE WHEN LENGTH(v_content) = 0 THEN
            SET v_content = CONCAT(v_actioner, ' CHANGE TASK LEVEL FROM [', v_old_level, '] TO [', v_new_level, ']');
        ELSE
            SET v_content = CONCAT(v_content, ', CHANGE TASK LEVEL FROM [', v_old_level, '] TO [', v_new_level, ']');
        END CASE;
    END IF;
    -- //end task level
    
    -- status
    IF(OLD.status_id <> NEW.status_id) THEN
        SET v_old_status = (SELECT name FROM task_statuses WHERE id = OLD.status_id);
        SET v_new_status = (SELECT name FROM task_statuses WHERE id = NEW.status_id);
        
        CASE WHEN LENGTH(v_content) = 0 THEN
            SET v_content = CONCAT(v_actioner, ' CHANGE TASK STATUS FROM [', v_old_status, '] TO [', v_new_status, ']');
        ELSE
            SET v_content = CONCAT(v_content, ', CHANGE TASK STATUS FROM [', v_old_status, '] TO [', v_new_status, ']');
        END CASE;
    END IF;
    -- //end status
    
    -- EDITOR AND QA
    IF(OLD.editor_id <> NEW.editor_id) THEN
        SET v_new_emp = (SELECT acronym FROM users WHERE id = NEW.editor_id);
        
        CASE WHEN OLD.editor_id <> 0 THEN
            SET v_old_emp = (SELECT acronym FROM users WHERE id = OLD.editor_id);
            
            CASE WHEN LENGTH(v_content) = 0 THEN
                SET v_content = CONCAT(v_actioner, ' CHANGE EDITOR FROM [', v_old_emp, '] TO [', v_new_emp, ']');
            ELSE
                SET v_content = CONCAT(v_content, ', CHANGE EDITOR FROM [', v_old_emp, '] TO [', v_new_emp, ']');
            END CASE;
        ELSE
            SET v_new_level = (SELECT name FROM levels WHERE id = NEW.level_id);
            
            CASE WHEN NEW.editor_assigned = 1 THEN
                CASE WHEN LENGTH(v_content) = 0 THEN
                    SET v_content = CONCAT(v_actioner, ' ASSIGN EDITOR [', v_new_emp, '] ON TASK [', v_new_level, ']');
                ELSE
                    SET v_content = CONCAT(v_content, ', ASSIGN EDITOR [', v_new_emp, '] ON TASK [', v_new_level, ']');
                END CASE;
            ELSE
                CASE WHEN LENGTH(v_content) = 0 THEN
                    SET v_content = CONCAT(v_actioner, ' GET TASK [', v_new_level, ']');
                ELSE
                    SET v_content = CONCAT(v_content, ', GET TASK [', v_new_level, ']');
                END CASE;
            END CASE;
        END CASE;
    END IF; 
    
    IF(OLD.qa_id <> NEW.qa_id) THEN
        SET v_new_emp = (SELECT acronym FROM users WHERE id = NEW.qa_id);
        
        CASE WHEN OLD.qa_id <> 0 THEN
            SET v_old_emp = (SELECT acronym FROM users WHERE id = OLD.qa_id);
            
            CASE WHEN LENGTH(v_content) = 0 THEN
                SET v_content = CONCAT(v_actioner, ' CHANGE QA FROM [', v_old_emp, '] TO [', v_new_emp, ']');
            ELSE
                SET v_content = CONCAT(v_content, ', CHANGE QA FROM [', v_old_emp, '] TO [', v_new_emp, ']');
            END CASE;
        ELSE
            SET v_new_level = (SELECT name FROM levels WHERE id = NEW.level_id);
            
            CASE WHEN NEW.qa_assigned = 1 THEN
                CASE WHEN LENGTH(v_content) = 0 THEN
                    SET v_content = CONCAT(v_actioner, ' ASSIGN QA [', v_new_emp, '] ON TASK [', v_new_level, ']');
                ELSE
                    SET v_content = CONCAT(v_content, ', ASSIGN QA [', v_new_emp, '] ON TASK [', v_new_level, ']');
                END CASE;
            ELSE
                CASE WHEN LENGTH(v_content) = 0 THEN
                    SET v_content = CONCAT('QA [', v_actioner, '] GET TASK [', v_new_level, ']');
                ELSE
                    SET v_content = CONCAT(v_content, ', GET TASK [', v_new_level, ']');
                END CASE;
            END CASE;
        END CASE;
    END IF;
    -- //END EDITOR AND QA
    
    -- change quantity
    IF(OLD.quantity <> NEW.quantity) THEN
        CASE WHEN LENGTH(v_content) = 0 THEN
            SET v_content = CONCAT(v_actioner, ' CHANGE QUANTITY FROM [', OLD.quantity, '] TO [', NEW.quantity, ']');
        ELSE
            SET v_content = CONCAT(v_content, ', CHANGE QUANTITY FROM [', OLD.quantity, '] TO [', NEW.quantity, ']');
        END CASE;
    END IF;
    -- //end change quantity
    
    -- insert logs
    INSERT INTO projects(project_id, timestamp, content)
    VALUES(NEW.project_id, NEW.updated_at, v_content);
END; //
DELIMITER ;
