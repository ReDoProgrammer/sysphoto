-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th10 12, 2023 lúc 07:23 AM
-- Phiên bản máy phục vụ: 10.4.28-MariaDB
-- Phiên bản PHP: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `sysphotohome`
--

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CCDelete` (IN `p_id` BIGINT, IN `p_deleted_by` VARCHAR(100))   BEGIN
	UPDATE ccs 
    SET deleted_by = p_deleted_by, deleted_at = NOW() 
    WHERE id = p_id;
    IF ROW_COUNT() > 0 THEN
		DELETE FROM ccs WHERE id = p_id;
    	SELECT ROW_COUNT() as rows_deleted;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CCInsert` (IN `p_project` BIGINT, IN `p_feedback` TEXT, IN `p_start_date` TIMESTAMP, IN `p_end_date` TIMESTAMP, IN `p_created_by` INT)   BEGIN
	INSERT INTO ccs(project_id,feedback,start_date,end_date,created_by)
    VALUES(p_project,NormalizeContent(p_feedback),p_start_date,p_end_date,p_created_by);
    SELECT LAST_INSERT_ID() AS last_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CusomerDestroy` (IN `p_id` INT)   BEGIN
	DECLARE v_rows_deleted INT;
    
	DELETE FROM customers WHERE id = p_id;
    SELECT COUNT(id) INTO v_rows_deleted FROM customers WHERE id = p_id;
    SELECT v_rows_deleted;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerBasicalAll` ()   BEGIN
	SELECT 
        id,
        CONCAT(name,' - [',acronym,']') as fullname
    FROM customers
    ORDER BY name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerCheckAcronym` (IN `p_id` INT, IN `p_acronym` VARCHAR(250))   BEGIN
    DECLARE checkacronym INT;

    SELECT COUNT(id) INTO checkacronym
    FROM customers
    WHERE acronym = p_acronym
    AND ((id <> p_id and p_id <> 0) OR p_id =0);

    SELECT checkacronym;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerCheckEmail` (IN `p_id` INT, IN `p_email` VARCHAR(250))   BEGIN
    DECLARE checkemail INT;

    SELECT COUNT(id) INTO checkemail
    FROM customers
    WHERE email = p_email
    AND (( id <> p_id and p_id<>0) OR p_id IS NULL);

    SELECT checkemail;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerDetailJoin` (IN `p_id` BIGINT)   BEGIN
    SELECT cp.name as company,c.avatar, c.name, c.acronym, c.email, c.customer_url, g.name as customer_group,
        cm.name as color_mode, op.name as output,c.size, c.is_straighten, c.straighten_remark, c.tv, c.fire, c.sky, c.grass,
        ns.name as national_style,cl.name as cloud,NormalizeContent(c.style_remark) as style_remark, DATE_FORMAT(c.created_at, '%d/%m/%Y %H:%i:%s') as created_at, u.fullname as created_by
    FROM customers c
    LEFT JOIN companies cp ON c.company_id = cp.id
    LEFT JOIN customer_groups g ON c.group_id = g.id
    LEFT JOIN color_modes cm ON c.color_mode_id = cm.id
    LEFT JOIN outputs op ON c.output_id = op.id
    LEFT JOIN national_styles ns ON c.national_style_id = ns.id
    LEFT JOIN clouds cl ON c.cloud_id = cl.id
    JOIN users u ON c.id = u.id
    WHERE c.id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerFilter` (IN `p_page` INT, IN `p_limit` INT, IN `p_group` INT, IN `p_search` VARCHAR(200))   BEGIN
    -- Khai báo biến để lưu trữ điều kiện WHERE và điều kiện LIMIT
    DECLARE where_clause VARCHAR(100) DEFAULT '';
    DECLARE limit_clause VARCHAR(50) DEFAULT '';
    DECLARE p_row_count INT;
    DECLARE p_pages INT;
    	

  

    -- Bổ sung điều kiện LIKE nếu p_search không rỗng
    IF p_search <> '' THEN        
        SET where_clause = CONCAT(where_clause, ' ( c.name LIKE CONCAT("%", p_search, "%")');
        SET where_clause = CONCAT(where_clause, '  c.acronym LIKE CONCAT("%", p_search, "%")');
        SET where_clause = CONCAT(where_clause, '  c.email LIKE CONCAT("%", p_search, "%")');
    END IF;
    
      -- Bổ sung điều kiện WHERE nếu p_group > 0
    IF p_group > 0 THEN
        SET where_clause = CONCAT('AND c.group_id = ', p_group);
    END IF;

    -- Tính toán giá trị của pages trước khi nối với p_limit và p_page
    SET @sql_count_query = CONCAT(
        'SELECT COUNT(*) 
         FROM customers c
         JOIN customer_groups g ON c.group_id = g.id
         LEFT JOIN companies cp ON c.company_id = cp.id',
         ' ', -- Dấu cách để ngăn truy vấn bị gộp với where_clause
         where_clause
    );

    PREPARE stmt_count FROM @sql_count_query;
    EXECUTE stmt_count USING p_search;
    SELECT FOUND_ROWS() INTO p_row_count;
    DEALLOCATE PREPARE stmt_count;

    IF p_limit > 0 THEN
        SET p_pages = p_row_count DIV p_limit;
        IF p_row_count % p_limit > 0 THEN
            SET p_pages = p_pages + 1;
        END IF;
    ELSE
        SET p_pages = 1;
    END IF;
    
    SELECT p_pages AS pages;

    -- Bổ sung điều kiện LIMIT sau khi tính giá trị của pages
    IF p_limit > 0 THEN
        SET limit_clause = CONCAT('LIMIT ', (p_page - 1) * p_limit, ', ', p_limit);
    END IF;

    -- Tạo truy vấn dựa trên điều kiện WHERE và điều kiện LIMIT
    SET @sql_query = CONCAT(
        'SELECT c.name, c.acronym, c.email, c.customer_url, g.name as group_name, cp.name as company
         FROM customers c
         JOIN customer_groups g ON c.group_id = g.id
         LEFT JOIN companies cp ON c.company_id = cp.id',
         ' ', -- Dấu cách để ngăn truy vấn bị gộp với where_clause hoặc limit_clause (nếu có)
         where_clause,
         ' ',
         limit_clause
    );

    -- Chuẩn bị và thực thi truy vấn với p_search
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt USING p_search;

    -- Đóng truy vấn và DEALLOCATE PREPARE
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerInsert` (IN `p_group_id` INT, IN `p_name` VARCHAR(100), IN `p_acronym` VARCHAR(50), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_customer_url` VARCHAR(255), IN `p_color_mode` INT, IN `p_output` INT, IN `p_size` VARCHAR(255), IN `p_is_straighten` BOOLEAN, IN `p_straighten_remark` VARCHAR(255), IN `p_tv` VARCHAR(255), IN `p_fire` VARCHAR(255), IN `p_sky` VARCHAR(255), IN `p_grass` VARCHAR(255), IN `p_national_style` INT, IN `p_cloud` INT, IN `p_style_remark` TEXT, IN `p_created_by` INT)   BEGIN
    SET p_name = NormalizeString(p_name);
	INSERT INTO customers(group_id,name,acronym,email,pwd,customer_url,color_mode_id,output_id,size,is_straighten,straighten_remark,tv,fire,sky,grass,national_style_id,cloud_id,style_remark,created_by)
    		VALUES(p_group_id,p_name,p_acronym,p_email,md5(p_password),p_customer_url,p_color_mode,p_output,p_size,p_is_straighten,p_straighten_remark,p_tv,p_fire,p_sky,p_grass,p_national_style,p_cloud,p_style_remark,p_created_by);
            SELECT LAST_INSERT_ID() AS last_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerUpdate` (IN `p_id` BIGINT, IN `p_group_id` INT, IN `p_name` VARCHAR(100), IN `p_acronym` VARCHAR(100), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_customer_url` VARCHAR(255), IN `p_color_mode` INT, IN `p_output` INT, IN `p_size` VARCHAR(255), IN `p_is_straighten` BOOLEAN, IN `p_straighten_remark` VARCHAR(255), IN `p_tv` VARCHAR(255), IN `p_fire` VARCHAR(255), IN `p_sky` VARCHAR(255), IN `p_grass` VARCHAR(255), IN `p_national_style` INT, IN `p_cloud` INT, IN `p_style_remark` TEXT, IN `p_updated_by` INT)   BEGIN
    SET p_name = NormalizeString(p_name);
	UPDATE customers
    SET group_id = p_group_id, name = p_name, acronym = p_acronym, email = p_email, pwd = MD5(p_password), customer_url = p_customer_url, color_mode_id = p_color_mode, output_id = p_output, size = p_size, is_straighten = p_is_straighten, straighten_remark = p_straighten_remark, tv = p_tv,fire=p_fire,sky = p_sky, grass = p_grass, national_style_id = p_national_style, cloud_id = p_cloud, style_remark = p_style_remark, updated_at = CURRENT_TIMESTAMP(), updated_by = p_updated_by
    WHERE id = p_id;
            SELECT ROW_COUNT() AS rows_changed;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EditorGetTask` (IN `p_editor` INT)   BEGIN
   DECLARE v_levels VARCHAR(100) DEFAULT '';
    DECLARE v_processing_tasks_count INT DEFAULT 0;
    DECLARE v_count_available_task INT DEFAULT 0;


    IF NOT EXISTS(SELECT * FROM users e JOIN employee_groups g ON e.editor_group_id = g.id WHERE e.id = p_editor)  THEN     
        SELECT JSON_OBJECT('code', '403', 'msg', CONCAT('You have not been assigned levels to access tasks. Please contact your administrator.'),'icon','danger','heading','Forbidden') AS msg;
    ELSE
        SET v_processing_tasks_count = (SELECT COUNT(id) FROM tasks
            WHERE editor_id = p_editor
            AND FIND_IN_SET(status_id, '0,2,5') > 0);
        IF v_processing_tasks_count > 0 THEN
             SELECT JSON_OBJECT('code', '423', 'msg', CONCAT('You cannot get more tasks until your current task has been submitted.'),'icon','danger','heading','Locked ') AS msg;
        ELSE          
            IF EXISTS( SELECT * FROM tasks t INNER JOIN projects p ON t.project_id = p.id WHERE t.editor_id = 0
                AND FIND_IN_SET(t.level_id, (SELECT levels FROM employee_groups WHERE id = (SELECT editor_group_id FROM users WHERE id = p_editor))) > 1 ORDER BY p.end_date LIMIT 1) THEN
                UPDATE tasks
                SET editor_id = p_editor, editor_timestamp = NOW(), updated_by = p_editor, updated_at = NOW()
                WHERE id = (SELECT  t.id
                                    FROM tasks t
                                    INNER JOIN projects p ON t.project_id = p.id
                                    WHERE t.editor_id = 0
                                    AND FIND_IN_SET(t.level_id, (SELECT levels FROM employee_groups WHERE id = (SELECT editor_group_id FROM users WHERE id = p_editor))) > 1 
                                    ORDER BY p.end_date
                                    LIMIT 1);
                IF ROW_COUNT() > 0 THEN
                    SELECT JSON_OBJECT('code', '200', 'msg', CONCAT('You have successfully obtained the task.'),'icon','success','heading','Get Task successfully ') AS msg;
                ELSE
                    SELECT JSON_OBJECT('code', '503', 'msg', CONCAT('Unable to fetch additional tasks.'),'icon','danger','heading','Locked ') AS msg;
                END IF;
            ELSE
                 SELECT JSON_OBJECT('code', '404', 'msg', CONCAT('No available task found.'),'icon','warning','heading','Not Found ') AS msg;
            END IF;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EmployeePages` (IN `p_group` INT, IN `p_search` VARCHAR(200), IN `p_limit` INT)   BEGIN
    DECLARE count INT;
    DECLARE total_count INT;

    SET p_search = CONCAT('%', p_search, '%');

    SELECT COUNT(*) INTO total_count
    FROM users u
    LEFT JOIN user_types ut ON u.type_id = ut.id
    LEFT JOIN employee_groups e ON u.editor_group_id = e.id
    LEFT JOIN employee_groups q ON u.qa_group_id = q.id
    LEFT JOIN user_groups ug ON u.group_id = ug.id
    WHERE (u.fullname LIKE p_search OR u.acronym LIKE p_search OR u.email LIKE p_search);

    IF p_group > 0 THEN
        SELECT COUNT(*) INTO count
        FROM users u
        LEFT JOIN user_types ut ON u.type_id = ut.id
        LEFT JOIN employee_groups e ON u.editor_group_id = e.id
        LEFT JOIN employee_groups q ON u.qa_group_id = q.id
        LEFT JOIN user_groups ug ON u.group_id = ug.id
        WHERE (u.fullname LIKE p_search OR u.acronym LIKE p_search OR u.email LIKE p_search)
        AND u.group_id = p_group;
    ELSE
        SET count = total_count;
    END IF;

    SELECT CEIL(count / p_limit) as pages;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EmployeeSearch` (IN `p_search` VARCHAR(255), IN `p_group` INT, IN `p_limit` INT, IN `p_page` INT)   BEGIN
    SET @sql = "SELECT u.id, u.fullname, u.acronym, u.email,
                    CASE WHEN u.status = 1 THEN 'Active' ELSE 'Inactive' END as status,
                    ut.name as role, ug.name as egroup,
                    e.name as editor, q.name as qa,
                    DATE_FORMAT(u.created_at, '%d/%m/%Y %H:%i') as joined_date                    
                FROM users u
                LEFT JOIN user_types ut ON u.type_id = ut.id
                LEFT JOIN employee_groups e ON u.editor_group_id = e.id
                LEFT JOIN employee_groups q ON u.qa_group_id = q.id
                LEFT JOIN user_groups ug ON u.group_id = ug.id;
                ";

    IF p_group > 0 THEN
        SET @sql = CONCAT(@sql, " AND u.group_id = ?");
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PrjectGetCCsWithTasks` (IN `p_project` BIGINT)   BEGIN
    SELECT 
        c.id AS c_id,
        c.feedback AS feedback,
        DATE_FORMAT(c.start_date, '%d/%m/%Y %H:%i') as start_date,
        DATE_FORMAT(c.end_date, '%d/%m/%Y %H:%i') as end_date,
        IF(
            COUNT(t.id) > 0,
            CONCAT('[', GROUP_CONCAT(
                JSON_OBJECT(
                    'task_id', t.id,
                    'level', lv.name,
                    'level_color',lv.color,
                    'description',t.description,
                    'quantity', t.quantity,
                    'editor', e.acronym,
                    'qa', q.acronym,
                    'dc', dc.acronym,
                    'status_id',t.status_id,
                    'status', ts.name,
                    'status_color', ts.color
                ) SEPARATOR ','
            ), ']'),
            '[]'
        ) AS tasks_list
    FROM ccs c
    LEFT JOIN tasks t ON c.id = t.cc_id
    LEFT JOIN levels lv ON t.level_id = lv.id
    LEFT JOIN users e ON t.editor_id = e.id
    LEFT JOIN users q ON t.qa_id = q.id
    LEFT JOIN users dc ON t.dc_id = dc.id
    LEFT JOIN task_statuses ts ON t.status_id = ts.id
    WHERE c.project_id = p_project
    GROUP BY c.id, c.project_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectApplyingTemplates` (IN `p_id` BIGINT)   BEGIN
	DECLARE v_levels VARCHAR(100);
    DECLARE v_created_by INT;
    DECLARE insertCount INT DEFAULT 0;
    
    SELECT levels INTO v_levels FROM projects WHERE id = p_id;
    SELECT created_by INTO v_created_by FROM projects WHERE id = p_id;

    SET @start = 1;
    SET @end = LOCATE(',', v_levels);
    
    -- Kiểm tra xem @end có rỗng hay không
    IF @end IS NOT NULL THEN
        WHILE @end > 0 DO
            INSERT INTO tasks (project_id, level_id,auto_gen, created_by)
            VALUES (p_id, SUBSTRING(v_levels, @start, @end - @start),1, v_created_by);
            SET @start = @end + 1;
            SET @end = LOCATE(',', v_levels, @start);
            SET insertCount = insertCount + 1;
        END WHILE;
    END IF;

    -- Xử lý giá trị cuối cùng
    IF SUBSTRING(v_levels, @start) > 0 THEN
        INSERT INTO tasks (project_id, level_id,auto_gen, created_by)
        VALUES (p_id, SUBSTRING(v_levels, @start),1, v_created_by);
        
        SET insertCount = insertCount + 1;
    END IF;
    
    SELECT insertCount AS rows_inserted;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectCheckName` (IN `p_id` INT, IN `p_name` VARCHAR(200))   BEGIN
	DECLARE v_count INT;
	SELECT count(id) INTO v_count FROM projects 
    WHERE LOWER(TRIM(name)) = LOWER(TRIM(p_name)) 
    AND ((p_id > 0 AND id <> p_id) OR p_id = 0);
    SELECT v_count AS available_rows;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectDescriptions` (IN `p_id` BIGINT)   BEGIN
    SELECT description as content, created_at FROM projects WHERE id = p_id
    UNION ALL
    SELECT feedback as content, created_at FROM ccs WHERE project_id = p_id
    UNION ALL
    SELECT content, created_at FROM project_instructions WHERE project_id = p_id
    ORDER BY created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectDetailJoin` (IN `p_id` BIGINT)   BEGIN
    SELECT 
    p.id,
    p.customer_id,
    p.name as project_name,
    p.description,
    MIN(pi.content) as instruction,
    p.levels,
    p.priority,
    DATE_FORMAT(p.start_date, '%d/%m/%Y %H:%i') as start_date,
    DATE_FORMAT(p.end_date, '%d/%m/%Y %H:%i') as end_date,
    p.combo_id,cb.name as combo, cb.color as combo_color,
    p.status_id,
    pst.name status,
    pst.color as status_color,    
    IF(
        COUNT(t.id) > 0,
        CONCAT('[', GROUP_CONCAT(
            DISTINCT JSON_OBJECT(
                'id', t.id,
                'level', lv.name,
                'level_color', lv.color,
                'quantity', t.quantity,
                'status_id', t.status_id,
                'status', ts.name,
                'status_color', ts.color,
                'editor', e.acronym,
                'qa', q.acronym,
                'dc', dc.acronym,
                'cc_id', t.cc_id
            ) ORDER BY t.id DESC SEPARATOR ','
        ), ']'),
        '[]'
    ) AS tasks_list
    FROM projects p
    LEFT JOIN project_instructions pi ON pi.project_id = p.id
    LEFT JOIN project_statuses pst ON p.status_id = pst.id
    LEFT JOIN tasks t ON p.id = t.project_id
    LEFT JOIN users e ON t.editor_id = e.id
    LEFT JOIN users q ON t.qa_id = q.id
    LEFT JOIN users dc ON t.dc_id = dc.id
    LEFT JOIN levels lv ON t.level_id = lv.id
    LEFT JOIN task_statuses ts ON t.status_id = ts.id
    LEFT JOIN comboes cb ON p.combo_id = cb.id
    WHERE p.id = p_id
    GROUP BY p.id
    ORDER BY p.id DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectFilter` (IN `p_from_date` TIMESTAMP, IN `p_to_date` TIMESTAMP, IN `p_status` VARCHAR(100), IN `p_search` VARCHAR(200), IN `p_page` INT, IN `p_limit` INT)   BEGIN
    DECLARE v_offset INT;
    SET v_offset = (p_page - 1) * p_limit;

    SELECT 
        p.id, p.name,
        p.priority,
        c.acronym,
        DATE_FORMAT(p.start_date, '%d/%m/%Y %H:%i') AS start_date,
        DATE_FORMAT(p.end_date, '%d/%m/%Y %H:%i') AS end_date,
        IF(LENGTH(p.levels) = 0,
            '-',
            (SELECT CONCAT(GROUP_CONCAT(name SEPARATOR ', '), ' ')
             FROM levels
             WHERE FIND_IN_SET(levels.id, p.levels)
            )
        ) AS templates,
        SUM(CASE WHEN t.auto_gen = 1 THEN 1 ELSE 0 END) as gen_number,
        IFNULL(p.status_id, '-1') as status_id,
        IFNULL(ps.name, 'Initial') AS status_name,
        IFNULL(ps.color, 'bg-secondary') AS status_color
    FROM projects p
    JOIN customers c ON p.customer_id = c.id
    LEFT JOIN project_statuses ps ON p.status_id = ps.id
    LEFT JOIN tasks t ON t.project_id = p.id
    WHERE p.end_date >= p_from_date AND p.end_date <= p_to_date
        AND (p.name LIKE CONCAT('%', p_search, '%') OR c.acronym LIKE CONCAT('%', p_search, '%'))
        AND (
            p_status = '' OR FIND_IN_SET(p.status_id, p_status)
        )
    GROUP BY p.id, p.name,p.priority, c.acronym, p.start_date, p.end_date, p.levels, p.status_id, ps.name, ps.color
    LIMIT v_offset, p_limit;

  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectInsert` (IN `p_customer_id` BIGINT, IN `p_name` VARCHAR(255), IN `p_start_date` TIMESTAMP, IN `p_end_date` TIMESTAMP, IN `p_status` INT, IN `p_combo_id` INT, IN `p_levels` VARCHAR(100), IN `p_priority` TINYINT, IN `p_description` TEXT, IN `p_created_by` INT)   BEGIN
	INSERT INTO projects(customer_id,name,start_date,end_date,status_id,combo_id,levels,priority,description,created_by)
    VALUES(p_customer_id,p_name,p_start_date,p_end_date,p_status,p_combo_id,p_levels,p_priority,NormalizeContent(p_description),p_created_by);
    SELECT LAST_INSERT_ID() AS last_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectInstruction1stUpdate` (IN `p_project_id` BIGINT, IN `p_content` TEXT, IN `p_updated_by` INT)   BEGIN
	DECLARE v_id bigint;
    SET v_id = (SELECT MIN(id) FROM project_instructions WHERE project_id = p_project_id);
    
    UPDATE project_instructions
    SET 
    	content = NormalizeContent(p_content),
        updated_at = NOW(),
        updated_by = p_updated_by
    WHERE id = v_id;
    
    SELECT ROW_COUNT() as updated_rows;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectInstructionInsert` (IN `p_project_id` BIGINT, IN `p_content` TEXT, IN `p_created_by` INT)   BEGIN
	INSERT INTO project_instructions(project_id,content,created_by)
    VALUES(p_project_id,NormalizeContent(p_content),p_created_by);
    SELECT LAST_INSERT_ID() AS last_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectLogs` (IN `p_id` BIGINT)   BEGIN
	SELECT 
    	id,
    	action,
    	DATE_FORMAT(timestamp, '%d/%m/%Y %H:%i:%s') as timestamp
    FROM 	project_logs 
    WHERE project_id = p_id 
    ORDER BY id DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectPages` (IN `p_from_date` TIMESTAMP, IN `p_end_date` TIMESTAMP, IN `p_status` VARCHAR(20), IN `p_search` VARCHAR(100), IN `p_limit` INT)   BEGIN
    DECLARE v_sql VARCHAR(5000);
    DECLARE v_total_records INT;
    DECLARE v_pages INT;

    -- Initialize v_total_records
    SET v_total_records = 0;

    -- Set up dynamic SQL
    SET v_sql = "SELECT COUNT(*) FROM projects p
                JOIN customers c ON p.customer_id = c.id
                LEFT JOIN project_statuses ps ON p.status_id = ps.id
                WHERE 1 = 1 ";

    IF p_status IS NOT NULL THEN
        SET v_sql = CONCAT(v_sql, " AND FIND_IN_SET(levels.id,");
    END IF;

    IF p_search IS NOT NULL AND p_search <> '' THEN
        SET v_sql = CONCAT(v_sql, " AND (p.name LIKE ? OR c.acronym LIKE ?) ");
    END IF;

    -- Prepare and execute the query to get the total number of records
    PREPARE stmt_count FROM v_sql;
    
    IF p_search IS NOT NULL AND p_search <> '' THEN
        EXECUTE stmt_count USING @p_search, @p_search;
    ELSE
        EXECUTE stmt_count;
    END IF;

    -- Store the result into v_total_records
    SELECT FOUND_ROWS() INTO v_total_records;

    -- Deallocate the prepared statement
    DEALLOCATE PREPARE stmt_count;

    -- Calculate the total number of pages
    SET v_pages = CEIL(v_total_records / p_limit);

    -- Now you can use the v_pages variable as needed
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectStatTaskByStatus` (IN `p_id` BIGINT)   BEGIN
    SELECT IFNULL(ts.name, 'init') AS status, COUNT(t.id) AS count
    FROM task_statuses ts
    RIGHT JOIN tasks t ON ts.id = t.status_id
    WHERE t.project_id = p_id
    GROUP BY IFNULL(ts.name, 'init');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectStatusAll` ()   BEGIN
	SELECT * FROM project_statuses;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectStatusCSSVisible` ()   BEGIN
	SELECT id,name,description FROM project_statuses WHERE visible = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectStatusDelete` (IN `p_id` INT)   BEGIN
	DELETE FROM project_statuses WHERE id = p_id;        
    SELECT ROW_COUNT() as rows_deleted;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectStatusDetail` (IN `p_id` INT)   BEGIN
	SELECT * FROM project_statuses WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectStatusInsert` (IN `p_name` VARCHAR(100), IN `p_color` VARCHAR(100), IN `p_description` VARCHAR(250), IN `p_visible` TINYINT(1), IN `p_created_by` INT)   BEGIN
	INSERT INTO project_statuses(name,color,description,visible,created_by)
    VALUES(p_name,p_color,p_description,p_visible,p_created_by);
    
    SELECT ROW_COUNT() as rows_inserted;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectStatusUpdate` (IN `p_id` INT, IN `p_name` VARCHAR(100), IN `p_color` VARCHAR(100), IN `p_description` VARCHAR(250), IN `p_visible` TINYINT(1), IN `p_updated_by` INT)   BEGIN
	UPDATE project_statuses
    SET name = p_name,
    	description = p_description,
        color = p_color,
        visible = p_visible,
        updated_at = CURRENT_TIMESTAMP(),
        updated_by = p_updated_by
    WHERE id =p_id;
        
    SELECT ROW_COUNT() as rows_updated;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectSubmit` (IN `p_id` BIGINT, IN `p_content` TEXT, IN `p_status` TINYINT, IN `p_actioner` INT)   BEGIN
	UPDATE projects
    SET	
    	updated_at = NOW(),updated_by = p_actioner,
        product_url = CASE WHEN IsURL(p_content) THEN p_content ELSE product_url END,
       	status_id = p_status
    WHERE id = p_id;
    
    SELECT ROW_COUNT() as rows_changed;
        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectUpdate` (IN `p_id` BIGINT, IN `p_customer_id` BIGINT, IN `p_name` VARCHAR(250), IN `p_start_date` TIMESTAMP, IN `p_end_date` TIMESTAMP, IN `p_status` INT, IN `p_combo_id` INT, IN `p_levels` VARCHAR(100), IN `p_priority` TINYINT, IN `p_description` TEXT, IN `p_updated_by` INT)   BEGIN
	UPDATE projects    
    SET
    	customer_id = p_customer_id,name = p_name, start_date = p_start_date, end_date = p_end_date, status_id = p_status,
        combo_id = p_combo_id,levels = p_levels,priority = p_priority, description = p_description,
        updated_at = NOW(), updated_by = p_updated_by
    WHERE id = p_id;
    SELECT ROW_COUNT() as updated_rows;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskDelete` (IN `p_id` BIGINT, IN `p_deleted_by` VARCHAR(20))   BEGIN
	UPDATE tasks 
    SET deleted_by = p_deleted_by, deleted_at = NOW() 
    WHERE id = p_id;
    
    CASE WHEN ROW_COUNT() > 0 THEN
    	DELETE FROM tasks WHERE id = p_id;
        SELECT ROW_COUNT() AS deleted_rows;
    ELSE
    	SELECT 'Update deleted info failed' AS msg;
    END CASE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskDetailJoin` (IN `p_id` BIGINT)   BEGIN   
      SELECT 
   		t.level_id,
        DATE_FORMAT(p.start_date, '%d/%m/%Y %H:%i') as start_date,
        DATE_FORMAT(p.end_date, '%d/%m/%Y %H:%i') as end_date,
        lv.name as level,
        lv.color as level_color,
        t.quantity,
        ts.name as status,
        ts.color as status_color,
		NormalizeContent(t.description) as task_description,
        NormalizeContent(p.description) as project_description,
        t.editor_id,
        e.acronym as editor,
         DATE_FORMAT(t.editor_timestamp, '%d/%m/%Y %H:%i:%s') as editor_timestamp,
        t.editor_read_instructions,
        t.editor_assigned,
		
        t.qa_id,
        q.acronym as qa,
        DATE_FORMAT(t.qa_timestamp, '%d/%m/%Y %H:%i:%s') as qa_timestamp,
        t.qa_read_instructions,
        t.qa_assigned,

        d.acronym as dc,
        t.dc_read_instructions,
        DATE_FORMAT(t.dc_timestamp, '%d/%m/%Y %H:%i:%s') as dc_timestamp ,
        
         tla.acronym as tla,
        t.tla_read_instructions,
        DATE_FORMAT(t.tla_timestamp, '%d/%m/%Y %H:%i:%s') as tla_timestamp ,

        DATE_FORMAT(t.created_at, '%d/%m/%Y %H:%i:%s') as created_at,
        c.acronym as created_by,
        DATE_FORMAT(t.updated_at, '%d/%m/%Y %H:%i:%s') as updated_at,
        u.acronym as updated_by,
       
         CONCAT('[', GROUP_CONCAT(
    DISTINCT JSON_OBJECT(
        'id',pi.id,
        'content', pi.content
    ) ORDER BY pl.id DESC SEPARATOR ','
), ']')  AS instructions_list,
    	t.cc_id,
    	CASE WHEN t.cc_id > 0 THEN
     		cc.feedback
       	 	ELSE ''
        END as cc_content,
     CONCAT('[', GROUP_CONCAT(
    DISTINCT JSON_OBJECT(
        'timestamp', DATE_FORMAT(pl.timestamp, '%d/%m/%Y %H:%i'),
        'content', pl.action
    ) ORDER BY pl.id DESC SEPARATOR ','
), ']') as task_logs,
 JSON_OBJECT(
    	'color',cm.name,'output',op.name,'size',ctm.size,
        'is_straighten',ctm.is_straighten,'straighten_remark',ctm.straighten_remark,
        'tv',ctm.tv,'fire',ctm.fire,'sky',ctm.sky,'grass',ctm.grass,
        'style',ns.name,'cloud',cl.name,'style_remark',ctm.style_remark
    ) as styles
    FROM tasks t
    JOIN projects p ON t.project_id = p.id
    JOIN customers ctm ON p.customer_id = ctm.id
   	LEFT JOIN color_modes cm ON ctm.color_mode_id = ctm.id
    LEFT JOIN outputs op ON ctm.output_id = op.id
    LEFT JOIN national_styles ns ON ctm.national_style_id = ns.id
    LEFT JOIN clouds cl ON ctm.cloud_id = cl.id
    JOIN project_logs pl ON pl.project_id = p.id AND pl.task_id = t.id
    LEFT JOIN project_instructions pi ON pi.project_id = p.id
	LEFT JOIN ccs cc ON t.cc_id = cc.id
	JOIN levels lv ON t.level_id = lv.id
    LEFT JOIN users e ON t.editor_id = e.id
    LEFT JOIN users q ON t.qa_id = q.id
    LEFT JOIN users d ON t.dc_id = d.id
    LEFT JOIN users tla ON t.tla_id = tla.id
    LEFT JOIN task_statuses ts ON t.status_id = ts.id
    JOIN users c ON t.created_by = c.id
    LEFT JOIN users u ON t.updated_by = u.id
    WHERE t.id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskGetting` (IN `p_actioner` INT, IN `p_role` INT, IN `p_task` BIGINT)   BEGIN
    IF (p_role = 5 OR p_role = 6) AND p_task = 0 THEN	
        IF CheckRoleSettingLevel(p_actioner,p_role) = 0 THEN
                SELECT JSON_OBJECT('code', '403', 'msg', CONCAT('You have not been assigned levels to access tasks. Please contact your administrator.'), 'icon', 'danger', 'heading', 'Forbidden') AS msg;
        ELSE       
            IF CountProcessingTasks(p_actioner,p_role) > 0 THEN
                SELECT JSON_OBJECT('code', '423', 'msg', CONCAT('You cannot get more tasks until your current task has been submitted.'), 'icon', 'danger', 'heading', 'Locked') AS msg;
            ELSE
                IF CountAvailableTasks(p_actioner,p_role) > 0 THEN               
                    IF GetTask(p_actioner,p_role,p_task) > 0 THEN
                        SELECT JSON_OBJECT('code', '200', 'msg', CONCAT('You have successfully obtained the task.'), 'icon', 'success', 'heading', 'Get Task successfully') AS msg;
                    ELSE
                        SELECT JSON_OBJECT('code', '503', 'msg', CONCAT('Unable to fetch additional tasks.'), 'icon', 'danger', 'heading', 'Locked') AS msg;
                    END IF;
                ELSE
                    SELECT JSON_OBJECT('code', '404', 'msg', CONCAT('No available task found.'), 'icon', 'warning', 'heading', 'Not Found') AS msg;
                END IF;
            END IF;
        END IF;
    ELSE 
        IF GetTask(p_actioner,p_role,p_task) > 0 THEN
            SELECT JSON_OBJECT('code', '200', 'msg', CONCAT('You have successfully obtained the task.'), 'icon', 'success', 'heading', 'Get Task successfully') AS msg;
        ELSE
            SELECT JSON_OBJECT('code', '503', 'msg', CONCAT('Unable to fetch additional tasks.'), 'icon', 'danger', 'heading', 'Locked') AS msg;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskInsert` (IN `p_project` BIGINT, IN `p_description` TEXT, IN `p_editor` INT, IN `p_qa` INT, IN `p_quantity` INT, IN `p_level` INT, IN `p_cc` INT, IN `p_created_by` INT)   BEGIN
	DECLARE v_last_id BIGINT;
    DECLARE v_project_status TINYINT;
    
	INSERT INTO tasks(project_id,description,editor_id,qa_id,quantity,level_id,cc_id,created_by)
    VALUES(p_project,p_description,p_editor,p_qa,p_quantity,p_level,p_cc,p_created_by);
    
    SET v_last_id =  (SELECT LAST_INSERT_ID());
    SET v_project_status = (SELECT status_id FROM projects WHERE id = p_project);
    
    IF v_last_id > 0 AND v_project_status = 0 THEN
    	UPDATE projects
        SET updated_at = NOW(), updated_by = p_created_by, status_id = 2 -- processing
        WHERE id = p_project;
     END IF;
     
     SELECT v_last_id as last_id;
     
        	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskRejecting` (IN `p_id` BIGINT, IN `p_remark` TEXT, IN `p_actioner` INT, IN `p_role` INT, IN `p_read_instructions` INT, IN `p_status` INT)   BEGIN
    INSERT INTO task_rejectings(role_id, remark, created_by)
    VALUES (p_role, NormalizeContent(p_remark), p_actioner);
    
    IF ROW_COUNT() > 0 THEN
        BEGIN
            UPDATE tasks
            SET updated_at = NOW(),
                updated_by = p_actioner,
                status_id = CASE
                    WHEN p_role = 5 THEN 2 -- QA role
                    WHEN p_role = 7 THEN 5 -- DC role
                    WHEN p_role = 4 THEN p_status -- TLA change status
                END,
                qa_reject_id = LAST_INSERT_ID() * (p_role = 5),
                qa_read_instructions =  p_read_instructions * (p_role = 5),


                dc_read_instructions = p_read_instructions * (p_role = 7),
                dc_id = CASE WHEN dc_id = 0 AND p_role = 7 THEN p_actioner ELSE dc_id END,
                dc_timestamp = CASE WHEN dc_id = 0 AND p_role = 7 THEN NOW() ELSE dc_timestamp END,
                dc_reject_id = LAST_INSERT_ID() * (p_role = 7),

                tla_read_instructions = p_read_instructions * (p_role = 4),
                tla_id = CASE WHEN tla_id = 0 AND p_role = 4 THEN p_actioner ELSE tla_id END,
                tla_timestamp = CASE WHEN tla_id = 0 AND p_role = 4 THEN NOW() ELSE tla_timestamp END,
                tla_reject_id = LAST_INSERT_ID() * (p_role = 4)
            WHERE id = p_id;
            SELECT ROW_COUNT() as updated_rows;
        END;
    ELSE
        SELECT 0 as updated_rows;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TasksAppliedFromTemplate` (IN `p_project` BIGINT)   BEGIN
	DECLARE v_levels VARCHAR(100);
    DECLARE v_created_by INT;
    
    SELECT levels INTO v_levels FROM projects WHERE id = p_project;
    SELECT created_by INTO v_created_by FROM projects WHERE id = p_project;

    SET @start = 1;
    SET @end = LOCATE(',', v_levels);
    
    -- Kiểm tra xem @end có rỗng hay không
    IF @end IS NOT NULL THEN
        WHILE @end > 0 DO
            INSERT INTO tasks (project_id, level_id,auto_gen, created_by)
            VALUES (NEW.id, SUBSTRING(v_levels, @start, @end - @start),1, v_created_by);
            SET @start = @end + 1;
            SET @end = LOCATE(',', v_levels, @start);
        END WHILE;
    END IF;

    -- Xử lý giá trị cuối cùng
    IF SUBSTRING(v_levels, @start) > 0 THEN
        INSERT INTO tasks (project_id, level_id,auto_gen, created_by)
        VALUES (NEW.id, SUBSTRING(v_levels, @start),1, v_created_by);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TasksFilter` (IN `p_from_date` TIMESTAMP, IN `p_to_date` TIMESTAMP, IN `p_status` INT, IN `p_search` VARCHAR(200), IN `p_page` INT, IN `p_limit` INT)   BEGIN
    DECLARE v_sql VARCHAR(5000);
    
    SET v_sql = "SELECT t.id,lv.name as level,lv.color as level_color,t.quantity, t.editor_assigned,t.qa_assigned,t.status_id, 
                    ts.name as status,ts.color as status_color,t.auto_gen,t.cc_id,
                    p.name as project_name,DATE_FORMAT(p.start_date,'%d/%m/%Y %H:%i') as start_date, DATE_FORMAT(p.end_date,'%d/%m/%Y %H:%i') as end_date,
                    ct.acronym as customer,
                    t.editor_id,e.acronym as editor,editor_url,
                    t.qa_id,qa.acronym as qa,                    
                    t.dc_id,dc.acronym as dc,
                    t.tla_id,tla.acronym as tla
                    FROM tasks t
                    LEFT JOIN levels lv ON t.level_id = lv.id
                    LEFT JOIN projects p ON t.project_id = p.id
                    LEFT JOIN customers ct ON p.customer_id = ct.id
                    LEFT JOIN users e ON t.editor_id = e.id
                    LEFT JOIN users qa ON t.qa_id = qa.id
                    LEFT JOIN users dc ON t.dc_id = dc.id
                    LEFT JOIN users tla ON t.tla_id = tla.id
                    LEFT JOIN task_statuses ts ON t.status_id = ts.id ";

    SET v_sql = CONCAT(v_sql, "WHERE p.end_date >= '", p_from_date, "' AND p.end_date <= '", p_to_date, "'");

    IF p_status > 0 THEN
        SET v_sql = CONCAT(v_sql, " AND t.status_id = ", p_status);
    END IF;
    
   -- SET v_sql = CONCAT(v_sql," AND (p.name LIKE '%'",p_search,"'%' OR ct.acronym LIKE '%'",p_search,"'%' OR lv.name LIKE '%'",p_search,"'%' OR e.acronym LIKE '%'",p_search,"'%' OR qa.acronym LIKE '%'",p_search,"'%' OR dc.acronym LIKE '%'",p_search,"'%' )");

    SET v_sql = CONCAT(v_sql, " ORDER BY p.end_date");

    IF p_limit > 0 THEN       
        SET v_sql = CONCAT(v_sql, " LIMIT ", p_limit, " OFFSET  ", (p_page-1)*p_limit);
    END IF;

    -- Prepare and execute the main query
    PREPARE stmt FROM v_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TasksGetByProject` (IN `p_id` BIGINT)   BEGIN
	SELECT 
        t.id,
        l.name,
        t.quantity,
        e.acronym as editor,
        q.acronym as qa,
        ts.name as status,
        ts.color as status_color
    FROM tasks t 
    JOIN levels l ON t.level_id = l.id
    LEFT JOIN task_statuses ts ON t.status_id = ts.id
    LEFT JOIN users e ON t.editor_id =e.id
    LEFT JOIN users q ON t.qa_id = q.id
    WHERE t.project_id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TasksGottenByOwner` (IN `p_from_date` TIMESTAMP, IN `p_to_date` TIMESTAMP, IN `p_status` INT, IN `p_page` INT, IN `p_limit` INT, IN `p_actioner` INT, IN `p_role` INT)   BEGIN
    DECLARE v_sql VARCHAR(5000);
    DECLARE v_role INT;  -- Khai báo biến local v_role

    SET v_role = p_role;  -- Gán giá trị của p_role cho biến local v_role

    SET v_sql = "SELECT t.id,lv.name as level,lv.color as level_color,t.quantity, t.editor_assigned,t.qa_assigned,t.status_id, 
                    ts.name as status,ts.color as status_color,t.auto_gen,t.cc_id,
                    p.name as project_name,DATE_FORMAT(p.start_date,'%d/%m/%Y %H:%i') as start_date, DATE_FORMAT(p.end_date,'%d/%m/%Y %H:%i') as end_date,
                    ct.acronym as customer,
                    t.editor_id,e.acronym as editor,editor_url,
                    t.qa_id,qa.acronym as qa,                    
                    t.dc_id,dc.acronym as dc, ";

    IF v_role = 6 THEN
        SET v_sql = CONCAT(v_sql, "DATE_FORMAT(t.editor_timestamp,'%d/%m/%Y %H:%i') AS commencement_date, FORMAT((editor_wage)* quantity,0) as wage");
    ELSEIF v_role = 5 THEN
        SET v_sql = CONCAT(v_sql, "DATE_FORMAT(t.qa_timestamp,'%d/%m/%Y %H:%i') AS commencement_date, FORMAT((qa_wage)* quantity,0) as wage");
    ELSEIF v_role = 7 THEN
        SET v_sql = CONCAT(v_sql, "DATE_FORMAT(t.dc_timestamp,'%d/%m/%Y %H:%i') AS commencement_date, FORMAT((dc_wage)* quantity,0) as wage");
    END IF;

    SET v_sql = CONCAT(v_sql, ", t.pay,t.unpaid_remark 
                FROM tasks t
                JOIN levels lv ON t.level_id = lv.id
                JOIN projects p ON t.project_id = p.id
                JOIN customers ct ON p.customer_id = ct.id
                LEFT JOIN users e ON t.editor_id = e.id
                LEFT JOIN users qa ON t.qa_id = qa.id
                LEFT JOIN users dc ON t.dc_id = dc.id
                LEFT JOIN task_statuses ts ON t.status_id = ts.id ");

    SET v_sql = CONCAT(v_sql, "WHERE p.end_date >= '", p_from_date, "' AND p.end_date <= '", p_to_date, "'");

    IF p_status > 0 THEN
        SET v_sql = CONCAT(v_sql, " AND t.status_id = ", p_status);
    END IF;

    IF v_role = 5 THEN -- QA
        SET v_sql = CONCAT(v_sql, " AND (t.qa_id = ", p_actioner," OR t.editor_id = ",p_actioner,")");
    ELSEIF v_role = 6 THEN -- Editor
        SET v_sql = CONCAT(v_sql, " AND t.editor_id = ", p_actioner);
    ELSEIF v_role = 7 THEN -- DC
        SET v_sql = CONCAT(v_sql, " AND (t.dc_id = ", p_actioner," OR t.qa_id = ",p_actioner," OR t.editor_id = ",p_actioner,")");
    END IF;

    SET v_sql = CONCAT(v_sql," ORDER BY t.status_id");

    IF p_limit > 0 THEN
         SET p_page = CAST(p_page AS SIGNED); 
         SET p_limit = CAST(p_limit AS SIGNED); 
         SET v_sql = CONCAT(v_sql, " LIMIT ", p_limit, " OFFSET ", (p_page - 1) * p_limit);
     END IF;

    -- Prepare and execute the main query
    PREPARE stmt FROM v_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TasksSearch` (IN `p_from_date` TIMESTAMP, IN `p_to_date` TIMESTAMP, IN `p_status` INT, IN `p_search` VARCHAR(200), IN `p_page` INT, IN `p_limit` INT)   BEGIN
    DECLARE v_json_result JSON;
    DECLARE v_json_array JSON;
    DECLARE v_json_object JSON;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_start INT;
    
    -- Initialize the JSON array
    SET v_json_array = JSON_ARRAY();
    
    -- Calculate the starting row
    SET v_start = p_page * p_limit;

    -- Create a temporary table to store the matching rows
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_results (
        id INT,
        level VARCHAR(255),
        level_color VARCHAR(255),
        quantity INT
        -- Include other columns here
    );

    -- Insert the matching rows into the temporary table
    INSERT INTO temp_results
    SELECT
        t.id,
        lv.name AS level,
        lv.color AS level_color,
        t.quantity
        -- Include other columns here
    FROM tasks t
    LEFT JOIN levels lv ON t.level_id = lv.id
    LEFT JOIN projects p ON t.project_id = p.id
    WHERE p.end_date >= p_from_date AND p.end_date <= p_to_date
    AND (p_status = 0 OR t.status_id = p_status);

    -- Loop through the temporary table and add rows to the JSON array
    REPEAT
        SELECT COUNT(*) INTO v_done FROM temp_results;
        IF NOT v_done THEN
            SELECT
                id,
                level,
                level_color,
                quantity
                -- Include other columns here
            INTO v_json_object
            FROM temp_results
            WHERE id = v_start + 1;
            
            IF v_json_object IS NOT NULL THEN
                SET v_json_array = JSON_MERGE_PRESERVE(v_json_array, JSON_OBJECT(
                    'id', id,
                    'level', level,
                    'level_color', level_color,
                    'quantity', quantity
                    -- Include other columns here
                ));
                SET v_start = v_start + 1;
            END IF;
        END IF;
    UNTIL v_start >= p_page * p_limit + p_limit OR v_done END REPEAT;

    -- Calculate the total number of rows
    SELECT COUNT(*) INTO @v_total_rows FROM tasks t
    LEFT JOIN levels lv ON t.level_id = lv.id
    LEFT JOIN projects p ON t.project_id = p.id
    WHERE p.end_date >= p_from_date AND p.end_date <= p_to_date
    AND (p_status = 0 OR t.status_id = p_status);

    -- Calculate the number of pages
    SET @v_pages = CEIL(@v_total_rows / p_limit);

    -- Construct the JSON object with pagination
    SET @v_json_result = JSON_OBJECT(
        'pages', @v_pages,
        'results', v_json_array
    );

    -- Return the JSON result
    SELECT @v_json_result;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_results;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskStatusAll` ()   BEGIN
	SELECT * FROM task_statuses ORDER BY id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskSubmited` (IN `p_id` BIGINT, IN `p_actioner` INT, IN `p_role` INT, IN `p_read_instructions` TINYINT, IN `p_content` TEXT)   BEGIN
    DECLARE v_wage FLOAT DEFAULT 0;
    DECLARE v_price INT DEFAULT 0;

    -- Lấy vai trò trực tiếp từ p_role
    SET v_price = (SELECT price FROM levels WHERE id = (SELECT level_id FROM tasks WHERE id = p_id));
    SET v_wage = (SELECT wage FROM user_types WHERE id = p_role) / 100 * v_price;

    UPDATE tasks
    SET updated_at = NOW(), updated_by = p_actioner,
        editor_fix = CASE
            WHEN p_role = 6 THEN
                CASE
                    WHEN status_id = 2 THEN 1 -- từ chối -> đúng
                    ELSE 0 -- đã xong -> sai
                END
        END,
        status_id = CASE
            WHEN p_role = 6 THEN
                CASE
                    WHEN p_role = 6 THEN
                        CASE
                            WHEN status_id = 0 THEN 1 -- đã xong
                            ELSE 3 -- đã sửa
                        END
                    WHEN p_role = 5 THEN 4 -- vai trò QA
                    ELSE 6
                END           
            WHEN p_role = 5 THEN 4 -- QA OK
            WHEN p_role = 7 THEN 
                CASE
                    WHEN editor_fix = 1 THEN 8 -- Sửa DC
                    ELSE 6 -- OK DC
                END
            ELSE 7 -- Tải lên TLA
        END,
        editor_read_instructions = p_read_instructions * (p_role = 6),
        qa_read_instructions = p_read_instructions * (p_role = 5),
        dc_read_instructions = p_read_instructions * (p_role = 7),
        tla_read_instructions = p_read_instructions * (p_role = 4),
        dc_id = CASE
            WHEN dc_id = 0 AND p_role = 7 THEN p_actioner
            ELSE dc_id
        END,
        dc_timestamp = CASE
            WHEN dc_id = 0 AND p_role = 7 THEN NOW()
            ELSE dc_timestamp
        END,
        tla_id = CASE
            WHEN tla_id = 0 AND p_role = 4 THEN p_actioner
            ELSE tla_id
        END,
        tla_timestamp = CASE
            WHEN tla_id = 0 AND p_role = 4 THEN NOW()
            ELSE tla_timestamp
        END,
        editor_url = CASE
            WHEN p_role = 6 AND p_content LIKE 'http%' THEN p_content
            ELSE editor_url
        END,
        tla_content = CASE
            WHEN p_role = 4 THEN NormalizeContent(p_content)
            ELSE tla_content
        END,
        editor_wage = v_wage * (p_role = 6),
        qa_wage = v_wage * (p_role = 5),
        dc_wage = v_wage * (p_role = 7)
    WHERE id = p_id;
    SELECT ROW_COUNT() as updated_rows;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskUpdate` (IN `p_id` BIGINT, IN `p_description` TEXT, IN `p_editor` INT, IN `p_assign_editor` TINYINT, IN `p_qa` INT, IN `p_assign_qa` TINYINT, IN `p_quantity` INT, IN `p_level` INT, IN `p_updated_by` INT)   BEGIN
	UPDATE tasks
    SET
    	description = NormalizeContent(p_description),
        editor_id = p_editor, editor_timestamp = NOW(),editor_assigned = p_assign_editor,
        qa_id = p_qa, qa_timestamp = NOW(), qa_assigned = p_assign_qa,
        quantity = p_quantity,level_id = p_level,
        updated_at = NOW(), updated_by = p_updated_by
    WHERE id = p_id;
    SELECT ROW_COUNT() as updated_rows;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserGroupsAll` ()   BEGIN
	SELECT * FROM user_groups;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserLogin` (IN `p_email` VARCHAR(200), IN `p_password` VARCHAR(200), IN `p_role` INT, IN `p_ip` VARCHAR(50))   BEGIN
	DECLARE v_count_users INT DEFAULT 0;
    SET v_count_users = (SELECT COUNT(*) FROM users WHERE email = p_email);
    IF v_count_users > 0 THEN
    	SET v_count_users = (SELECT COUNT(*) FROM users WHERE email = p_email AND password = MD5(p_password));
        IF v_count_users > 0 THEN
        	IF EXISTS(SELECT * FROM users u INNER JOIN user_types ut ON u.type_id = ut.id WHERE u.email = p_email AND u.type_id = p_role) THEN
            	IF (SELECT riv FROM user_groups WHERE id = (SELECT group_id FROM users WHERE email = p_email)) = 1 THEN
                	IF EXISTS(SELECT 1 FROM ips WHERE address = p_ip) THEN
                    	SELECT JSON_OBJECT(
                        'code',200,
                        'msg',CONCAT('Login successfully with currently IP address: ',p_ip),
                        'icon','success',
                        'heading','SUCCESSFULLY',
                        'id', u.id,
                        'fullname', u.fullname,
                        'acronym', u.acronym,
                        'email', u.email,
                        'role_id', u.type_id,
                        'role_name', ut.name,
                        'task_getable',u.task_getable
                    ) AS result
                    FROM users u
                    JOIN user_types ut ON u.type_id = ut.id
                    WHERE email = p_email;
                    ELSE
                    	SELECT JSON_OBJECT('code', '204', 'msg', CONCAT('Your IP address is: ',p_ip,'. You are currently out of the company.'),'icon','danger','heading','No IP address match') AS result;
                    END IF;
                ELSE
                	SELECT JSON_OBJECT(
                        'code',200,
                        'msg','Login successfully',
                        'icon','success',
                        'heading','SUCCESSFULLY',
                        'id', u.id,
                        'fullname', u.fullname,
                        'acronym', u.acronym,
                        'email', u.email,
                        'role_id', u.type_id,
                        'role_name', ut.name,
                        'task_getable',u.task_getable
                    ) AS result
                    FROM users u
                    JOIN user_types ut ON u.type_id =ut.id
                    WHERE email = p_email;

                END IF;
            ELSE
            	SELECT JSON_OBJECT('code', '403', 'msg', 'You have no rule to access this module.','icon','danger','heading','Forbidden') AS result;	
            END IF;
        ELSE
        	SELECT JSON_OBJECT('code', '401', 'msg', 'The password does not match.','icon','danger','heading','Unauthorized') AS result;
        END IF;
    ELSE
    	SELECT JSON_OBJECT('code', '404', 'msg', 'The email does not exist in the system.','icon','danger','heading','Not Found') AS result;
    END IF;
END$$

--
-- Các hàm
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CheckRoleSettingLevel` (`p_actioner` INT, `p_role` INT) RETURNS TINYINT(1)  BEGIN
	DECLARE v_count int default 0;
    SET v_count = (SELECT count(*)
                    FROM users u
                    INNER JOIN employee_groups eg
                    ON (CASE WHEN p_role = 6 THEN u.editor_group_id
                        WHEN p_role = 5 THEN u.qa_group_id
                        END) = eg.id
                 	 WHERE u.id = p_actioner);
      RETURN v_count>0;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountAvailableTasks` (`p_actioner` INT, `p_role` INT) RETURNS INT(11)  BEGIN
	DECLARE v_count int default 0;
    DECLARE v_levels varchar(100);

    SET v_levels = (
                        SELECT levels 
                        FROM employee_groups 
                        WHERE id = (
                                        SELECT CASE WHEN p_role = 6 THEN editor_group_id ELSE qa_group_id END 
                                        FROM users 
                                        WHERE id = p_actioner
                                    )
                    );


    IF p_role = 6 THEN
        SET v_count = (
                        SELECT COUNT(*) FROM tasks t 
                        INNER JOIN projects p ON t.project_id = p.id
                        WHERE FIND_IN_SET(t.level_id,v_levels ) > 0
                        AND t.editor_id = 0                       
                    );
    ELSE -- count QA tasks available
         SET v_count = (
                        SELECT COUNT(*) FROM tasks t 
                        INNER JOIN projects p ON t.project_id = p.id
                        WHERE t.qa_id = 0  -- none QA got task           				        				
            				AND dc_timestamp IS NULL -- non DC got task as Editor or QA
            				AND FIND_IN_SET(t.status_id,'1,3')>0 -- status is: done or fixed
            				AND FIND_IN_SET(t.level_id, v_levels) > 0
                        );
    END IF;
   
    RETURN v_count;
    
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountProcessingTasks` (`p_actioner` INT, `p_role` INT) RETURNS INT(11)  BEGIN
	DECLARE v_processing_tasks_count int DEFAULT 0;
    IF p_role = 6 THEN -- editor
    	-- processing status: default(0), QA reject(2), DC reject(5)
    	 SET v_processing_tasks_count = (SELECT COUNT(id) FROM tasks
                                                            WHERE editor_id = p_actioner
                                                            AND FIND_IN_SET(status_id, '0,2,5') > 0);
    ELSE -- QA
    	--  status: default(0): access as editor
        -- done(1), fixed(3), DC reject(5)
    	 SET v_processing_tasks_count = (SELECT COUNT(id) FROM tasks
                                                            WHERE (editor_id = p_actioner AND FIND_IN_SET(status_id, '0,5') > 0) 
                                         					OR (qa_id = p_actioner AND  FIND_IN_SET(status_id, '1,3,5') > 0));
                                        
    END IF;
    RETURN v_processing_tasks_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetInitials` (`p_name` VARCHAR(255)) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
-- hàm trả về chuỗi bao gồm các chữ cái đầu tiên của mỗi từ, đã được viết hoa
    DECLARE result VARCHAR(255) DEFAULT '';
    DECLARE current_char VARCHAR(1);
    DECLARE i INT DEFAULT 1;
    DECLARE is_first_char INT DEFAULT 1;

    SET p_name = TRIM(p_name);

    WHILE i <= LENGTH(p_name) DO
        SET current_char = SUBSTRING(p_name, i, 1);

        IF current_char = ' ' THEN
            SET is_first_char = 1;
        ELSE
            IF is_first_char = 1 THEN
                SET result = CONCAT(result, UPPER(current_char));
                SET is_first_char = 0;
            END IF;
        END IF;

        SET i = i + 1;
    END WHILE;

    RETURN result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetTask` (`p_actioner` INT, `p_role` INT, `p_task` BIGINT) RETURNS INT(11)  BEGIN
	DECLARE v_task_id bigint;
		DECLARE v_levels varchar(100);
		DECLARE v_role int DEFAULT 0;
    IF (p_role = 5 OR p_role = 6 ) AND p_task = 0 THEN -- Editor/QA
		
		SET v_role = (SELECT type_id FROM users WHERE id = p_actioner); -- get actioner role
		
		SET v_levels = (	SELECT levels FROM employee_groups 
							WHERE id = CASE WHEN p_role = 5 THEN (SELECT qa_group_id FROM users WHERE id = p_actioner) 
											ELSE (SELECT editor_group_id FROM users WHERE id = p_actioner) 
										END
					);
					
		IF p_role = 6 THEN -- Get task as Editor(p_role:6)
    	SET v_task_id = (
            				SELECT t.id FROM tasks t INNER JOIN projects p ON t.project_id = p.id
            				WHERE t.editor_id = 0 
            				AND qa_timestamp IS NULL AND dc_timestamp IS NULL -- None DC,QA get task as Editor
            				AND FIND_IN_SET(t.level_id, v_levels) > 0
            				ORDER BY p.end_date
            				LIMIT 1
        				);    
         IF v_role = 6 THEN
         	UPDATE tasks
            SET updated_at = NOW(), updated_by = p_actioner,
            	editor_id = p_actioner,editor_timestamp = NOW(), editor_assigned = 0
            WHERE id = v_task_id;
         ELSE
         	UPDATE tasks
            SET updated_at = NOW(), updated_by = p_actioner,editor_timestamp = NULL,
            	editor_id = p_actioner,qa_timestamp = NOW(), qa_assigned = 0
            WHERE id = v_task_id;
         END IF;
     ELSE -- Getting task as QA(p_role:5)
     	SET v_task_id = (
            				SELECT t.id FROM tasks t INNER JOIN projects p ON t.project_id = p.id
            				WHERE t.qa_id = 0            				        				
            				AND dc_timestamp IS NULL -- non DC get task as QA
            				AND FIND_IN_SET(t.status_id,'1,3')>0 -- status is: done or fixed
            				AND FIND_IN_SET(t.level_id, v_levels) > 0
            				ORDER BY p.end_date
            				LIMIT 1
        				);   
         UPDATE tasks
         SET updated_at = NOW(), updated_by = p_actioner,
            	qa_id = p_actioner,qa_timestamp = NOW(), qa_assigned = 0
         WHERE id = v_task_id;
     END IF;
	ELSE -- DC, TLA, CSS, CSO, CEO
		UPDATE tasks
		SET updated_at = NOW(), updated_by = p_actioner,
			dc_id = p_actioner * (p_role = 7), -- DC
			tla_id = p_actioner * (p_role = 4), -- TLA
			dc_timestamp = CASE
				WHEN p_role = 7 THEN NOW()
				ELSE dc_timestamp
			END,
			tla_timestamp = CASE
				WHEN p_role = 4 THEN NOW()
				ELSE tla_timestamp
			END
		WHERE id = p_task;
	END IF;
    RETURN ROW_COUNT();
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `IsURL` (`url` VARCHAR(255)) RETURNS TINYINT(1)  BEGIN
  DECLARE url_pattern VARCHAR(255);
  SET url_pattern = '^(http|https)://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}(\\S*)?$';
  
  IF url REGEXP url_pattern THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `NormalizeContent` (`input_text` TEXT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
	-- hàm chuẩn hóa content
    DECLARE output_text TEXT;
    
    -- Loại bỏ nhiều ký tự xuống hàng liên tục, giữ lại 1 ký tự xuống hàng
    SET output_text = REGEXP_REPLACE(input_text, '\n+', '\n');
    
    -- Loại bỏ nhiều khoảng trắng liên tục, giữ lại 1 khoảng trắng
    SET output_text = REGEXP_REPLACE(output_text, ' +', ' ');
    
    RETURN output_text;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `NormalizeString` (`input_string` VARCHAR(255)) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
-- Hàm chuẩn hóa lại chuỗi
-- viết hoa chữ cái đầu của mỗi từ
-- các chữ cái còn lại viết thường
   DECLARE normalized_string VARCHAR(255) DEFAULT '';
    DECLARE current_char VARCHAR(1);
    DECLARE i INT DEFAULT 1;
    DECLARE is_new_word INT DEFAULT 1;

    WHILE i <= LENGTH(input_string) DO
        SET current_char = SUBSTRING(input_string, i, 1);

        IF current_char = ' ' THEN
            SET is_new_word = 1;
            SET normalized_string = CONCAT(normalized_string, ' ');
        ELSE
            IF is_new_word = 1 THEN
                SET normalized_string = CONCAT(normalized_string, UPPER(current_char));
                SET is_new_word = 0;
            ELSE
                SET normalized_string = CONCAT(normalized_string, LOWER(current_char));
            END IF;
        END IF;

        SET i = i + 1;
    END WHILE;

    RETURN normalized_string;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ProjectInstructionInsert` (`project_id` BIGINT, `content` TEXT, `created_by` INT) RETURNS BIGINT(20)  BEGIN
	INSERT INTO project_instructions
    SET 
    	project_id = project_id,
        content = content,
        created_by = created_by;
     RETURN LAST_INSERT_ID();
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ccs`
--

CREATE TABLE `ccs` (
  `id` int(11) NOT NULL,
  `project_id` bigint(11) NOT NULL,
  `feedback` text NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL,
  `deleted_by` varchar(100) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp() COMMENT 'Thời điểm xóa cc'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `ccs`
--

INSERT INTO `ccs` (`id`, `project_id`, `feedback`, `start_date`, `end_date`, `created_at`, `created_by`, `updated_at`, `updated_by`, `deleted_by`, `deleted_at`) VALUES
(5, 6, '<p>54235325</p>\n', '2023-11-11 21:33:00', '2023-11-11 21:33:00', '2023-11-11 21:36:38', 6, '2023-11-11 14:36:38', 0, '', NULL),
(6, 6, '<p>54235325</p>\n', '2023-11-11 21:33:00', '2023-11-11 21:33:00', '2023-11-11 21:41:59', 6, '2023-11-11 14:41:59', 0, '', NULL),
(7, 6, '<p>fdsafsafsdafasdf</p>\n', '2023-11-11 21:42:00', '2023-11-11 21:42:00', '2023-11-11 21:42:19', 6, '2023-11-11 14:42:19', 0, '', NULL),
(8, 6, '<p>fdsafsaf</p>\n', '2023-11-11 22:00:00', '2023-11-11 22:00:00', '2023-11-11 22:00:49', 1, '2023-11-11 15:00:49', 0, '', NULL);

--
-- Bẫy `ccs`
--
DELIMITER $$
CREATE TRIGGER `after_cc_deleted` AFTER DELETE ON `ccs` FOR EACH ROW BEGIN
	INSERT INTO project_logs(project_id,cc_id,timestamp,content)
    VALUES(OLD.project_id,OLD.id,OLD.deleted_at,CONCAT('[<span class="fw-bold text-info">',OLD.deleted_by,'</span>] <span class="text-danger">DELETE CC</span> FROM [',DATE_FORMAT(OLD.start_date, '%d/%m/%Y %H:%i'),'] TO [',DATE_FORMAT(OLD.end_date, '%d/%m/%Y %H:%i'),']'));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_cc_inserted` AFTER INSERT ON `ccs` FOR EACH ROW BEGIN
	DECLARE v_created_by varchar(100); 
    DECLARE v_role varchar(100) DEFAULT '';
    DECLARE v_action varchar(250) DEFAULT '';
     
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM ccs WHERE id = NEW.id));
    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.created_by));
    SET v_action = CONCAT(v_role,' [<span class="fw-bold text-info">',v_created_by,'</span>] <span class="text-success">CREATE NEW CC</span> FROM [<span class="text-warning">',DATE_FORMAT(NEW.start_date, '%d/%m/%Y %H:%i'),'</span>] TO [<span class="text-warning">',DATE_FORMAT(NEW.end_date, '%d/%m/%Y %H:%i'),'</span>]');
    
    INSERT INTO project_logs(project_id,cc_id,timestamp,action)
    VALUES(NEW.project_id,NEW.id,NEW.created_at,v_action);
    
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_cc_deleted` BEFORE DELETE ON `ccs` FOR EACH ROW BEGIN
	UPDATE tasks SET deleted_by = OLD.deleted_by, deleted_at = NOW() WHERE cc_id = OLD.id;
    DELETE FROM tasks WHERE cc_id = OLD.id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `clouds`
--

CREATE TABLE `clouds` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL DEFAULT 1,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `clouds`
--

INSERT INTO `clouds` (`id`, `name`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'Google Drive', '2023-10-06 00:13:35', 1, NULL, 0),
(2, 'Dropbox', '2023-10-06 00:13:35', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `color_modes`
--

CREATE TABLE `color_modes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `color_modes`
--

