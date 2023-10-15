DELIMITER //
CREATE TRIGGER after_task_deleted
AFTER DELETE ON tasks
FOR EACH ROW
BEGIN
	DECLARE v_level varchar(100);
    DECLARE v_role varchar(100) DEFAULT '';

    SET v_level = (SELECT name FROM levels WHERE id = OLD.level_id);
    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE acronym = OLD.deleted_by));
	INSERT INTO project_logs(project_id,task_id,timestamp,content)
    VALUES(OLD.project_id,OLD.id,OLD.deleted_at,CONCAT(v_role,' [<span class="text-info fw-bold">',OLD.deleted_by,'</span>] <span class="text-danger">DELETE TASK </span>[',v_level,']'));
END; //
DELIMITER ;
