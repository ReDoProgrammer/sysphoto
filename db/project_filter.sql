DELIMITER //
CREATE PROCEDURE ProjectFilter(
	IN p_from_date timestamp,
    IN p_end_date timestamp,
    IN p_status varchar(20),
    IN p_search varchar(100),
    IN p_page INT,
    IN p_limit INT
)
BEGIN
	DECLARE v_sql varchar(5000);
    SET v_sql = "SELECT p.name,
                    c.acronym,
                    DATE_FORMAT(p.start_date, '%d/%m/%Y %H:%i') as start_date,
                    DATE_FORMAT(p.end_date, '%d/%m/%Y %H:%i') as end_date,
                    (SELECT CONCAT(GROUP_CONCAT(name SEPARATOR ', '), ' ')
                     FROM levels
                     WHERE FIND_IN_SET(levels.id, p.levels)
                    ) AS templates,
                    ps.name as status_name,
                    ps.color as status_color
            FROM projects p
            JOIN customers c ON p.customer_id = c.id
            LEFT JOIN project_statuses ps ON p.status_id = ps.id
            WHERE 1 = 1 ";
   	IF p_status IS NOT NULL THEN
        SET v_sql = CONCAT(v_sql, " AND FIND_IN_SET(levels.id,");
    END IF;

    SET @sql = CONCAT(@sql, " LIMIT ? OFFSET ?");

    -- Prepare and execute the main query
    PREPARE stmt FROM @sql;

    SET @p_search = CONCAT('%', p_search, '%');

    IF p_group > 0 THEN
        EXECUTE stmt USING @p_search, @p_search, @p_search, p_group, p_limit, (p_page-1)*p_limit;
    ELSE
        EXECUTE stmt USING @p_search, @p_search, @p_search, p_limit, (p_page-1)*p_limit;
    END IF;

    DEALLOCATE PREPARE stmt;
END; //
DELIMITER ;
