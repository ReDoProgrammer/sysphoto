-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th10 03, 2023 lúc 05:49 PM
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_task_lists` (IN `project_id` INT)   BEGIN
   DECLARE done INT DEFAULT FALSE;
DECLARE user_id VARCHAR(255);
DECLARE user_list_len INT DEFAULT 0;
DECLARE level_ids VARCHAR(255);
DECLARE cur CURSOR FOR 
    SELECT user_ids, idlevels 
    FROM project_list 
    WHERE id = project_id;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cur;

read_loop: LOOP
    FETCH cur INTO user_id, level_ids;
    IF done THEN
        LEAVE read_loop;
    END IF;

    SET user_list_len = LENGTH(user_id) - LENGTH(REPLACE(user_id, ',', '')) + 1;

    INSERT IGNORE INTO task_list (editor, idlevel, project_id, status) 
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(user_id, ',', n.n), ',', -1) as editor,
           SUBSTRING_INDEX(SUBSTRING_INDEX(level_ids, ',', n.n), ',', -1) as idlevel,
           project_id,
           1 as status
    FROM (SELECT DISTINCT n FROM 
          (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) d) n
    WHERE n.n <= user_list_len 
          AND n.n <= LENGTH(level_ids) - LENGTH(REPLACE(level_ids, ',', '')) + 1;
END LOOP;

CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_task_lists_lv` (IN `p_project_id` INT)   BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE level_ids VARCHAR(255);
  DECLARE cur CURSOR FOR 
    SELECT idlevels 
    FROM project_list 
    WHERE id = p_project_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  OPEN cur;
  
  read_loop: LOOP
    FETCH cur INTO level_ids;
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    -- Split the comma-separated values in idlevels into individual idlevel values
    -- and insert one task_list for each idlevel
    WHILE LENGTH(level_ids) > 0 DO
      SET @idlevel = TRIM(SUBSTRING_INDEX(level_ids, ',', 1));
      SET level_ids = TRIM(SUBSTR(level_ids, LENGTH(@idlevel) + 2));
      
      -- Insert a task_list for the current idlevel
      INSERT INTO task_list (project_id, idlevel, status)
      SELECT p_project_id, @idlevel, 0
      FROM dual
      WHERE NOT EXISTS (
        SELECT * FROM task_list
        WHERE project_id = p_project_id
          AND idlevel = @idlevel
      );
    END WHILE;
  END LOOP;
  
  CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertCustomer` (IN `first_name` VARCHAR(50), IN `last_name` VARCHAR(50), IN `email` VARCHAR(100), OUT `new_customer_id` INT)   BEGIN
    INSERT INTO customers1 
    SET 
    first_name = first_name,
    last_name = last_name,
    email = email;

    SET new_customer_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_tasks` (IN `p_project_id` INT)   BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE user_id VARCHAR(255);
  DECLARE level_ids VARCHAR(255);
  DECLARE cur CURSOR FOR 
    SELECT user_ids, idlevels 
    FROM project_list 
    WHERE id = p_project_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  OPEN cur;
  
  read_loop: LOOP
    FETCH cur INTO user_id, level_ids;
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    -- Split the comma-separated values in user_ids into individual user IDs
    -- and insert one task_list for each user_id
    WHILE LENGTH(user_id) > 0 DO
      SET @user_id = TRIM(SUBSTRING_INDEX(user_id, ',', 1));
      SET user_id = TRIM(SUBSTR(user_id, LENGTH(@user_id) + 2));
      
      -- Insert a task_list for the current user_id and idlevel
      INSERT INTO task_list (project_id, idlevel, editor, status)