INSERT INTO `color_modes` (`id`, `name`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'Adobe 1998', '2023-10-06 00:11:29', 1, NULL, 0),
(2, 'sRGB', '2023-10-06 00:11:29', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `comboes`
--

CREATE TABLE `comboes` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `color` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `comboes`
--

INSERT INTO `comboes` (`id`, `name`, `color`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'combo 1', 'bg-danger text-white', '2023-10-02 09:00:22', 0, NULL, 0),
(2, 'combo 2', 'bg-primary text-light', '2023-10-02 09:00:22', 0, NULL, 0),
(3, 'combo 3', 'bg-success text-dark', '2023-10-02 09:00:22', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `companies`
--

CREATE TABLE `companies` (
  `id` bigint(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(12) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `companies`
--

INSERT INTO `companies` (`id`, `name`, `description`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'PHOTOHOME', '											', '2023-02-18 00:00:00', 0, '2023-10-02 09:00:51', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `configs`
--

CREATE TABLE `configs` (
  `id` int(30) NOT NULL,
  `cf_key` varchar(20) NOT NULL,
  `cf_value` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `configs`
--

INSERT INTO `configs` (`id`, `cf_key`, `cf_value`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'Quản lý công việc', 'contactphotohome@gmail.com', '2023-10-02 22:55:37', 0, '2023-10-02 09:01:15', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customers`
--

CREATE TABLE `customers` (
  `id` bigint(30) NOT NULL,
  `company_id` bigint(11) NOT NULL,
  `name` varchar(200) DEFAULT NULL,
  `acronym` varchar(50) NOT NULL COMMENT 'Tên viết tắt',
  `email` varchar(200) NOT NULL,
  `customer_url` varchar(200) NOT NULL,
  `pwd` text NOT NULL,
  `avatar` text NOT NULL,
  `group_id` int(11) NOT NULL,
  `color_mode_id` int(11) NOT NULL COMMENT 'Hệ màu',
  `output_id` int(11) NOT NULL COMMENT 'Định dạng file xuất',
  `size` varchar(100) NOT NULL COMMENT 'Kích thước file thành phẩm',
  `is_straighten` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Gióng thẳng',
  `straighten_remark` varchar(255) NOT NULL,
  `tv` varchar(255) NOT NULL,
  `fire` varchar(255) NOT NULL,
  `sky` varchar(255) NOT NULL,
  `grass` varchar(255) NOT NULL,
  `national_style_id` int(11) DEFAULT 0,
  `cloud_id` int(11) NOT NULL DEFAULT 0,
  `style_remark` text NOT NULL COMMENT 'Ghi chú style',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `customers`
--

INSERT INTO `customers` (`id`, `company_id`, `name`, `acronym`, `email`, `customer_url`, `pwd`, `avatar`, `group_id`, `color_mode_id`, `output_id`, `size`, `is_straighten`, `straighten_remark`, `tv`, `fire`, `sky`, `grass`, `national_style_id`, `cloud_id`, `style_remark`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 0, 'Test 1234', 'C431651-T1', 'emailtes1t1@gmail.com', 'adsfasdf', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '1234fazfdxdsrqw', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 2, 'style remark\n', '2023-10-06 20:51:28', 1, '2023-10-10 02:43:51', 0),
(4, 0, 'Test2', 'C431651-T', 'emailtest2@gmail.com', 'adsfasdf', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '1234fazfdxdsrqw', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 2, 'style remark\n', '2023-10-06 20:54:11', 1, '2023-10-10 02:43:51', 0),
(5, 0, 'Test3', 'C431651-T', 'emailtest3@gmail.com', 'adsfasdf', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '1234fazfdxdsrqw', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 1, 'style remark\n', '2023-10-06 20:55:06', 1, '2023-10-10 02:43:51', 0),
(6, 0, 'Test4 Ra Fdasf ', 'C431651-TRF', 'emailtest4@gmail.com', 'adsfasdf', '202cb962ac59075b964b07152d234b70', '', 2, 1, 2, '1234fazfdxdsrqw', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 1, 1, 'style remark\n', '2023-10-06 20:55:51', 1, '2023-10-10 02:43:51', 0),
(8, 0, 'Truong Nguyen Huu', 'C431651-TNH', 'emailtest21@gmail.com', 'url ', '202cb962ac59075b964b07152d234b70', '', 2, 2, 1, '2134x1234', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 1, 'style remark\n', '2023-10-06 20:59:22', 1, '2023-10-10 02:43:51', 0),
(9, 0, 'Truong Nguyen Huu', 'C441635-TNH', 'emailtest221@gmail.com', 'url ', '202cb962ac59075b964b07152d234b70', '', 1, 2, 1, '2134x1234', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 1, 'style remark\n', '2023-10-06 20:59:40', 1, '2023-10-10 02:44:35', 1),
(10, 0, 'Spyder Man', 'C431651-SM', 'syperman@gmail.com', 'spyder man url', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, 'origin', 1, '1234', '', '', '', '411', 1, 1, 'style remark\n', '2023-10-06 21:04:23', 1, '2023-10-10 02:43:51', 0),
(11, 0, 'Jocker Allain', 'C431651-JA', 'testemail123@gmail.com', 'adsfá', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-10-06 21:08:07', 1, '2023-10-10 02:43:51', 0),
(12, 0, 'Test  New Acronym', 'C451601-TNA', 'testnewacronym@gmail.com', 'sdf', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '1234fazfdxdsrqw', 1, 'dfsấ', 'fsadfsa', 'fdsấ', 'fdsấ', 'fdsàdsa', 0, 0, 'dsàdsà2134\n', '2023-10-06 21:14:11', 1, '2023-10-10 02:45:01', 1),
(13, 0, 'Test  New Acronym ', 'C431651-TNA', 'testnewacronym1@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '', 1, '', '', '', '', '', 0, 0, 'dsàdsà2134\n', '2023-10-06 21:15:11', 1, '2023-10-10 02:43:51', 0),
(15, 0, 'This Is New Customer1', 'C481631-TINCEMA', 'emailtes1t11@gmail.com', 'dsfấ', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-10-06 21:19:23', 1, '2023-10-10 02:48:31', 1),
(16, 0, 'Test Straighten1', 'C481615-TSTES', 'teststraighten@gmail.com', 'straighten url', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '', 1, 'straighten note', 'tvnote', 'fire note', 'sky note', 'grass note', 1, 1, 'straighten style remark\n\nremark \n\ndfafasd fdasf                     fsdjfsalkfj \n\n\n\n\nfdsafsadjf\nfsadfjsdal\n\n1234124\n\nfdsafsa\n', '2023-10-06 22:02:34', 1, '2023-10-10 02:48:15', 1),
(17, 0, 'Fdasfasfsa', 'fasdfasdfasđfdá', 'fasdfasfasf@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 1, 1, '1234fazfdxdsrqw', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 09:27:57', 1, '2023-11-08 02:27:57', 0),
(18, 0, 'Fsdafasdfas', 'fdsafasdfasfds', 'f123421rdfsafas@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 1, 1, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 09:28:34', 1, '2023-11-08 02:28:34', 0),
(19, 0, 'Fsdafasdf', '12asdfkasfhaskfh', '124h312jkfhasdfsa@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 09:29:26', 1, '2023-11-08 02:29:26', 0),
(20, 0, 'Fdasfsdafsaj', 'fdasfjkasfklasfa', 'kfjlsl@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 09:31:07', 1, '2023-11-08 02:31:07', 0),
(21, 0, 'Fsdafsafa', 'fasfsd124hsfj', 'dfsafjksf2@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 09:32:25', 1, '2023-11-08 02:32:25', 0),
(24, 0, 'Fsdafasdf', 'fasdfasdfasdfsda', 'emailtes1t21@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 09:42:37', 1, '2023-11-08 02:42:37', 0),
(25, 0, 'Fdsafasdf', 'fdasfasdfasd', 'fasdfasr123r4fasdf@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 09:44:31', 1, '2023-11-08 02:44:31', 0),
(26, 0, 'Dsafasdf', 'fdasfsdaf', 'emailtes11t1@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:32:58', 1, '2023-11-08 04:32:58', 0),
(27, 0, 'Dsafasdf', 'fdasfsdaf2', 'emai2ltes11t1@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:34:21', 1, '2023-11-08 04:34:21', 0),
(28, 0, 'Deasfdsafsaf', '41234124', '1rsdafasfd@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:35:55', 1, '2023-11-08 04:35:55', 0),
(29, 0, 'Dfasfasfasdf', 'fdasfsdafsaf', 'gfdafdsafr1423@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:36:41', 1, '2023-11-08 04:36:41', 0),
(30, 0, 'Fasdfasdr12423', 'fdasfasfsd1rfdsaf', 'fdas1dagfsa@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:37:24', 1, '2023-11-08 04:37:24', 0),
(31, 0, 'Gsfgdsgsdfg', '42141234', '4321fdsafa@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:52:05', 1, '2023-11-08 04:52:05', 0),
(32, 0, 'Gsfgdsgsdfg', '42141234rewqrwq', '4321fdsafrewrwa@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:55:08', 1, '2023-11-08 04:55:08', 0),
(33, 0, 'Fasfasdf', 'fdsafasfsda@gmail.com', 'dsafkfjsakdfjsa@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:56:53', 1, '2023-11-08 04:56:53', 0),
(34, 0, 'Fasfasdf123', 'fdsafasfsd12a@gmail.com', '123dsafkfjsakdfjsa@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 11:58:28', 1, '2023-11-08 04:58:28', 0),
(35, 0, 'Fdafasfdasfd1', 'asdf123dsfaf', '1234fdfas@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 0, '', '', '', '', '', 0, 0, '', '2023-11-08 11:59:54', 1, '2023-11-08 04:59:54', 0),
(36, 0, 'Fasfasdf123123', 'fd4321safasfsd12a@gmail.com', '124323dsafkfjsakdfjsa@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 12:01:00', 1, '2023-11-08 05:01:00', 0),
(37, 0, 'Fasfasdf123123', '1234fasdfsaf', '123akdfjsa@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 12:01:59', 1, '2023-11-08 05:01:59', 0),
(38, 0, 'Fasfasdf123123', 'adsfcz1', '1a@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 12:03:14', 1, '2023-11-08 05:03:14', 0),
(39, 0, 'Fasfasdf123123', 'adsfc2z1', '1a2@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-11-08 12:04:13', 1, '2023-11-08 05:04:13', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customer_groups`
--

CREATE TABLE `customer_groups` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `levels` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `customer_groups`
--

INSERT INTO `customer_groups` (`id`, `name`, `description`, `levels`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'Group 1', NULL, NULL, '2023-10-02 10:03:33', 0, '2023-10-02 10:03:33', 0),
(2, 'Group 2', NULL, NULL, '2023-10-02 10:03:53', 1, '2023-10-02 10:04:07', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `employee_groups`
--

CREATE TABLE `employee_groups` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `levels` varchar(255) DEFAULT NULL COMMENT 'Các level của task có thể nhận',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `employee_groups`
--

INSERT INTO `employee_groups` (`id`, `name`, `description`, `levels`, `created_by`, `created_at`, `updated_at`, `updated_by`) VALUES
(1, 'Nhóm Mattport', '', '1,2,3', 1, '2023-09-02 23:10:28', '2023-09-02 22:26:02', 0),
(2, 'Nhóm Mattport pro', '', '1,2,3,4,5,6,7', 1, '2023-09-02 23:12:36', '2023-09-02 22:25:57', 0),
(3, 'Nhóm pro', '', '1,2,3,4,5,6,7', 1, '2023-09-02 23:23:04', '2023-09-02 23:23:04', 0),
(4, 'Nhóm training', '', '1,2,3', 1, '2023-09-02 23:24:13', '2023-09-02 23:24:13', 0),
(5, 'Nhóm QA Pro', '', '1,2,3,4,5,6,7,8', 1, '2023-09-05 01:59:11', '2023-09-05 01:59:11', 0),
(6, 'Nhóm DTE', '', '8', 1, '2023-09-05 02:03:26', '2023-09-05 02:03:26', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `invoices`
--

CREATE TABLE `invoices` (
  `id` int(11) NOT NULL,
  `customer_id` bigint(11) NOT NULL,
  `title` varchar(50) NOT NULL,
  `total` float NOT NULL,
  `tax` int(11) NOT NULL,
  `transport` float NOT NULL,
  `status_id` int(11) NOT NULL COMMENT 'Tham chiếu khóa ngoại tới bảng invoice_status',
  `remark` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `invoice_statuses`
--

CREATE TABLE `invoice_statuses` (
  `id` int(11) NOT NULL,
  `name` varchar(12) NOT NULL,
  `color` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `invoice_statuses`
--

INSERT INTO `invoice_statuses` (`id`, `name`, `color`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'wait', 'badge badge-secondary', '2023-04-16 00:00:00', 0, '2023-10-02 09:04:44', 0),
(2, 'Sent', 'badge badge-success', '2023-04-16 00:00:00', 0, '2023-10-02 09:04:44', 0),
(3, 'Paid', 'badge badge-info', '2023-04-16 00:00:00', 0, '2023-10-02 09:04:44', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ips`
--

CREATE TABLE `ips` (
  `id` int(11) NOT NULL,
  `address` varchar(15) NOT NULL,
  `remark` varchar(50) DEFAULT NULL,
  `status` int(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `ips`
--

INSERT INTO `ips` (`id`, `address`, `remark`, `status`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(4, '113.160.15.183', 'IP công ty', 1, '2023-09-16 13:08:27', 0, NULL, 0),
(5, '113.178.40.243', 'Ip wifi công ty', 1, '2023-09-16 13:09:09', 0, NULL, 0),
(6, '171.231.0.247', 'Ip anh thiện', 1, '2023-09-16 13:09:41', 0, NULL, 0),
(7, '42.1.77.147', 'Ip Css thành', 1, '2023-09-16 13:10:13', 0, NULL, 0),
(8, '142.250.66.100', 'IP CSS thành', 1, '2023-09-16 13:10:41', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `levels`
--

CREATE TABLE `levels` (
  `id` int(30) NOT NULL,
  `name` varchar(30) NOT NULL,
  `price` int(11) NOT NULL COMMENT 'đơn giá',
  `color` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `levels`
--

INSERT INTO `levels` (`id`, `name`, `price`, `color`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'PE-STAND', 5000, 'bg-danger text-white', '0000-00-00 00:00:00', 0, NULL, 0),
(2, 'PE-BASIC', 3500, 'bg-success text-white', '0000-00-00 00:00:00', 0, NULL, 0),
(3, 'PE-Drone-Basic', 1000, 'bg-warning text-white', '0000-00-00 00:00:00', 0, NULL, 0),
(4, 'Re-Stand', 6000, 'text-success', '0000-00-00 00:00:00', 0, NULL, 0),
(5, 'Re-Basic', 3000, 'text-danger', '0000-00-00 00:00:00', 0, NULL, 0),
(6, 'Re-ADV', 15000, 'text-warning', '0000-00-00 00:00:00', 0, NULL, 0),
(7, 'Re-Extreme', 50000, 'text-info', '0000-00-00 00:00:00', 0, NULL, 0),
(8, 'PE-DTE', 20000, 'bg-info text-white', '0000-00-00 00:00:00', 0, NULL, 0),
(9, 'VHS', 140000, 'bg-dark text-white', '0000-00-00 00:00:00', 0, NULL, 0),
(10, 'VIDEO', 50000, 'bg-white text-dark', '0000-00-00 00:00:00', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `national_styles`
--

CREATE TABLE `national_styles` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `national_styles`
--

INSERT INTO `national_styles` (`id`, `name`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'US Style', '2023-10-06 00:15:18', 1, '2023-10-06 00:15:18', 0),
(2, 'US AU', '2023-10-06 00:15:18', 1, '2023-10-06 00:15:18', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `outputs`
--

CREATE TABLE `outputs` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL DEFAULT 1,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `outputs`
--

INSERT INTO `outputs` (`id`, `name`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'JPG', '2023-10-06 02:01:17', 1, NULL, 0),
(2, 'TIFF', '2023-10-06 02:01:17', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `projects`
--

CREATE TABLE `projects` (
  `id` bigint(30) NOT NULL,
  `customer_id` bigint(30) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `status_id` tinyint(1) NOT NULL DEFAULT 0,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `levels` varchar(100) NOT NULL COMMENT 'Danh sách level khi sử dụng template',
  `invoice_id` varchar(11) NOT NULL,
  `product_url` text DEFAULT NULL,
  `wait_note` varchar(255) DEFAULT NULL,
  `combo_id` int(11) NOT NULL DEFAULT 0,
  `priority` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `projects`
--

INSERT INTO `projects` (`id`, `customer_id`, `name`, `description`, `status_id`, `start_date`, `end_date`, `levels`, `invoice_id`, `product_url`, `wait_note`, `combo_id`, `priority`, `created_at`, `created_by`, `updated_at`, `updated_by`, `deleted_at`, `deleted_by`) VALUES
(1, 27, 'Test 111123 with status', '\n', 6, '2023-11-11 11:04:00', '2023-11-11 14:04:00', '1,2,3', '', NULL, NULL, 2, 0, '2023-11-11 11:11:07', 1, '2023-11-11 19:50:18', 6, NULL, ''),
(2, 29, 'TEST PROJECT 61123', 'fdà\n', 6, '2023-11-11 19:45:00', '2023-11-11 22:45:00', '2', '', NULL, NULL, 1, 1, '2023-11-11 19:47:10', 6, NULL, 0, NULL, ''),
(3, 29, 'TEST PROJECT 61123', 'fdà\n', 0, '2023-11-11 19:45:00', '2023-11-11 22:45:00', '2', '', NULL, NULL, 1, 1, '2023-11-11 19:47:28', 6, '2023-11-11 19:50:31', 6, NULL, ''),
(4, 27, 'fsadfasd', '\n', 8, '2023-11-11 19:55:00', '2023-11-11 22:55:00', '1', '', NULL, NULL, 3, 1, '2023-11-11 19:55:46', 6, NULL, 0, NULL, ''),
(5, 29, 'TEST PROJECT 111123', '<p>&lt;p&gt;&amp;lt;p&amp;gt;This is html description for the 111123 project&amp;lt;/p&amp;gt;&lt;/p&gt;</p>\n', 0, '2023-11-11 20:04:00', '2023-11-11 23:04:00', '1', '', NULL, NULL, 2, 0, '2023-11-11 20:05:57', 6, '2023-11-11 21:15:03', 6, NULL, ''),
(6, 27, 'The test project using ckeditor plugin', '<p>The 1st line of description</p>\n\n<p><strong>The 2nd line of description</strong></p>\n\n<p><em>The 3rd line of description</em></p>\n\n<p><u>The 4th line of description</u></p>\n\n<p>&nbsp;</p>\n', 2, '2023-11-11 20:47:00', '2023-11-11 23:47:00', '3', '', NULL, NULL, 2, 0, '2023-11-11 20:49:22', 6, '2023-11-11 22:07:28', 1, NULL, ''),
(7, 27, 'test 123', '', 0, '2023-11-11 20:47:00', '2023-11-11 23:47:00', '', '', NULL, NULL, 2, 0, '2023-11-11 22:10:07', 1, '2023-11-11 22:10:19', 1, NULL, '');

--
-- Bẫy `projects`
--
DELIMITER $$
CREATE TRIGGER `after_project_inserted` AFTER INSERT ON `projects` FOR EACH ROW BEGIN
	DECLARE v_created_by varchar(100);
    DECLARE v_customer varchar(100);
    DECLARE v_role varchar(100) DEFAULT '';
    
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM projects WHERE id = NEW.id));
    SET v_customer = (SELECT acronym FROM customers WHERE id = NEW.customer_id);
    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.created_by));
    
    
    INSERT INTO project_logs(project_id,timestamp,action)
    VALUES(NEW.id,NEW.created_at,CONCAT(v_role,' [<span class="text-info fw-bold">',v_created_by,'</span>] <span class="text-success">CREATE PROJECT FOR CUSTOMER</span> [<span class="text-primary">',v_customer,'</span>]'));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_project_updated` AFTER UPDATE ON `projects` FOR EACH ROW BEGIN
	DECLARE v_actioner  varchar(100);
    DECLARE v_actions varchar(255) DEFAULT '';
    DECLARE v_content text DEFAULT '';
    
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
    SET v_actions = CONCAT(v_role,' [<span class="fw-bold text-info">',v_actioner,'</span>]');
    
       -- name
    	IF NEW.name <> OLD.name THEN
        	SET v_changed = TRUE;
        	SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE NAME</span> FROM [<span class="text-secondary">',OLD.name,'</span>] TO [<span class="text-info">',NEW.name,'</span>],');            
        END IF;
    -- //name
    
    -- customer
    	IF OLD.customer_id <> NEW.customer_id THEN
        	 SET v_changed = TRUE;
        	SET v_old_customer = (SELECT acronym FROM customers WHERE id = OLD.customer_id);
        	SET v_new_customer = (SELECT acronym FROM customers WHERE id = NEW.customer_id);
            SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE CUSTOMER</span> FROM [<span class="text-secondary">',v_old_customer,'</span>] TO [<span class="text-info">',v_new_customer,'</span>],');
           
        END IF;
    -- //customer
    
    -- description 
    	IF NEW.description <> OLD.description THEN
        	SET v_changed = TRUE;
        	SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE DESCRIPTION</span><a href="javascript:void(0)" onClick="ViewContent(',NEW.id,')">View detail</a>,');            
            SET v_content = CONCAT('<span class="text-secondary">FROM:</span><br/><hr>',OLD.description,'<span class="mt-3 text-secondary">TO:</span><hr/>',NEW.description);
        END IF;
    -- //description
    
    -- status
    	IF NEW.status_id <> OLD.status_id THEN
        	SET v_changed = TRUE;
        	SET v_old_status = (SELECT name FROM project_statuses WHERE id = OLD.status_id);
        	SET v_new_status = (SELECT name FROM project_statuses WHERE id = NEW.status_id);
            IF v_new_status IS NULL THEN
            	SET v_new_status = 'Initital';
            END IF;
          IF v_old_status IS NULL THEN
            SET v_old_status ='Initital';
          END IF;
          SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE STATUS</span> FROM [<span class="text-secondary">',v_old_status,'</span>] TO [<span class="text-info">',v_new_status,'</span>],');            
        END IF;
    -- //status
    
    -- START DATE
    	IF NEW.start_date <> OLD.start_date THEN
        	SET v_changed = TRUE;
        	SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE START DATE</span> FROM [<span class="text-secondary">',DATE_FORMAT(OLD.start_date,'%d/%m/%Y %H:%i'),'</span>] TO [<span class="text-info">',DATE_FORMAT(NEW.start_date,'%d/%m/%Y %H:%i'),'</span>],');            
        END IF;
    -- //START DATE
    
        -- END DATE
    	IF NEW.end_date <> OLD.end_date THEN
        	SET v_changed = TRUE;
        	SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE END DATE</span> FROM [<span class="text-secondary">',DATE_FORMAT(OLD.end_date,'%d/%m/%Y %H:%i'),'</span>] TO [<span class="text-info">',DATE_FORMAT(NEW.end_date,'%d/%m/%Y %H:%i'),'</span>],');            
        END IF;
    -- //END DATE
    
    -- templates
    	IF NEW.levels <> OLD.levels THEN
        	SET v_changed = TRUE;
        	IF LENGTH(NEW.levels) = 0 THEN -- huy ap dung template
            	SET v_old_templates = (SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM levels WHERE FIND_IN_SET(id, OLD.levels) > 0);
                SET v_actions = CONCAT(v_actions,' <span class="text-danger">CANCEL TEMPLATES</span> [',v_old_templates,'],');                
            ELSE
            	IF LENGTH(OLD.levels) = 0 THEN -- ap template
                	SET v_new_templates = (SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM levels WHERE FIND_IN_SET(id, NEW.levels) > 0);
                	SET v_actions = CONCAT(v_actions,' <span class="text-info">APPLY TEMPLATES</span> [',v_new_templates,'],');
                ELSE -- thay doi template
                	SET v_old_templates = (SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM levels WHERE FIND_IN_SET(id, OLD.levels) > 0);
                    SET v_new_templates = (SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM levels WHERE FIND_IN_SET(id, NEW.levels) > 0);
                    SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE TEMPLATES</span> FROM [<span class="text-secondary">',v_old_templates,'</span>] TO [<span class="text-info">',v_new_templates,'</span>],');
                END IF;
            END IF;
        END IF;
    -- //templates
    
    -- combo
    	IF OLD.combo_id <> NEW.combo_id THEN
        	SET v_changed = TRUE;
        	IF NEW.combo_id = 0 THEN -- neu la huy combo
            	SET v_old_combo = (SELECT name FROM comboes WHERE id = OLD.combo_id);
            	SET v_actions = CONCAT(v_actions,' <span class="text-danger">CANCEL COMBO</span> [',v_old_combo,'],');
            ELSE -- thay doi combo
            	IF OLD.combo_id =0 THEN -- neu truoc do chua co combo
                	SET v_new_combo = (SELECT name FROM comboes WHERE id = NEW.combo_id);
                    SET v_actions = CONCAT(v_actions,' <span class="text-success">APPLY COMBO</span> [',v_new_combo,'],');
                ELSE -- thay doi combo 1 sang combo 2
                	SET v_old_combo = (SELECT name FROM comboes WHERE id = OLD.combo_id);
                    SET v_new_combo = (SELECT name FROM comboes WHERE id = NEW.combo_id);
                    SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE COMBO</span> FROM [<span class="text-secondary">',v_old_combo,'</span>] TO [<span class="text-info">',v_new_combo,'</span>],');
                END IF;
            END IF;
        END IF;
    -- //combo
    
    -- priority
    	IF NEW.priority <> OLD.priority THEN
        	SET v_changed = TRUE;
        	IF NEW.priority = 1 THEN 
            	SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE PRIORITY</span> TO [<span class="text-danger">URGEN</span>],');
            ELSE
            	SET v_actions = CONCAT(v_actions,' <span class="text-warning">CHANGE PRIORITY</span> TO [<span class="text-secondary">NORMAL</span>],');
            END IF;            
        END IF;
    -- //priority
    
    
    IF v_changed = TRUE THEN
    		SET v_actions = (SELECT TRIM(TRAILING ',' FROM v_actions));
             INSERT INTO project_logs(project_id,timestamp,action,content)
             VALUES(OLD.id,NEW.updated_at,v_actions,v_content);
    END IF;

    
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `project_instructions`
--

CREATE TABLE `project_instructions` (
  `id` bigint(20) NOT NULL,
  `project_id` bigint(20) NOT NULL,
  `content` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL,
  `deleted_by` varchar(50) DEFAULT NULL COMMENT 'Người xóa ',
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `project_instructions`
--

INSERT INTO `project_instructions` (`id`, `project_id`, `content`, `created_at`, `created_by`, `updated_at`, `updated_by`, `deleted_by`, `deleted_at`) VALUES
(1, 2, 'fá\n', '2023-11-11 19:47:10', 6, NULL, 0, NULL, NULL),
(2, 3, 'fá\n', '2023-11-11 19:47:28', 6, '2023-11-11 12:50:31', 6, NULL, NULL),
(3, 5, '<p>&lt;p&gt;&amp;lt;p&amp;gt;This is html instruction for&amp;lt;/p&amp;gt;&amp;lt;p&amp;gt;the 111123 project &amp;lt;/p&amp;gt;&lt;/p&gt;</p>\n', '2023-11-11 20:05:57', 6, '2023-11-11 14:15:03', 6, NULL, NULL),
(4, 6, '<p>fasdfasfasdfasdfasfdasf</p>\n', '2023-11-11 20:49:22', 6, '2023-11-11 15:07:28', 1, NULL, NULL),
(5, 6, '<p>new instruction</p>\n', '2023-11-11 21:44:52', 6, NULL, 0, NULL, NULL),
(6, 6, '<p>fasdfasfasdfasdfasfdasf</p>\n', '2023-11-11 22:01:41', 1, NULL, 0, NULL, NULL);

--
-- Bẫy `project_instructions`
--
DELIMITER $$
CREATE TRIGGER `after_instruction_inserted` AFTER INSERT ON `project_instructions` FOR EACH ROW BEGIN 
 	DECLARE v_ins_count INT DEFAULT 0;
    DECLARE v_actioner varchar(100);
    DECLARE v_action text DEFAULT '';
    DECLARE v_role varchar(100) DEFAULT '';
    
    SET v_ins_count = (SELECT COUNT(id) FROM project_instructions WHERE project_id = NEW.project_id and id < NEW.id);
    
    IF v_ins_count > 0 THEN
    	SET v_actioner = (SELECT acronym FROM users WHERE id = NEW.created_by);
         SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.created_by));
        SET v_action = CONCAT(v_role,' [<span class="fw-bold text-info">', v_actioner, '</span>] <span class="text-success">INSERT NEW INSTRUCTION</span> <a href="javascript:void(0)" onClick="ViewContent(''', NEW.content, ''')">View detail</a>');

    	INSERT INTO project_logs(project_id,timestamp,action)
        VALUES(NEW.project_id,NEW.created_at,v_action);
    END IF;
 END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_project_instruction_updated` AFTER UPDATE ON `project_instructions` FOR EACH ROW BEGIN
	DECLARE v_actions varchar(255) DEFAULT '';
    DECLARE v_content text DEFAULT '';
    DECLARE v_actioner varchar(50);
    DECLARE v_role varchar(100) DEFAULT '';
    
	IF NEW.content <> OLD.content THEN
     	SET v_actioner = (SELECT acronym FROM users WHERE id = NEW.updated_by);
        SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.updated_by));
    	SET v_actions = CONCAT(v_role,' [<span class="fw-bold text-info">',v_actioner,'</span>] <span class="text-warning">CHANGE INSTRUCTION</span> <a href="javascript:void(0)" onClick="ViewContent(',NEW.id,')">View detail</a>,');     
        SET v_content = CONCAT('<span class="text-secondary">FROM:</span><br/><hr>',OLD.content,'<span class="mt-3 text-secondary">TO:</span><hr/>',NEW.content);
        INSERT INTO project_logs(project_id,timestamp,action,content)
        VALUES(OLD.project_id,NEW.updated_at,v_actions,v_content);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `project_logs`
--

CREATE TABLE `project_logs` (
  `id` bigint(50) NOT NULL,
  `project_id` bigint(20) NOT NULL,
  `task_id` bigint(20) NOT NULL DEFAULT 0,
  `cc_id` bigint(20) NOT NULL DEFAULT 0,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `action` varchar(255) NOT NULL,
  `content` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `project_logs`
--

INSERT INTO `project_logs` (`id`, `project_id`, `task_id`, `cc_id`, `timestamp`, `action`, `content`) VALUES
(1, 1, 0, 0, '2023-11-11 11:11:07', 'CEO [<span class=\"text-info fw-bold\">admin</span>] <span class=\"text-success\">CREATE PROJECT FOR CUSTOMER</span> [<span class=\"text-primary\">fdasfsdaf2</span>]', ''),
(2, 1, 0, 0, '2023-11-11 11:11:50', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-warning\">CHANGE STATUS</span> FROM [<span class=\"text-secondary\">Ask again</span>] TO [<span class=\"text-info\">Unpaid</span>]', ''),
(3, 2, 0, 0, '2023-11-11 19:47:10', 'CSS [<span class=\"text-info fw-bold\">binh.tt</span>] <span class=\"text-success\">CREATE PROJECT FOR CUSTOMER</span> [<span class=\"text-primary\">fdasfsdafsaf</span>]', ''),
(4, 3, 0, 0, '2023-11-11 19:47:28', 'CSS [<span class=\"text-info fw-bold\">binh.tt</span>] <span class=\"text-success\">CREATE PROJECT FOR CUSTOMER</span> [<span class=\"text-primary\">fdasfsdafsaf</span>]', ''),
(5, 1, 0, 0, '2023-11-11 19:48:44', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-warning\">CHANGE STATUS</span> FROM [<span class=\"text-secondary\">Unpaid</span>] TO [<span class=\"text-info\">Paid</span>]', ''),
(6, 4, 0, 0, '2023-11-11 19:55:46', 'CSS [<span class=\"text-info fw-bold\">binh.tt</span>] <span class=\"text-success\">CREATE PROJECT FOR CUSTOMER</span> [<span class=\"text-primary\">fdasfsdaf2</span>]', ''),
(7, 5, 0, 0, '2023-11-11 20:05:57', 'CSS [<span class=\"text-info fw-bold\">binh.tt</span>] <span class=\"text-success\">CREATE PROJECT FOR CUSTOMER</span> [<span class=\"text-primary\">fdasfsdafsaf</span>]', ''),
(8, 5, 0, 0, '2023-11-11 20:06:27', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE DESCRIPTION</span><a href=\"javascript:void(0)\" onClick=\"ViewContent(5)\">View detail</a>, <span class=\"text-warning\">CHANGE STATUS</span> FROM [<span class=\"text-seconda', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>This is html description for the 111123 project</p><span class=\"mt-3 text-secondary\">TO:</span><hr/><p>&lt;p&gt;This is html description for the 111123 project&lt;/p&gt;</p>'),
(9, 5, 0, 0, '2023-11-11 20:06:27', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE INSTRUCTION</span> <a href=\"javascript:void(0)\" onClick=\"ViewContent(3)\">View detail</a>,', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>This is html instruction for</p><p>the 111123 project </p><span class=\"mt-3 text-secondary\">TO:</span><hr/><p>&lt;p&gt;This is html instruction for&lt;/p&gt;&lt;p&gt;the 111123 project &lt;/p&gt;</p>'),
(10, 5, 0, 0, '2023-11-11 20:06:51', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE DESCRIPTION</span><a href=\"javascript:void(0)\" onClick=\"ViewContent(5)\">View detail</a>, <span class=\"text-warning\">CHANGE STATUS</span> FROM [<span class=\"text-seconda', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>&lt;p&gt;This is html description for the 111123 project&lt;/p&gt;</p><span class=\"mt-3 text-secondary\">TO:</span><hr/><p>&lt;p&gt;&amp;lt;p&amp;gt;This is html description for the 111123 project&amp;lt;/p&amp;gt;&lt;/p&gt;</p>'),
(11, 5, 0, 0, '2023-11-11 20:06:51', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE INSTRUCTION</span> <a href=\"javascript:void(0)\" onClick=\"ViewContent(3)\">View detail</a>,', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>&lt;p&gt;This is html instruction for&lt;/p&gt;&lt;p&gt;the 111123 project &lt;/p&gt;</p><span class=\"mt-3 text-secondary\">TO:</span><hr/><p>&lt;p&gt;&amp;lt;p&amp;gt;This is html instruction for&amp;lt;/p&amp;gt;&amp;lt;p&amp;gt;the 111123 project &amp;lt;/p&amp;gt;&lt;/p&gt;</p>'),
(12, 6, 0, 0, '2023-11-11 20:49:22', 'CSS [<span class=\"text-info fw-bold\">binh.tt</span>] <span class=\"text-success\">CREATE PROJECT FOR CUSTOMER</span> [<span class=\"text-primary\">fdasfsdaf2</span>]', ''),
(13, 6, 0, 0, '2023-11-11 20:49:37', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE DESCRIPTION</span><a href=\"javascript:void(0)\" onClick=\"ViewContent(6)\">View detail</a>', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>The 1st line of description</p>\n<p><strong>The 2nd line of description</strong></p>\n<p><em>The 3rd line of description</em></p>\n<p><u>The 4th line of description</u></p>\n<p>&nbsp;</p>\n<span class=\"mt-3 text-secondary\">TO:</span><hr/><p>The 1st line of description</p>\n\n<p><strong>The 2nd line of description</strong></p>\n\n<p><em>The 3rd line of description</em></p>\n\n<p><u>The 4th line of description</u></p>\n\n<p>&nbsp;</p>\n'),
(14, 6, 0, 0, '2023-11-11 21:14:35', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE STATUS</span> FROM [<span class=\"text-secondary\">Paid</span>] TO [<span class=\"text-info\">Initital</span>]', ''),
(15, 5, 0, 0, '2023-11-11 21:15:03', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE DESCRIPTION</span><a href=\"javascript:void(0)\" onClick=\"ViewContent(5)\">View detail</a>, <span class=\"text-warning\">CHANGE STATUS</span> FROM [<span class=\"text-seconda', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>&lt;p&gt;&amp;lt;p&amp;gt;This is html description for the 111123 project&amp;lt;/p&amp;gt;&lt;/p&gt;</p><span class=\"mt-3 text-secondary\">TO:</span><hr/><p>&lt;p&gt;&amp;lt;p&amp;gt;This is html description for the 111123 project&amp;lt;/p&amp;gt;&lt;/p&gt;</p>\n'),
(16, 5, 0, 0, '2023-11-11 21:15:03', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE INSTRUCTION</span> <a href=\"javascript:void(0)\" onClick=\"ViewContent(3)\">View detail</a>,', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>&lt;p&gt;&amp;lt;p&amp;gt;This is html instruction for&amp;lt;/p&amp;gt;&amp;lt;p&amp;gt;the 111123 project &amp;lt;/p&amp;gt;&lt;/p&gt;</p><span class=\"mt-3 text-secondary\">TO:</span><hr/><p>&lt;p&gt;&amp;lt;p&amp;gt;This is html instruction for&amp;lt;/p&amp;gt;&amp;lt;p&amp;gt;the 111123 project &amp;lt;/p&amp;gt;&lt;/p&gt;</p>\n'),
(17, 6, 0, 6, '2023-11-11 21:41:59', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-success\">CREATE NEW CC</span> FROM [<span class=\"text-warning\">11/11/2023 21:33</span>] TO [<span class=\"text-warning\">11/11/2023 21:33</span>]', ''),
(18, 6, 0, 7, '2023-11-11 21:42:19', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-success\">CREATE NEW CC</span> FROM [<span class=\"text-warning\">11/11/2023 21:42</span>] TO [<span class=\"text-warning\">11/11/2023 21:42</span>]', ''),
(19, 6, 0, 0, '2023-11-11 21:44:52', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-success\">INSERT NEW INSTRUCTION</span> <a href=\"javascript:void(0)\" onClick=\"ViewContent(\'<p>new instruction</p>\n\')\">View detail</a>', ''),
(20, 6, 0, 0, '2023-11-11 21:46:43', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-warning\">CHANGE INSTRUCTION</span> <a href=\"javascript:void(0)\" onClick=\"ViewContent(4)\">View detail</a>,', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>The 1st line of instruction</p>\n<p><strong>The 2nd line of instruction</strong></p>\n<p><em>The 3rd line of instruction</em></p>\n<p><u>The 4th line of instruction</u></p>\n<span class=\"mt-3 text-secondary\">TO:</span><hr/><p>new instruction</p>\n'),
(21, 6, 1, 0, '2023-11-11 21:54:06', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW TASK</span> [<span class=\"fw-bold bg-danger text-white\">PE-STAND</span>] with quantity: [1]', ''),
(22, 6, 0, 0, '2023-11-11 21:54:06', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-warning\">CHANGE STATUS</span> FROM [<span class=\"text-secondary\">Initital</span>] TO [<span class=\"text-info\">Processing</span>]', ''),
(23, 6, 0, 8, '2023-11-11 22:00:49', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">CREATE NEW CC</span> FROM [<span class=\"text-warning\">11/11/2023 22:00</span>] TO [<span class=\"text-warning\">11/11/2023 22:00</span>]', ''),
(24, 6, 0, 0, '2023-11-11 22:01:41', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW INSTRUCTION</span> <a href=\"javascript:void(0)\" onClick=\"ViewContent(\'<p>fasdfasfasdfasdfasfdasf</p>\n\')\">View detail</a>', ''),
(25, 6, 2, 0, '2023-11-11 22:02:13', 'CSS [<span class=\"fw-bold text-info\">binh.tt</span>] <span class=\"text-info\">CREATE NEW TASK</span> [<span class=\"fw-bold bg-warning text-white\">PE-Drone-Basic</span>] FROM TEMPLATE with quantity: [1]', ''),
(26, 6, 0, 0, '2023-11-11 22:07:28', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-warning\">CHANGE INSTRUCTION</span> <a href=\"javascript:void(0)\" onClick=\"ViewContent(4)\">View detail</a>,', '<span class=\"text-secondary\">FROM:</span><br/><hr><p>new instruction</p>\n<span class=\"mt-3 text-secondary\">TO:</span><hr/><p>fasdfasfasdfasdfasfdasf</p>\n'),
(27, 7, 0, 0, '2023-11-11 22:10:07', 'CEO [<span class=\"text-info fw-bold\">admin</span>] <span class=\"text-success\">CREATE PROJECT FOR CUSTOMER</span> [<span class=\"text-primary\">fdasfsdaf2</span>]', ''),
(28, 7, 0, 0, '2023-11-11 22:10:19', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-warning\">CHANGE STATUS</span> FROM [<span class=\"text-secondary\">Processing</span>] TO [<span class=\"text-info\">Initital</span>]', ''),
(29, 6, 3, 0, '2023-11-11 23:56:43', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW TASK</span> [<span class=\"fw-bold text-success\">Re-Stand</span>] with quantity: [1]', ''),
(30, 6, 4, 0, '2023-11-11 23:57:04', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW TASK</span> [<span class=\"fw-bold bg-warning text-white\">PE-Drone-Basic</span>] with quantity: [1]', ''),
(31, 6, 5, 0, '2023-11-11 23:57:39', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW TASK</span> [<span class=\"fw-bold bg-warning text-white\">PE-Drone-Basic</span>] with quantity: [1]', ''),
(32, 6, 6, 0, '2023-11-11 23:58:05', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW TASK</span> [<span class=\"fw-bold bg-danger text-white\">PE-STAND</span>] with quantity: [1]', ''),
(33, 6, 7, 0, '2023-11-11 23:58:36', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW CC TASK</span> [<span class=\"fw-bold bg-danger text-white\">PE-STAND</span>] with quantity: [1]', ''),
(34, 6, 8, 0, '2023-11-12 10:26:43', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW TASK</span> [<span class=\"fw-bold bg-warning text-white\">PE-Drone-Basic</span>] with quantity: [3]', ''),
(35, 6, 9, 0, '2023-11-12 10:31:50', 'CEO [<span class=\"fw-bold text-info\">admin</span>] <span class=\"text-success\">INSERT NEW TASK</span> [<span class=\"fw-bold text-warning\">Re-ADV</span>] with quantity: [1]', ''),
(36, 6, 7, 0, '2023-11-12 13:14:20', 'UPDATED TASK [<span <span class=\"text-warning\">CHANGED QUANTITY</span> FROM [<span class=\"text-secondary\">1</span>] TO [<span class=\"text-primary\">3</span>]', '');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `project_statuses`
--

CREATE TABLE `project_statuses` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `description` varchar(100) NOT NULL,
  `color` varchar(50) NOT NULL,
  `visible` bit(1) NOT NULL DEFAULT b'0' COMMENT 'Trạng thái chỉ có CSS nhìn thấy',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(10) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `project_statuses`
--

INSERT INTO `project_statuses` (`id`, `name`, `description`, `color`, `visible`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'wait', 'Chờ down task, chưa thêm task được', 'badge badge-warning', b'1', '0000-00-00 00:00:00', 0, '2023-11-09 05:38:26', 1),
(2, 'Processing', 'Đang trong quá trình xử lý task', 'badge badge-warning', b'0', '0000-00-00 00:00:00', 0, '2023-11-09 05:38:30', 1),
(3, 'Ready', 'Các task của project đã đc upload', 'badge badge-success', b'0', '2023-10-19 16:28:45', 1, NULL, 0),
(4, 'Upload Link', 'TLA tiến hành upload link thành phẩm của project ', 'badge badge-success', b'0', '0000-00-00 00:00:00', 0, NULL, 0),
(5, 'Sent', 'CSS gửi link thành phẩm cho khách hàng', 'badge badge-success', b'0', '0000-00-00 00:00:00', 0, NULL, 0),
(6, 'Paid', 'Được thanh toán', 'badge badge-info', b'0', '0000-00-00 00:00:00', 0, NULL, 0),
(7, 'Unpaid', 'Không được thanh toán', 'badge badge-danger', b'0', '0000-00-00 00:00:00', 0, NULL, 0),
(8, 'Ask again', 'Yêu cầu làm lại', 'badge badge-warning', b'0', '0000-00-00 00:00:00', 0, NULL, 0),
(9, 'Responded', 'Quy trách nhiệm cho nhân viên', 'badge badge-danger', b'0', '0000-00-00 00:00:00', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tasks`
--

CREATE TABLE `tasks` (
  `id` bigint(30) NOT NULL,
  `project_id` bigint(30) NOT NULL,
  `description` text DEFAULT NULL,
  `status_id` tinyint(4) NOT NULL DEFAULT 0,
  `editor_id` int(11) NOT NULL,
  `editor_timestamp` timestamp NULL DEFAULT NULL COMMENT 'Thời điểm editor được gán hoặc nhận task',
  `editor_assigned` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1: Editor được gán, 0: editor nhận task',
  `editor_wage` float DEFAULT 0 COMMENT 'Tiền công của editor',
  `editor_fix` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đánh dấu task có qua bước fix hay không. Nếu là 1 thì DC submit sẽ đc tính là DC-fix',
  `editor_read_instructions` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Editor đã đọc instructions',
  `editor_url` varchar(5000) NOT NULL COMMENT 'Link submit của editor parttime',
  `qa_id` int(11) NOT NULL,
  `qa_timestamp` timestamp NULL DEFAULT NULL COMMENT 'Thời điểm qa được gán task hoặc nhận task',
  `qa_assigned` tinyint(1) NOT NULL COMMENT '1: QA được gán, 0: QA nhận task',
  `qa_wage` float NOT NULL DEFAULT 0 COMMENT 'Tiền công của QA',
  `qa_read_instructions` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đánh dấu QA đã đọc instructions',
  `qa_reject_id` bigint(20) NOT NULL DEFAULT 0 COMMENT 'Tham chiếu tới id của task_rejectings',
  `dc_id` int(11) NOT NULL COMMENT 'Quản lý chất lượng ảnh đầu ra',
  `dc_timestamp` timestamp NULL DEFAULT NULL COMMENT 'Thời điểm dc_submit',
  `dc_wage` float NOT NULL DEFAULT 0 COMMENT 'Tiền công của DC',
  `dc_read_instructions` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'DC đã đọc instructions',
  `dc_reject_id` bigint(20) NOT NULL DEFAULT 0 COMMENT 'Tham chiếu tới id của task_rejectings',
  `level_id` int(30) NOT NULL,
  `tla_id` int(11) NOT NULL,
  `tla_timestamp` timestamp NULL DEFAULT NULL,
  `tla_wage` float NOT NULL DEFAULT 0,
  `tla_read_instructions` tinyint(4) NOT NULL DEFAULT 0,
  `tla_reject_id` bigint(20) NOT NULL DEFAULT 0,
  `tla_content` text NOT NULL COMMENT 'Nội dung khi TLA upload task',
  `auto_gen` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Đánh dấu task được gen tự động hay là insert thủ công. 1: auto, 0: insert',
  `cc_id` int(11) NOT NULL DEFAULT 0 COMMENT 'CC id nếu có (>0). Mặc định sẽ là 0',
  `quantity` int(11) NOT NULL DEFAULT 1,
  `pay` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Đánh dấu task có được thanh toán không',
  `unpaid_remark` text NOT NULL COMMENT 'Ghi chú lí do nếu không thanh toán',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tasks`
--

INSERT INTO `tasks` (`id`, `project_id`, `description`, `status_id`, `editor_id`, `editor_timestamp`, `editor_assigned`, `editor_wage`, `editor_fix`, `editor_read_instructions`, `editor_url`, `qa_id`, `qa_timestamp`, `qa_assigned`, `qa_wage`, `qa_read_instructions`, `qa_reject_id`, `dc_id`, `dc_timestamp`, `dc_wage`, `dc_read_instructions`, `dc_reject_id`, `level_id`, `tla_id`, `tla_timestamp`, `tla_wage`, `tla_read_instructions`, `tla_reject_id`, `tla_content`, `auto_gen`, `cc_id`, `quantity`, `pay`, `unpaid_remark`, `created_at`, `created_by`, `updated_at`, `updated_by`, `deleted_at`, `deleted_by`) VALUES
(1, 6, '<p>new task description</p>\n', 0, 0, NULL, 0, 0, 0, 0, '', 0, NULL, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 1, 0, NULL, 0, 0, 0, '', 0, 0, 1, 1, '', '2023-11-11 21:54:06', 1, '2023-11-11 14:54:06', 0, NULL, NULL),
(2, 6, NULL, 0, 0, NULL, 0, 0, 0, 0, '', 0, NULL, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 3, 0, NULL, 0, 0, 0, '', 1, 0, 1, 1, '', '2023-11-11 22:02:13', 6, '2023-11-11 15:02:13', 0, NULL, NULL),
(3, 6, '<p>fdsafdas</p>\n', 0, 0, NULL, 0, 0, 0, 0, '', 0, NULL, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 4, 0, NULL, 0, 0, 0, '', 0, 0, 1, 1, '', '2023-11-11 23:56:43', 1, '2023-11-11 16:56:43', 0, NULL, NULL),
(4, 6, '<p>fsadfsafd</p>\n', 0, 0, NULL, 0, 0, 0, 0, '', 0, NULL, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 3, 0, NULL, 0, 0, 0, '', 0, 0, 1, 1, '', '2023-11-11 23:57:04', 1, '2023-11-11 16:57:04', 0, NULL, NULL),
(5, 6, '<p>fsdafsdaf</p>\n', 0, 0, NULL, 0, 0, 0, 0, '', 0, NULL, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 3, 0, NULL, 0, 0, 0, '', 0, 0, 1, 1, '', '2023-11-11 23:57:39', 1, '2023-11-11 16:57:39', 0, NULL, NULL),
(6, 6, '<p>fdsafsadf</p>\n', 0, 0, NULL, 0, 0, 0, 0, '', 0, NULL, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 1, 0, NULL, 0, 0, 0, '', 0, 0, 1, 1, '', '2023-11-11 23:58:05', 1, '2023-11-11 16:58:05', 0, NULL, NULL),
(7, 6, '<p>Task description</p>\n<p>Line 1&nbsp;</p>\n<p><strong>Line 2</strong></p>\n<p>Line 3</p>\n<div alt=\"0\" id=\"SL_balloon_obj\" style=\"display:block\">\n<div class=\"SL_ImTranslatorLogo\" id=\"SL_button\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/imtranslator-s.png&quot;); opacity:100\">&nbsp;</div>\n<div id=\"SL_shadow_translation_result2\" style=\"display:none\">&nbsp;</div>\n<div class=\"notranslate\" id=\"SL_shadow_translator\">\n<div id=\"SL_planshet\">\n<div id=\"SL_arrow_up\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/up.png&quot;)\">&nbsp;</div>\n<div id=\"SL_Bproviders\">\n<div class=\"SL_BL_LABLE_ON\" id=\"SL_P0\" title=\"Google\">\n<div id=\"SL_PN0\">G</div>\n</div>\n<div class=\"SL_BL_LABLE_ON\" id=\"SL_P1\" title=\"Microsoft\">\n<div id=\"SL_PN1\">M</div>\n</div>\n<div class=\"SL_BL_LABLE_ON\" id=\"SL_P2\" title=\"Translator\">\n<div id=\"SL_PN2\">T</div>\n</div>\n<div class=\"SL_BL_LABLE_ON\" id=\"SL_P3\" title=\"Yandex\">\n<div id=\"SL_PN3\">Y</div>\n</div>\n</div>\n<div id=\"SL_alert_bbl\">\n<div id=\"SLHKclose\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/delete.png&quot;)\">&nbsp;</div>\n<div id=\"SL_alert_cont\">&nbsp;</div>\n</div>\n<div id=\"SL_TB\">\n<div cellspacing=\"1\" id=\"SL_tables\">&nbsp;</div>\n</div>\n</div>\n</div>\n</div>\n<tr>\n	<td align=\"right\" class=\"SL_td\" width=\"10%\"><input checked=\"true\" id=\"SL_locer\" title=\"Khóa ngôn ngữ\" type=\"checkbox\" /></td>\n	<td align=\"left\" class=\"SL_td\" width=\"20%\"><select class=\"SL_lngs\" id=\"SL_lng_from\"><option value=\"auto\">Ph&aacute;t hiện ng&ocirc;n ngữ</option><option value=\"eo\">Quốc Tế Ngữ</option><option value=\"ar\">Tiếng Ả Rập</option><option value=\"sq\">Tiếng Albania</option><option value=\"am\">Tiếng Amharic</option><option value=\"en\">Tiếng Anh</option><option value=\"hy\">Tiếng Armenia</option><option value=\"az\">Tiếng Azerbaijan</option><option value=\"pl\">Tiếng Ba Lan</option><option value=\"fa\">Tiếng Ba Tư</option><option value=\"sw\">Tiếng Swahili</option><option value=\"eu\">Tiếng Basque</option><option value=\"be\">Tiếng Belarus</option><option value=\"bn\">Tiếng Bengal</option><option value=\"pt\">Tiếng Bồ Đ&agrave;o Nha</option><option value=\"bs\">Tiếng Bosnia</option><option value=\"bg\">Tiếng Bulgaria</option><option value=\"ca\">Tiếng Catalan</option><option value=\"ceb\">Tiếng Cebuano</option><option value=\"ny\">Tiếng Chichewa</option><option value=\"co\">Tiếng Corsi</option><option value=\"ht\">Tiếng Creole ở Haiti</option><option value=\"hr\">Tiếng Croatia</option><option value=\"da\">Tiếng Đan Mạch</option><option value=\"iw\">Tiếng Do Th&aacute;i</option><option value=\"de\">Tiếng Đức</option><option value=\"et\">Tiếng Estonia</option><option value=\"tl\">Tiếng Filipino</option><option value=\"fy\">Tiếng Frisia</option><option value=\"gd\">Tiếng Gael Scotland</option><option value=\"gl\">Tiếng Galicia</option><option value=\"ka\">Ti&ecirc;́ng George</option><option value=\"gu\">Tiếng Gujarat</option><option value=\"nl\">Tiếng H&agrave; Lan</option><option value=\"af\">Tiếng H&agrave; Lan (Nam Phi)</option><option value=\"ko\">Tiếng H&agrave;n</option><option value=\"ha\">Tiếng Hausa</option><option value=\"haw\">Tiếng Hawaii</option><option value=\"hi\">Tiếng Hindi</option><option value=\"hmn\">Tiếng Hmong</option><option value=\"hu\">Tiếng Hungary</option><option value=\"el\">Tiếng Hy Lạp</option><option value=\"is\">Tiếng Iceland</option><option value=\"ig\">Tiếng Igbo</option><option value=\"id\">Tiếng Indonesia</option><option value=\"ga\">Tiếng Ireland</option><option value=\"jw\">Tiếng Java</option><option value=\"kn\">Tiếng Kannada</option><option value=\"kk\">Tiếng Kazakh</option><option value=\"km\">Tiếng Khmer</option><option value=\"ku\">Tiếng Kurd (Kurmanji)</option><option value=\"ckb\">Tiếng Kurd (Sorani)</option><option value=\"ky\">Tiếng Kyrgyz</option><option value=\"lo\">Tiếng L&agrave;o</option><option value=\"la\">Tiếng Latinh</option><option value=\"lv\">Tiếng Latvia</option><option value=\"lt\">Tiếng Litva</option><option value=\"lb\">Tiếng Luxembourg</option><option value=\"ms\">Tiếng M&atilde; Lai</option><option value=\"mk\">Tiếng Macedonia</option><option value=\"mg\">Tiếng Malagasy</option><option value=\"ml\">Tiếng Malayalam</option><option value=\"mt\">Tiếng Malta</option><option value=\"mi\">Tiếng Maori</option><option value=\"mr\">Tiếng Marathi</option><option value=\"mn\">Tiếng M&ocirc;ng Cổ</option><option value=\"my\">Tiếng Myanmar</option><option value=\"no\">Tiếng Na Uy</option><option value=\"ne\">Tiếng Nepal</option><option value=\"ru\">Tiếng Nga</option><option value=\"ja\">Tiếng Nhật</option><option value=\"ps\">Tiếng Pashto</option><option value=\"fi\">Tiếng Phần Lan</option><option value=\"fr\">Tiếng Ph&aacute;p</option><option value=\"pa\">Tiếng Punjab</option><option value=\"ro\">Tiếng Rumani</option><option value=\"sm\">Tiếng Samoa</option><option value=\"cs\">Tiếng S&eacute;c</option><option value=\"sr\">Tiếng Serbia</option><option value=\"st\">Tiếng Sesotho</option><option value=\"sn\">Tiếng Shona</option><option value=\"sd\">Tiếng Sindhi</option><option value=\"si\">Tiếng Sinhala</option><option value=\"sk\">Tiếng Slovak</option><option value=\"sl\">Tiếng Slovenia</option><option value=\"so\">Tiếng Somali</option><option value=\"su\">Tiếng Sunda</option><option value=\"sw\">Tiếng Swahili</option><option value=\"tg\">Tiếng Tajik</option><option value=\"ta\">Tiếng Tamil</option><option value=\"tt\">Tiếng Tatar</option><option value=\"es\">Tiếng T&acirc;y Ban Nha</option><option value=\"te\">Tiếng Telugu</option><option value=\"th\">Tiếng Th&aacute;i</option><option value=\"tr\">Tiếng Thổ Nhĩ Kỳ</option><option value=\"sv\">Tiếng Thụy Điển</option><option value=\"zh-CN\">Tiếng Trung</option><option value=\"zh-TW\">Tiếng Trung giản thể</option><option value=\"uk\">Tiếng Ukraina</option><option value=\"ur\">Tiếng Urdu</option><option value=\"uz\">Tiếng Uzbek</option><option value=\"vi\">Tiếng Việt</option><option value=\"cy\">Tiếng Xứ Wales</option><option value=\"it\">Tiếng &Yacute;</option><option value=\"yi\">Tiếng Yiddish</option><option value=\"yo\">Tiếng Yoruba</option><option value=\"zu\">Tiếng Zulu</option></select></td>\n	<td align=\"center\" class=\"SL_td\" width=\"3\">\n	<div id=\"SL_switch_b\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/switchb.png&quot;)\" title=\"Chuyển ngôn ngữ\">&nbsp;</div>\n	</td>\n	<td align=\"left\" class=\"SL_td\" width=\"20%\"><select class=\"SL_lngs\" id=\"SL_lng_to\"><option selected=\"selected\" value=\"vi\">Tiếng Việt</option><option disabled=\"true\">-------- [ Tất cả ] --------</option><option value=\"eo\">Quốc Tế Ngữ</option><option value=\"ar\">Tiếng Ả Rập</option><option value=\"sq\">Tiếng Albania</option><option value=\"am\">Tiếng Amharic</option><option value=\"en\">Tiếng Anh</option><option value=\"hy\">Tiếng Armenia</option><option value=\"az\">Tiếng Azerbaijan</option><option value=\"pl\">Tiếng Ba Lan</option><option value=\"fa\">Tiếng Ba Tư</option><option value=\"sw\">Tiếng Swahili</option><option value=\"eu\">Tiếng Basque</option><option value=\"be\">Tiếng Belarus</option><option value=\"bn\">Tiếng Bengal</option><option value=\"pt\">Tiếng Bồ Đ&agrave;o Nha</option><option value=\"bs\">Tiếng Bosnia</option><option value=\"bg\">Tiếng Bulgaria</option><option value=\"ca\">Tiếng Catalan</option><option value=\"ceb\">Tiếng Cebuano</option><option value=\"ny\">Tiếng Chichewa</option><option value=\"co\">Tiếng Corsi</option><option value=\"ht\">Tiếng Creole ở Haiti</option><option value=\"hr\">Tiếng Croatia</option><option value=\"da\">Tiếng Đan Mạch</option><option value=\"iw\">Tiếng Do Th&aacute;i</option><option value=\"de\">Tiếng Đức</option><option value=\"et\">Tiếng Estonia</option><option value=\"tl\">Tiếng Filipino</option><option value=\"fy\">Tiếng Frisia</option><option value=\"gd\">Tiếng Gael Scotland</option><option value=\"gl\">Tiếng Galicia</option><option value=\"ka\">Ti&ecirc;́ng George</option><option value=\"gu\">Tiếng Gujarat</option><option value=\"nl\">Tiếng H&agrave; Lan</option><option value=\"af\">Tiếng H&agrave; Lan (Nam Phi)</option><option value=\"ko\">Tiếng H&agrave;n</option><option value=\"ha\">Tiếng Hausa</option><option value=\"haw\">Tiếng Hawaii</option><option value=\"hi\">Tiếng Hindi</option><option value=\"hmn\">Tiếng Hmong</option><option value=\"hu\">Tiếng Hungary</option><option value=\"el\">Tiếng Hy Lạp</option><option value=\"is\">Tiếng Iceland</option><option value=\"ig\">Tiếng Igbo</option><option value=\"id\">Tiếng Indonesia</option><option value=\"ga\">Tiếng Ireland</option><option value=\"jw\">Tiếng Java</option><option value=\"kn\">Tiếng Kannada</option><option value=\"kk\">Tiếng Kazakh</option><option value=\"km\">Tiếng Khmer</option><option value=\"ku\">Tiếng Kurd (Kurmanji)</option><option value=\"ckb\">Tiếng Kurd (Sorani)</option><option value=\"ky\">Tiếng Kyrgyz</option><option value=\"lo\">Tiếng L&agrave;o</option><option value=\"la\">Tiếng Latinh</option><option value=\"lv\">Tiếng Latvia</option><option value=\"lt\">Tiếng Litva</option><option value=\"lb\">Tiếng Luxembourg</option><option value=\"ms\">Tiếng M&atilde; Lai</option><option value=\"mk\">Tiếng Macedonia</option><option value=\"mg\">Tiếng Malagasy</option><option value=\"ml\">Tiếng Malayalam</option><option value=\"mt\">Tiếng Malta</option><option value=\"mi\">Tiếng Maori</option><option value=\"mr\">Tiếng Marathi</option><option value=\"mn\">Tiếng M&ocirc;ng Cổ</option><option value=\"my\">Tiếng Myanmar</option><option value=\"no\">Tiếng Na Uy</option><option value=\"ne\">Tiếng Nepal</option><option value=\"ru\">Tiếng Nga</option><option value=\"ja\">Tiếng Nhật</option><option value=\"ps\">Tiếng Pashto</option><option value=\"fi\">Tiếng Phần Lan</option><option value=\"fr\">Tiếng Ph&aacute;p</option><option value=\"pa\">Tiếng Punjab</option><option value=\"ro\">Tiếng Rumani</option><option value=\"sm\">Tiếng Samoa</option><option value=\"cs\">Tiếng S&eacute;c</option><option value=\"sr\">Tiếng Serbia</option><option value=\"st\">Tiếng Sesotho</option><option value=\"sn\">Tiếng Shona</option><option value=\"sd\">Tiếng Sindhi</option><option value=\"si\">Tiếng Sinhala</option><option value=\"sk\">Tiếng Slovak</option><option value=\"sl\">Tiếng Slovenia</option><option value=\"so\">Tiếng Somali</option><option value=\"su\">Tiếng Sunda</option><option value=\"sw\">Tiếng Swahili</option><option value=\"tg\">Tiếng Tajik</option><option value=\"ta\">Tiếng Tamil</option><option value=\"tt\">Tiếng Tatar</option><option value=\"es\">Tiếng T&acirc;y Ban Nha</option><option value=\"te\">Tiếng Telugu</option><option value=\"th\">Tiếng Th&aacute;i</option><option value=\"tr\">Tiếng Thổ Nhĩ Kỳ</option><option value=\"sv\">Tiếng Thụy Điển</option><option value=\"zh-CN\">Tiếng Trung</option><option value=\"zh-TW\">Tiếng Trung giản thể</option><option value=\"uk\">Tiếng Ukraina</option><option value=\"ur\">Tiếng Urdu</option><option value=\"uz\">Tiếng Uzbek</option><option value=\"vi\">Tiếng Việt</option><option value=\"cy\">Tiếng Xứ Wales</option><option value=\"it\">Tiếng &Yacute;</option><option value=\"yi\">Tiếng Yiddish</option><option value=\"yo\">Tiếng Yoruba</option><option value=\"zu\">Tiếng Zulu</option></select></td>\n	<td align=\"center\" class=\"SL_td\" width=\"5%\">&nbsp;</td>\n	<td align=\"center\" class=\"SL_td\" width=\"8%\">\n	<div id=\"SL_TTS_voice\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/ttsvoice.png&quot;)\" title=\"undefined\">&nbsp;</div>\n	</td>\n	<td align=\"center\" class=\"SL_td\" width=\"8%\">\n	<div class=\"SL_copy\" id=\"SL_copy\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/copy.png&quot;)\" title=\"Chép bản dịch\">\n	<div id=\"SL_copy_tip\">&nbsp;</div>\n	</div>\n	</td>\n	<td align=\"center\" class=\"SL_td\" width=\"8%\">\n	<div id=\"SL_bbl_font_patch\">&nbsp;</div>\n	<div class=\"SL_bbl_font\" id=\"SL_bbl_font\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/font.png&quot;)\" title=\"Cỡ chữ\">&nbsp;</div>\n	</td>\n	<td align=\"center\" class=\"SL_td\" width=\"8%\">\n	<div id=\"SL_bbl_help\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/bhelp.png&quot;)\" title=\"Trợ giúp\">&nbsp;</div>\n	</td>\n	<td align=\"right\" class=\"SL_td\" width=\"15%\">\n	<div class=\"SL_pin_off\" id=\"SL_pin\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/pin-on.png&quot;)\" title=\"Gắn cửa sổ pop-up\">&nbsp;</div>\n	</td>\n</tr>\n<div id=\"SL_shadow_translation_result\">&nbsp;</div>\n<div class=\"SL_loading\" id=\"SL_loading\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/loading.gif&quot;)\">&nbsp;</div>\n<div id=\"SL_player2\">&nbsp;</div>\n<div id=\"SL_alert100\">Chức năng ph&aacute;t &acirc;m giới hạn ở 200 k&yacute; tự</div>\n<div id=\"SL_Balloon_options\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/bg3.png&quot;) #ffffff\">\n<div id=\"SL_arrow_down\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/down.png&quot;)\">&nbsp;</div>\n<div id=\"SL_tbl_opt\">&nbsp;</div>\n</div>\n<tr>\n	<td align=\"center\" class=\"SL_td\" width=\"5%\"><input checked=\"true\" id=\"SL_BBL_locer\" title=\"Hiển thị nút của biên dịch viên 3 giây\" type=\"checkbox\" /></td>\n	<td align=\"left\" class=\"SL_td\" width=\"5%\">\n	<div id=\"SL_BBL_IMG\" style=\"background:url(&quot;chrome-extension://noaijdpnepcgjemiklgfkcfbkokogabh/content/img/util/bbl-logo.png&quot;)\" title=\"Hiển thị nút của biên dịch viên 3 giây\">&nbsp;</div>\n	</td>\n	<td align=\"center\" class=\"SL_td\" width=\"100%\"><span class=\"SL_options\" id=\"BBL_OPT\" title=\"Hiển thị các tùy chọn\">C&aacute;c T&ugrave;y chọn</span> : <span class=\"SL_options\" id=\"HIST_OPT\" title=\"Lược sử biên dịch\">Lược sử</span> : <span class=\"SL_options\" id=\"FEED_OPT\" title=\"Phản hồi\">Phản hồi</span> : <span class=\"SL_options\" id=\"DONATE_OPT\" title=\"Đóng góp\">Donate</span></td>\n	<td align=\"right\" class=\"SL_td\" nowrap=\"nowrap\" width=\"15%\"><span class=\"SL_options\" id=\"SL_Balloon_Close\" title=\"Đóng\">Đ&oacute;ng</span></td>\n</tr>\n', 0, 0, '2023-11-12 06:14:20', 0, 0, 0, 0, '', 0, '2023-11-12 06:14:20', 0, 0, 0, 0, 0, NULL, 0, 0, 0, 1, 0, NULL, 0, 0, 0, '', 0, 5, 3, 1, '', '2023-11-11 23:58:36', 1, '2023-11-12 06:14:20', 1, NULL, NULL),
(8, 6, '<p>fsadfasfasdf</p>\n', 0, 0, NULL, 0, 0, 0, 0, '', 0, NULL, 0, 0, 0, 0, 0, NULL, 0, 0, 0, 3, 0, NULL, 0, 0, 0, '', 0, 0, 3, 1, '', '2023-11-12 10:26:43', 1, '2023-11-12 03:26:43', 0, NULL, NULL),
(9, 6, '<p>retwetewt</p>\n', 0, 0, '2023-11-12 06:13:47', 0, 0, 0, 0, '', 0, '2023-11-12 06:13:47', 0, 0, 0, 0, 0, NULL, 0, 0, 0, 6, 0, NULL, 0, 0, 0, '', 0, 0, 1, 1, '', '2023-11-12 10:31:50', 1, '2023-11-12 06:13:47', 1, NULL, NULL);

--
-- Bẫy `tasks`
--
DELIMITER $$
CREATE TRIGGER `after_task_deleted` AFTER DELETE ON `tasks` FOR EACH ROW BEGIN
	DECLARE v_level varchar(100);
    DECLARE v_role varchar(100) DEFAULT '';

    SET v_level = (SELECT name FROM levels WHERE id = OLD.level_id);
    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE acronym = OLD.deleted_by));
	INSERT INTO project_logs(project_id,task_id,timestamp,action)
    VALUES(OLD.project_id,OLD.id,OLD.deleted_at,CONCAT(v_role,' [<span class="text-info fw-bold">',OLD.deleted_by,'</span>] <span class="text-danger">DELETE TASK </span>[',v_level,']'));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_task_inserted` AFTER INSERT ON `tasks` FOR EACH ROW BEGIN
	DECLARE v_created_by varchar(100);
    DECLARE v_level varchar(50);
    DECLARE v_level_color varchar(200);
    DECLARE v_action varchar(5000);
    DECLARE v_role varchar(100) DEFAULT '';
    
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM tasks WHERE id = NEW.id));
    SET v_level = (SELECT name FROM levels WHERE id = NEW.level_id);
    SET v_level_color = (SELECT color FROM levels WHERE id = NEW.level_id);
    
    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.created_by));
    
    SET v_action = CONCAT(v_role,' [<span class="fw-bold text-info">',v_created_by,'</span>] ');
    IF NEW.auto_gen = 1 THEN 
    	SET v_action = CONCAT( v_action,'<span class="text-info">CREATE NEW TASK</span> [<span class="fw-bold ',v_level_color,'">',v_level,'</span>] FROM TEMPLATE with quantity: [',NEW.quantity,']');
    ELSEIF NEW.cc_id > 0 THEN
    	SET v_action = CONCAT( v_action,'<span class="text-success">INSERT NEW CC TASK</span> [<span class="fw-bold ',v_level_color,'">',v_level,'</span>] with quantity: [',NEW.quantity,']');
    ELSE
    	SET v_action = CONCAT(v_action,'<span class="text-success">INSERT NEW TASK</span> [<span class="fw-bold ',v_level_color,'">',v_level,'</span>] with quantity: [',NEW.quantity,']');
    END IF;
    
    INSERT INTO project_logs(project_id,task_id,timestamp,action)
    VALUES(NEW.project_id,NEW.id,NEW.created_at,v_action);
   
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_task_updated` AFTER UPDATE ON `tasks` FOR EACH ROW BEGIN 
    
    DECLARE v_old_level VARCHAR(100) DEFAULT '';
    DECLARE v_new_level VARCHAR(100) DEFAULT '';
    
    DECLARE v_old_status VARCHAR(100) DEFAULT '';
    DECLARE v_new_status VARCHAR(100) DEFAULT '';
    
    DECLARE v_old_emp VARCHAR(100) DEFAULT '';
    DECLARE v_new_emp VARCHAR(100) DEFAULT '';

    DECLARE v_role varchar(100) DEFAULT '';
    DECLARE v_action varchar(250) DEFAULT '';
    DECLARE v_actioner varchar(20) DEFAULT '';

    DECLARE v_content text DEFAULT '';

  
  	SET v_old_level = (SELECT name FROM levels WHERE id = OLD.level_id); -- lay level cu 	
    IF v_old_level IS NULL THEN -- nếu không thay đổi về level => old level chinh la new level
    	SET v_old_level = (SELECT name FROM levels WHERE id = NEW.level_id); -- lay level cu 	
    END IF;

    SET v_role = (SELECT name FROM user_types WHERE id = (SELECT type_id FROM users WHERE id = NEW.updated_by));
    
   SET v_actioner = CONCAT('UPDATED TASK [<span class="fw-bold">89778</span>]');
   
    
    -- description
    -- IF(OLD.description <> NEW.description) THEN    	
    	
    -- END IF;
    -- //end description
    
    -- task level
    IF(OLD.level_id <> NEW.level_id) THEN 
        SET v_new_level = (SELECT name FROM levels WHERE id = NEW.level_id); -- lay level hien tai    
        SET v_action = CONCAT('<span class="text-warning">CHANGED LEVEL</span> TO [<span class="fw-bold text-info">', v_new_level, '</span>]');    
        INSERT INTO project_logs(project_id,task_id, timestamp, action,content)
        VALUES(OLD.project_id,NEW.id, NEW.updated_at, CONCAT(v_actioner,v_action),v_content);
    END IF;
    -- //end task level
    
    -- status
    IF(OLD.status_id <> NEW.status_id) THEN
        SET v_new_status = (SELECT name FROM task_statuses WHERE id = NEW.status_id);        
        SET v_old_status = (SELECT name FROM task_statuses WHERE id = OLD.status_id);
        
        IF v_new_status IS NOT NULL THEN
            IF v_old_status IS NOT NULL THEN
                SET v_action = CONCAT('<span class="text-warning">CHANGED STATUS FROM</span> [<span class="fw-bold text-secondary">',v_old_status,'</span>] TO [<span class="fw-bold text-info">', v_new_status, '</span>]');               
            ELSE
                SET v_action = CONCAT('<span class="text-warning">CHANGED STATUS FROM</span> [<span class="fw-bold text-secondary">STARTED</span>] TO [<span class="fw-bold text-info">', v_new_status, '</span>]');               
            END IF;
        ELSE -- neu null => status_id = 0
            SET v_action = CONCAT('<span class="text-warning">CHANGED STATUS FROM</span> [<span class="fw-bold text-secondary">',v_old_status,'</span>] TO [<span class="fw-bold text-info">STARTED</span>]');               
        END IF;
        
        
           -- editor url
           IF OLD.editor_url <> NEW.editor_url AND  IsURL(NEW.editor_url) THEN
                SET v_action = CONCAT(v_action,' with <a href="',NEW.editor_url,'" target="_blank">Link</a>');       
           END IF;
            -- //editor url
    
        INSERT INTO project_logs(project_id,task_id, timestamp, action,content)
        VALUES(OLD.project_id,NEW.id, NEW.updated_at, CONCAT(v_actioner,v_action),v_content);
    END IF;
    -- //end status
    
    -- EDITOR
    IF(OLD.editor_id <> NEW.editor_id) THEN
    	SET v_new_emp = (SELECT acronym FROM users WHERE id = NEW.editor_id);        
      	IF OLD.editor_id = 0 THEN -- neu truoc do chua co editor     		
            IF NEW.editor_assigned = 1 THEN -- neu la gan editor
            	SET v_action = CONCAT('<span class="text-warning">ASSIGNED EDITOR</span> [<span class="text-info">', v_new_emp, '</span>]');        
            ELSE -- neu la editor get task
            	SET v_action = CONCAT('GOT TASK AS AN EDITOR');
            END IF;            
     	ELSE -- neu truoc do co editor
            SET v_old_emp = (SELECT acronym FROM users WHERE id = OLD.editor_id);   
        	IF NEW.editor_id = 0 THEN -- neu la huy editor
            	SET v_action = CONCAT('<span class="text-danger">UNASSIGNED EDITOR </span>[<span class="fw-bold">',v_old_emp,'</span>]');        
            ELSE -- thay sang editor khac
                SET v_action = CONCAT('<span class="text-warning">CHANGED EDITOR</span> FROM [<span class="text-secondary">', v_old_emp, '</span>] TO [<span class="text-info">', v_new_emp, '</span>]');        
            END IF;      
      	END IF;       
        
        INSERT INTO project_logs(project_id,task_id, timestamp, action,content)
        VALUES(OLD.project_id,NEW.id, NEW.updated_at, CONCAT(v_actioner,v_action),v_content);
    END IF; 
    -- //EDITOR
    
 
    
    
    -- QA
     IF(OLD.qa_id <> NEW.qa_id) THEN
    	SET v_new_emp = (SELECT acronym FROM users WHERE id = NEW.qa_id);        
      	IF OLD.qa_id = 0 THEN -- neu truoc do chua co QA     		
            IF NEW.qa_assigned = 1 THEN -- neu la gan QA
            	SET v_action = CONCAT('<span class="text-warning">ASSIGNED QA</span> [<span class="text-warning">', v_new_emp, '</span>]');        
            ELSE -- neu la QA get task
            	SET v_action = CONCAT('GOT TASK AS A QA');
            END IF;            
     	ELSE -- neu truoc do co QA
            SET v_old_emp = (SELECT acronym FROM users WHERE id = OLD.qa_id);
        	IF NEW.qa_id = 0 THEN -- neu la huy QA
            	SET v_action = CONCAT('<span class="text-danger">UNASSIGNED QA</span> [<span class="fw-bold text-secondary">',v_old_emp,'</span>]');        
            ELSE -- thay doi QA            	
                SET v_action = CONCAT('<span class="text-warning">CHANGED QA</span> FROM [<span class="text-secondary">', v_old_emp, '</span>] TO [<span class="text-info">', v_new_emp, '</span>]');        
            END IF;      
      	END IF;     
        INSERT INTO project_logs(project_id,task_id, timestamp, action,content)
        VALUES(OLD.project_id,NEW.id, NEW.updated_at, CONCAT(v_actioner,v_action),v_content);
    END IF; 
    
    -- // QA
    	
    -- DC
    	IF NEW.dc_timestamp <> OLD.dc_timestamp THEN -- neu co tac dong cua DC
        	SET v_new_emp = (SELECT acronym FROM users WHERE id = NEW.dc_id);     
        	IF OLD.dc_id = 0 THEN -- DC nhan task            	
            	SET v_action = CONCAT('GOT TASK AS A DC');
            ELSE -- DC submit task hoac thay doi DC
            	IF OLD.dc_id <> NEW.dc_id THEN -- thay doi DC
                	SET v_old_emp = (SELECT acronym FROM users WHERE id = OLD.dc_id);    
                    SET v_action = CONCAT('<span class="text-warning">CHANGED DC</span> FROM [<span class="text-secondary">', v_old_emp, '</span>] TO [<span class="text-info">', v_new_emp, '</span>]'); 
                END IF;
            END IF;
            INSERT INTO project_logs(project_id,task_id, timestamp, action,content)
            VALUES(OLD.project_id,NEW.id, NEW.updated_at, CONCAT(v_actioner,v_action),v_content);
        END IF;  
    -- //DC
    
    -- quantity
    IF(OLD.quantity <> NEW.quantity) THEN
        SET v_action = CONCAT('<span class="text-warning">CHANGED QUANTITY</span> FROM [<span class="text-secondary">', OLD.quantity, '</span>] TO [<span class="text-primary">', NEW.quantity, '</span>]');
        INSERT INTO project_logs(project_id,task_id, timestamp, action,content)
        VALUES(OLD.project_id,NEW.id, NEW.updated_at, CONCAT(v_actioner,v_action),v_content);
    END IF;
    -- //end quantity
    
    -- paid
    	IF OLD.pay <> NEW.pay THEN
        	IF NEW.pay = 1 THEN            	
        		SET v_action = CONCAT('<span class="text-warning">CHANGED PAID STATUS</span> FROM [<span class="text-secondary">FALSE</span>] TO [<span class="text-primary">TRUE</span>],');
            ELSE
            	SET v_action = CONCAT('<span class="text-warning">CHANGED PAID STATUS</span> FROM [<span class="text-primary">TRUE</span>] TO [<span class="text-secondary">FALSE</span>],');
            END IF;
            INSERT INTO project_logs(project_id,task_id, timestamp, action,content)
            VALUES(OLD.project_id,NEW.id, NEW.updated_at, CONCAT(v_actioner,v_action),v_content);
        END IF;
    -- //paid
    

	IF (SELECT COUNT(*) FROM tasks WHERE status_id <> 7) = 0 THEN
    	UPDATE projects 
        SET status_id = 3,updated_at = NOW(),updated_by = NEW.updated_by
        WHERE id = NEW.project_id; -- chuyển project sang trạng thái ready để TLA biết đường upload link
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `task_rejectings`
--

CREATE TABLE `task_rejectings` (
  `id` bigint(20) NOT NULL,
  `role_id` int(11) NOT NULL COMMENT 'Tham chiếu tới bảng user_types',
  `remark` text NOT NULL COMMENT 'Ghi chú lí do reject',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `task_statuses`
--

CREATE TABLE `task_statuses` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `color` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(10) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `task_statuses`
--

INSERT INTO `task_statuses` (`id`, `name`, `color`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'Editor OK', 'badge badge-success', '2023-10-13 01:37:09', 1, NULL, 0),
(2, 'QA Reject', 'badge badge-danger', '2023-10-13 01:37:09', 1, NULL, 0),
(3, 'Editor Fixed', 'badge badge-info', '2023-10-13 01:37:09', 1, NULL, 0),
(4, 'QA OK', 'badge badge-info', '2023-10-13 01:37:09', 1, NULL, 0),
(5, 'DC Reject', 'badge badge-danger', '2023-10-13 01:37:09', 1, NULL, 0),
(6, 'DC OK', 'badge badge-success', '2023-10-13 01:37:09', 1, NULL, 0),
(7, 'Upload', 'badge badge-warning', '2023-10-13 01:37:09', 1, NULL, 0),
(8, 'DC Fixed', 'badge badge-ligh', '2023-10-13 01:37:09', 1, NULL, 0),
(9, 'Wait', 'badge badge-dark', '2023-10-13 01:37:09', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `task_suggestions`
--

CREATE TABLE `task_suggestions` (
  `id` bigint(20) NOT NULL,
  `project_id` bigint(20) NOT NULL,
  `level_id` int(11) NOT NULL,
  `editor_id` int(11) NOT NULL,
  `qa_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `description` text NOT NULL,
  `applied` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0: mặc định. 1 được tạo. -1 từ chối',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` int(30) NOT NULL,
  `fullname` varchar(50) NOT NULL,
  `acronym` varchar(30) NOT NULL COMMENT 'Tên viết tắt',
  `email` varchar(200) NOT NULL,
  `password` varchar(255) NOT NULL,
  `type_id` tinyint(1) NOT NULL DEFAULT 2 COMMENT 'Tham chiếu tới table user_types',
  `editor_group_id` int(10) NOT NULL,
  `qa_group_id` int(11) NOT NULL,
  `avatar` text NOT NULL,
  `task_getable` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đánh dấu được get task hay không. Áp dụng cho cả Editor và QA',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Trạng thái hoạt động của tài khoản. 0 hoặc 1',
  `group_id` int(10) NOT NULL COMMENT 'Tham chiếu tới group user. exp: nhân viên chính thức, cộng tác viên',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `update_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `fullname`, `acronym`, `email`, `password`, `type_id`, `editor_group_id`, `qa_group_id`, `avatar`, `task_getable`, `status`, `group_id`, `created_at`, `created_by`, `updated_at`, `update_by`) VALUES
(1, 'Administrator', 'admin', 'admin@admin.com', '2db5228517bf8473a1dda3cab7cb4b8c', 1, 0, 0, '', 0, 0, 4, '2020-11-25 20:57:04', 0, NULL, 0),
(2, 'Nguyễn Hoàng Yến', 'Yen.nh', 'sale1@photohome.com.vn', '81dc9bdb52d04dc20036dbd8313ed055', 2, 0, 0, '', 0, 0, 1, '2023-08-19 20:55:42', 0, NULL, 0),
(3, 'Nguyễn Hữu Bình', 'Binh.nh', 'binh.nhphotohome@gmail.com', '202cb962ac59075b964b07152d234b70', 4, 0, 0, '1693061220_12 228 Main Photo 62.JPG', 0, 0, 3, '2023-08-19 20:57:13', 0, NULL, 0),
(4, 'Thiện', 'thien.pd', 'thien@gmail.com', '202cb962ac59075b964b07152d234b70', 6, 5, 6, '', 1, 0, 2, '2023-08-19 21:40:37', 0, NULL, 0),
(5, 'Đỗ Thị Ngọc Mai', 'Mai.dn', 'Mai.dnPhotohome@gmail.com', '202cb962ac59075b964b07152d234b70', 7, 0, 0, '', 0, 0, 3, '2023-08-20 02:40:39', 0, NULL, 0),
(6, 'Trịnh Thanh Bình', 'binh.tt', 'binh.ttphotohome@gmail.com', '202cb962ac59075b964b07152d234b70', 3, 0, 0, '', 0, 0, 3, '2023-08-24 21:19:50', 0, NULL, 0),
(7, 'Trần Tú Thành', 'Thanh.tt', 'Thanh.ttphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, 1, '2023-08-24 21:36:12', 0, NULL, 0),
(8, 'Trần Hồng Nhung', 'nhung.th', 'nhung.thphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, 1, '2023-09-04 07:41:06', 0, NULL, 0),
(9, 'Phạm Năng Bình', 'binh.pn', 'binh@photohome.com', '202cb962ac59075b964b07152d234b70', 5, 5, 5, '', 1, 1, 3, '2023-09-05 01:00:36', 0, NULL, 0),
(10, 'Bùi Đức Hiếu', 'hieu.bd', 'hieu.bdphotohome@gmai.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:52:26', 0, NULL, 0),
(11, 'Phạm Phương Nam', 'nam.pp', 'nam.ppphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:53:05', 0, NULL, 0),
(12, 'Nguyễn Đức Việt', 'viet.nd', 'viet.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:53:39', 0, NULL, 0),
(13, 'Vũ văn Đạt', 'dat.vv', 'dat.vvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:54:18', 0, NULL, 0),
(14, 'Bùi Văn Tuấn', 'tuan.bv', 'tuan.bvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:54:50', 0, NULL, 0),
(15, 'Vi Đức Trịnh', 'trinh.vd', 'trinh.vdphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:55:23', 0, NULL, 0),
(16, 'Phùng Minh Phong', 'phong.pm', 'phong.pmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:55:56', 0, NULL, 0),
(17, 'Nguyễn Hồng Sơn', 'son.nh', 'son.nhphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:56:33', 0, NULL, 0),
(18, 'Vũ Đức Thắng', 'thang.vd', 'thang.vdphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:57:58', 0, NULL, 0),
(19, 'Chu Thị Thúy', 'thuy.ct', 'thuy.ctphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:58:36', 0, NULL, 0),
(20, 'Trần Văn Đoàn', 'doan.tv', 'doan.tvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-09 09:59:01', 0, NULL, 0),
(21, 'Vũ Hồng Sơn', 'son.vh', 'son.vhphotohome@gmail.com', '202cb962ac59075b964b07152d234b70', 5, 6, 5, '', 1, 0, 1, '2023-09-09 19:40:43', 0, NULL, 0),
(22, 'Nguyễn Tuấn Nam', 'nam.nt', 'nam.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:12:02', 0, NULL, 0),
(23, 'Bùi Văn Hưng', 'hung.bv', 'hung.bvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:12:26', 0, NULL, 0),
(24, 'Bùi Ngọc Hoàng', 'hoang.bn', 'hoang.bnphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:12:55', 0, NULL, 0),
(25, 'Nguyễn Quốc Cường', 'cuong.nq', 'cuong.nqphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:13:21', 0, NULL, 0),
(26, 'Phùng Hữu Tình', 'tinh.ph', 'tinh.phphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:14:41', 0, NULL, 0),
(27, 'Phan Văn Thiêm', 'thiem.pv', 'thiem.pvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:15:05', 0, NULL, 0),
(28, 'Nguyễn Việt Hoàng', 'hoang.nv', 'hoang.nvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:15:33', 0, NULL, 0),
(29, 'Nguyễn Duy Tú', 'tu.nd', 'tu.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:15:54', 0, NULL, 0),
(30, 'Nguyễn Đức Chính', 'chinh.nd', 'chinh.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:16:21', 0, NULL, 0),
(31, 'Dương Văn Hưng', 'hung.dv', 'hung.dvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:16:52', 0, NULL, 0),
(32, 'Dương nguyễn kiên', 'kien.dn', 'kien.dnphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:17:14', 0, NULL, 0),
(33, 'Bùi Thị Hoa', 'hoa.bt', 'hoa.btphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:17:34', 0, NULL, 0),
(34, 'Phạm Thị thùy Trang', 'trang.pt', 'trang.ptphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:18:03', 0, NULL, 0),
(35, 'Nguyễn Thị Thu', 'thu.nt', 'thu.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:18:26', 0, NULL, 0),
(36, 'Lê Thu Hiên', 'hien.lt', 'hien.ltphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:18:53', 0, NULL, 0),
(37, 'Phạm Thúy Hảo', 'hao.pt', 'hoa.ptphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:19:15', 0, NULL, 0),
(38, 'Hoàng Thị Thanh Lam', 'lam.ht', 'Lam.htphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:19:40', 0, NULL, 0),
(39, 'Đinh Thị Minh Thi', 'thi.dt', 'thi.dmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:20:06', 0, NULL, 0),
(40, 'Trần Mạnh Hùng', 'hung.tm', 'hung.tmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:20:28', 0, NULL, 0),
(41, 'Trần Văn Chung', 'chung.tv', 'chung.tvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:20:51', 0, NULL, 0),
(42, 'Nguyễn Tuấn Đạt', 'dat.nt', 'dat.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:21:14', 0, NULL, 0),
(43, 'Đặng Đức Anh', 'anh.dd', 'anh.ddphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:21:36', 0, NULL, 0),
(44, 'Lê Minh Thành', 'thanh.lm', 'thanh.lmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:22:09', 0, NULL, 0),
(45, 'Cấn Việt Ánh', 'anh.cv', 'anh.cvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:22:28', 0, NULL, 0),
(46, 'Nguyễn Công Thành', 'thanh.nc', 'thanh.ncphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:22:55', 0, NULL, 0),
(47, 'Đinh Công Hưng', 'hung.dc', 'hung.dcphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:23:17', 0, NULL, 0),
(48, 'Nguyễn Công Lực', 'luc.nc', 'luc.ncphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, 1, '2023-09-10 21:23:38', 0, NULL, 0),
(49, 'Hoàng Anh Dũng', 'dung.ha', 'dung.haphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, 1, '2023-09-10 21:51:45', 0, NULL, 0),
(50, 'Đỗ Văn Chủ', 'chu.dv', 'chu.dvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, 1, '2023-09-10 22:01:17', 0, NULL, 0),
(51, 'Đỗ Tiến Duy', 'duy.dd', 'duy.ddphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, 1, '2023-09-10 22:01:50', 0, NULL, 0),
(52, 'Trần Xuân Thịnh', 'thinh.tx', 'thinh.txphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, 1, '2023-09-11 22:07:42', 0, NULL, 0),
(53, 'Phạm Thị Dung', 'dung.pt', 'dung.pt@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, 1, '2023-09-12 21:00:12', 0, NULL, 0),
(54, 'Lê Minh Quân', 'Quan.lm', 'Quan.lm@photohome.com', 'cdf28f8b7d14ab02d12a2329d71e4079', 1, 0, 0, '', 0, 0, 1, '2023-09-14 00:07:22', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_groups`
--

CREATE TABLE `user_groups` (
  `id` int(11) NOT NULL,
  `name` varchar(250) NOT NULL,
  `riv` tinyint(4) NOT NULL COMMENT 'request for IP address verification: ràng buộc check ip address',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `user_groups`
--

INSERT INTO `user_groups` (`id`, `name`, `riv`, `created_at`, `created_by`, `updated_at`, `updated_by`, `deleted_at`, `deleted_by`) VALUES
(1, 'Full-time employee', 1, '2023-10-12 05:02:31', 0, NULL, 0, NULL, ''),
(2, 'Part-time employee', 0, '2023-10-12 05:02:31', 1, NULL, 0, NULL, ''),
(3, 'Supervisor', 0, '2023-10-12 05:03:52', 1, NULL, 0, NULL, ''),
(4, 'Administrator', 0, '2023-10-12 05:04:51', 1, NULL, 0, NULL, '');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_productivities`
--

CREATE TABLE `user_productivities` (
  `id` int(30) NOT NULL,
  `project_id` int(30) NOT NULL,
  `task_id` int(30) NOT NULL,
  `comment` text NOT NULL,
  `user_id` int(30) NOT NULL,
  `time_rendered` float NOT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_types`
--

CREATE TABLE `user_types` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `description` varchar(200) NOT NULL,
  `wage` float NOT NULL COMMENT 'Tính theo % đơn giá của task level',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(12) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `user_types`
--

INSERT INTO `user_types` (`id`, `name`, `description`, `wage`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'CEO', 'Toàn quyền hệ thống', 100, '0000-00-00 00:00:00', 0, NULL, 0),
(2, 'CSO', 'Kế toán', 70, '0000-00-00 00:00:00', 0, NULL, 0),
(3, 'CSS', 'Giao dịch với khách hàng', 60, '0000-00-00 00:00:00', 0, NULL, 0),
(4, 'TLA', 'Quản lý công việc', 50, '0000-00-00 00:00:00', 0, NULL, 0),
(5, 'QA', 'Thẩm định ảnh lv1', 20, '0000-00-00 00:00:00', 0, NULL, 0),
(6, 'EDITOR', 'Xử lý ảnh', 40, '0000-00-00 00:00:00', 0, NULL, 0),
(7, 'DC', 'Thẩm định ảnh lv2', 25, '2023-10-13 10:21:51', 1, NULL, 0);

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `ccs`
--
ALTER TABLE `ccs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `project_id` (`project_id`);

--
-- Chỉ mục cho bảng `clouds`
--
ALTER TABLE `clouds`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `color_modes`
--
ALTER TABLE `color_modes`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `comboes`
--
ALTER TABLE `comboes`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `configs`
--
ALTER TABLE `configs`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `group_id` (`group_id`);

--
-- Chỉ mục cho bảng `customer_groups`
--
ALTER TABLE `customer_groups`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `employee_groups`
--
ALTER TABLE `employee_groups`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `status_id` (`status_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Chỉ mục cho bảng `invoice_statuses`
--
ALTER TABLE `invoice_statuses`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `ips`
--
ALTER TABLE `ips`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `levels`
--
ALTER TABLE `levels`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `national_styles`
--
ALTER TABLE `national_styles`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `outputs`
--
ALTER TABLE `outputs`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Chỉ mục cho bảng `project_instructions`
--
ALTER TABLE `project_instructions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `project_id` (`project_id`);

--
-- Chỉ mục cho bảng `project_logs`
--
ALTER TABLE `project_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `project_id` (`project_id`);

--
-- Chỉ mục cho bảng `project_statuses`
--
ALTER TABLE `project_statuses`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `project_id` (`project_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `level_id` (`level_id`);

--
-- Chỉ mục cho bảng `task_rejectings`
--
ALTER TABLE `task_rejectings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `role_id` (`role_id`);

--
-- Chỉ mục cho bảng `task_statuses`
--
ALTER TABLE `task_statuses`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `task_suggestions`
--
ALTER TABLE `task_suggestions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_project` (`project_id`),
  ADD KEY `fk_level` (`level_id`),
  ADD KEY `fk_editor` (`editor_id`),
  ADD KEY `fk_qa` (`qa_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`);

--
-- Chỉ mục cho bảng `user_groups`
--
ALTER TABLE `user_groups`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `user_productivities`
--
ALTER TABLE `user_productivities`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `user_types`
--
ALTER TABLE `user_types`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `ccs`
--
ALTER TABLE `ccs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `clouds`
--
ALTER TABLE `clouds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `color_modes`
--
ALTER TABLE `color_modes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `comboes`
--
ALTER TABLE `comboes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `companies`
--
ALTER TABLE `companies`
  MODIFY `id` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `configs`
--
ALTER TABLE `configs`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT cho bảng `customer_groups`
--
ALTER TABLE `customer_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `employee_groups`
--
ALTER TABLE `employee_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `invoice_statuses`
--
ALTER TABLE `invoice_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `ips`
--
ALTER TABLE `ips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `levels`
--
ALTER TABLE `levels`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `national_styles`
--
ALTER TABLE `national_styles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `outputs`
--
ALTER TABLE `outputs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `projects`
--
ALTER TABLE `projects`
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `project_instructions`
--
ALTER TABLE `project_instructions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `project_logs`
--
ALTER TABLE `project_logs`
  MODIFY `id` bigint(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT cho bảng `project_statuses`
--
ALTER TABLE `project_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT cho bảng `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `task_rejectings`
--
ALTER TABLE `task_rejectings`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `task_statuses`
--
ALTER TABLE `task_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `task_suggestions`
--
ALTER TABLE `task_suggestions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT cho bảng `user_groups`
--
ALTER TABLE `user_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `user_productivities`
--
ALTER TABLE `user_productivities`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `user_types`
--
ALTER TABLE `user_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `ccs`
--
ALTER TABLE `ccs`
  ADD CONSTRAINT `ccs_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);

--
-- Các ràng buộc cho bảng `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `customer_groups` (`id`);

--
-- Các ràng buộc cho bảng `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`status_id`) REFERENCES `invoice_statuses` (`id`),
  ADD CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

--
-- Các ràng buộc cho bảng `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

--
-- Các ràng buộc cho bảng `project_instructions`
--
ALTER TABLE `project_instructions`
  ADD CONSTRAINT `project_instructions_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);

--
-- Các ràng buộc cho bảng `project_logs`
--
ALTER TABLE `project_logs`
  ADD CONSTRAINT `project_logs_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);

--
-- Các ràng buộc cho bảng `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `tasks_ibfk_4` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `tasks_ibfk_5` FOREIGN KEY (`level_id`) REFERENCES `levels` (`id`);

--
-- Các ràng buộc cho bảng `task_rejectings`
--
ALTER TABLE `task_rejectings`
  ADD CONSTRAINT `task_rejectings_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `user_types` (`id`);

--
-- Các ràng buộc cho bảng `task_suggestions`
--
ALTER TABLE `task_suggestions`
  ADD CONSTRAINT `fk_editor` FOREIGN KEY (`editor_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_level` FOREIGN KEY (`level_id`) REFERENCES `levels` (`id`),
  ADD CONSTRAINT `fk_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  ADD CONSTRAINT `fk_qa` FOREIGN KEY (`qa_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
