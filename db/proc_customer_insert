DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerInsert`(
    IN `p_group_id` INT, 
    IN `p_name` VARCHAR(200), 
    IN `p_email` VARCHAR(200), 
    IN `p_password` VARCHAR(200), 
    IN p_customer_url varchar(200),
    IN `p_created_by` INT)
BEGIN
	DECLARE v_acronym varchar(50) DEFAULT '';  
    SET v_acronym = CONCAT('C',GetInitials(p_name),YEAR(CURDATE()));
    
	INSERT INTO customers(group_id,name,acronym,email,pwd,customer_url,created_by)
    VALUES(p_group_id,p_name,v_acronym,p_email,md5(p_password),p_customer_url,p_created_by);
    SELECT LAST_INSERT_ID() AS last_id;
END$$
DELIMITER ;