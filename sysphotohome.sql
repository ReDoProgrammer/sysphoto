-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th10 07, 2023 lúc 04:35 PM
-- Phiên bản máy phục vụ: 10.4.27-MariaDB
-- Phiên bản PHP: 8.2.0

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerInsert` (IN `p_group_id` INT, IN `p_name` VARCHAR(100), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_customer_url` VARCHAR(255), IN `p_color_mode` INT, IN `p_output` INT, IN `p_size` VARCHAR(255), IN `p_is_straighten` BOOLEAN, IN `p_straighten_remark` VARCHAR(255), IN `p_tv` VARCHAR(255), IN `p_fire` VARCHAR(255), IN `p_sky` VARCHAR(255), IN `p_grass` VARCHAR(255), IN `p_national_style` INT, IN `p_cloud` INT, IN `p_style_remark` TEXT, IN `p_created_by` INT)   BEGIN
    DECLARE v_acronym VARCHAR(100) DEFAULT '';
    SET v_acronym = CONCAT('C',DATE_FORMAT(NOW(), '%i%H%s'),GetInitials(p_name),DATE_FORMAT(NOW(), '%Y%m'));
    SET p_name = NormalizeString(p_name);
	INSERT INTO customers(group_id,name,acronym,email,pwd,customer_url,color_mode_id,output_id,size,is_straighten,straighten_remark,tv,fire,sky,grass,national_style_id,cloud_id,style_remark,created_by)
    		VALUES(p_group_id,p_name,v_acronym,p_email,md5(p_password),p_customer_url,p_color_mode,p_output,p_size,p_is_straighten,p_straighten_remark,p_tv,p_fire,p_sky,p_grass,p_national_style,p_cloud,p_style_remark,p_created_by);
            SELECT LAST_INSERT_ID() AS last_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CustomerUpdate` (IN `p_id` BIGINT, IN `p_group_id` INT, IN `p_name` VARCHAR(100), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_customer_url` VARCHAR(255), IN `p_color_mode` INT, IN `p_output` INT, IN `p_size` VARCHAR(255), IN `p_is_straighten` BOOLEAN, IN `p_straighten_remark` VARCHAR(255), IN `p_tv` VARCHAR(255), IN `p_fire` VARCHAR(255), IN `p_sky` VARCHAR(255), IN `p_grass` VARCHAR(255), IN `p_national_style` INT, IN `p_cloud` INT, IN `p_style_remark` TEXT, IN `p_updated_by` INT)   BEGIN
    DECLARE v_acronym VARCHAR(100) DEFAULT '';
    SET v_acronym = CONCAT('C',DATE_FORMAT(NOW(), '%i%H%s'),GetInitials(p_name),DATE_FORMAT(NOW(), '%Y%m'));
    SET p_name = NormalizeString(p_name);
	UPDATE customers
    SET group_id = p_group_id, name = p_name, acronym = v_acronym, email = p_email, pwd = MD5(p_password), customer_url = p_customer_url, color_mode_id = p_color_mode, output_id = p_output, size = p_size, is_straighten = p_is_straighten, straighten_remark = p_straighten_remark, tv = p_tv,fire=p_fire,sky = p_sky, grass = p_grass, national_style_id = p_national_style, cloud_id = p_cloud, style_remark = p_style_remark, updated_at = CURRENT_TIMESTAMP(), updated_by = p_updated_by
    WHERE id = p_id;
            SELECT ROW_COUNT() AS rows_changed;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectDetailJoin` (IN `p_id` BIGINT)   BEGIN
	SELECT
        p.id AS project_id,
        p.name AS project_name,
        c.acronym as customer,
        p.priority,
        ps.name as status, ps.color as status_color,
        NormalizeContent(p.description) as description,
        DATE_FORMAT(start_date, '%d/%c/%Y %h:%i:%s') as start_date,
        DATE_FORMAT(end_date, '%d/%c/%Y %h:%i:%s') as end_date,
        cb.name as combo_name,cb.color as combo_color, 
        COUNT(t.id) as tasks_number,
        CONCAT('[', GROUP_CONCAT(JSON_OBJECT(           
            'status',ts.name, 
            'quantity', t.quantity           
        )), ']') AS tasks_list
    FROM projects p
    JOIN customers c ON p.customer_id = c.id
    LEFT JOIN comboes cb ON p.combo_id = cb.id
    LEFT JOIN project_statuses ps ON p.status_id = ps.id
    LEFT JOIN tasks t ON p.id = t.project_id
    LEFT JOIN task_statuses ts ON t.level_id = ts.id
    WHERE p.id = p_id
    GROUP BY p.id, p.name,ps.name,c.acronym;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectInsert` (IN `p_customer_id` BIGINT, IN `p_name` VARCHAR(255), IN `p_start_date` TIMESTAMP, IN `p_end_date` TIMESTAMP, IN `p_status_id` TINYINT, IN `p_combo_id` INT, IN `p_levels` VARCHAR(100), IN `p_priority` TINYINT, IN `p_description` TEXT, IN `p_created_by` INT)   BEGIN
	INSERT INTO projects(customer_id,name,start_date,end_date,combo_id,levels,priority,description,status_id,created_by)
    VALUES(p_customer_id,p_name,p_start_date,p_end_date,p_combo_id,p_levels,p_priority,p_description,p_status_id,p_created_by);
    SELECT LAST_INSERT_ID() AS last_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectInstructionInsert` (IN `p_project_id` BIGINT, IN `p_content` TEXT, IN `p_created_by` INT)   BEGIN
	INSERT INTO project_instructions(project_id,content,created_by)
    VALUES(p_project_id,p_content,p_created_by);
    SELECT LAST_INSERT_ID() AS last_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectLogs` (IN `p_id` BIGINT)   BEGIN
	SELECT 
    	content,
    	DATE_FORMAT(timestamp, '%d/%m/%Y %H:%i:%s') as timestamp
    FROM 	project_logs 
    WHERE project_id = p_id 
    ORDER BY timestamp DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskDelete` (IN `p_id` BIGINT)   BEGIN
	DELETE FROM tasks
    WHERE id = p_id;
    SELECT ROW_COUNT() AS deleted_rows;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskDetailJoin` (IN `p_id` BIGINT)   BEGIN   
   SELECT 
   		t.level_id,
        lv.name as level,
        t.quantity,
        ts.name as status,
		NormalizeContent(t.description) as description,
        t.editor_id,
        e.acronym as editor,
         DATE_FORMAT(t.editor_timestamp, '%d/%m/%Y %H:%i:%s') as editor_timestamp,
        t.editor_view,
        t.editor_assigned,
		
        t.qa_id,
        q.acronym as qa,
        DATE_FORMAT(t.qa_timestamp, '%d/%m/%Y %H:%i:%s') as qa_timestamp,
        t.qa_view,
        t.qa_assigned,

        d.acronym as dc,
        t.dc_submit,
        DATE_FORMAT(t.dc_timestamp, '%d/%m/%Y %H:%i:%s') as dc_timestamp ,

        DATE_FORMAT(t.created_at, '%d/%m/%Y %H:%i:%s') as created_at,
        c.acronym as created_by,
        DATE_FORMAT(t.updated_at, '%d/%m/%Y %H:%i:%s') as updated_at,
        u.acronym as updated_by
    FROM tasks t
    JOIN levels lv ON t.level_id = lv.id
    LEFT JOIN users e ON t.editor_id = e.id
    LEFT JOIN users q ON t.qa_id = q.id
    LEFT JOIN users d ON t.dc_id = e.id
    LEFT JOIN task_statuses ts ON t.status_id = ts.id
    JOIN users c ON t.created_by = c.id
    LEFT JOIN users u ON t.updated_by = u.id
    WHERE t.id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskInsert` (IN `p_project` BIGINT, IN `p_description` TEXT, IN `p_editor` INT, IN `p_qa` INT, IN `p_quantity` INT, IN `p_level` INT, IN `p_created_by` INT)   BEGIN
	INSERT INTO tasks(project_id,description,editor_id,qa_id,quantity,level_id,created_by)
    VALUES(p_project,p_description,p_editor,p_qa,p_quantity,p_level,p_created_by);
    SELECT LAST_INSERT_ID() as last_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `TaskUpdate` (IN `p_id` BIGINT, IN `p_description` TEXT, IN `p_editor` INT, IN `p_assign_editor` TINYINT, IN `p_qa` INT, IN `p_assign_qa` TINYINT, IN `p_quantity` INT, IN `p_level` INT, IN `p_updated_by` INT)   BEGIN
	UPDATE tasks
    SET
    	description = p_description,
        editor_id = p_editor, editor_timestamp = NOW(),editor_assigned = p_assign_editor,
        qa_id = p_qa, qa_timestamp = NOW(), qa_assigned = p_assign_qa,
        quantity = p_quantity,level_id = p_level,
        updated_at = NOW(), updated_by = p_updated_by
    WHERE id = p_id;
    SELECT ROW_COUNT() as updated_rows;
END$$

--
-- Các hàm
--
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
-- Cấu trúc bảng cho bảng `ccses`
--

CREATE TABLE `ccses` (
  `id` int(11) NOT NULL,
  `project_id` bigint(11) NOT NULL,
  `feedback` text NOT NULL,
  `intruction` text NOT NULL,
  `status_id` int(11) NOT NULL DEFAULT 1,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
(1, 'Google Drive', '2023-10-06 07:13:35', 1, NULL, 0),
(2, 'Dropbox', '2023-10-06 07:13:35', 1, NULL, 0);

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
(1, 'Adobe 1998', '2023-10-06 07:11:29', 1, NULL, 0),
(2, 'sRGB', '2023-10-06 07:11:29', 1, NULL, 0);

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
(1, 'combo 1', 'bg-danger text-white', '2023-10-02 16:00:22', 0, NULL, 0),
(2, 'combo 2', 'bg-primary text-light', '2023-10-02 16:00:22', 0, NULL, 0),
(3, 'combo 3', 'bg-success text-dark', '2023-10-02 16:00:22', 0, NULL, 0);

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
(1, 'PHOTOHOME', '											', '2023-02-18 00:00:00', 0, '2023-10-02 16:00:51', 0);

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
(1, 'Quản lý công việc', 'contactphotohome@gmail.com', '2023-10-02 22:55:37', 0, '2023-10-02 16:01:15', 0);

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
(1, 0, 'Test 1234', 'C122115T1202310', 'emailtes1t1@gmail.com', 'adsfasdf', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '1234fazfdxdsrqw', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 2, 'style remark\n', '2023-10-06 20:51:28', 1, '2023-10-06 14:57:11', 0),
(4, 0, 'Test2', 'C122115T202310', 'emailtest2@gmail.com', 'adsfasdf', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '1234fazfdxdsrqw', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 2, 'style remark\n', '2023-10-06 20:54:11', 1, '2023-10-06 14:12:15', 0),
(5, 0, 'Test3', 'C122115T202310', 'emailtest3@gmail.com', 'adsfasdf', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '1234fazfdxdsrqw', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 1, 'style remark\n', '2023-10-06 20:55:06', 1, '2023-10-06 14:12:15', 0),
(6, 0, 'Test4 Ra Fdasf ', 'C122115TRF202310', 'emailtest4@gmail.com', 'adsfasdf', '202cb962ac59075b964b07152d234b70', '', 2, 1, 2, '1234fazfdxdsrqw', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 1, 1, 'style remark\n', '2023-10-06 20:55:51', 1, '2023-10-06 14:12:15', 0),
(8, 0, 'Truong Nguyen Huu', 'C122115TNH202310', 'emailtest21@gmail.com', 'url ', '202cb962ac59075b964b07152d234b70', '', 2, 2, 1, '2134x1234', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 1, 'style remark\n', '2023-10-06 20:59:22', 1, '2023-10-06 14:12:15', 0),
(9, 0, 'Truong Nguyen Huu', 'C122115TNH202310', 'emailtest221@gmail.com', 'url ', '202cb962ac59075b964b07152d234b70', '', 2, 2, 1, '2134x1234', 1, 'straighten', 'tv', 'fire', 'fire', 'grass', 2, 1, 'style remark\n', '2023-10-06 20:59:40', 1, '2023-10-06 14:12:15', 0),
(10, 0, 'Spyder Man', 'C122115SM202310', 'syperman@gmail.com', 'spyder man url', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, 'origin', 1, '1234', '', '', '', '411', 1, 1, 'style remark\n', '2023-10-06 21:04:23', 1, '2023-10-06 14:12:15', 0),
(11, 0, 'Jocker Allain', 'C122115JA202310', 'testemail123@gmail.com', 'adsfá', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-10-06 21:08:07', 1, '2023-10-06 14:12:15', 0),
(12, 0, 'Test  New Acronym', 'C142111TNA2023October', 'testnewacronym@gmail.com', 'sdf', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '1234fazfdxdsrqw', 1, 'dfsấ', 'fsadfsa', 'fdsấ', 'fdsấ', 'fdsàdsa', 0, 0, 'dsàdsà2134\n', '2023-10-06 21:14:11', 1, '2023-10-06 14:14:11', 0),
(13, 0, 'Test  New Acronym ', 'C152111TNA202310', 'testnewacronym1@gmail.com', '', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '', 1, '', '', '', '', '', 0, 0, 'dsàdsà2134\n', '2023-10-06 21:15:11', 1, '2023-10-06 14:15:11', 0),
(15, 0, 'This Is New Customer1', 'C322232TINC202310', 'emailtes1t11@gmail.com', 'dsfấ', '202cb962ac59075b964b07152d234b70', '', 1, 0, 0, '', 1, '', '', '', '', '', 0, 0, '\n', '2023-10-06 21:19:23', 1, '2023-10-06 15:32:32', 1),
(16, 0, 'Test Straighten1', 'C290147TS202310', 'teststraighten@gmail.com', 'straighten url', '202cb962ac59075b964b07152d234b70', '', 1, 1, 2, '', 1, 'straighten note', 'tvnote', 'fire note', 'sky note', 'grass note', 1, 1, 'straighten style remark\n\nremark \n\ndfafasd fdasf                     fsdjfsalkfj \n\n\n\n\nfdsafsadjf\nfsadfjsdal\n\n1234124\n\nfdsafsa\n', '2023-10-06 22:02:34', 1, '2023-10-06 18:29:47', 1);

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
(1, 'Group 1', NULL, NULL, '2023-10-02 17:03:33', 0, '2023-10-02 17:03:33', 0),
(2, 'Group 2', NULL, NULL, '2023-10-02 17:03:53', 1, '2023-10-02 17:04:07', 0);

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
(1, 'Nhóm Mattport', '', '1,2,3', 1, '2023-09-03 06:10:28', '2023-09-03 05:26:02', 0),
(2, 'Nhóm Mattport pro', '', '1,2,3,4,5,6,7', 1, '2023-09-03 06:12:36', '2023-09-03 05:25:57', 0),
(3, 'Nhóm pro', '', '1,2,3,4,5,6,7', 1, '2023-09-03 06:23:04', '2023-09-03 06:23:04', 0),
(4, 'Nhóm training', '', '1,2,3', 1, '2023-09-03 06:24:13', '2023-09-03 06:24:13', 0),
(5, 'Nhóm QA Pro', '', '1,2,3,4,5,6,7,8', 1, '2023-09-05 08:59:11', '2023-09-05 08:59:11', 0),
(6, 'Nhóm DTE', '', '8', 1, '2023-09-05 09:03:26', '2023-09-05 09:03:26', 0);

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
(1, 'wait', 'badge badge-secondary', '2023-04-16 00:00:00', 0, '2023-10-02 16:04:44', 0),
(2, 'Sent', 'badge badge-success', '2023-04-16 00:00:00', 0, '2023-10-02 16:04:44', 0),
(3, 'Paid', 'badge badge-info', '2023-04-16 00:00:00', 0, '2023-10-02 16:04:44', 0);

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
(8, '216.58.203.68', 'IP CSS thành', 1, '2023-09-16 13:10:41', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `levels`
--

CREATE TABLE `levels` (
  `id` int(30) NOT NULL,
  `name` varchar(30) NOT NULL,
  `price` float NOT NULL,
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
(1, 'US Style', '2023-10-06 07:15:18', 1, '2023-10-06 07:15:18', 0),
(2, 'US AU', '2023-10-06 07:15:18', 1, '2023-10-06 07:15:18', 0);

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
(1, 'JPG', '2023-10-06 09:01:17', 1, NULL, 0),
(2, 'TIFF', '2023-10-06 09:01:17', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `projects`
--

CREATE TABLE `projects` (
  `id` bigint(30) NOT NULL,
  `customer_id` bigint(30) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `status_id` tinyint(1) NOT NULL DEFAULT 1,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `levels` varchar(100) NOT NULL COMMENT 'Danh sách level khi sử dụng template',
  `invoice_id` varchar(11) NOT NULL,
  `done_link` varchar(255) DEFAULT NULL,
  `wait_note` varchar(255) DEFAULT NULL,
  `combo_id` int(11) NOT NULL DEFAULT 0,
  `priority` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `projects`
--

INSERT INTO `projects` (`id`, `customer_id`, `name`, `description`, `status_id`, `start_date`, `end_date`, `levels`, `invoice_id`, `done_link`, `wait_note`, `combo_id`, `priority`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(2, 10, 'TEST project with triggers', 'description here\n', 1, '2023-10-07 05:09:00', '2023-10-07 08:09:00', '1,2,3', '', NULL, NULL, 1, 1, '2023-10-07 05:11:04', 1, NULL, 0);

--
-- Bẫy `projects`
--
DELIMITER $$
CREATE TRIGGER `AutoInsertTask` AFTER INSERT ON `projects` FOR EACH ROW BEGIN
    DECLARE v_project_id BIGINT;
    DECLARE v_levels VARCHAR(100);
    DECLARE v_created_by INT;
    
    SELECT MAX(id) INTO v_project_id FROM projects;
    SELECT levels INTO v_levels FROM projects WHERE id = v_project_id;
    SELECT created_by INTO v_created_by FROM projects WHERE id = v_project_id;

    SET @start = 1;
    SET @end = LOCATE(',', v_levels);
    
    -- Kiểm tra xem @end có rỗng hay không
    IF @end IS NOT NULL THEN
        WHILE @end > 0 DO
            INSERT INTO tasks (project_id, level_id, created_by)
            VALUES (v_project_id, SUBSTRING(v_levels, @start, @end - @start), v_created_by);
            SET @start = @end + 1;
            SET @end = LOCATE(',', v_levels, @start);
        END WHILE;
    END IF;

    -- Xử lý giá trị cuối cùng
    IF SUBSTRING(v_levels, @start) > 0 THEN
        INSERT INTO tasks (project_id, level_id, created_by)
        VALUES (v_project_id, SUBSTRING(v_levels, @start), v_created_by);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_project` AFTER INSERT ON `projects` FOR EACH ROW BEGIN
	DECLARE v_created_by varchar(100);
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM projects WHERE id = NEW.id));
    
    INSERT INTO project_logs(project_id,timestamp,content)
    VALUES(NEW.id,NEW.created_at,CONCAT('[',v_created_by,'] ','CREATE PROJECT' ));
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
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `project_instructions`
--

