DELIMITER //
CREATE TRIGGER before_cc_deleted
BEFORE DELETE ON ccs
FOR EACH ROW
BEGIN
	UPDATE tasks SET deleted_by = OLD.deleted_by, deleted_at = NOW() WHERE cc_id = OLD.id;
    DELETE FROM tasks WHERE cc_id = OLD.id;
END; //
DELIMITER ;