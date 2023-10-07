DELIMITER //
CREATE PROCEDURE ProjectDetailJoin(IN p_id bigint)
BEGIN
	SELECT
        p.id AS project_id,
        p.name AS project_name,
        c.acronym as customer,
        ps.name as status,
        COUNT(t.id) as tasks_number,
        CONCAT('[', GROUP_CONCAT(JSON_OBJECT('level', lv.name,'status',ts.name, 'quantity', t.quantity)), ']') AS tasks_list
    FROM projects p
    JOIN customers c ON p.customer_id = c.id
    JOIN project_statuses ps ON p.status_id = ps.id
    LEFT JOIN tasks t ON p.id = t.project_id
    LEFT JOIN levels lv ON t.level_id = lv.id
    LEFT JOIN task_statuses ts ON t.level_id = ts.id
    WHERE p.id = p_id
    GROUP BY p.id, p.name,ps.name,c.acronym;
END; //
DELIMITER ;