INSERT INTO `project_instructions` (`id`, `project_id`, `content`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 2, 'instruction here\n', '2023-10-07 05:11:04', 1, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `project_logs`
--

CREATE TABLE `project_logs` (
  `id` bigint(50) NOT NULL,
  `project_id` bigint(20) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `content` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `project_logs`
--

INSERT INTO `project_logs` (`id`, `project_id`, `timestamp`, `content`) VALUES
(4, 2, '2023-10-07 05:11:04', '[admin] INSERT TASK [PE-STAND] with quantity: [1]'),
(5, 2, '2023-10-07 05:11:04', '[admin] INSERT TASK [PE-BASIC] with quantity: [1]'),
(6, 2, '2023-10-07 05:11:04', '[admin] INSERT TASK [PE-Drone-Basic] with quantity: [1]'),
(7, 2, '2023-10-07 05:11:04', '[admin] CREATE PROJECT'),
(8, 2, '2023-10-07 15:43:51', '[admin] INSERT TASK [PE-STAND] with quantity: [1]'),
(9, 2, '2023-10-07 15:59:16', '[admin] INSERT TASK [VHS] with quantity: [3]'),
(10, 2, '2023-10-07 16:01:30', '[admin] INSERT TASK [Re-Stand] with quantity: [6]');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `project_statuses`
--

CREATE TABLE `project_statuses` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `color` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(10) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `project_statuses`
--

INSERT INTO `project_statuses` (`id`, `name`, `color`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'wait', 'badge badge-secondary', '0000-00-00 00:00:00', 0, NULL, 0),
(2, 'Processing', 'badge badge-warning', '0000-00-00 00:00:00', 0, NULL, 0),
(3, 'Sent', 'badge badge-success', '0000-00-00 00:00:00', 0, NULL, 0),
(4, 'Paid', 'badge badge-info', '0000-00-00 00:00:00', 0, NULL, 0),
(5, 'Unpay', 'badge badge-danger', '0000-00-00 00:00:00', 0, NULL, 0),
(6, 'Upload Link', 'badge badge-danger', '0000-00-00 00:00:00', 0, NULL, 0),
(7, 'Ask again', 'badge badge-dark', '0000-00-00 00:00:00', 0, NULL, 0),
(8, 'Responded', 'badge badge-danger', '0000-00-00 00:00:00', 0, NULL, 0);

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
  `qa_id` int(11) NOT NULL,
  `qa_timestamp` timestamp NULL DEFAULT NULL COMMENT 'Thời điểm qa được gán task hoặc nhận task',
  `qa_assigned` tinyint(1) NOT NULL COMMENT '1: QA được gán, 0: QA nhận task',
  `dc_id` int(11) NOT NULL COMMENT 'Quản lý chất lượng ảnh đầu ra',
  `dc_submit` tinyint(4) DEFAULT 0 COMMENT '1: ok, -1 reject',
  `dc_timestamp` timestamp NULL DEFAULT NULL COMMENT 'Thời điểm dc_submit',
  `level_id` int(30) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `editor_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đánh dấu Editor đã xem instruction',
  `qa_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đánh dấu QA đã xem instruction',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tasks`
--

INSERT INTO `tasks` (`id`, `project_id`, `description`, `status_id`, `editor_id`, `editor_timestamp`, `editor_assigned`, `qa_id`, `qa_timestamp`, `qa_assigned`, `dc_id`, `dc_submit`, `dc_timestamp`, `level_id`, `quantity`, `editor_view`, `qa_view`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(5, 2, NULL, 0, 0, '2023-10-07 05:58:32', 0, 0, '2023-10-07 05:57:54', 0, 0, 0, NULL, 2, 1, 0, 0, '2023-10-07 05:11:04', 1, '2023-10-06 22:11:04', 0),
(8, 2, 'dasfasfdas fasdfas \nsdfaf asdfdsa \nfdsafsadf sda fasd frdsafa 12341234 fdsaf asdf\nrewqr ewqrqwre weqr\n', 0, 30, '2023-10-07 14:27:22', 1, 0, '2023-10-07 14:27:22', 0, 0, 0, NULL, 9, 3, 0, 0, '2023-10-07 15:59:16', 1, '2023-10-07 14:27:22', 1),
(9, 2, 'fdsafasd324 frsad fasdf sda 41 fdasf asdfas\nfsdaf asfds\na\n fdsa\n f\nasd \nf\nasdf\nsad \nfasd\nfasdf\nf1243124\nfdasf dsa\n', 0, 30, '2023-10-07 14:27:10', 1, 49, '2023-10-07 14:27:10', 1, 0, 0, NULL, 1, 6, 0, 0, '2023-10-07 16:01:30', 1, '2023-10-07 14:27:10', 1);

--
-- Bẫy `tasks`
--
DELIMITER $$
CREATE TRIGGER `after_insert_task` AFTER INSERT ON `tasks` FOR EACH ROW BEGIN
	DECLARE v_created_by varchar(100);
    DECLARE v_level varchar(50);
    
    SET v_created_by = (SELECT acronym FROM users WHERE id = (SELECT created_by FROM tasks WHERE id = NEW.id));
    SET v_level = (SELECT name FROM levels WHERE id = NEW.level_id);
    
    INSERT INTO project_logs(project_id,timestamp,content)
    VALUES(NEW.project_id,NEW.created_at,CONCAT('[',v_created_by,'] INSERT TASK [',v_level,'] with quantity: [',NEW.quantity,']'));
    
END
$$
DELIMITER ;

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
(1, 'Done', 'badge badge-success', '0000-00-00 00:00:00', 0, NULL, 0),
(2, 'Reject', 'badge badge-dark', '0000-00-00 00:00:00', 0, NULL, 0),
(3, 'Fixed', 'badge badge-info', '0000-00-00 00:00:00', 0, NULL, 0),
(4, 'QA-Done', 'badge badge-warning', '0000-00-00 00:00:00', 0, NULL, 0),
(5, 'DC-RJ', 'badge badge-secondary', '0000-00-00 00:00:00', 0, NULL, 0),
(6, 'OK-DC', 'badge badge-danger', '0000-00-00 00:00:00', 0, NULL, 0),
(7, 'Upload', 'badge badge-warning', '0000-00-00 00:00:00', 0, NULL, 0),
(8, 'DC-FIX', 'badge badge-ligh', '0000-00-00 00:00:00', 0, NULL, 0),
(9, 'Wait', 'badge badge-dark', '0000-00-00 00:00:00', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `test`
--

CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `level` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `test`
--

INSERT INTO `test` (`id`, `name`, `description`, `level`) VALUES
(1, '0', '0', 1);

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
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Trạng thái hoạt động của tài khoản. 0 hoặc 1',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `update_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `fullname`, `acronym`, `email`, `password`, `type_id`, `editor_group_id`, `qa_group_id`, `avatar`, `task_getable`, `status`, `created_at`, `created_by`, `updated_at`, `update_by`) VALUES
(1, 'Administrator', 'admin', 'admin@admin.com', '2db5228517bf8473a1dda3cab7cb4b8c', 1, 0, 0, '', 0, 0, '2020-11-26 03:57:04', 0, NULL, 0),
(2, 'Nguyễn Hoàng Yến', 'Yen.nh', 'sale1@photohome.com.vn', '81dc9bdb52d04dc20036dbd8313ed055', 2, 0, 0, '', 0, 0, '2023-08-20 03:55:42', 0, NULL, 0),
(3, 'Nguyễn Hữu Bình', 'Binh.nh', 'binh.nhphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 4, 0, 0, '1693061220_12 228 Main Photo 62.JPG', 0, 0, '2023-08-20 03:57:13', 0, NULL, 0),
(4, 'Thiện', 'thien.pd', 'thien@gmail.com', '202cb962ac59075b964b07152d234b70', 6, 1, 0, '', 1, 0, '2023-08-20 04:40:37', 0, NULL, 0),
(5, 'Đỗ Thị Ngọc Mai', 'Mai.dn', 'Mai.dnPhotohome@gmail.com', '37f075e83964183d460c4eca59d27d0b', 2, 0, 0, '', 0, 0, '2023-08-20 09:40:39', 0, NULL, 0),
(6, 'Trịnh Thanh Bình', 'binh.tt', 'binh.ttphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, '2023-08-25 04:19:50', 0, NULL, 0),
(7, 'Trần Tú Thành', 'Thanh.tt', 'Thanh.ttphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, '2023-08-25 04:36:12', 0, NULL, 0),
(8, 'Trần Hồng Nhung', 'nhung.th', 'nhung.thphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, '2023-09-04 14:41:06', 0, NULL, 0),
(9, 'Phạm Năng Bình', 'binh.pn', 'binh@photohome.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-05 08:00:36', 0, NULL, 0),
(10, 'Bùi Đức Hiếu', 'hieu.bd', 'hieu.bdphotohome@gmai.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:52:26', 0, NULL, 0),
(11, 'Phạm Phương Nam', 'nam.pp', 'nam.ppphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:53:05', 0, NULL, 0),
(12, 'Nguyễn Đức Việt', 'viet.nd', 'viet.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:53:39', 0, NULL, 0),
(13, 'Vũ văn Đạt', 'dat.vv', 'dat.vvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:54:18', 0, NULL, 0),
(14, 'Bùi Văn Tuấn', 'tuan.bv', 'tuan.bvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:54:50', 0, NULL, 0),
(15, 'Vi Đức Trịnh', 'trinh.vd', 'trinh.vdphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:55:23', 0, NULL, 0),
(16, 'Phùng Minh Phong', 'phong.pm', 'phong.pmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:55:56', 0, NULL, 0),
(17, 'Nguyễn Hồng Sơn', 'son.nh', 'son.nhphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:56:33', 0, NULL, 0),
(18, 'Vũ Đức Thắng', 'thang.vd', 'thang.vdphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:57:58', 0, NULL, 0),
(19, 'Chu Thị Thúy', 'thuy.ct', 'thuy.ctphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:58:36', 0, NULL, 0),
(20, 'Trần Văn Đoàn', 'doan.tv', 'doan.tvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 16:59:01', 0, NULL, 0),
(21, 'Vũ Hồng Sơn', 'son.vh', 'son.vhphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-10 02:40:43', 0, NULL, 0),
(22, 'Nguyễn Tuấn Nam', 'nam.nt', 'nam.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:12:02', 0, NULL, 0),
(23, 'Bùi Văn Hưng', 'hung.bv', 'hung.bvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:12:26', 0, NULL, 0),
(24, 'Bùi Ngọc Hoàng', 'hoang.bn', 'hoang.bnphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:12:55', 0, NULL, 0),
(25, 'Nguyễn Quốc Cường', 'cuong.nq', 'cuong.nqphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:13:21', 0, NULL, 0),
(26, 'Phùng Hữu Tình', 'tinh.ph', 'tinh.phphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:14:41', 0, NULL, 0),
(27, 'Phan Văn Thiêm', 'thiem.pv', 'thiem.pvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:15:05', 0, NULL, 0),
(28, 'Nguyễn Việt Hoàng', 'hoang.nv', 'hoang.nvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:15:33', 0, NULL, 0),
(29, 'Nguyễn Duy Tú', 'tu.nd', 'tu.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:15:54', 0, NULL, 0),
(30, 'Nguyễn Đức Chính', 'chinh.nd', 'chinh.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:16:21', 0, NULL, 0),
(31, 'Dương Văn Hưng', 'hung.dv', 'hung.dvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:16:52', 0, NULL, 0),
(32, 'Dương nguyễn kiên', 'kien.dn', 'kien.dnphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:17:14', 0, NULL, 0),
(33, 'Bùi Thị Hoa', 'hoa.bt', 'hoa.btphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:17:34', 0, NULL, 0),
(34, 'Phạm Thị thùy Trang', 'trang.pt', 'trang.ptphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:18:03', 0, NULL, 0),
(35, 'Nguyễn Thị Thu', 'thu.nt', 'thu.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:18:26', 0, NULL, 0),
(36, 'Lê Thu Hiên', 'hien.lt', 'hien.ltphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:18:53', 0, NULL, 0),
(37, 'Phạm Thúy Hảo', 'hao.pt', 'hoa.ptphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:19:15', 0, NULL, 0),
(38, 'Hoàng Thị Thanh Lam', 'lam.ht', 'Lam.htphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:19:40', 0, NULL, 0),
(39, 'Đinh Thị Minh Thi', 'thi.dt', 'thi.dmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:20:06', 0, NULL, 0),
(40, 'Trần Mạnh Hùng', 'hung.tm', 'hung.tmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:20:28', 0, NULL, 0),
(41, 'Trần Văn Chung', 'chung.tv', 'chung.tvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:20:51', 0, NULL, 0),
(42, 'Nguyễn Tuấn Đạt', 'dat.nt', 'dat.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:21:14', 0, NULL, 0),
(43, 'Đặng Đức Anh', 'anh.dd', 'anh.ddphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:21:36', 0, NULL, 0),
(44, 'Lê Minh Thành', 'thanh.lm', 'thanh.lmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:22:09', 0, NULL, 0),
(45, 'Cấn Việt Ánh', 'anh.cv', 'anh.cvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:22:28', 0, NULL, 0),
(46, 'Nguyễn Công Thành', 'thanh.nc', 'thanh.ncphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:22:55', 0, NULL, 0),
(47, 'Đinh Công Hưng', 'hung.dc', 'hung.dcphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:23:17', 0, NULL, 0),
(48, 'Nguyễn Công Lực', 'luc.nc', 'luc.ncphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 04:23:38', 0, NULL, 0),
(49, 'Hoàng Anh Dũng', 'dung.ha', 'dung.haphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-11 04:51:45', 0, NULL, 0),
(50, 'Đỗ Văn Chủ', 'chu.dv', 'chu.dvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-11 05:01:17', 0, NULL, 0),
(51, 'Đỗ Tiến Duy', 'duy.dd', 'duy.ddphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-11 05:01:50', 0, NULL, 0),
(52, 'Trần Xuân Thịnh', 'thinh.tx', 'thinh.txphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-12 05:07:42', 0, NULL, 0),
(53, 'Phạm Thị Dung', 'dung.pt', 'dung.pt@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, '2023-09-13 04:00:12', 0, NULL, 0),
(54, 'Lê Minh Quân', 'Quan.lm', 'Quan.lm@photohome.com', 'cdf28f8b7d14ab02d12a2329d71e4079', 1, 0, 0, '', 0, 0, '2023-09-14 07:07:22', 0, NULL, 0);

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
  `group` varchar(120) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(12) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `user_types`
--

INSERT INTO `user_types` (`id`, `name`, `group`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 'CEO', '1', '0000-00-00 00:00:00', 0, NULL, 0),
(2, 'CSO', '', '0000-00-00 00:00:00', 0, NULL, 0),
(3, 'CSS', '', '0000-00-00 00:00:00', 0, NULL, 0),
(4, 'TLA', '', '0000-00-00 00:00:00', 0, NULL, 0),
(5, 'QA', '', '0000-00-00 00:00:00', 0, NULL, 0),
(6, 'EDITOR', '', '0000-00-00 00:00:00', 0, NULL, 0);

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `ccses`
--
ALTER TABLE `ccses`
  ADD PRIMARY KEY (`id`);

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
-- Chỉ mục cho bảng `task_statuses`
--
ALTER TABLE `task_statuses`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `test`
--
ALTER TABLE `test`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
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
-- AUTO_INCREMENT cho bảng `ccses`
--
ALTER TABLE `ccses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

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
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `project_instructions`
--
ALTER TABLE `project_instructions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `project_logs`
--
ALTER TABLE `project_logs`
  MODIFY `id` bigint(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `project_statuses`
--
ALTER TABLE `project_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `task_statuses`
--
ALTER TABLE `task_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `test`
--
ALTER TABLE `test`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT cho bảng `user_productivities`
--
ALTER TABLE `user_productivities`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `user_types`
--
ALTER TABLE `user_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Các ràng buộc cho các bảng đã đổ
--

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