SELECT p_project_id, SUBSTRING_INDEX(level_ids, ',', 1), @user_id, 0
FROM dual
WHERE NOT EXISTS (
  SELECT * FROM task_list
  WHERE project_id = p_project_id
    AND idlevel = SUBSTRING_INDEX(level_ids, ',', 1)
    AND editor = @user_id
);
    END WHILE;
  END LOOP;
  
  CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pProjectInsert` (IN `p_customer_id` BIGINT, IN `p_name` VARCHAR(255), IN `p_description` TEXT, IN `p_status_id` TINYINT, IN `p_start_date` DATETIME, IN `p_end_date` DATETIME, IN `p_combo_id` INT, IN `p_priority` INT, IN `p_created_by` INT, OUT `inserted_id` INT)   BEGIN
    INSERT INTO projects (customer_id, name, description, status_id, start_date, end_date, combo_id, priority, created_by)
    VALUES (p_customer_id, p_name, p_description, p_status_id, p_start_date, p_end_date, p_combo_id, p_priority, p_created_by);
    
    SET inserted_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `project_insert` (IN `p_customer_id` BIGINT(30), IN `p_name` VARCHAR(255), IN `p_description` TEXT, IN `p_status_id` TINYINT(1), IN `p_start_date` TEXT, IN `p_end_date` TEXT, IN `p_combo_id` INT(10), IN `p_priority` INT(10), IN `p_created_by` INT(10), OUT `last_id` INT)   BEGIN

    INSERT INTO projects 
    SET 
    	customer_id = p_customer_id,
        name= p_name,
        description = p_description, 
        status_id =  p_status_id,
        start_date = p_start_date,
        end_date = p_end_date,
        combo_id = p_combo_id,
        priority = p_priority,
        created_by = p_created_by;

    SET last_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ptest` (IN `_name` VARCHAR(50), IN `_description` VARCHAR(50), IN `_level` INT, OUT `last_id` INT)   BEGIN
    INSERT INTO test (name, description, level)
    VALUES (_name, _description, _level);

    SET last_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SimpleProcedure` (IN `input_param` INT, OUT `output_param` INT)   BEGIN
    -- Các câu lệnh xử lý dữ liệu ở đây
    SET output_param = input_param * 2;
END$$

--
-- Các hàm
--
CREATE DEFINER=`root`@`localhost` FUNCTION `InsertEmployee` (`emp_name` VARCHAR(255), `emp_salary` DECIMAL(10,2)) RETURNS INT(11)  BEGIN
    INSERT INTO employee (employee_name, employee_salary)
    VALUES ( emp_name, emp_salary);
    RETURN LAST_INSERT_ID();

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ProjectInsert` (`p_customer_id` BIGINT, `p_name` VARCHAR(255), `p_start_date` DATETIME, `p_end_date` DATETIME, `p_status_id` TINYINT(1), `p_combo_id` TINYINT(2), `p_priority` TINYINT(1), `p_description` TEXT, `p_created_by` INT(2)) RETURNS BIGINT(20)  BEGIN
	INSERT INTO projects
    SET	
    	customer_id = p_customer_id,
        name = p_name,
        start_date = p_start_date,
        end_date = p_end_date,
        status_id = p_status_id,
        priority = p_priority,
        description = p_description,
        combo_id = p_combo_id,
        created_by = p_created_by;
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
  `password` text NOT NULL,
  `style` text DEFAULT NULL,
  `avatar` text NOT NULL,
  `group_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `customers`
--

INSERT INTO `customers` (`id`, `company_id`, `name`, `acronym`, `email`, `customer_url`, `password`, `style`, `avatar`, `group_id`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(124, 1, 'Jhon Parker', 'JP', 'jp2023@gmail.com', '', '', NULL, '', 1, '2023-10-03 00:04:23', 0, '2023-10-02 17:04:23', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customers1`
--

CREATE TABLE `customers1` (
  `customer_id` int(11) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `customers1`
--

INSERT INTO `customers1` (`customer_id`, `first_name`, `last_name`, `email`) VALUES
(1, '0', '0', '0'),
(2, '0', '0', '0'),
(3, '0', '0', '0'),
(4, 'value2', 'value2', 'value2'),
(5, 'value 2', 'value 2', 'value 2'),
(6, '231@gmail.com', '231@gmail.com', '231@gmail.com'),
(7, '231@gmail.com', '231@gmail.com', '231@gmail.com');

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
-- Cấu trúc bảng cho bảng `employee`
--

CREATE TABLE `employee` (
  `employee_id` int(11) NOT NULL,
  `employee_name` varchar(255) DEFAULT NULL,
  `employee_salary` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `employee`
--

INSERT INTO `employee` (`employee_id`, `employee_name`, `employee_salary`) VALUES
(1, 'Employee name', '12.50'),
(2, 'Employee name', '12.50'),
(3, 'Employee name 1', '3.50'),
(4, 'Employee name 4', '4.50');

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
(8, '172.217.25.4', 'IP CSS thành', 1, '2023-09-16 13:10:41', 0, NULL, 0);

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

INSERT INTO `projects` (`id`, `customer_id`, `name`, `description`, `status_id`, `start_date`, `end_date`, `invoice_id`, `done_link`, `wait_note`, `combo_id`, `priority`, `created_at`, `created_by`, `updated_at`, `updated_by`) VALUES
(1, 124, 'test full inputs', 'Description\n', 1, '2023-10-03 22:45:00', '2023-10-03 22:45:00', '', NULL, NULL, 2, 0, '2023-10-03 22:48:01', 4, NULL, 0),
(2, 124, 'test full inputs', 'Description\n', 1, '2023-10-03 22:45:00', '2023-10-04 04:45:00', '', NULL, NULL, 2, 0, '2023-10-03 22:48:14', 4, NULL, 0);

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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `project_levels`
--

CREATE TABLE `project_levels` (
  `project_id` bigint(20) NOT NULL,
  `level_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `project_statuses`
--

CREATE TABLE `project_statuses` (
  `id` int(11) NOT NULL,
  `stt_job_name` varchar(30) NOT NULL,
  `color_sttj` varchar(50) NOT NULL,
  `group_sttj` varchar(10) NOT NULL,
  `ngay_tao_sttj` date NOT NULL,
  `nguoi_tao_sttj` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `project_statuses`
--

INSERT INTO `project_statuses` (`id`, `stt_job_name`, `color_sttj`, `group_sttj`, `ngay_tao_sttj`, `nguoi_tao_sttj`) VALUES
(1, 'wait', 'badge badge-secondary', '', '0000-00-00', ''),
(2, 'Processing', 'badge badge-warning', '', '0000-00-00', ''),
(3, 'Sent', 'badge badge-success', '', '0000-00-00', ''),
(4, 'Paid', 'badge badge-info', '', '0000-00-00', ''),
(5, 'Unpay', 'badge badge-danger', '', '0000-00-00', ''),
(6, 'Upload Link', 'badge badge-danger', '', '0000-00-00', ''),
(7, 'Ask again', 'badge badge-dark', '', '0000-00-00', ''),
(8, 'Responded', 'badge badge-danger', '', '0000-00-00', '');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tasks`
--

CREATE TABLE `tasks` (
  `id` bigint(30) NOT NULL,
  `project_id` bigint(30) NOT NULL,
  `name` varchar(200) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status_id` tinyint(4) NOT NULL DEFAULT 1,
  `editor_id` int(11) NOT NULL,
  `qa_id` int(11) NOT NULL,
  `level_id` int(30) NOT NULL,
  `quantity` int(11) NOT NULL,
  `editor_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đánh dấu Editor đã xem instruction',
  `qa_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Đánh dấu QA đã xem instruction',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) NOT NULL
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
-- Cấu trúc bảng cho bảng `timelines`
--

CREATE TABLE `timelines` (
  `id` bigint(20) NOT NULL,
  `project_id` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `actioner` int(11) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `task_id` bigint(20) NOT NULL,
  `ccs` bigint(20) NOT NULL
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
-- Chỉ mục cho bảng `customers1`
--
ALTER TABLE `customers1`
  ADD PRIMARY KEY (`customer_id`);

--
-- Chỉ mục cho bảng `customer_groups`
--
ALTER TABLE `customer_groups`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`employee_id`);

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
-- Chỉ mục cho bảng `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Chỉ mục cho bảng `project_instructions`
--
ALTER TABLE `project_instructions`
  ADD PRIMARY KEY (`id`);

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
  ADD KEY `level_id` (`level_id`),
  ADD KEY `project_id` (`project_id`),
  ADD KEY `created_by` (`created_by`);

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
-- Chỉ mục cho bảng `timelines`
--
ALTER TABLE `timelines`
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
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT cho bảng `customers1`
--
ALTER TABLE `customers1`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `customer_groups`
--
ALTER TABLE `customer_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `employee`
--
ALTER TABLE `employee`
  MODIFY `employee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
-- AUTO_INCREMENT cho bảng `projects`
--
ALTER TABLE `projects`
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `project_instructions`
--
ALTER TABLE `project_instructions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `project_statuses`
--
ALTER TABLE `project_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` bigint(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=424;

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
-- AUTO_INCREMENT cho bảng `timelines`
--
ALTER TABLE `timelines`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

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
-- Các ràng buộc cho bảng `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`level_id`) REFERENCES `levels` (`id`),
  ADD CONSTRAINT `tasks_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `tasks_ibfk_4` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
