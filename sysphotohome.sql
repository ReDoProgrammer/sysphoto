-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th9 30, 2023 lúc 05:50 PM
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

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ccs`
--

CREATE TABLE `ccs` (
  `id` int(11) NOT NULL,
  `idpj` int(11) NOT NULL,
  `customer_fb` text NOT NULL,
  `intruction` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `at_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `created_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `combo`
--

CREATE TABLE `combo` (
  `id` int(11) NOT NULL,
  `ten_combo` varchar(255) NOT NULL,
  `mau_sac` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `combo`
--

INSERT INTO `combo` (`id`, `ten_combo`, `mau_sac`) VALUES
(1, 'combo 1', 'bg-danger text-white'),
(2, 'combo 2', 'bg-primary text-light'),
(3, 'combo 3', 'bg-success text-dark');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_ty`
--

CREATE TABLE `cong_ty` (
  `id_cong_ty` int(11) NOT NULL,
  `ten_cong_ty` varchar(50) NOT NULL,
  `mo_ta_ct` varchar(100) NOT NULL,
  `ngay_tao` date NOT NULL,
  `nguoi_tao` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cong_ty`
--

INSERT INTO `cong_ty` (`id_cong_ty`, `ten_cong_ty`, `mo_ta_ct`, `ngay_tao`, `nguoi_tao`) VALUES
(1, 'PHOTOHOME', '											', '2023-02-18', 'admin');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `custom`
--

CREATE TABLE `custom` (
  `id` int(30) NOT NULL,
  `id_cong_ty` int(11) NOT NULL,
  `name_ct` varchar(200) DEFAULT NULL,
  `name_ct_mh` varchar(200) NOT NULL,
  `email` varchar(200) NOT NULL,
  `link_kh` varchar(200) NOT NULL,
  `password` text NOT NULL,
  `style` text DEFAULT NULL,
  `avatar` text NOT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `custom`
--

INSERT INTO `custom` (`id`, `id_cong_ty`, `name_ct`, `name_ct_mh`, `email`, `link_kh`, `password`, `style`, `avatar`, `date_created`) VALUES
(71, 1, 'Brian H', '0023MT', '0023MT@gmail.com', '', '', '											', '', '2023-09-05 00:53:50'),
(72, 1, 'Randy E', '0073MT', '0073MT@gmail.com', '', '', '											', '', '2023-09-05 01:13:58'),
(73, 1, 'Anthony James', '0106MT', '0106MT@gmail.com', '', '', '											', '', '2023-09-05 03:03:28'),
(74, 1, 'Jonathan D', '0034MT', '0034MT@gmail.com', '', '', '											', '', '2023-09-05 03:41:26'),
(75, 0, 'Wayne Helm', '0026MTD', '0026MTD@gmail.com', '', '', '											', '', '2023-09-05 04:30:48'),
(76, 0, 'TJ Muldoon', '0003MT', '0003MT@gmail.com', '', '', '											', '', '2023-09-05 08:34:23'),
(77, 1, 'Andy Connors', '0110MT', '0110MT@gmail.com', '', '', '																						', '', '2023-09-05 11:39:16'),
(78, 1, 'Ryder', '0108MT', '0108MT@gmail.com', '', '', '											', '', '2023-09-06 00:02:31'),
(79, 1, 'Ibugg', '0016MT', '0016MT@gmail.com', '', '', '											', '', '2023-09-06 00:46:47'),
(80, 1, 'Allen', '0006MT', '0006MT@gmail.com', '', '', '											', '', '2023-09-06 01:06:01'),
(81, 1, 'Juan C', '0103MT', '0103MT@gmail.com', '', '', '											', '', '2023-09-06 01:48:57'),
(82, 1, 'Sam G', '0040MT', '0040MT@gmail.com', '', '', '											', '', '2023-09-06 02:22:00'),
(83, 1, 'Jim Wall', '0278MT', '0278MT@gmail.com', '', '', '											', '', '2023-09-06 02:57:36'),
(84, 1, 'Kevin F', '0036MT', '0036MT@gmail.com', '', '', '											', '', '2023-09-06 03:18:58'),
(85, 1, 'Chris Ba', '0055MT', '0055MT@gmail.com', '', '', '											', '', '2023-09-06 05:09:14'),
(86, 0, 'Bill Regan', '0065MT', '0065MT@gmail.com', '', '', '											', '', '2023-09-06 05:40:23'),
(87, 1, 'Stacie P', '0097MT', '0097MT@gmail.com', '', '', '											', '', '2023-09-06 05:48:18'),
(88, 1, 'Carl C', '0010MT', '0010MT@gmail.com', '', '', '											', '', '2023-09-06 06:06:12'),
(89, 1, 'Jim F', '0109MT', '0109MT@gmail.com', '', '', '											', '', '2023-09-06 06:59:34'),
(90, 0, 'Ken Gillie', '0051MT', '0051MT@gmail.com', '', '', '											', '', '2023-09-06 10:16:11'),
(91, 0, 'Grant Childress', '0088MT', '0088MT@gmail.com', '', '', '											', '', '2023-09-06 17:37:49'),
(92, 1, 'Jared C', '0039MT', '0039MT@gmail.com', '', '', '											', '', '2023-09-06 23:21:46'),
(93, 1, 'Greg M', '0004MT', '0004MT@gmail.com', '', '', '											', '', '2023-09-07 00:50:57'),
(94, 1, 'Jerry', '0001MT', '0001MT@gmail.com', '', '', '											', '', '2023-09-07 00:53:39'),
(95, 1, 'Meyer', '0053MT', '0053MT@gmail.com', '', '', '											', '', '2023-09-07 01:58:32'),
(96, 1, 'Scott A', '0107MT', '0107MT@gmail.com', '', '', '											', '', '2023-09-07 02:57:06'),
(97, 0, 'Brian B', '0063MT', '0063MT@gmail.com', '', '', '											', '', '2023-09-07 03:44:22'),
(98, 1, 'Chris H', '0029MT', '0029MT@gmail.com', '', '', '											', '', '2023-09-07 04:16:30'),
(99, 0, 'Chuck Co', '0020MT', '0020MT@gmail.', '', '', '											', '', '2023-09-07 05:50:15'),
(100, 0, 'Judy Marchi / Paul Marchi', '0094MT', '0094MT@gmail.com', '', '', '											', '', '2023-09-07 06:59:51'),
(101, 0, 'Nick C', '0024MT', '0024MT@gmail.com', '', '', '											', '', '2023-09-07 07:16:25'),
(102, 0, 'Tim L', '0022MT', '0022MT@gmail.com', '', '', '											', '', '2023-09-07 07:42:20'),
(103, 0, 'Dan H', '0005MT', '0005MT@gmail.com', '', '', '											', '', '2023-09-07 08:51:57'),
(104, 0, 'Matt A', '0008MT', '0008MT@gmail.com', '', '', '											', '', '2023-09-07 08:54:26'),
(105, 0, 'Marck S', '0062MT', '0062MT@gmail.com', '', '', '											', '', '2023-09-07 10:00:01'),
(106, 0, 'Gaya P', '0058MT', '0058MT@gmail.com', '', '', '											', '', '2023-09-07 11:04:35'),
(107, 0, 'Michael B', '0224MT', '0224MT@gmail.com', '', '', '											', '', '2023-09-07 11:11:04'),
(108, 0, 'Tim W', '0048MT', '0048MT@gmail.com', '', '', '											', '', '2023-09-09 04:18:01'),
(109, 0, 'Chris P', '0038MT', '0038MT@gmail.com', '', '', '											', '', '2023-09-09 04:33:02'),
(110, 1, 'Bernhard S', '0031MT', '0031MT@gmail.com', '', '', '																						', '', '2023-09-09 06:07:47'),
(111, 1, 'Evens', '0066MT', '0066MT@gmail.com', '', '', '											', '', '2023-09-10 01:28:08'),
(112, 1, 'Jim Pe', '0027MT', '0027MT@gmail.com', '', '', '											', '', '2023-09-10 04:49:16'),
(113, 1, 'Raymond', '0060MT', '0060MT@gmail.com', '', '', '											', '', '2023-09-11 08:06:57'),
(114, 1, 'Vince F', '0030MT', '0030MT@gmail.com', '', '', '											', '', '2023-09-12 08:52:03'),
(115, 1, 'Michele', '0398MT', '0398MT@gmail.com', '', '', '											', '', '2023-09-12 09:30:41'),
(116, 0, 'Justin Schulman', '0032MT', '0032MT@gmail.com', '', '', '											', '', '2023-09-13 07:57:12'),
(117, 0, 'Ashley & Jason Kothenbeutel', '0021MT', '0021MT@gmail.com', '', '', '											', '', '2023-09-13 08:00:07'),
(118, 0, ' Alex Larson', '0068MT', '0068MT@gmail.com', '', '', '											', '', '2023-09-13 08:24:38'),
(119, 0, 'Joel Phelps', '0019MT', '0019MT@gmail.com', '', '', '											', '', '2023-09-13 08:32:54'),
(120, 0, 'Sam Shin', '0013MT', '0013MT@gmail.com', '', '', '											', '', '2023-09-13 08:41:55'),
(121, 0, 'Phil Lipscomb', '0296MT', '0296MT@gmail.com', '', '', '											', '', '2023-09-13 10:44:43'),
(122, 0, 'Brian Martin', '0028MT', '0028MT@gmail.com', '', '', '											', '', '2023-09-15 09:23:42'),
(123, 0, 'Omar B', '0072MT', '0072MT@gmail.com', '', '', '											', '', '2023-09-16 09:49:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `group_c`
--

CREATE TABLE `group_c` (
  `groupc_id` int(11) NOT NULL,
  `groupc_name` varchar(255) NOT NULL,
  `groupc_description` text DEFAULT NULL,
  `levels` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `group_e`
--

CREATE TABLE `group_e` (
  `group_id` int(11) NOT NULL,
  `group_name` varchar(255) NOT NULL,
  `group_description` text DEFAULT NULL,
  `levels` varchar(255) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `group_e`
--

INSERT INTO `group_e` (`group_id`, `group_name`, `group_description`, `levels`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'Nhóm Mattport', '', '1,2,3', 1, '2023-09-03 06:10:28', '2023-09-03 05:26:02'),
(2, 'Nhóm Mattport pro', '', '1,2,3,4,5,6,7', 1, '2023-09-03 06:12:36', '2023-09-03 05:25:57'),
(3, 'Nhóm pro', '', '1,2,3,4,5,6,7', 1, '2023-09-03 06:23:04', '2023-09-03 06:23:04'),
(4, 'Nhóm training', '', '1,2,3', 1, '2023-09-03 06:24:13', '2023-09-03 06:24:13'),
(5, 'Nhóm QA Pro', '', '1,2,3,4,5,6,7,8', 1, '2023-09-05 08:59:11', '2023-09-05 08:59:11'),
(6, 'Nhóm DTE', '', '8', 1, '2023-09-05 09:03:26', '2023-09-05 09:03:26');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `invoice`
--

CREATE TABLE `invoice` (
  `id` int(11) NOT NULL,
  `idkh` int(11) NOT NULL,
  `name_iv` varchar(50) NOT NULL,
  `total` float NOT NULL,
  `tax` int(11) NOT NULL,
  `transport` float NOT NULL,
  `status` int(11) NOT NULL,
  `ghi_chu` text DEFAULT NULL,
  `create_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ip_photo`
--

CREATE TABLE `ip_photo` (
  `id` int(11) NOT NULL,
  `dia_chi` varchar(15) NOT NULL,
  `ghi_chu` varchar(50) DEFAULT NULL,
  `trang_thai` int(11) NOT NULL DEFAULT 1,
  `ngay_tao` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `ip_photo`
--

INSERT INTO `ip_photo` (`id`, `dia_chi`, `ghi_chu`, `trang_thai`, `ngay_tao`) VALUES
(4, '113.160.15.183', 'IP công ty', 1, '2023-09-16 13:08:27'),
(5, '113.178.40.243', 'Ip wifi công ty', 1, '2023-09-16 13:09:09'),
(6, '171.231.0.247', 'Ip anh thiện', 1, '2023-09-16 13:09:41'),
(7, '42.1.77.147', 'Ip Css thành', 1, '2023-09-16 13:10:13'),
(8, '142.250.204.132', 'IP CSS thành', 1, '2023-09-16 13:10:41');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `level`
--

CREATE TABLE `level` (
  `id` int(30) NOT NULL,
  `name` varchar(30) NOT NULL,
  `dongia` mediumint(9) NOT NULL,
  `mau_sac` varchar(50) DEFAULT NULL,
  `nguoi_tao_lv` varchar(50) NOT NULL,
  `ngay_tao_lv` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `level`
--

INSERT INTO `level` (`id`, `name`, `dongia`, `mau_sac`, `nguoi_tao_lv`, `ngay_tao_lv`) VALUES
(1, 'PE-STAND', 5000, 'bg-danger text-white', '', '0000-00-00'),
(2, 'PE-BASIC', 3500, 'bg-success text-white', '', '0000-00-00'),
(3, 'PE-Drone-Basic', 1000, 'bg-warning text-white', '', '0000-00-00'),
(4, 'Re-Stand', 6000, 'text-success', '', '0000-00-00'),
(5, 'Re-Basic', 3000, 'text-danger', '', '0000-00-00'),
(6, 'Re-ADV', 15000, 'text-warning', '', '0000-00-00'),
(7, 'Re-Extreme', 50000, 'text-info', '', '0000-00-00'),
(8, 'PE-DTE', 20000, 'bg-info text-white', '', '0000-00-00'),
(9, 'VHS', 140000, 'bg-dark text-white', '', '0000-00-00'),
(10, 'VIDEO', 50000, 'bg-white text-dark', '', '0000-00-00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `logs`
--

CREATE TABLE `logs` (
  `id` int(11) NOT NULL,
  `project_id` int(11) DEFAULT NULL,
  `tasklist_id` int(11) DEFAULT NULL,
  `ccs` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `action_type` text DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `timestamp` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `logs`
--

INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(582, 112, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1138 Meadowlark Ln', 8, '2023-09-05 00:56:04'),
(583, 113, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6948 Pickett Pl', 8, '2023-09-05 01:15:34'),
(584, 114, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1130 Valley Ridge Ct, Marietta, GA 30067', 8, '2023-09-05 03:05:12'),
(585, 115, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1829 Thompsons Station Rd W', 5, '2023-09-05 03:42:18'),
(586, 116, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1006 Oak Ave, Cañon City, CO 81212', 5, '2023-09-05 04:31:49'),
(587, 116, 88, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 08:19:07'),
(588, 116, 88, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-05 08:19:07'),
(589, 116, 88, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 08:19:07'),
(590, 116, 87, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 08:27:11'),
(591, 116, 87, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-05 08:27:11'),
(592, 116, 87, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 08:27:11'),
(593, 116, 86, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'39\'', 3, '2023-09-05 08:27:24'),
(594, 116, 86, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-05 08:27:24'),
(595, 116, 86, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 08:27:24'),
(596, 117, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Listing 95 Wentworth St, Bridgeport, CT 06606', 6, '2023-09-05 08:37:20'),
(597, 117, 89, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-05 08:38:45'),
(598, 112, 82, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'46\'', 3, '2023-09-05 08:46:22'),
(599, 112, 82, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-05 08:46:22'),
(600, 112, 82, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 08:46:22'),
(601, 112, 90, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-05 08:47:46'),
(602, 112, 82, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'2 anh 130-DSC02985,165-DSC03020 bi mo\'', 3, '2023-09-05 08:52:44'),
(603, 113, 83, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'27\'', 3, '2023-09-05 08:53:17'),
(604, 113, 83, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-05 08:53:17'),
(605, 113, 83, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 08:53:24'),
(606, 117, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 19px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Photo HDR        38 \r\n</span><a href=\"https://adobe.ly/3P5eDAv\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 19px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3P5eDAv</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 19px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">  </span>											\' to \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 19px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\r\n</span><br><div><table class=\"table table-striped table-bordered table-hover table-full-width\" style=\"outline: 0px; border-width: initial; border-style: initial; border-color: transparent; border-spacing: 0px; background-color: rgb(255, 255, 255); width: 2702px; max-width: 100%; margin-bottom: 20px; color: rgb(51, 51, 51); font-family: Seravek-Medium; font-size: 14px;\"><tbody style=\"outline: 0px; border: none;\"><tr style=\"outline: 0px; border: none; background-color: transparent;\"><td colspan=\"2\" style=\"outline: 0px; border-color: rgb(221, 221, 221); padding: 2px 8px; font-size: 15px; color: rgb(0, 0, 0); line-height: 18px; background-color: rgb(255, 204, 153);\">https://imaging.hommati.cloud/widget/download/editing-team/28036857</td></tr></tbody></table></div><div><table class=\"table table-striped table-bordered table-hover table-full-width\" style=\"outline: 0px; border-width: initial; border-style: initial; border-color: transparent; border-spacing: 0px; background-color: rgb(255, 255, 255); width: 2702px; max-width: 100%; margin-bottom: 20px; color: rgb(51, 51, 51); font-family: Seravek-Medium; font-size: 14px;\"><tbody style=\"outline: 0px; border: none;\"><tr style=\"outline: 0px; border: none; background-color: transparent;\"><td colspan=\"2\" style=\"outline: 0px; border-color: rgb(221, 221, 221); padding: 2px 8px; line-height: 18px; background-color: rgb(255, 204, 153);\"><font color=\"#000000\"><span style=\"font-size: 15px;\">Hello Team. Please enhance these HDR files. Thsnk you!</span></font><br></td></tr></tbody></table></div>\'', 6, '2023-09-05 09:01:15'),
(607, 117, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                     Photo HDR        38                \' to \'                                              \'', 6, '2023-09-05 09:01:15'),
(608, 114, 84, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'38\'', 3, '2023-09-05 09:27:44'),
(609, 114, 84, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 09:27:44'),
(610, 115, 85, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'62\'', 3, '2023-09-05 09:38:39'),
(611, 115, 85, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-05 09:38:39'),
(612, 115, 85, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-05 09:38:39'),
(613, 118, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 25 Wine Time Cir, Lisbon ME', 6, '2023-09-05 11:40:09'),
(614, 118, 94, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-05 13:39:44'),
(615, 118, 91, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-05 15:26:57'),
(616, 118, 91, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'thien.pd\'', 1, '2023-09-05 15:26:57'),
(617, 118, 91, NULL, 'Update Task', 'Field \'status\' Thay đổi từ \'0\' to \'1\'', 1, '2023-09-05 15:27:08'),
(618, 118, 91, NULL, 'Update Task', 'Field \'soluong\' Thay đổi từ \'0\' to \'30\'', 1, '2023-09-05 15:27:08'),
(619, 118, 92, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-05 15:27:18'),
(620, 118, 92, NULL, 'Update Task', 'Field \'status\' Thay đổi từ \'0\' to \'1\'', 1, '2023-09-05 15:27:18'),
(621, 118, 92, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'thien.pd\'', 1, '2023-09-05 15:27:18'),
(622, 118, 92, NULL, 'Update Task', 'Field \'soluong\' Thay đổi từ \'0\' to \'1\'', 1, '2023-09-05 15:27:18'),
(623, 116, 86, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:19:54'),
(624, 116, 86, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:19:57'),
(625, 116, 86, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:20:00'),
(626, 116, 86, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:20:03'),
(627, 116, 87, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:20:17'),
(628, 116, 86, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:20:28'),
(629, 116, 86, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:21:40'),
(630, 116, 86, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:23:34'),
(631, 116, 87, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:23:45'),
(632, 112, 82, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:25:49'),
(633, 113, 83, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:25:59'),
(634, 118, 91, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:27:02'),
(635, 118, 91, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-05 16:27:16'),
(636, 118, 92, '0', 'Get task', 'Get task mới', 9, '2023-09-05 16:27:19'),
(637, 118, 92, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-05 16:27:27'),
(638, 116, 87, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-05 16:28:17'),
(639, 116, 87, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-05 16:28:17'),
(640, 116, 87, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-05 16:28:17'),
(641, 116, 86, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-05 16:28:30'),
(642, 116, 86, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-05 16:28:30'),
(643, 116, 86, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-05 16:28:30'),
(644, 113, 83, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-05 16:28:59'),
(645, 113, 83, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-05 16:28:59'),
(646, 112, 82, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-05 16:29:47'),
(647, 118, 91, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-05 16:30:25'),
(648, 118, 92, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-05 16:30:32'),
(649, 118, 91, NULL, 'Update Task', 'Field \'status\' Thay đổi từ \'2\' to \'1\'', 1, '2023-09-05 17:00:23'),
(650, 118, 92, NULL, 'Update Task', 'Field \'status\' Thay đổi từ \'2\' to \'1\'', 1, '2023-09-05 17:00:32'),
(651, 118, 91, '0', 'Get task', 'Get task mới', 9, '2023-09-05 17:10:36'),
(652, 118, 91, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'0\'', 9, '2023-09-05 17:12:51'),
(653, 118, 91, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-05 17:12:51'),
(654, 118, 91, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'2\'', 9, '2023-09-05 17:13:36'),
(655, 116, 87, '0', 'Get task', 'Get task mới', 9, '2023-09-05 17:15:14'),
(656, 118, 92, '0', 'Get task', 'Get task mới', 9, '2023-09-05 17:15:34'),
(657, 118, 92, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-05 17:16:11'),
(658, 118, 91, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-05 17:16:49'),
(659, 118, 92, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 9, '2023-09-05 17:17:22'),
(660, 118, 92, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-05 17:17:22'),
(661, 118, 91, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 9, '2023-09-05 17:17:51'),
(662, 119, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6948 Pickett Pl, Carmel, IN 46033, USA', 7, '2023-09-05 18:27:00'),
(663, 117, 89, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'50\'', 1, '2023-09-05 23:04:24'),
(664, 118, 93, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 1, '2023-09-05 23:04:36'),
(665, 118, 91, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'30\' thành \'57\'', 1, '2023-09-05 23:05:10'),
(666, 120, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1190 Watts Rd, Forest Park, GA 30297', 8, '2023-09-05 23:16:50'),
(667, 121, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2101 Meadowview Dr, Keller, TX 76248', 8, '2023-09-06 00:04:22'),
(668, 122, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 13544 W 83rd St', 8, '2023-09-06 00:07:20'),
(669, 123, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 18083 Elizabeth', 8, '2023-09-06 00:47:31'),
(670, 124, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Photo edit for 1735 Forest Lake Cir W Unit 1', 8, '2023-09-06 01:07:25'),
(671, 125, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: pictures to edit', 8, '2023-09-06 01:08:17'),
(672, 126, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: pictures to edit for 7108', 8, '2023-09-06 01:13:19'),
(673, 127, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: pictures to edit for 8314', 8, '2023-09-06 01:14:42'),
(674, 123, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day. \\n\\nhttps://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061805,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:193,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:193,&quot;2&quot;:&quot;https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0&quot;}{&quot;1&quot;:284}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day.<br><br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0\">https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0</a></span></span>											\' to \'<p>						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day. \\n\\nhttps://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061805,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:193,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:193,&quot;2&quot;:&quot;https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0&quot;}{&quot;1&quot;:284}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day.<br><br></span></span><a href=\"https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0\" target=\"_blank\">https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0</a><span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day. \\n\\nhttps://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061805,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:193,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:193,&quot;2&quot;:&quot;https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0&quot;}{&quot;1&quot;:284}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0\"></a></span></span></p><p><span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day. \\n\\nhttps://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061805,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:193,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:193,&quot;2&quot;:&quot;https://www.dropbox.com/scl/fo/g7arnslawua5jw7u4z8zd/h?rlkey=sqp44otbbr0p5xfvwrbqlaxn9&amp;dl=0&quot;}{&quot;1&quot;:284}\" style=\"font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none;\"><span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;link trống đ&atilde; b&aacute;o kh&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:13311,&quot;3&quot;:{&quot;1&quot;:0},&quot;4&quot;:{&quot;1&quot;:2,&quot;2&quot;:16776960},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" style=\"font-size: 14pt; background-color: rgb(255, 255, 0);\"><font color=\"#000000\">link trống đ&atilde; b&aacute;o kh, chờ kh ph</font></span><br></span></span>																</p>\'', 8, '2023-09-06 01:28:12'),
(675, 123, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \' \"Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day. \r\n                                \' to \'                     \"Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day. \r\n                                                \'', 8, '2023-09-06 01:28:12'),
(676, 128, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6417 Basil Ct. Fredericksburg, VA', 8, '2023-09-06 01:49:53'),
(677, 129, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1256 Hensfield Dr. Murfreesboro, TN 37128', 8, '2023-09-06 02:23:03'),
(678, 130, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3114 Noe Bixby Rd, Columbus, OH 43232', 8, '2023-09-06 02:58:30'),
(679, 131, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit 74 McNtt Ave, Albany, NY 12205', 5, '2023-09-06 03:19:37'),
(680, 132, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1446 NW Lawnridge, Grants Pass, OR', 5, '2023-09-06 05:09:48'),
(681, 133, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 18 Simpson Lane, York, ME', 5, '2023-09-06 05:18:21'),
(682, 134, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: ', 5, '2023-09-06 05:21:36'),
(683, 134, NULL, NULL, 'Update Project', 'Field \'name\' Thay đổi từ \'\' to \'31 Middle Road, Acton, ME\'', 5, '2023-09-06 05:21:48'),
(684, 134, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0 x_ContentPasted1\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\"><a href=\"https://drive.google.com/drive/folders/1e9uNUWhWpHmB1AfTa46ZczoLhEg8W6tL?usp=drive_link\" target=\"_blank\" rel=\"noopener noreferrer\" data-auth=\"NotApplicable\" id=\"LPlnkOWA1ea786b2-c355-9c4d-345d-518cc6439da5\" class=\"x_OWAAutoLink\" data-linkindex=\"0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline;\">https://drive.google.com/drive/folders/1e9uNUWhWpHmB1AfTa46ZczoLhEg8W6tL?usp=drive_link</a><br aria-hidden=\"true\"></span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\"><br aria-hidden=\"true\"></span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">INPUT FILE COUNTS:</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">5X DJI = 239</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">5X SONY = 231</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">VIDEO FILES = 28</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><br aria-hidden=\"true\"></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\">EDITOR CHOOSE MUSIC</p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">NO HOMMATI SPLASH PAGE</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">*STABILIZE WINDY/BOUNCY CLIPS*</span></p><p style=\"margin: 0in; font-family: Calibri; font-size: 11pt; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP</span></p><p style=\"margin: 0in; font-family: Calibri; font-size: 11pt; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">NOTES:&nbsp;</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Exterior sky replacement = YES</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Interior sky replacement = YES</span></p><p style=\"margin: 0in; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: Calibri; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Correct Lens Distortion on&nbsp;</span><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">SONY</span><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: Calibri; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;files</span></p><p style=\"margin: 0in; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: Calibri; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Level horizon on&nbsp;</span><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">DJI</span><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: Calibri; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;files</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Resize to 3,000 x 2,000 pixels</span></p>											\' to \'						<p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0 x_ContentPasted1\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\"><a href=\"https://drive.google.com/drive/folders/1e9uNUWhWpHmB1AfTa46ZczoLhEg8W6tL?usp=drive_link\" target=\"_blank\" rel=\"noopener noreferrer\" data-auth=\"NotApplicable\" id=\"LPlnkOWA1ea786b2-c355-9c4d-345d-518cc6439da5\" class=\"x_OWAAutoLink\" data-linkindex=\"0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline;\">https://drive.google.com/drive/folders/1e9uNUWhWpHmB1AfTa46ZczoLhEg8W6tL?usp=drive_link</a><br aria-hidden=\"true\"></span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\"><br aria-hidden=\"true\"></span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">INPUT FILE COUNTS:</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">5X DJI = 239</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">5X SONY = 231</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">VIDEO FILES = 28</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><br aria-hidden=\"true\"></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\">EDITOR CHOOSE MUSIC</p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">NO HOMMATI SPLASH PAGE</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">*STABILIZE WINDY/BOUNCY CLIPS*</span></p><p style=\"margin: 0in; font-family: Calibri; font-size: 11pt; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP</span></p><p style=\"margin: 0in; font-family: Calibri; font-size: 11pt; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">NOTES:&nbsp;</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Exterior sky replacement = YES</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Interior sky replacement = YES</span></p><p style=\"margin: 0in; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: Calibri; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Correct Lens Distortion on&nbsp;</span><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">SONY</span><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: Calibri; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;files</span></p><p style=\"margin: 0in; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: Calibri; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Level horizon on&nbsp;</span><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: bold; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">DJI</span><span class=\"x_ContentPasted0\" style=\"border: 0px; font-style: inherit; font-variant: inherit; font-weight: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: Calibri; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">&nbsp;files</span></p><p style=\"margin: 0in; font-size: 12pt; font-family: Calibri; color: black !important;\"><span class=\"x_ContentPasted0\" style=\"border: 0px; font: inherit; margin: 0px; padding: 0px; vertical-align: baseline; color: inherit; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial;\">Resize to 3,000 x 2,000 pixels</span></p>																\'', 5, '2023-09-06 05:21:48'),
(685, 134, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'INPUT FILE COUNTS:\r\n5X DJI = 239\r\n5X SONY = 231\r\nVIDEO FILES = 28\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                      \' to \'                    INPUT FILE COUNTS:\r\n5X DJI = 239\r\n5X SONY = 231\r\nVIDEO FILES = 28\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                                      \'', 5, '2023-09-06 05:21:48'),
(686, 135, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1606 JOHNSTON - HOMMATI 169', 5, '2023-09-06 05:42:00'),
(687, 136, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: TWP 191 EDIT', 5, '2023-09-06 05:48:54'),
(688, 137, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3002 Lime Kiln Ln - Photos', 5, '2023-09-06 06:06:56'),
(689, 138, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4809 Cedar Forest Pl - Photos', 5, '2023-09-06 06:09:56'),
(690, 139, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6008 Robinhood Ln - Photos', 5, '2023-09-06 06:10:19'),
(691, 140, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 631 W 59th Terr', 5, '2023-09-06 06:42:56'),
(692, 141, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4939 Floramar Terrace 605N', 5, '2023-09-06 07:00:04'),
(693, 142, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 516 Doral Country Dr', 6, '2023-09-06 08:05:50'),
(694, 143, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1808 State St apt 207', 6, '2023-09-06 10:13:53');
INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(695, 144, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1020 Church St, Evanston, IL 60201        ', 6, '2023-09-06 10:16:53'),
(696, 145, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 213 Ventura Rd St Augustine FL 32080', 6, '2023-09-06 10:17:45'),
(697, 145, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;\\&quot;SORRY!!! The count i sent earlier was wrong. This is for 213 Ventura Rd St Augustine FL 32080 145 photo files 17 videos files and 1 agent file Thank you Grace \\&quot;\\n\\n\\nhttps://www.dropbox.com/l/scl/AAC_TPsV_tVUwIiNWCqKCFllKMytqD86ZmU &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:164,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:229}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:164,&quot;2&quot;:&quot;https://www.dropbox.com/l/scl/AAC_TPsV_tVUwIiNWCqKCFllKMytqD86ZmU&quot;}{&quot;1&quot;:229}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">\"SORRY!!! The count i sent earlier was wrong. This is for 213 Ventura Rd St Augustine FL 32080 145 photo files 17 videos files and 1 agent file Thank you Grace \"<br><br><br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/l/scl/AAC_TPsV_tVUwIiNWCqKCFllKMytqD86ZmU\">https://www.dropbox.com/l/scl/AAC_TPsV_tVUwIiNWCqKCFllKMytqD86ZmU</a></span><span style=\"font-size: 14pt;\"></span></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;\\&quot;SORRY!!! The count i sent earlier was wrong. This is for 213 Ventura Rd St Augustine FL 32080 145 photo files 17 videos files and 1 agent file Thank you Grace \\&quot;\\n\\n\\nhttps://www.dropbox.com/l/scl/AAC_TPsV_tVUwIiNWCqKCFllKMytqD86ZmU &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:164,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:229}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:164,&quot;2&quot;:&quot;https://www.dropbox.com/l/scl/AAC_TPsV_tVUwIiNWCqKCFllKMytqD86ZmU&quot;}{&quot;1&quot;:229}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">\"SORRY!!! The count i sent earlier was wrong. This is for 213 Ventura Rd St Augustine FL 32080 145 photo files 17 videos files and 1 agent file Thank you Grace \"<br><br><br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/l/scl/AAC_TPsV_tVUwIiNWCqKCFllKMytqD86ZmU\">https://www.dropbox.com/l/scl/AAC_TPsV_tVUwIiNWCqKCFllKMytqD86ZmU</a></span><span style=\"font-size: 14pt;\"></span></span>																\'', 6, '2023-09-06 10:18:40'),
(698, 145, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                          \"\"\"SORRY!!! The count i sent earlier was wrong. This is for 213 Ventura Rd St Augustine FL 32080 145 photo files 17 videos files and 1 agent file Thank you Grace \"\"\r\n          \' to \'                                              \"\"\"SORRY!!! The count i sent earlier was wrong. This is for 213 Ventura Rd St Augustine FL 32080 145 photo files 17 videos files and 1 agent file Thank you Grace \"\"\r\n                          \'', 6, '2023-09-06 10:18:40'),
(699, 145, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'1\' to \'1,10\'', 6, '2023-09-06 10:18:40'),
(700, 146, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 5519 Rose Ridge Ln, Colorado Springs, CO 80917', 6, '2023-09-06 10:19:27'),
(701, 147, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4576 Seton Hall Rd, Colorado Springs, CO 80918', 6, '2023-09-06 10:20:06'),
(702, 148, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 270 Dixie St, Palmer Lake, CO 80133', 6, '2023-09-06 10:20:48'),
(703, 149, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 15847 Long Valley Dr, Colorado Springs, CO 80921', 6, '2023-09-06 10:21:38'),
(704, 150, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 8978 Braemore Hts, Colorado Springs, CO 80927', 6, '2023-09-06 10:22:10'),
(705, 151, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1032 Thelma ln, Grants Pass, OR', 6, '2023-09-06 10:22:53'),
(706, 152, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: HILTON EDIT', 6, '2023-09-06 10:23:48'),
(707, 152, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Photo HDR    18\\nhttps://www.dropbox.com/t/lqRED0PX9W96SjA8 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:15,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:58}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:15,&quot;2&quot;:&quot;https://www.dropbox.com/t/lqRED0PX9W96SjA8&quot;}{&quot;1&quot;:58}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Photo HDR 18</span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/t/lqRED0PX9W96SjA8\"><br>https://www.dropbox.com/t/lqRED0PX9W96SjA8</a></span><span style=\"font-size: 14pt;\"></span></span>											\' to \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;HILTON EDIT\\nI&#x2019;m requesting an EXPERIENCED EDITOR please . . .\\n\\nPLEASE DARKEN TVs . . .\\n\\nPlease make sure photos are bright, sharp &amp; crisp . . .\\n\\nPlease make sure edits are not too yellow . . . THIS HOME IS BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES\\n\\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\\n\\n250 files . . . thank you\\n\\nhttps://staciemosley.wetransfer.com/downloads/829e7c68359ea0291d3570e6fdbbe22520230905231330/f4b6273d6c0f511f6c9a1565f2e5689920230905231331/9c7b48?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1057725,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:372,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:594}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:372,&quot;2&quot;:&quot;https://staciemosley.wetransfer.com/downloads/829e7c68359ea0291d3570e6fdbbe22520230905231330/f4b6273d6c0f511f6c9a1565f2e5689920230905231331/9c7b48?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid&quot;}{&quot;1&quot;:594}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">HILTON EDIT<br>I&#x2019;m requesting an EXPERIENCED EDITOR please . . .<br><br>PLEASE DARKEN TVs . . .<br><br>Please make sure photos are bright, sharp &amp; crisp . . .<br><br>Please make sure edits are not too yellow . . . THIS HOME IS BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES<br><br>Please pay attention to proper white balance . . . please enhance whites and pull windows.<br><br>250 files . . . thank you<br><br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://staciemosley.wetransfer.com/downloads/829e7c68359ea0291d3570e6fdbbe22520230905231330/f4b6273d6c0f511f6c9a1565f2e5689920230905231331/9c7b48?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid\">https://staciemosley.wetransfer.com/downloads/829e7c68359ea0291d3570e6fdbbe22520230905231330/f4b6273d6c0f511f6c9a1565f2e5689920230905231331/9c7b48?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid</a></span><span style=\"font-size: 14pt;\"></span></span>\'', 6, '2023-09-06 10:24:12'),
(708, 152, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                        Photo HDR 18            \' to \'HILTON EDIT\r\nI\'m requesting an EXPERIENCED EDITOR please . . .\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . . THIS HOME IS BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n250 files . . . thank you\r\n\'', 6, '2023-09-06 10:24:12'),
(709, 153, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: WITHERSPOON EDIT', 6, '2023-09-06 10:24:45'),
(710, 154, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: UPPER ALBANY EDIT', 6, '2023-09-06 10:25:12'),
(711, 155, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: HECKERT EDIT', 6, '2023-09-06 10:25:49'),
(712, 156, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 181 York Woods Rd, South Berwick ME', 6, '2023-09-06 12:30:51'),
(713, 157, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 738 Old Hillsboro Rd, Henniker NH', 6, '2023-09-06 12:34:05'),
(714, 158, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 8836 Glendale Cir Manhattan KS', 5, '2023-09-06 23:22:25'),
(715, 159, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2633 Tally Ho Dr, Blacklick, OH 43004', 5, '2023-09-06 23:49:44'),
(716, 160, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: photos to edit 13 Arbor Club Dr Unit 101 Ponte Vedra Beach FL 32082', 5, '2023-09-07 00:01:24'),
(717, 161, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 10361 Champions Cir', 5, '2023-09-07 00:51:35'),
(718, 162, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6031 Heckert Rd, Westerville, OH 43081, USA', 5, '2023-09-07 00:54:34'),
(719, 163, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 611 Truslow Rd. Fredericksburg, VA', 5, '2023-09-07 01:43:54'),
(720, 164, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2311 Kala St, Helena, AL 35080', 5, '2023-09-07 01:59:19'),
(721, 165, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 141 Canaan Rd NH, Strafford, Strafford 03884', 5, '2023-09-07 02:23:33'),
(722, 166, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3209 Radiance Rd', 5, '2023-09-07 02:47:01'),
(723, 167, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 169 Oak Glen Road, Howell, NJ', 5, '2023-09-07 02:57:51'),
(724, 168, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1925 Ruckle St. Indianapolis, IN 46202', 5, '2023-09-07 03:45:35'),
(725, 169, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 11 Nancy Allen St, Crawfordville, FL 32327', 5, '2023-09-07 04:17:15'),
(726, 170, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 792 Daybreak Dr', 5, '2023-09-07 04:17:48'),
(727, 171, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1981 North Rd SW, Snellville, GA 30078', 5, '2023-09-07 04:24:42'),
(728, 172, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 39 Cherry St, Newtown, CT 06482', 5, '2023-09-07 04:26:22'),
(729, 173, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Photo edit 12948 Gillespie Ave', 5, '2023-09-07 04:33:55'),
(730, 174, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 Greencrest Dr Ponte Vedra Beach FL 32082', 5, '2023-09-07 04:35:18'),
(731, 175, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6514 Prairie Dunes Dr', 5, '2023-09-07 04:36:28'),
(732, 176, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 514 Mehaffey Dr, Fairburn, GA 30213', 5, '2023-09-07 04:42:38'),
(733, 177, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3013 Westdale Rd', 5, '2023-09-07 04:45:37'),
(734, 178, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3509 Seaway Drive', 5, '2023-09-07 05:11:46'),
(735, 179, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2047 Sicily Ln TX, Haslet, Tarrant 76052', 5, '2023-09-07 05:12:35'),
(736, 180, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 39347 Corte Alisos, Murrieta, CA 92563', 5, '2023-09-07 05:50:49'),
(737, 181, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: CLEARFORK EDIT', 5, '2023-09-07 06:27:34'),
(738, 182, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 341 Plainview Pl, Manitou Springs, CO 80829', 5, '2023-09-07 06:44:06'),
(739, 183, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 867 Harpswell Island Road, Harpswell, ME', 5, '2023-09-07 06:44:48'),
(740, 184, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 176 New Hope Mountain Rd, Pelham, AL 35124', 5, '2023-09-07 06:45:31'),
(741, 185, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4 Honeysuckle Lane, Old Orchard Beach, ME', 5, '2023-09-07 06:46:10'),
(742, 186, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4999 Rusty Nail Point, Colorado Springs, CO 80916', 5, '2023-09-07 06:59:06'),
(743, 187, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1550 S Blue Island Ave 1108 Chicago IL', 5, '2023-09-07 07:00:21'),
(744, 188, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: FREEDOM RIDGE EDIT', 5, '2023-09-07 07:02:53'),
(745, 189, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: ', 8, '2023-09-07 07:17:45'),
(746, 189, NULL, NULL, 'Update Project', 'Field \'name\' Thay đổi từ \'\' to \'140 West G St. Benicia, CA\'', 8, '2023-09-07 07:18:02'),
(747, 189, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Hi,\\n\\nHere&#x2019;s the link for HDR editing for 140 West G St.\\n\\nhttps://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjU3OTIyZTE4LTg5MTgtNDE5MC05ZDQ5LTNkZTY5MTcyNjUzYSIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzAwZjRlYTg0NjY5NzQ5NTk4Mjk0MGYzMmQ3ZWI4NjVhP2ludml0ZV9pZD1jMmY5ZDIyYmI0NmM0YzZlOTEzMjBkMjg4Mjg1NjBmZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.5S-Jt9tgaAHPlUvlPzwiaxmKiao3A31UG6WOYMiEWHoR23-R4KiNx4GJEt04G5E0oTYDl-f-sHamKnMFE3wSLw \\n\\nThanks,\\n\\nNick&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:57,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:592}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:57,&quot;2&quot;:&quot;https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjU3OTIyZTE4LTg5MTgtNDE5MC05ZDQ5LTNkZTY5MTcyNjUzYSIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzAwZjRlYTg0NjY5NzQ5NTk4Mjk0MGYzMmQ3ZWI4NjVhP2ludml0ZV9pZD1jMmY5ZDIyYmI0NmM0YzZlOTEzMjBkMjg4Mjg1NjBmZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.5S-Jt9tgaAHPlUvlPzwiaxmKiao3A31UG6WOYMiEWHoR23-R4KiNx4GJEt04G5E0oTYDl-f-sHamKnMFE3wSLw&quot;}{&quot;1&quot;:592}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Hi,<br><br>Here&#x2019;s the link for HDR editing for 140 West G St.<br><br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjU3OTIyZTE4LTg5MTgtNDE5MC05ZDQ5LTNkZTY5MTcyNjUzYSIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzAwZjRlYTg0NjY5NzQ5NTk4Mjk0MGYzMmQ3ZWI4NjVhP2ludml0ZV9pZD1jMmY5ZDIyYmI0NmM0YzZlOTEzMjBkMjg4Mjg1NjBmZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.5S-Jt9tgaAHPlUvlPzwiaxmKiao3A31UG6WOYMiEWHoR23-R4KiNx4GJEt04G5E0oTYDl-f-sHamKnMFE3wSLw\">https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjU3OTIyZTE4LTg5MTgtNDE5MC05ZDQ5LTNkZTY5MTcyNjUzYSIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzAwZjRlYTg0NjY5NzQ5NTk4Mjk0MGYzMmQ3ZWI4NjVhP2ludml0ZV9pZD1jMmY5ZDIyYmI0NmM0YzZlOTEzMjBkMjg4Mjg1NjBmZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.5S-Jt9tgaAHPlUvlPzwiaxmKiao3A31UG6WOYMiEWHoR23-R4KiNx4GJEt04G5E0oTYDl-f-sHamKnMFE3wSLw</a></span><span style=\"font-size: 14pt;\"><br><br>Thanks,<br></span></span><br>\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Hi,\\n\\nHere&#x2019;s the link for HDR editing for 140 West G St.\\n\\nhttps://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjU3OTIyZTE4LTg5MTgtNDE5MC05ZDQ5LTNkZTY5MTcyNjUzYSIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzAwZjRlYTg0NjY5NzQ5NTk4Mjk0MGYzMmQ3ZWI4NjVhP2ludml0ZV9pZD1jMmY5ZDIyYmI0NmM0YzZlOTEzMjBkMjg4Mjg1NjBmZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.5S-Jt9tgaAHPlUvlPzwiaxmKiao3A31UG6WOYMiEWHoR23-R4KiNx4GJEt04G5E0oTYDl-f-sHamKnMFE3wSLw \\n\\nThanks,\\n\\nNick&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:57,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:592}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:57,&quot;2&quot;:&quot;https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjU3OTIyZTE4LTg5MTgtNDE5MC05ZDQ5LTNkZTY5MTcyNjUzYSIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzAwZjRlYTg0NjY5NzQ5NTk4Mjk0MGYzMmQ3ZWI4NjVhP2ludml0ZV9pZD1jMmY5ZDIyYmI0NmM0YzZlOTEzMjBkMjg4Mjg1NjBmZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.5S-Jt9tgaAHPlUvlPzwiaxmKiao3A31UG6WOYMiEWHoR23-R4KiNx4GJEt04G5E0oTYDl-f-sHamKnMFE3wSLw&quot;}{&quot;1&quot;:592}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Hi,<br><br>Here&#x2019;s the link for HDR editing for 140 West G St.<br><br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjU3OTIyZTE4LTg5MTgtNDE5MC05ZDQ5LTNkZTY5MTcyNjUzYSIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzAwZjRlYTg0NjY5NzQ5NTk4Mjk0MGYzMmQ3ZWI4NjVhP2ludml0ZV9pZD1jMmY5ZDIyYmI0NmM0YzZlOTEzMjBkMjg4Mjg1NjBmZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.5S-Jt9tgaAHPlUvlPzwiaxmKiao3A31UG6WOYMiEWHoR23-R4KiNx4GJEt04G5E0oTYDl-f-sHamKnMFE3wSLw\">https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjU3OTIyZTE4LTg5MTgtNDE5MC05ZDQ5LTNkZTY5MTcyNjUzYSIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzAwZjRlYTg0NjY5NzQ5NTk4Mjk0MGYzMmQ3ZWI4NjVhP2ludml0ZV9pZD1jMmY5ZDIyYmI0NmM0YzZlOTEzMjBkMjg4Mjg1NjBmZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.5S-Jt9tgaAHPlUvlPzwiaxmKiao3A31UG6WOYMiEWHoR23-R4KiNx4GJEt04G5E0oTYDl-f-sHamKnMFE3wSLw</a></span><span style=\"font-size: 14pt;\"><br><br>Thanks,<br></span></span><br>					\'', 8, '2023-09-07 07:18:02'),
(748, 189, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'\"Hi,\r\n\r\nHere\'s the link for HDR editing for 140 West G St.\r\n\r\n\r\n\r\nThanks,\r\n\r\n\' to \'                    \"Hi,\r\n\r\nHere\'s the link for HDR editing for 140 West G St.\r\n\r\n\r\n\r\nThanks,\r\n\r\n                \'', 8, '2023-09-07 07:18:02'),
(749, 190, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: OH 180 EDIT', 8, '2023-09-07 07:40:00'),
(750, 191, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2800 Keller Dr, Tustin CA 92782', 8, '2023-09-07 07:43:03'),
(751, 192, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 5936 Downfield Wood Dr, Charlotte, NC 28269', 8, '2023-09-07 08:50:58'),
(752, 193, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 16828 Heather Moor Dr, Florissant, MO 63034', 8, '2023-09-07 08:52:50'),
(753, 194, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: HDR 3-1 202 Harrison St. SE Leesburg, VA Project 1', 8, '2023-09-07 08:55:09'),
(754, 195, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Aerial Stills 202 Harrison St. SE Leesburg, VA Project 2', 8, '2023-09-07 08:55:37'),
(755, 196, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4320 NC-73, Concord, NC 28025', 8, '2023-09-07 09:57:04'),
(756, 197, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1713 GULF BEACH BLVD, TARPON SPRINGS, FL 34689', 8, '2023-09-07 09:58:01'),
(757, 198, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3985 Nara Dr, Florissant, MO 63033', 8, '2023-09-07 09:58:58'),
(758, 199, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 387 Hunington Ave, Eugene, OR 97405', 8, '2023-09-07 10:01:17'),
(759, 200, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Twilight Shoot', 8, '2023-09-07 10:02:08'),
(760, 201, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3 Lots Coburg, Or DR', 8, '2023-09-07 10:23:15'),
(761, 202, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3990 Terrace Trail, Eugene, OR 97405 DR', 8, '2023-09-07 11:00:39'),
(762, 203, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 video Edit 167 Wood Dale Dr, Ballston Lake, NY 12019', 8, '2023-09-07 11:01:50'),
(763, 204, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit 167 Wood Dale Dr, Ballston Lake, NY 12019', 8, '2023-09-07 11:02:20'),
(764, 205, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit 267 West Deans Mill Road, Coxsackie, NY 12192', 8, '2023-09-07 11:02:53'),
(765, 204, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'0\' to \'84\'', 8, '2023-09-07 11:03:08'),
(766, 204, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6ImNvbnRhY3RwaG90b2hvbWVAZ21haWwuY29tIiwicmVxdWVzdElkIjoiYWNlNTYxOTctODQwZC00ZWEzLThlM2YtZmUyODA1N2I5YWU5IiwibGluayI6Imh0dHBzOi8vbGlnaHRyb29tLmFkb2JlLmNvbS9zaGFyZXMvNzMzNDU1OTY2Zjk5NDY2Mzg3ZWMxZDczZDY2NjFhZTM_aW52aXRlX2lkPWJjYWE3OGU2N2E5NDQyOTViYTJjODA5MjdiM2RlODg2IiwibGFiZWwiOiIyIiwibG9jYWxlIjoiZW5fVVMifQ.xBrxi_3Eg_52W_PNfe8cbPyeQYe3tuY4B-MbZKtVEZigWM8UyceR-I2Zq5GQNi5_NEmuRTfXRNrc07KzEJAinw &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:13309,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" data-sheets-hyperlink=\"https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6ImNvbnRhY3RwaG90b2hvbWVAZ21haWwuY29tIiwicmVxdWVzdElkIjoiYWNlNTYxOTctODQwZC00ZWEzLThlM2YtZmUyODA1N2I5YWU5IiwibGluayI6Imh0dHBzOi8vbGlnaHRyb29tLmFkb2JlLmNvbS9zaGFyZXMvNzMzNDU1OTY2Zjk5NDY2Mzg3ZWMxZDczZDY2NjFhZTM_aW52aXRlX2lkPWJjYWE3OGU2N2E5NDQyOTViYTJjODA5MjdiM2RlODg2IiwibGFiZWwiOiIyIiwibG9jYWxlIjoiZW5fVVMifQ.xBrxi_3Eg_52W_PNfe8cbPyeQYe3tuY4B-MbZKtVEZigWM8UyceR-I2Zq5GQNi5_NEmuRTfXRNrc07KzEJAinw\" style=\"text-decoration-line: underline; font-size: 14pt; font-family: Arial; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" href=\"https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6ImNvbnRhY3RwaG90b2hvbWVAZ21haWwuY29tIiwicmVxdWVzdElkIjoiYWNlNTYxOTctODQwZC00ZWEzLThlM2YtZmUyODA1N2I5YWU5IiwibGluayI6Imh0dHBzOi8vbGlnaHRyb29tLmFkb2JlLmNvbS9zaGFyZXMvNzMzNDU1OTY2Zjk5NDY2Mzg3ZWMxZDczZDY2NjFhZTM_aW52aXRlX2lkPWJjYWE3OGU2N2E5NDQyOTViYTJjODA5MjdiM2RlODg2IiwibGFiZWwiOiIyIiwibG9jYWxlIjoiZW5fVVMifQ.xBrxi_3Eg_52W_PNfe8cbPyeQYe3tuY4B-MbZKtVEZigWM8UyceR-I2Zq5GQNi5_NEmuRTfXRNrc07KzEJAinw\" target=\"_blank\">https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6ImNvbnRhY3RwaG90b2hvbWVAZ21haWwuY29tIiwicmVxdWVzdElkIjoiYWNlNTYxOTctODQwZC00ZWEzLThlM2YtZmUyODA1N2I5YWU5IiwibGluayI6Imh0dHBzOi8vbGlnaHRyb29tLmFkb2JlLmNvbS9zaGFyZXMvNzMzNDU1OTY2Zjk5NDY2Mzg3ZWMxZDczZDY2NjFhZTM_aW52aXRlX2lkPWJjYWE3OGU2N2E5NDQyOTViYTJjODA5MjdiM2RlODg2IiwibGFiZWwiOiIyIiwibG9jYWxlIjoiZW5fVVMifQ.xBrxi_3Eg_52W_PNfe8cbPyeQYe3tuY4B-MbZKtVEZigWM8UyceR-I2Zq5GQNi5_NEmuRTfXRNrc07KzEJAinw</a></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6ImNvbnRhY3RwaG90b2hvbWVAZ21haWwuY29tIiwicmVxdWVzdElkIjoiYWNlNTYxOTctODQwZC00ZWEzLThlM2YtZmUyODA1N2I5YWU5IiwibGluayI6Imh0dHBzOi8vbGlnaHRyb29tLmFkb2JlLmNvbS9zaGFyZXMvNzMzNDU1OTY2Zjk5NDY2Mzg3ZWMxZDczZDY2NjFhZTM_aW52aXRlX2lkPWJjYWE3OGU2N2E5NDQyOTViYTJjODA5MjdiM2RlODg2IiwibGFiZWwiOiIyIiwibG9jYWxlIjoiZW5fVVMifQ.xBrxi_3Eg_52W_PNfe8cbPyeQYe3tuY4B-MbZKtVEZigWM8UyceR-I2Zq5GQNi5_NEmuRTfXRNrc07KzEJAinw &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:13309,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" data-sheets-hyperlink=\"https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6ImNvbnRhY3RwaG90b2hvbWVAZ21haWwuY29tIiwicmVxdWVzdElkIjoiYWNlNTYxOTctODQwZC00ZWEzLThlM2YtZmUyODA1N2I5YWU5IiwibGluayI6Imh0dHBzOi8vbGlnaHRyb29tLmFkb2JlLmNvbS9zaGFyZXMvNzMzNDU1OTY2Zjk5NDY2Mzg3ZWMxZDczZDY2NjFhZTM_aW52aXRlX2lkPWJjYWE3OGU2N2E5NDQyOTViYTJjODA5MjdiM2RlODg2IiwibGFiZWwiOiIyIiwibG9jYWxlIjoiZW5fVVMifQ.xBrxi_3Eg_52W_PNfe8cbPyeQYe3tuY4B-MbZKtVEZigWM8UyceR-I2Zq5GQNi5_NEmuRTfXRNrc07KzEJAinw\" style=\"text-decoration-line: underline; font-size: 14pt; font-family: Arial; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" href=\"https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6ImNvbnRhY3RwaG90b2hvbWVAZ21haWwuY29tIiwicmVxdWVzdElkIjoiYWNlNTYxOTctODQwZC00ZWEzLThlM2YtZmUyODA1N2I5YWU5IiwibGluayI6Imh0dHBzOi8vbGlnaHRyb29tLmFkb2JlLmNvbS9zaGFyZXMvNzMzNDU1OTY2Zjk5NDY2Mzg3ZWMxZDczZDY2NjFhZTM_aW52aXRlX2lkPWJjYWE3OGU2N2E5NDQyOTViYTJjODA5MjdiM2RlODg2IiwibGFiZWwiOiIyIiwibG9jYWxlIjoiZW5fVVMifQ.xBrxi_3Eg_52W_PNfe8cbPyeQYe3tuY4B-MbZKtVEZigWM8UyceR-I2Zq5GQNi5_NEmuRTfXRNrc07KzEJAinw\" target=\"_blank\">https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6ImNvbnRhY3RwaG90b2hvbWVAZ21haWwuY29tIiwicmVxdWVzdElkIjoiYWNlNTYxOTctODQwZC00ZWEzLThlM2YtZmUyODA1N2I5YWU5IiwibGluayI6Imh0dHBzOi8vbGlnaHRyb29tLmFkb2JlLmNvbS9zaGFyZXMvNzMzNDU1OTY2Zjk5NDY2Mzg3ZWMxZDczZDY2NjFhZTM_aW52aXRlX2lkPWJjYWE3OGU2N2E5NDQyOTViYTJjODA5MjdiM2RlODg2IiwibGFiZWwiOiIyIiwibG9jYWxlIjoiZW5fVVMifQ.xBrxi_3Eg_52W_PNfe8cbPyeQYe3tuY4B-MbZKtVEZigWM8UyceR-I2Zq5GQNi5_NEmuRTfXRNrc07KzEJAinw</a></span>																\'', 8, '2023-09-07 11:03:08'),
(767, 204, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    \' to \'                                                                        \'', 8, '2023-09-07 11:03:08'),
(768, 206, NULL, NULL, 'Insert Project', 'Tạo Job mới tên:  7 Wilmot St', 8, '2023-09-07 11:06:44'),
(769, 206, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'0\' to \'106\'', 8, '2023-09-07 11:07:06'),
(770, 206, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"Hi,&nbsp;</div><div><br></div><div>Good Morning! Here are the details for this listing 7 Wilmot St</div><div><br></div><div>&nbsp;</div><div><br></div><div>Package Type : PlatPak+ Video And Photo Editing Package</div><div><br></div><div>Drive Information:</div><div><br></div><div>Drive Location:&nbsp; https://drive.google.com/drive/folders/167AAv9Wm-kNC3cZF-AxtUzvFBIq0PHkU?usp=sharing</div><div>Total Number of Regular Photos: 33</div><div>Total Number of Twilight Photos: 2</div><div>Total Number of Video files: 9</div><div>Total Number of Photos to be used in Videos: 6</div><div>&nbsp;</div><div><br></div><div>Photo Requirement:</div><div><br></div><div>Final Photo output size&nbsp; - 7MB -10MB, we are allowed upto 12 MB files.</div><div>Window Treatment &ndash; Blue sky to all window pull</div><div><br></div><div>Photo Editing:</div><div>Please refer to images in this folder for corrections:</div><div><br></div><div>https://drive.google.com/drive/folders/1z2JkV6etiUKb5ZjLuJjwZLAspA16OZxK?usp=sharing</div><div><br></div><div>dsc_5132 - remove fan and wire on the floor, remove everything by the window.</div><div>dsc_5141 - remove all visible wires and remove fan on the floor.</div><div>dsc_5144 - remove white wire on the floor, remove vacuum cleaner and all blankets near the couch.</div><div>dsc_5156 - remove everything including wire in the landing area.</div><div>dsc_5159 - fix fan&nbsp;</div><div>dsc_5174 - fix fan&nbsp;</div><div>dsc_5185 - remove everything on the table and the corner shelf and the center table with stuff on it&nbsp;&nbsp;</div><div>dsc_5196 - fix fan&nbsp;</div><div>dsc_5199 - remove sun light from ceiling</div><div>dsc_5211 - remove sunlight from ceiling and remove purple patch on the wall.</div><div>dsc_5256 - remove green coat rack and fix fan</div><div>dsc_5273 - remove everything in basement - make basement empty except washer and dryer.</div><div>dsc_5284 - remove everything in the basement except the washer and dryer.</div><div>dsc_5294 - remove red bricks and broom on the back wall and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon</div><div>dsc_5304 - remove red bricks on the wall and broom and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon</div><div>dsc_5322 - remove cars</div><div>dsc_5331 - remove cars</div><div><br></div><div>Video Requirement:&nbsp;&nbsp;</div><div><br></div><div>Clip 1 &ndash; Photo of the property with client information</div><div>Client Info : https://drive.google.com/drive/folders/1aEmXYwav_8GoozSx3XcQ40aSetgnTkYM?usp=share_link</div><div>House Address to be added on clip 1 &ndash; 7 Wilmot St, East Brunswick, NJ</div><div>After few clips, Insert Photos</div><div>After photos combine these videos for the flow</div><div>Hommati splash video at the end&nbsp; ( Do not add client details at the end)</div><div>&nbsp;</div><div><br></div><div>Thanks\"</div>											\' to \'						<div>\"Hi,&nbsp;</div><div><br></div><div>Good Morning! Here are the details for this listing 7 Wilmot St</div><div><br></div><div>&nbsp;</div><div><br></div><div>Package Type : PlatPak+ Video And Photo Editing Package</div><div><br></div><div>Drive Information:</div><div><br></div><div>Drive Location:&nbsp; https://drive.google.com/drive/folders/167AAv9Wm-kNC3cZF-AxtUzvFBIq0PHkU?usp=sharing</div><div>Total Number of Regular Photos: 33</div><div>Total Number of Twilight Photos: 2</div><div>Total Number of Video files: 9</div><div>Total Number of Photos to be used in Videos: 6</div><div>&nbsp;</div><div><br></div><div>Photo Requirement:</div><div><br></div><div>Final Photo output size&nbsp; - 7MB -10MB, we are allowed upto 12 MB files.</div><div>Window Treatment &ndash; Blue sky to all window pull</div><div><br></div><div>Photo Editing:</div><div>Please refer to images in this folder for corrections:</div><div><br></div><div>https://drive.google.com/drive/folders/1z2JkV6etiUKb5ZjLuJjwZLAspA16OZxK?usp=sharing</div><div><br></div><div>dsc_5132 - remove fan and wire on the floor, remove everything by the window.</div><div>dsc_5141 - remove all visible wires and remove fan on the floor.</div><div>dsc_5144 - remove white wire on the floor, remove vacuum cleaner and all blankets near the couch.</div><div>dsc_5156 - remove everything including wire in the landing area.</div><div>dsc_5159 - fix fan&nbsp;</div><div>dsc_5174 - fix fan&nbsp;</div><div>dsc_5185 - remove everything on the table and the corner shelf and the center table with stuff on it&nbsp;&nbsp;</div><div>dsc_5196 - fix fan&nbsp;</div><div>dsc_5199 - remove sun light from ceiling</div><div>dsc_5211 - remove sunlight from ceiling and remove purple patch on the wall.</div><div>dsc_5256 - remove green coat rack and fix fan</div><div>dsc_5273 - remove everything in basement - make basement empty except washer and dryer.</div><div>dsc_5284 - remove everything in the basement except the washer and dryer.</div><div>dsc_5294 - remove red bricks and broom on the back wall and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon</div><div>dsc_5304 - remove red bricks on the wall and broom and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon</div><div>dsc_5322 - remove cars</div><div>dsc_5331 - remove cars</div><div><br></div><div>Video Requirement:&nbsp;&nbsp;</div><div><br></div><div>Clip 1 &ndash; Photo of the property with client information</div><div>Client Info : https://drive.google.com/drive/folders/1aEmXYwav_8GoozSx3XcQ40aSetgnTkYM?usp=share_link</div><div>House Address to be added on clip 1 &ndash; 7 Wilmot St, East Brunswick, NJ</div><div>After few clips, Insert Photos</div><div>After photos combine these videos for the flow</div><div>Hommati splash video at the end&nbsp; ( Do not add client details at the end)</div><div>&nbsp;</div><div><br></div><div>Thanks\"</div>																\'', 8, '2023-09-07 11:07:06'),
(771, 206, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'\"Hi, \r\n\r\nGood Morning! Here are the details for this listing 7 Wilmot St\r\n\r\n \r\n\r\nPackage Type : PlatPak+ Video And Photo Editing Package\r\n\r\nDrive Information:\r\n\r\n\r\nTotal Number of Regular Photos: 33\r\nTotal Number of Twilight Photos: 2\r\nTotal Number of Video files: 9\r\nTotal Number of Photos to be used in Videos: 6\r\n \r\n\r\nPhoto Requirement:\r\n\r\nFinal Photo output size  - 7MB -10MB, we are allowed upto 12 MB files.\r\nWindow Treatment – Blue sky to all window pull\r\n\r\nPhoto Editing:\r\nPlease refer to images in this folder for corrections:\r\n\r\nhttps://drive.google.com/drive/folders/1z2JkV6etiUKb5ZjLuJjwZLAspA16OZxK?usp=sharing\r\n\r\ndsc_5132 - remove fan and wire on the floor, remove everything by the window.\r\ndsc_5141 - remove all visible wires and remove fan on the floor.\r\ndsc_5144 - remove white wire on the floor, remove vacuum cleaner and all blankets near the couch.\r\ndsc_5156 - remove everything including wire in the landing area.\r\ndsc_5159 - fix fan \r\ndsc_5174 - fix fan \r\ndsc_5185 - remove everything on the table and the corner shelf and the center table with stuff on it  \r\ndsc_5196 - fix fan \r\ndsc_5199 - remove sun light from ceiling\r\ndsc_5211 - remove sunlight from ceiling and remove purple patch on the wall.\r\ndsc_5256 - remove green coat rack and fix fan\r\ndsc_5273 - remove everything in basement - make basement empty except washer and dryer.\r\ndsc_5284 - remove everything in the basement except the washer and dryer.\r\ndsc_5294 - remove red bricks and broom on the back wall and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon\r\ndsc_5304 - remove red bricks on the wall and broom and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon\r\ndsc_5322 - remove cars\r\ndsc_5331 - remove cars\r\n\r\nVideo Requirement:  \r\n\r\nClip 1 – Photo of the property with client information\r\nClient Info : https://drive.google.com/drive/folders/1aEmXYwav_8GoozSx3XcQ40aSetgnTkYM?usp=share_link\r\nHouse Address to be added on clip 1 – 7 Wilmot St, East Brunswick, NJ\r\nAfter few clips, Insert Photos\r\nAfter photos combine these videos for the flow\r\nHommati splash video at the end  ( Do not add client details at the end)\r\n \r\n\r\nThanks\"\' to \'                    \"Hi, \r\n\r\nGood Morning! Here are the details for this listing 7 Wilmot St\r\n\r\n \r\n\r\nPackage Type : PlatPak+ Video And Photo Editing Package\r\n\r\nDrive Information:\r\n\r\n\r\nTotal Number of Regular Photos: 33\r\nTotal Number of Twilight Photos: 2\r\nTotal Number of Video files: 9\r\nTotal Number of Photos to be used in Videos: 6\r\n \r\n\r\nPhoto Requirement:\r\n\r\nFinal Photo output size  - 7MB -10MB, we are allowed upto 12 MB files.\r\nWindow Treatment – Blue sky to all window pull\r\n\r\nPhoto Editing:\r\nPlease refer to images in this folder for corrections:\r\n\r\nhttps://drive.google.com/drive/folders/1z2JkV6etiUKb5ZjLuJjwZLAspA16OZxK?usp=sharing\r\n\r\ndsc_5132 - remove fan and wire on the floor, remove everything by the window.\r\ndsc_5141 - remove all visible wires and remove fan on the floor.\r\ndsc_5144 - remove white wire on the floor, remove vacuum cleaner and all blankets near the couch.\r\ndsc_5156 - remove everything including wire in the landing area.\r\ndsc_5159 - fix fan \r\ndsc_5174 - fix fan \r\ndsc_5185 - remove everything on the table and the corner shelf and the center table with stuff on it  \r\ndsc_5196 - fix fan \r\ndsc_5199 - remove sun light from ceiling\r\ndsc_5211 - remove sunlight from ceiling and remove purple patch on the wall.\r\ndsc_5256 - remove green coat rack and fix fan\r\ndsc_5273 - remove everything in basement - make basement empty except washer and dryer.\r\ndsc_5284 - remove everything in the basement except the washer and dryer.\r\ndsc_5294 - remove red bricks and broom on the back wall and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon\r\ndsc_5304 - remove red bricks on the wall and broom and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon\r\ndsc_5322 - remove cars\r\ndsc_5331 - remove cars\r\n\r\nVideo Requirement:  \r\n\r\nClip 1 – Photo of the property with client information\r\nClient Info : https://drive.google.com/drive/folders/1aEmXYwav_8GoozSx3XcQ40aSetgnTkYM?usp=share_link\r\nHouse Address to be added on clip 1 – 7 Wilmot St, East Brunswick, NJ\r\nAfter few clips, Insert Photos\r\nAfter photos combine these videos for the flow\r\nHommati splash video at the end  ( Do not add client details at the end)\r\n \r\n\r\nThanks\"                \'', 8, '2023-09-07 11:07:06'),
(772, 207, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4234 N I35, Denton, TX 76207', 8, '2023-09-07 11:08:07'),
(773, 208, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 181 York Woods Rd ME, South Berwick, York 03908', 8, '2023-09-07 11:09:41'),
(774, 209, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 13600 Thornhill Place Chester, VA', 8, '2023-09-07 11:12:20'),
(775, 210, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1561 Upper Woods Rd PA, Pleasant Mount, Wayne 18453', 5, '2023-09-07 23:59:44'),
(776, 211, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 743 N Emerson Ave, Indianapolis, IN 46219', 6, '2023-09-08 11:40:26'),
(777, 212, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Photo edit 104 Elk Grove Ln', 6, '2023-09-08 11:40:56'),
(778, 213, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1302 Wyoming Dr', 6, '2023-09-08 11:41:51'),
(779, 214, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: GLEN MAWR 94 EDIT ', 6, '2023-09-08 11:42:22'),
(780, 215, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 8803 KY-401, Custer, KY 40115', 6, '2023-09-08 11:42:46'),
(781, 216, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1454 Lovers Ln, Lake Arrowhead CA 92352', 6, '2023-09-08 11:43:13'),
(782, 217, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 213 Inverness Dr TX, Trophy Club, Denton 76262', 8, '2023-09-09 00:15:36'),
(783, 218, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 67 Welch\'s Point Road, East Winthrop, ME', 8, '2023-09-09 00:17:24'),
(784, 219, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 22 Fernwood Drive, West Bath, ME22 Fernwood Drive, West Bath, ME', 8, '2023-09-09 00:19:43'),
(785, 220, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 675 River Road, Leeds, ME', 8, '2023-09-09 00:20:57'),
(786, 221, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 242 Royal Tern Way, Carrabelle, FL 32322', 8, '2023-09-09 00:23:43'),
(787, 222, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 210 Flowers Dr, Covington, GA 30016', 8, '2023-09-09 02:41:31');
INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(788, 222, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"Photo HDR , Aerial Video&nbsp; &nbsp; &nbsp;35</div><div>pt: https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjljMWE5Y2JkLWJiZjEtNGMyMy1hOGQwLWE1NGQ2MzI5ZTk4MyIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzEyMTlhZmRjZjhjYjQ3ODA4Y2QxZWY4YmU0MGFiY2E3P2ludml0ZV9pZD1iYzBmOTEwNzZiOWY0MTUxOTg1YjNlYTlhNjgxNmNjOCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.HZPPKtCDqTzMwyHP_allCwz6pmRUubUKXA_eb7MnK9I5vIefxs_jmmMmdmYT6DnKA0T55zzM5iqg-kl05zqmaQ&nbsp;</div><div>vid:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;https://adobe.ly/48kEv4z&nbsp;</div><div>Twilight Images - 2&nbsp; &nbsp; &nbsp; &nbsp; Total Images</div><div>2&nbsp;&nbsp;</div><div>Total number of images with changes:</div><div><br></div><div>Total number of images without changes:</div><div><br></div><div>Total number of twilight enhancement images: 2</div><div><br></div><div>Total number of blue sky/green grass enhancement images:</div><div><br></div><div>Google Photos account link: https://www.dropbox.com/t/k6tMuqG8jHoRFtqC</div><div><br></div><div>Property style:</div><div><br></div><div>Special Instructions:NA</div><div><br></div><div>Option\"</div>											\' to \'						<div>\"Photo HDR , Aerial Video&nbsp; &nbsp; &nbsp;35</div><div>pt: https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjljMWE5Y2JkLWJiZjEtNGMyMy1hOGQwLWE1NGQ2MzI5ZTk4MyIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzEyMTlhZmRjZjhjYjQ3ODA4Y2QxZWY4YmU0MGFiY2E3P2ludml0ZV9pZD1iYzBmOTEwNzZiOWY0MTUxOTg1YjNlYTlhNjgxNmNjOCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.HZPPKtCDqTzMwyHP_allCwz6pmRUubUKXA_eb7MnK9I5vIefxs_jmmMmdmYT6DnKA0T55zzM5iqg-kl05zqmaQ&nbsp;</div><div>vid:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;https://adobe.ly/48kEv4z&nbsp;</div><div>Twilight Images - 2&nbsp; &nbsp; &nbsp; &nbsp; Total Images</div><div>2&nbsp;&nbsp;</div><div>Total number of images with changes:</div><div><br></div><div>Total number of images without changes:</div><div><br></div><div>Total number of twilight enhancement images: 2</div><div><br></div><div>Total number of blue sky/green grass enhancement images:</div><div><br></div><div>Google Photos account link: https://www.dropbox.com/t/k6tMuqG8jHoRFtqC</div><div><br></div><div>Property style:</div><div><br></div><div>Special Instructions:NA</div><div><br></div><div>Option\"</div>																\'', 8, '2023-09-09 02:42:12'),
(789, 222, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'      \"Photo HDR , Aerial Video     35\r\n\r\nTwilight Images - 2        Total Images\r\n2  \r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"                              \' to \'                          \"Photo HDR , Aerial Video     35\r\n\r\nTwilight Images - 2        Total Images\r\n2  \r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"                                              \'', 8, '2023-09-09 02:42:12'),
(790, 222, NULL, NULL, 'Update Project', 'Field \'start_date\' Thay đổi từ \'2023-08-09 23:20:00\' to \'2023-09-09 01:34:00\'', 8, '2023-09-09 02:42:12'),
(791, 222, NULL, NULL, 'Update Project', 'Field \'end_date\' Thay đổi từ \'2023-08-10 07:20:00\' to \'2023-09-09 09:34:00\'', 8, '2023-09-09 02:42:12'),
(792, 223, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 137 W Church St, Newark, OH 43055', 8, '2023-09-09 02:43:04'),
(793, 224, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4125 Cider Dr. Murfreesboro, TN 37129', 8, '2023-09-09 03:27:36'),
(794, 225, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 505 Douglas', 8, '2023-09-09 03:28:04'),
(795, 225, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1QkHzZKgPB-GwXQ5KZcVCBf7jiNQnwQCU?usp=sharing&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-hyperlink=\"https://drive.google.com/drive/folders/1QkHzZKgPB-GwXQ5KZcVCBf7jiNQnwQCU?usp=sharing\" style=\"text-decoration-line: underline; font-size: 14pt; font-family: Arial; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" href=\"https://drive.google.com/drive/folders/1QkHzZKgPB-GwXQ5KZcVCBf7jiNQnwQCU?usp=sharing\" target=\"_blank\">https://drive.google.com/drive/folders/1QkHzZKgPB-GwXQ5KZcVCBf7jiNQnwQCU?usp=sharing</a></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1QkHzZKgPB-GwXQ5KZcVCBf7jiNQnwQCU?usp=sharing&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-hyperlink=\"https://drive.google.com/drive/folders/1QkHzZKgPB-GwXQ5KZcVCBf7jiNQnwQCU?usp=sharing\" style=\"text-decoration-line: underline; font-size: 14pt; font-family: Arial; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" href=\"https://drive.google.com/drive/folders/1QkHzZKgPB-GwXQ5KZcVCBf7jiNQnwQCU?usp=sharing\" target=\"_blank\">https://drive.google.com/drive/folders/1QkHzZKgPB-GwXQ5KZcVCBf7jiNQnwQCU?usp=sharing</a></span>																\'', 8, '2023-09-09 03:28:29'),
(796, 225, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    \' to \'                                                                        \'', 8, '2023-09-09 03:28:29'),
(797, 225, NULL, NULL, 'Update Project', 'Field \'start_date\' Thay đổi từ \'2023-09-09 03:27:00\' to \'2023-09-09 03:04:00\'', 8, '2023-09-09 03:28:29'),
(798, 225, NULL, NULL, 'Update Project', 'Field \'end_date\' Thay đổi từ \'2023-09-09 11:27:00\' to \'2023-09-09 11:04:00\'', 8, '2023-09-09 03:28:29'),
(799, 226, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 231 Crest Cir, Lake Arrowhead CA 92352', 8, '2023-09-09 03:34:39'),
(800, 227, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 16571 Lakeville Crossing', 8, '2023-09-09 03:45:00'),
(801, 228, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 102 NW 2nd St', 8, '2023-09-09 04:04:01'),
(802, 229, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: CHELSEA GREEN EDIT', 8, '2023-09-09 04:09:57'),
(803, 230, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2203 Dawn Way by Timothy Wallace', 8, '2023-09-09 04:18:56'),
(804, 230, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"Hi Folks,</div><div><br></div><div>Please edit the HDR and bracketed aerial photos for the following link:</div><div>https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjE1NDExMmJjLTU2OWMtNDUyMy04NjIyLTgxNTI0YzdiYzNlNyIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzM1YzFiYzE2MWU0MTRlNWZiMmQ0ZWYxYTY4NDgyN2VlP2ludml0ZV9pZD0xMDQyZWFlZDAzZjQ0NjBhYjI0OTUyOTIxZjVjMWRjOSIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.p8oL9Ps-HtpZBzG6ljRQS7JWqTt09sEXSO12VE5J3pRwQNk7F-1Z9off4213dBXWqvHSStWUn0d_GvEBzOtcBw \"</div>											\' to \'						<div><br></div><div><br></div><div>Please edit the HDR and bracketed aerial photos for the following link:</div><div>https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6IjE1NDExMmJjLTU2OWMtNDUyMy04NjIyLTgxNTI0YzdiYzNlNyIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzM1YzFiYzE2MWU0MTRlNWZiMmQ0ZWYxYTY4NDgyN2VlP2ludml0ZV9pZD0xMDQyZWFlZDAzZjQ0NjBhYjI0OTUyOTIxZjVjMWRjOSIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.p8oL9Ps-HtpZBzG6ljRQS7JWqTt09sEXSO12VE5J3pRwQNk7F-1Z9off4213dBXWqvHSStWUn0d_GvEBzOtcBw \"</div>																\'', 8, '2023-09-09 04:19:34'),
(805, 230, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'     \' to \'    \r\n\r\nPlease edit the HDR and bracketed aerial photos for the following link:                             \'', 8, '2023-09-09 04:19:34'),
(806, 231, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 609 SE 21st St', 8, '2023-09-09 04:32:02'),
(807, 232, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 480 Frisco Ct', 8, '2023-09-09 04:33:39'),
(808, 233, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 306 N Yadkin Ave, Spencer, NC 28159', 8, '2023-09-09 05:30:42'),
(809, 234, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 211 Pearl Vista Dr, O\'Fallon, MO 63376', 8, '2023-09-09 05:31:48'),
(810, 235, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 202 Callaway Avenue', 8, '2023-09-09 05:32:29'),
(811, 236, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: \"3588 Colorado Rd Pomona KS \"', 8, '2023-09-09 05:33:22'),
(812, 237, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6700 S South Shore Dr, 8H, Chicago, IL 60649', 8, '2023-09-09 05:37:32'),
(813, 238, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 333 E Center St, Glenwood, IL 60425', 8, '2023-09-09 06:01:59'),
(814, 239, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 9847 Huber Ln, Niles, IL 60714', 8, '2023-09-09 06:03:02'),
(815, 240, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1072 Post Road, Wells ME, Unit 129', 8, '2023-09-09 06:04:58'),
(816, 241, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 188 North Street, Bath ME', 8, '2023-09-09 06:06:03'),
(817, 242, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2601 La Honda Dr, Anchorage, AK 99517', 8, '2023-09-09 06:08:38'),
(818, 116, 86, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:04:23'),
(819, 112, 82, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:05:10'),
(820, 113, 83, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:06:19'),
(821, 114, 84, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:06:35'),
(822, 115, 85, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:07:29'),
(823, 120, 95, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:07:32'),
(824, 121, 96, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:07:36'),
(825, 121, 96, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'30\'', 4, '2023-09-09 16:08:54'),
(826, 121, 96, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:08:54'),
(827, 122, 100, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:08:57'),
(828, 235, 120, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:09:04'),
(829, 235, 120, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'50\'', 4, '2023-09-09 16:09:20'),
(830, 235, 120, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:09:20'),
(831, 236, 119, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:09:23'),
(832, 236, 119, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'40\'', 4, '2023-09-09 16:13:13'),
(833, 236, 119, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:13:13'),
(834, 236, 119, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:13:13'),
(835, 237, 116, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:13:25'),
(836, 237, 116, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'75\'', 4, '2023-09-09 16:13:57'),
(837, 237, 116, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:13:57'),
(838, 237, 116, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:13:57'),
(839, 238, 113, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:18:07'),
(840, 238, 113, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'25\'', 4, '2023-09-09 16:19:43'),
(841, 238, 113, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:19:43'),
(842, 238, 113, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:19:43'),
(843, 239, 110, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:19:49'),
(844, 239, 110, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'78\'', 4, '2023-09-09 16:22:09'),
(845, 239, 110, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:22:09'),
(846, 240, 109, '0', 'Get task', 'Get task mới', 4, '2023-09-09 16:23:07'),
(847, 240, 121, NULL, 'Insert Task', 'Tạo Task mới', 4, '2023-09-09 16:27:39'),
(848, 240, 109, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'38\'', 4, '2023-09-09 16:28:04'),
(849, 240, 109, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:28:04'),
(850, 240, 109, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 16:28:04'),
(851, 239, 122, NULL, 'Insert Task', 'Tạo Task mới', 4, '2023-09-09 16:29:03'),
(852, 217, 101, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'2\'', 1, '2023-09-09 18:57:49'),
(853, 121, 97, '0', 'Get task', 'Get task mới', 9, '2023-09-09 18:57:59'),
(854, 217, 101, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 1, '2023-09-09 18:58:02'),
(855, 121, 96, '0', 'Get task', 'Get task mới', 9, '2023-09-09 18:59:40'),
(856, 121, 96, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 9, '2023-09-09 19:00:51'),
(857, 235, 120, '0', 'Get task', 'Get task mới', 9, '2023-09-09 19:01:51'),
(858, 235, 123, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-09 19:03:07'),
(859, 235, 120, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 9, '2023-09-09 19:05:02'),
(860, 235, 120, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-09 19:05:02'),
(861, 235, 120, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'2\'', 9, '2023-09-09 19:06:56'),
(862, 235, 124, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-09 19:11:12'),
(863, 235, 123, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'2\'', 9, '2023-09-09 19:12:03'),
(864, 235, 124, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'2\'', 9, '2023-09-09 19:12:11'),
(865, 236, 119, '0', 'Get task', 'Get task mới', 9, '2023-09-09 19:57:12'),
(866, 236, 119, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-09 19:58:38'),
(867, 237, 116, '0', 'Get task', 'Get task mới', 9, '2023-09-09 19:58:41'),
(868, 237, 116, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 9, '2023-09-09 19:58:58'),
(869, 238, 113, '0', 'Get task', 'Get task mới', 9, '2023-09-09 19:59:04'),
(870, 238, 113, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-09 19:59:48'),
(871, 239, 110, '0', 'Get task', 'Get task mới', 9, '2023-09-09 19:59:54'),
(872, 238, 113, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 4, '2023-09-09 20:12:03'),
(873, 236, 119, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 4, '2023-09-09 20:12:13'),
(874, 236, 119, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:12:13'),
(875, 235, 120, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 4, '2023-09-09 20:13:18'),
(876, 237, 116, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'0\'', 4, '2023-09-09 20:23:06'),
(877, 237, 116, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:25:41'),
(878, 237, 116, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'1\' thành \'on\'', 4, '2023-09-09 20:28:20'),
(879, 237, 116, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:30:20'),
(880, 235, 120, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:34:10'),
(881, 240, 121, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 4, '2023-09-09 20:34:20'),
(882, 240, 121, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:34:20'),
(883, 235, 120, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 4, '2023-09-09 20:34:47'),
(884, 239, 110, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 4, '2023-09-09 20:35:30'),
(885, 239, 110, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:35:30'),
(886, 241, 106, '0', 'Get task', 'Get task mới', 4, '2023-09-09 20:35:36'),
(887, 241, 106, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:35:48'),
(888, 241, 106, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:35:48'),
(889, 242, 105, '0', 'Get task', 'Get task mới', 4, '2023-09-09 20:35:53'),
(890, 242, 105, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:36:15'),
(891, 242, 105, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 4, '2023-09-09 20:36:15'),
(892, 218, 102, '0', 'Get task', 'Get task mới', 4, '2023-09-09 20:36:23'),
(893, 243, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 332 Sewell Street, Lebanon ME ', 8, '2023-09-10 00:50:43'),
(894, 244, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 135 Concord Ave NY, White Plains, Westchester 10606', 8, '2023-09-10 01:29:08'),
(895, 245, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 135 Concord Ave NY, White Plains, Westchester 10606', 8, '2023-09-10 01:54:24'),
(896, 246, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4750 South Glenhaven Avenue, Springfield, MO 65804', 8, '2023-09-10 04:50:40'),
(897, 247, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 7879 W Sally Ct, Wasilla, AK 99623', 8, '2023-09-10 06:24:55'),
(898, 248, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 9903 BAY DRIVE, GIBSONTON, FL 33534', 8, '2023-09-10 06:51:27'),
(899, 241, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'0\' to \'77\'', 1, '2023-09-10 08:32:28'),
(900, 241, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"https://drive.google.com/drive/folders/1ZCxBcMZmdG0xGVc265BmcZ6Ntt_cKBqy?usp=drive_link</div><div><br></div><div><br></div><div><br></div><div>INPUT FILE COUNTS:</div><div><br></div><div>&nbsp;</div><div><br></div><div>5X DJI = 50</div><div><br></div><div>5X SONY = 240&nbsp;</div><div><br></div><div>&nbsp;</div><div><br></div><div>NO HOMMATI SPLASH PAGE</div><div><br></div><div>*STABILIZE WINDY/BOUNCY CLIPS*</div><div><br></div><div>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP</div><div><br></div><div>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**</div><div><br></div><div>&nbsp;</div><div><br></div><div>NOTES:&nbsp;</div><div><br></div><div>Exterior sky replacement = YES</div><div><br></div><div>Interior sky replacement = YES</div><div><br></div><div>Correct Lens Distortion on SONY files</div><div><br></div><div>Level horizon on DJI files</div><div><br></div><div>Resize to 3,000 x 2,000 pixels</div><div><br></div><div>No, there is no video for this request.<br></div>											\' to \'						<div>\"https://drive.google.com/drive/folders/1ZCxBcMZmdG0xGVc265BmcZ6Ntt_cKBqy?usp=drive_link</div><div><br></div><div><br></div><div><br></div><div>INPUT FILE COUNTS:</div><div><br></div><div>&nbsp;</div><div><br></div><div>5X DJI = 50</div><div><br></div><div>5X SONY = 240&nbsp;</div><div><br></div><div>&nbsp;</div><div><br></div><div>NO HOMMATI SPLASH PAGE</div><div><br></div><div>*STABILIZE WINDY/BOUNCY CLIPS*</div><div><br></div><div>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP</div><div><br></div><div>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**</div><div><br></div><div>&nbsp;</div><div><br></div><div>NOTES:&nbsp;</div><div><br></div><div>Exterior sky replacement = YES</div><div><br></div><div>Interior sky replacement = YES</div><div><br></div><div>Correct Lens Distortion on SONY files</div><div><br></div><div>Level horizon on DJI files</div><div><br></div><div>Resize to 3,000 x 2,000 pixels</div><div><br></div><div>No, there is no video for this request.<br></div>																\'', 1, '2023-09-10 08:32:28'),
(901, 241, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 50\r\n\r\n5X SONY = 240 \r\n\r\n \r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\r\n\r\nNo, there is no video for this request.                                   \' to \'                    \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 50\r\n\r\n5X SONY = 240 \r\n\r\n \r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\r\n\r\nNo, there is no video for this request.                                                   \'', 1, '2023-09-10 08:32:28'),
(902, 249, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1920 Chambers St, Eugene, OR 97405', 8, '2023-09-10 08:47:56'),
(903, 250, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1920 Chambers St, Eugene, OR 97405', 8, '2023-09-10 08:49:41'),
(904, 250, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'0\' to \'94\'', 8, '2023-09-10 08:49:52'),
(905, 250, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Twilight Images - 1        Total Images\\n1\\nDo not replace sky. thank you\\nTotal number of images with changes:\\n\\nTotal number of images without changes:\\n\\nTotal number of twilight enhancement images: 1\\n\\nTotal number of blue sky/green grass enhancement images:\\n\\nGoogle Photos account link: [http://Please use DSC3638 for DTE]http://Please use DSC3638 for DTE\\n\\nhttps://imaging.hommati.cloud/widget/download/editing-team/28190017 \\nProperty style:\\n\\nSpecial Instructions:Please enhance with DTE photos DSC3638\\n\\nOption&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:355,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:422}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:355,&quot;2&quot;:&quot;https://imaging.hommati.cloud/widget/download/editing-team/28190017&quot;}{&quot;1&quot;:422}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Twilight Images - 1 Total Images<br>1<br>Do not replace sky. thank you<br>Total number of images with changes:<br><br>Total number of images without changes:<br><br>Total number of twilight enhancement images: 1<br><br>Total number of blue sky/green grass enhancement images:<br><br>Google Photos account link: [http://Please use DSC3638 for DTE]http://Please use DSC3638 for DTE<br><br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://imaging.hommati.cloud/widget/download/editing-team/28190017\">https://imaging.hommati.cloud/widget/download/editing-team/28190017</a></span><span style=\"font-size: 14pt;\"><br>Property style:<br><br>Special Instructions:Please enhance with DTE photos DSC3638<br><br>Option</span></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Twilight Images - 1        Total Images\\n1\\nDo not replace sky. thank you\\nTotal number of images with changes:\\n\\nTotal number of images without changes:\\n\\nTotal number of twilight enhancement images: 1\\n\\nTotal number of blue sky/green grass enhancement images:\\n\\nGoogle Photos account link: [http://Please use DSC3638 for DTE]http://Please use DSC3638 for DTE\\n\\nhttps://imaging.hommati.cloud/widget/download/editing-team/28190017 \\nProperty style:\\n\\nSpecial Instructions:Please enhance with DTE photos DSC3638\\n\\nOption&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:355,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:422}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:355,&quot;2&quot;:&quot;https://imaging.hommati.cloud/widget/download/editing-team/28190017&quot;}{&quot;1&quot;:422}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Twilight Images - 1 Total Images<br>1<br>Do not replace sky. thank you<br>Total number of images with changes:<br><br>Total number of images without changes:<br><br>Total number of twilight enhancement images: 1<br><br>Total number of blue sky/green grass enhancement images:<br><br>Google Photos account link: [http://Please use DSC3638 for DTE]http://Please use DSC3638 for DTE<br><br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://imaging.hommati.cloud/widget/download/editing-team/28190017\">https://imaging.hommati.cloud/widget/download/editing-team/28190017</a></span><span style=\"font-size: 14pt;\"><br>Property style:<br><br>Special Instructions:Please enhance with DTE photos DSC3638<br><br>Option</span></span>																\'', 8, '2023-09-10 08:49:52'),
(906, 250, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \' cua 0062MT             \"Twilight Images - 1        Total Images\r\n1\r\nDo not replace sky. thank you\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 1\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: [http://Please use DSC3638 for DTE]http://Please use DSC3638 for DTE\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:Please enhance with DTE photos DSC3638\r\n\r\nOption\"                      \' to \'                     cua 0062MT             \"Twilight Images - 1        Total Images\r\n1\r\nDo not replace sky. thank you\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 1\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: [http://Please use DSC3638 for DTE]http://Please use DSC3638 for DTE\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:Please enhance with DTE photos DSC3638\r\n\r\nOption\"                                      \'', 8, '2023-09-10 08:49:52'),
(907, 251, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 341 Indian Grass St, Calhan, CO 80808', 8, '2023-09-10 09:37:29'),
(908, 252, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 365 Gdn Pk Ave, Calhan, CO 80808', 8, '2023-09-10 09:38:07'),
(909, 253, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 369 Indian Grass St, Calhan, CO 80808', 8, '2023-09-10 09:38:52'),
(910, 254, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 15828 Cala Rojo Dr, Colorado Springs, CO 80926', 8, '2023-09-10 09:39:25'),
(911, 254, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'0\' to \'75\'', 8, '2023-09-10 09:39:35'),
(912, 254, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Photos + Drone + Social Media\\n\\nPhotos: 205 plus DTE\\n\\nDrone: 9 files\\n\\nSocial Media: 21 files\\nhttps://www.dropbox.com/scl/fo/v0ih6jmopw3pf9iydhkfi/h?rlkey=pipartjwdxubiisb4ystqbzkb&amp;dl=0 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:92,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:183}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:92,&quot;2&quot;:&quot;https://www.dropbox.com/scl/fo/v0ih6jmopw3pf9iydhkfi/h?rlkey=pipartjwdxubiisb4ystqbzkb&amp;dl=0&quot;}{&quot;1&quot;:183}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Photos + Drone + Social Media<br><br>Photos: 205 plus DTE<br><br>Drone: 9 files<br><br>Social Media: 21 files<br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/scl/fo/v0ih6jmopw3pf9iydhkfi/h?rlkey=pipartjwdxubiisb4ystqbzkb&amp;dl=0\">https://www.dropbox.com/scl/fo/v0ih6jmopw3pf9iydhkfi/h?rlkey=pipartjwdxubiisb4ystqbzkb&amp;dl=0</a></span><span style=\"font-size: 14pt;\"></span></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Photos + Drone + Social Media\\n\\nPhotos: 205 plus DTE\\n\\nDrone: 9 files\\n\\nSocial Media: 21 files\\nhttps://www.dropbox.com/scl/fo/v0ih6jmopw3pf9iydhkfi/h?rlkey=pipartjwdxubiisb4ystqbzkb&amp;dl=0 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:92,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:183}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:92,&quot;2&quot;:&quot;https://www.dropbox.com/scl/fo/v0ih6jmopw3pf9iydhkfi/h?rlkey=pipartjwdxubiisb4ystqbzkb&amp;dl=0&quot;}{&quot;1&quot;:183}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Photos + Drone + Social Media<br><br>Photos: 205 plus DTE<br><br>Drone: 9 files<br><br>Social Media: 21 files<br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/scl/fo/v0ih6jmopw3pf9iydhkfi/h?rlkey=pipartjwdxubiisb4ystqbzkb&amp;dl=0\">https://www.dropbox.com/scl/fo/v0ih6jmopw3pf9iydhkfi/h?rlkey=pipartjwdxubiisb4ystqbzkb&amp;dl=0</a></span><span style=\"font-size: 14pt;\"></span></span>																\'', 8, '2023-09-10 09:39:35'),
(913, 254, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'    \"Photos + Drone + Social Media\r\n\r\nPhotos: 205 plus DTE\r\n\r\nDrone: 9 files\r\n\r\nSocial Media: 21 files                 \' to \'                        \"Photos + Drone + Social Media\r\n\r\nPhotos: 205 plus DTE\r\n\r\nDrone: 9 files\r\n\r\nSocial Media: 21 files                                 \'', 8, '2023-09-10 09:39:35'),
(914, 255, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1622 Southhampton Way', 8, '2023-09-10 09:42:14'),
(915, 256, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1710 Canoe Branch Rd', 8, '2023-09-10 09:44:33'),
(916, 237, 117, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:09:11'),
(917, 235, 120, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-10 10:18:01'),
(918, 236, 119, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-10 10:18:10'),
(919, 238, 113, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-10 10:18:18'),
(920, 239, 122, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-10 10:18:27'),
(921, 239, 110, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-10 10:18:39'),
(922, 240, 121, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-10 10:18:47'),
(923, 235, 124, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'7\'', 3, '2023-09-10 10:18:54'),
(924, 121, 96, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-10 10:19:03'),
(925, 235, 123, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'7\'', 3, '2023-09-10 10:19:11'),
(926, 237, 116, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'7\'', 3, '2023-09-10 10:19:20'),
(927, 240, 109, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'7\'', 3, '2023-09-10 10:19:28'),
(928, 241, 106, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'7\'', 3, '2023-09-10 10:19:35'),
(929, 242, 105, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'7\'', 3, '2023-09-10 10:19:42'),
(930, 119, 99, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:19:50'),
(931, 121, 98, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:19:58'),
(932, 121, 97, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:20:05'),
(933, 237, 118, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:20:12'),
(934, 237, 117, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:20:19'),
(935, 238, 115, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:20:28'),
(936, 238, 114, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:20:35'),
(937, 239, 112, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:20:41'),
(938, 239, 111, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:20:47'),
(939, 241, 108, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:20:54'),
(940, 241, 107, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:21:00'),
(941, 218, 104, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:21:06'),
(942, 218, 103, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:21:11'),
(943, 218, 102, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:21:16'),
(944, 217, 101, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-10 10:21:24'),
(945, 238, 114, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:21:38'),
(946, 239, 111, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:21:44'),
(947, 241, 107, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:26:40'),
(948, 243, 146, '0', 'Get task', 'Get task mới', 18, '2023-09-10 10:26:46'),
(949, 218, 103, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:26:47'),
(950, 246, 144, '0', 'Get task', 'Get task mới', 15, '2023-09-10 10:26:48'),
(951, 217, 101, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:27:06'),
(952, 247, 141, '0', 'Get task', 'Get task mới', 12, '2023-09-10 10:27:14'),
(953, 247, 141, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'047\'', 12, '2023-09-10 10:28:21'),
(954, 247, 141, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 12, '2023-09-10 10:28:34'),
(955, 247, 141, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 12, '2023-09-10 10:28:34'),
(956, 248, 138, '0', 'Get task', 'Get task mới', 19, '2023-09-10 10:31:03'),
(957, 243, 146, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-10 10:33:26'),
(958, 247, 142, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:33:56'),
(959, 236, NULL, NULL, 'Update Project', 'Field \'name\' Thay đổi từ \'\"3588 Colorado Rd Pomona KS \"\' to \'3588 Colorado Rd Pomona KS\'', 1, '2023-09-10 10:34:03'),
(960, 236, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"Hello, I have shared:</div><div>-270 photos for HDR Bracketed editing</div><div>-5 photos for HD editing</div><div>-Shared link --&gt;&nbsp; https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6ImU0MzY3Y2JlLTk4YjUtNGNkZS04ZWE0LWYyOTUyNzZkOTEyNiIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzNiNTYxMDk1NTkzNTRlZmJhMTBjZGNmMTY0MzQ0OTAyP2ludml0ZV9pZD05OTc5MzliYTIzNzk0ZGRmYjVhYmNiNzU1YjVkNGI0ZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.AKrrMV6JJizjokCmPRvKk09LgnlxYyj_D8KyO4JlVILyBkuceHS6iiSnV8JIVcRtgK9CAGCoI60EEUqm2yEwRw&nbsp;</div><div>Photos are currently uploading in the shared album.&nbsp;&nbsp;</div><div>Thank you!\"</div>											\' to \'						<div>\"Hello, I have shared:</div><div>-270 photos for HDR Bracketed editing</div><div>-5 photos for HD editing</div><div>-Shared link --&gt;&nbsp; https://postoffice.adobe.com/po-server/link/redirect?target=eyJhbGciOiJIUzUxMiJ9.eyJ0ZW1wbGF0ZSI6Im96X2luY29taW5nX2ludml0ZSIsImVtYWlsQWRkcmVzcyI6InBob3RvZWRpdGluZ0Bob21tYXRpLmNvbSIsInJlcXVlc3RJZCI6ImU0MzY3Y2JlLTk4YjUtNGNkZS04ZWE0LWYyOTUyNzZkOTEyNiIsImxpbmsiOiJodHRwczovL2xpZ2h0cm9vbS5hZG9iZS5jb20vc2hhcmVzLzNiNTYxMDk1NTkzNTRlZmJhMTBjZGNmMTY0MzQ0OTAyP2ludml0ZV9pZD05OTc5MzliYTIzNzk0ZGRmYjVhYmNiNzU1YjVkNGI0ZCIsImxhYmVsIjoiMiIsImxvY2FsZSI6ImVuX1VTIn0.AKrrMV6JJizjokCmPRvKk09LgnlxYyj_D8KyO4JlVILyBkuceHS6iiSnV8JIVcRtgK9CAGCoI60EEUqm2yEwRw&nbsp;</div><div>Photos are currently uploading in the shared album.&nbsp;&nbsp;</div><div>Thank you!\"</div>																\'', 1, '2023-09-10 10:34:03'),
(961, 236, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'               \"Hello, I have shared:\r\n-270 photos for HDR Bracketed editing\r\n-5 photos for HD editing\r\nThank you!\"                     \' to \'                                   \"Hello, I have shared:\r\n-270 photos for HDR Bracketed editing\r\n-5 photos for HD editing\r\nThank you!\"                                     \'', 1, '2023-09-10 10:34:03'),
(962, 249, 136, '0', 'Get task', 'Get task mới', 13, '2023-09-10 10:34:12'),
(963, 249, 136, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'66\'', 13, '2023-09-10 10:35:25'),
(964, 249, 136, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-10 10:35:25'),
(965, 249, 136, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-10 10:35:25'),
(966, 249, 136, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'66\' thành \'54\'', 13, '2023-09-10 10:35:52'),
(967, 251, 134, '0', 'Get task', 'Get task mới', 13, '2023-09-10 10:35:57'),
(968, 247, 141, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:36:53'),
(969, 252, 132, '0', 'Get task', 'Get task mới', 14, '2023-09-10 10:38:14'),
(970, 247, 141, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-10 10:47:36'),
(971, 249, 136, '0', 'Get task', 'Get task mới', 21, '2023-09-10 10:48:10'),
(972, 249, 136, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-10 10:48:45'),
(973, 251, 134, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'30\'', 13, '2023-09-10 12:30:43'),
(974, 251, 134, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-10 12:30:43'),
(975, 251, 134, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-10 12:30:43'),
(976, 251, 134, '0', 'Get task', 'Get task mới', 21, '2023-09-10 14:54:59'),
(977, 251, 134, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-10 14:55:14'),
(978, 247, 141, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-10 14:55:23'),
(979, 249, 136, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-10 14:55:33'),
(980, 253, 130, '0', 'Get task', 'Get task mới', 13, '2023-09-10 14:56:56'),
(981, 253, 130, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'24\'', 13, '2023-09-10 14:57:21'),
(982, 253, 130, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-10 14:57:21'),
(983, 253, 130, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-10 14:57:21'),
(984, 248, 138, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'21\'', 19, '2023-09-10 14:57:59'),
(985, 248, 138, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 19, '2023-09-10 14:57:59'),
(986, 248, 138, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 19, '2023-09-10 14:57:59'),
(987, 254, 127, '0', 'Get task', 'Get task mới', 19, '2023-09-10 14:58:03'),
(988, 255, 126, '0', 'Get task', 'Get task mới', 17, '2023-09-10 14:58:26'),
(989, 255, 126, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'30\'', 17, '2023-09-10 14:58:44'),
(990, 255, 126, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-10 14:58:44'),
(991, 255, 126, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-10 14:58:44'),
(992, 256, 125, '0', 'Get task', 'Get task mới', 17, '2023-09-10 14:58:49'),
(993, 256, 125, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'40\'', 17, '2023-09-10 14:59:03'),
(994, 256, 125, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-10 14:59:03'),
(995, 256, 125, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-10 14:59:03'),
(996, 252, 132, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'26\'', 14, '2023-09-10 14:59:38'),
(997, 252, 132, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 14, '2023-09-10 14:59:38'),
(998, 252, 132, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 14, '2023-09-10 14:59:38'),
(999, 248, 138, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:01:01'),
(1000, 248, 138, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-10 15:01:38'),
(1001, 252, 132, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:01:42'),
(1002, 252, 132, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-10 15:02:06'),
(1003, 253, 130, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:02:09'),
(1004, 252, 132, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'26\' thành \'\'', 14, '2023-09-10 15:02:27'),
(1005, 252, 132, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 14, '2023-09-10 15:02:27'),
(1006, 253, 130, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-10 15:02:38'),
(1007, 246, 144, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-10 15:02:39');
INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(1008, 246, 144, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-10 15:02:39'),
(1009, 246, 144, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-10 15:02:39'),
(1010, 243, 146, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'14\'', 18, '2023-09-10 15:02:48'),
(1011, 243, 146, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-10 15:02:48'),
(1012, 243, 149, NULL, 'Insert Task', 'Tạo Task mới', 18, '2023-09-10 15:03:21'),
(1013, 254, 127, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'023\'', 19, '2023-09-10 15:05:08'),
(1014, 254, 127, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 19, '2023-09-10 15:05:08'),
(1015, 254, 127, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 19, '2023-09-10 15:05:08'),
(1016, 247, 142, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 21, '2023-09-10 15:05:23'),
(1017, 247, 142, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-10 15:05:23'),
(1018, 244, 148, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:05:28'),
(1019, 243, 146, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:05:43'),
(1020, 244, 148, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 21, '2023-09-10 15:05:56'),
(1021, 244, 148, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-10 15:05:56'),
(1022, 248, 139, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:05:59'),
(1023, 248, 139, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 21, '2023-09-10 15:06:11'),
(1024, 248, 139, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-10 15:06:11'),
(1025, 243, 146, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-10 15:06:26'),
(1026, 243, 149, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:06:29'),
(1027, 252, 132, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 21, '2023-09-10 15:06:36'),
(1028, 243, 149, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-10 15:06:45'),
(1029, 246, 144, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:06:48'),
(1030, 253, 130, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-10 15:06:56'),
(1031, 248, 138, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-10 15:07:03'),
(1032, 246, 144, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-10 15:07:12'),
(1033, 254, 127, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:07:15'),
(1034, 254, 127, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-10 15:07:27'),
(1035, 255, 126, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:07:29'),
(1036, 255, 126, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-10 15:07:39'),
(1037, 256, 125, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:07:42'),
(1038, 256, 125, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-10 15:07:56'),
(1039, 250, 137, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:08:05'),
(1040, 250, 137, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 21, '2023-09-10 15:08:13'),
(1041, 250, 137, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-10 15:08:13'),
(1042, 254, 128, '0', 'Get task', 'Get task mới', 21, '2023-09-10 15:08:16'),
(1043, 254, 128, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 21, '2023-09-10 15:08:32'),
(1044, 254, 128, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-10 15:08:32'),
(1045, 251, 134, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-10 15:15:48'),
(1046, 257, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 13778 Hillcrest', 8, '2023-09-11 08:07:36'),
(1047, 257, 150, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-11 11:45:56'),
(1048, 257, 150, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'hien.lt\'', 3, '2023-09-11 11:45:56'),
(1049, 257, 150, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'38\'', 36, '2023-09-11 11:47:12'),
(1050, 257, 150, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 36, '2023-09-11 11:47:12'),
(1051, 257, 150, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 36, '2023-09-11 11:47:12'),
(1052, 257, 150, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'\' sang \'chu.dv\'', 3, '2023-09-11 12:19:46'),
(1053, 257, 150, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-11 13:20:58'),
(1054, 258, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 977 Jamaica Blvd, Toms River, NJ', 8, '2023-09-12 08:06:52'),
(1055, 259, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1825 Beach Blvd, Point Pleasant, NJ', 8, '2023-09-12 08:17:58'),
(1056, 260, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 243 Barbados Drive N, Toms River, NJ ', 8, '2023-09-12 08:40:29'),
(1057, 261, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 153 Beacon Ridge Dr Seven Lakes NC', 8, '2023-09-12 08:52:46'),
(1058, 262, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 612 Dowd Rd Carthage NC', 8, '2023-09-12 08:54:09'),
(1059, 263, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 313 Zimmerman St, Arvin, CA 93203', 8, '2023-09-12 09:31:28'),
(1060, 263, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Photo HDR  30\\nhttps://imaging.hommati.cloud/widget/download/editing-team/28201254 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:13309,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\">Photo HDR 30&nbsp;<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;dashboard&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:15359,&quot;3&quot;:{&quot;1&quot;:0},&quot;4&quot;:{&quot;1&quot;:2,&quot;2&quot;:65280},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:3,&quot;12&quot;:0,&quot;14&quot;:{&quot;1&quot;:2,&quot;2&quot;:0},&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" style=\"font-size: 14pt;\">dashboard</span><br>https://imaging.hommati.cloud/widget/download/editing-team/28201254</span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Photo HDR  30\\nhttps://imaging.hommati.cloud/widget/download/editing-team/28201254 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:13309,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\">Photo HDR 30&nbsp;<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;dashboard&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:15359,&quot;3&quot;:{&quot;1&quot;:0},&quot;4&quot;:{&quot;1&quot;:2,&quot;2&quot;:65280},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:3,&quot;12&quot;:0,&quot;14&quot;:{&quot;1&quot;:2,&quot;2&quot;:0},&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" style=\"font-size: 14pt;\">dashboard</span><br>https://imaging.hommati.cloud/widget/download/editing-team/28201254</span>																\'', 8, '2023-09-12 09:31:35'),
(1061, 263, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'            Photo HDR 30 dashboard                        \' to \'                                Photo HDR 30 dashboard                                        \'', 8, '2023-09-12 09:31:35'),
(1062, 263, NULL, NULL, 'Update Project', 'Field \'urgent\' Thay đổi từ \'1\' to \'0\'', 8, '2023-09-12 09:31:35'),
(1063, 258, 151, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-12 09:33:32'),
(1064, 258, 151, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'dat.nt\'', 3, '2023-09-12 09:33:32'),
(1065, 258, 152, '0', 'Get task', 'Get task mới', 21, '2023-09-12 09:33:50'),
(1066, 259, 155, '0', 'Get task', 'Get task mới', 50, '2023-09-12 09:34:16'),
(1067, 264, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4108 Trinity Rd', 8, '2023-09-12 09:35:24'),
(1068, 265, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit Life style photos 9 Bingham St, Saratoga, NY 12866', 8, '2023-09-12 09:39:07'),
(1069, 259, 154, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-12 09:39:18'),
(1070, 259, 154, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'anh.dd\'', 3, '2023-09-12 09:39:18'),
(1071, 266, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 753 Belfast Farmington Rd', 8, '2023-09-12 09:42:12'),
(1072, 259, 155, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 50, '2023-09-12 09:55:20'),
(1073, 259, 155, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 50, '2023-09-12 09:55:20'),
(1074, 259, 155, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 50, '2023-09-12 09:55:20'),
(1075, 266, 161, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-12 10:33:20'),
(1076, 266, 161, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'thien.pd\'', 1, '2023-09-12 10:33:20'),
(1077, 264, 162, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-12 10:33:47'),
(1078, 265, 163, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-12 10:35:23'),
(1079, 260, 157, '0', 'Get task', 'Get task mới', 18, '2023-09-12 10:51:19'),
(1080, 261, 158, '0', 'Get task', 'Get task mới', 11, '2023-09-12 10:52:43'),
(1081, 259, 156, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-12 10:56:25'),
(1082, 259, 156, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'thien.pd\'', 3, '2023-09-12 10:56:25'),
(1083, 262, 159, '0', 'Get task', 'Get task mới', 20, '2023-09-12 10:56:28'),
(1084, 258, 153, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-12 10:57:11'),
(1085, 258, 153, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 10:57:11'),
(1086, 244, 148, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:57:46'),
(1087, 243, 149, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:57:54'),
(1088, 243, 146, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:58:02'),
(1089, 246, 144, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:58:11'),
(1090, 247, 142, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:58:22'),
(1091, 247, 141, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:58:31'),
(1092, 248, 139, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:58:40'),
(1093, 263, 160, '0', 'Get task', 'Get task mới', 10, '2023-09-12 10:58:52'),
(1094, 248, 138, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:58:59'),
(1095, 250, 137, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:59:05'),
(1096, 249, 136, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 10:59:15'),
(1097, 252, 132, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 11:04:24'),
(1098, 253, 130, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 11:10:56'),
(1099, 254, 128, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 11:11:03'),
(1100, 254, 127, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 11:11:10'),
(1101, 255, 126, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 11:11:21'),
(1102, 256, 125, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 11:11:28'),
(1103, 259, 155, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 11:11:37'),
(1104, 245, 147, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 11:11:44'),
(1105, 246, 145, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 11:11:53'),
(1106, 247, 143, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 11:12:01'),
(1107, 258, 151, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'49\'', 42, '2023-09-12 11:12:09'),
(1108, 258, 151, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-12 11:12:09'),
(1109, 258, 151, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-12 11:12:09'),
(1110, 248, 140, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 11:12:12'),
(1111, 251, 135, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 11:12:25'),
(1112, 252, 133, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 11:12:49'),
(1113, 253, 131, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 11:12:58'),
(1114, 254, 129, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-12 11:13:10'),
(1115, 258, 151, '0', 'Get task', 'Get task mới', 21, '2023-09-12 11:19:26'),
(1116, 258, 151, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-12 11:28:11'),
(1117, 260, 157, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'019\'', 18, '2023-09-12 13:08:41'),
(1118, 260, 157, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-12 13:08:41'),
(1119, 260, 157, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-12 13:08:41'),
(1120, 260, 157, '0', 'Get task', 'Get task mới', 9, '2023-09-12 13:18:47'),
(1121, 258, 151, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 42, '2023-09-12 14:41:17'),
(1122, 258, 151, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-12 14:41:17'),
(1123, 258, 152, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-12 14:53:32'),
(1124, 258, 152, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 21, '2023-09-12 14:53:32'),
(1125, 258, 152, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-12 14:53:32'),
(1126, 260, 157, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 18, '2023-09-12 14:54:36'),
(1127, 258, 151, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 21, '2023-09-12 14:59:33'),
(1128, 260, 157, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 9, '2023-09-12 15:10:37'),
(1129, 261, 164, NULL, 'Insert Task', 'Tạo Task mới', NULL, '2023-09-12 15:30:33'),
(1130, 261, 158, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'54\'', 11, '2023-09-12 15:31:26'),
(1131, 261, 158, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-12 15:31:43'),
(1132, 261, 158, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-12 15:31:43'),
(1133, 261, 164, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-12 15:31:52'),
(1134, 261, 158, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 11, '2023-09-12 15:39:59'),
(1135, 261, 164, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 11, '2023-09-12 15:40:05'),
(1136, 260, 157, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 18:34:29'),
(1137, 258, 151, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 18:34:45'),
(1138, 258, 152, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-12 18:35:02'),
(1139, 261, 164, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-13 07:27:55'),
(1140, 261, 158, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-13 07:28:03'),
(1141, 267, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3009 Lake Vista Dr KY, Louisville, Jefferson 40241', 6, '2023-09-13 07:53:11'),
(1142, 268, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 328 Montgomery Avenue', 6, '2023-09-13 07:53:47'),
(1143, 269, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 7670 Hwy 245', 6, '2023-09-13 07:55:27'),
(1144, 266, 161, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 07:56:48'),
(1145, 264, 162, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 07:56:54'),
(1146, 265, 163, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 07:56:59'),
(1147, 263, 160, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 07:57:04'),
(1148, 262, 159, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 07:57:11'),
(1149, 259, 154, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 07:57:16'),
(1150, 259, 156, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 07:57:23'),
(1151, 270, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3806 W Empedrado St, Tampa FL', 6, '2023-09-13 07:58:00'),
(1152, 271, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 9538 Rolling Cir, San Antonio FL', 6, '2023-09-13 07:58:31'),
(1153, 272, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 901 Bayshore Blvd, Tampa FL', 6, '2023-09-13 07:59:05'),
(1154, 273, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4117 2nd Place NW Rochester, MN', 6, '2023-09-13 08:00:45'),
(1155, 274, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 208 Abigaile Ct, McDonough, GA 30252        ', 6, '2023-09-13 08:01:24'),
(1156, 275, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 10 Hillcrest Court Road, August ME', 6, '2023-09-13 08:02:47'),
(1157, 276, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 130 Bradford Point Road, Friendship ME', 6, '2023-09-13 08:03:48'),
(1158, 276, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link \\r\\n\\r\\n\\r\\n\\r\\nINPUT FILE COUNTS:\\r\\n\\r\\n \\r\\n\\r\\n5X DJI = 145\\r\\n\\r\\n5X SONY = 155\\r\\n\\r\\nVIDEO FILES = 23\\r\\n\\r\\n \\r\\n\\r\\nEDITOR CHOOSE MUSIC\\r\\n\\r\\nNO HOMMATI SPLASH PAGE\\r\\n\\r\\n*STABILIZE WINDY/BOUNCY CLIPS*\\r\\n\\r\\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\\r\\n\\r\\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\\r\\n\\r\\n \\r\\n\\r\\nNOTES: \\r\\n\\r\\nExterior sky replacement = YES\\r\\n\\r\\nInterior sky replacement = YES\\r\\n\\r\\nCorrect Lens Distortion on SONY files\\r\\n\\r\\nLevel horizon on DJI files\\r\\n\\r\\nResize to 3,000 x 2,000 pixels&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:87}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:0,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link&quot;}{&quot;1&quot;:87}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link\">https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link</a></span><span style=\"font-size: 14pt;\"><br><br><br><br>INPUT FILE COUNTS:<br><br><br><br>5X DJI = 145<br><br>5X SONY = 155<br><br>VIDEO FILES = 23<br><br><br><br>EDITOR CHOOSE MUSIC<br><br>NO HOMMATI SPLASH PAGE<br><br>*STABILIZE WINDY/BOUNCY CLIPS*<br><br>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP<br><br>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**<br><br><br><br>NOTES:<br><br>Exterior sky replacement = YES<br><br>Interior sky replacement = YES<br><br>Correct Lens Distortion on SONY files<br><br>Level horizon on DJI files<br><br>Resize to 3,000 x 2,000 pixels</span></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link \\r\\n\\r\\n\\r\\n\\r\\nINPUT FILE COUNTS:\\r\\n\\r\\n \\r\\n\\r\\n5X DJI = 145\\r\\n\\r\\n5X SONY = 155\\r\\n\\r\\nVIDEO FILES = 23\\r\\n\\r\\n \\r\\n\\r\\nEDITOR CHOOSE MUSIC\\r\\n\\r\\nNO HOMMATI SPLASH PAGE\\r\\n\\r\\n*STABILIZE WINDY/BOUNCY CLIPS*\\r\\n\\r\\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\\r\\n\\r\\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\\r\\n\\r\\n \\r\\n\\r\\nNOTES: \\r\\n\\r\\nExterior sky replacement = YES\\r\\n\\r\\nInterior sky replacement = YES\\r\\n\\r\\nCorrect Lens Distortion on SONY files\\r\\n\\r\\nLevel horizon on DJI files\\r\\n\\r\\nResize to 3,000 x 2,000 pixels&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:87}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:0,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link&quot;}{&quot;1&quot;:87}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link\">https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link</a></span><span style=\"font-size: 14pt;\"><br><br><br><br>INPUT FILE COUNTS:<br><br><br><br>5X DJI = 145<br><br>5X SONY = 155<br><br>VIDEO FILES = 23<br><br><br><br>EDITOR CHOOSE MUSIC<br><br>NO HOMMATI SPLASH PAGE<br><br>*STABILIZE WINDY/BOUNCY CLIPS*<br><br>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP<br><br>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**<br><br><br><br>NOTES:<br><br>Exterior sky replacement = YES<br><br>Interior sky replacement = YES<br><br>Correct Lens Distortion on SONY files<br><br>Level horizon on DJI files<br><br>Resize to 3,000 x 2,000 pixels</span></span>																\'', 6, '2023-09-13 08:06:08'),
(1159, 276, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 145\r\n\r\n5X SONY = 155\r\n\r\nVIDEO FILES = 23\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"    \' to \'                                                    \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 145\r\n\r\n5X SONY = 155\r\n\r\nVIDEO FILES = 23\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                    \'', 6, '2023-09-13 08:06:08'),
(1160, 276, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'1\' to \'1,8,10\'', 6, '2023-09-13 08:06:08'),
(1161, 277, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4775 Northway', 6, '2023-09-13 08:06:47'),
(1162, 278, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 372 Alhambra Vallejo, CA', 6, '2023-09-13 08:07:24'),
(1163, 279, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 16 Lippincott Dr, Little Egg Harbor, NJ', 6, '2023-09-13 08:08:25'),
(1164, 280, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 5430 Saxton Hollow Rd, Colorado Springs, CO 80917', 6, '2023-09-13 08:09:11'),
(1165, 281, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1624 W Colorado Ave, Colorado Springs, CO 80904', 6, '2023-09-13 08:11:42'),
(1166, 281, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Added files.  \\n\\nDrone: 11 files\\n\\nPhotos: 11 files\\nhttps://www.dropbox.com/scl/fo/wv5xh8py5jrt4qoyrrwcn/h?rlkey=hsojyav1cf548rl4xw2vn0buk&amp;dl=0 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:50,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:141}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:50,&quot;2&quot;:&quot;https://www.dropbox.com/scl/fo/wv5xh8py5jrt4qoyrrwcn/h?rlkey=hsojyav1cf548rl4xw2vn0buk&amp;dl=0&quot;}{&quot;1&quot;:141}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Added files.<br><br>Drone: 11 files<br><br>Photos: 11 files<br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/scl/fo/wv5xh8py5jrt4qoyrrwcn/h?rlkey=hsojyav1cf548rl4xw2vn0buk&amp;dl=0\">https://www.dropbox.com/scl/fo/wv5xh8py5jrt4qoyrrwcn/h?rlkey=hsojyav1cf548rl4xw2vn0buk&amp;dl=0</a></span><span style=\"font-size: 14pt;\"></span></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Added files.  \\n\\nDrone: 11 files\\n\\nPhotos: 11 files\\nhttps://www.dropbox.com/scl/fo/wv5xh8py5jrt4qoyrrwcn/h?rlkey=hsojyav1cf548rl4xw2vn0buk&amp;dl=0 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:50,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:141}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:50,&quot;2&quot;:&quot;https://www.dropbox.com/scl/fo/wv5xh8py5jrt4qoyrrwcn/h?rlkey=hsojyav1cf548rl4xw2vn0buk&amp;dl=0&quot;}{&quot;1&quot;:141}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Added files.<br><br>Drone: 11 files<br><br>Photos: 11 files<br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://www.dropbox.com/scl/fo/wv5xh8py5jrt4qoyrrwcn/h?rlkey=hsojyav1cf548rl4xw2vn0buk&amp;dl=0\">https://www.dropbox.com/scl/fo/wv5xh8py5jrt4qoyrrwcn/h?rlkey=hsojyav1cf548rl4xw2vn0buk&amp;dl=0</a></span><span style=\"font-size: 14pt;\"></span></span>																\'', 6, '2023-09-13 08:11:56'),
(1167, 281, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'        \"Added files.  \r\n\r\nDrone: 11 files\r\n\r\nPhotos: 11 files\r\n                          \' to \'                            \"Added files.  \r\n\r\nDrone: 11 files\r\n\r\nPhotos: 11 files\r\n                                          \'', 6, '2023-09-13 08:11:56'),
(1168, 281, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'1\' to \'1,10\'', 6, '2023-09-13 08:11:56'),
(1169, 275, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'88\' to \'77\'', 6, '2023-09-13 08:16:55'),
(1170, 275, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q2te8tt3oJQqUD-Nuuakwt4S9vIS4s33?usp=drive_link \\n\\n\\n\\nINPUT FILE COUNTS:\\n\\n \\n\\n5X DJI = 115\\n\\n5X SONY = 136\\n\\nVIDEO FILES = 23\\n\\n \\n\\nAGENT BRANDED VIDEO REQUIRED\\n\\nEDITOR CHOOSE MUSIC\\n\\nNO HOMMATI SPLASH PAGE\\n\\n*STABILIZE WINDY/BOUNCY CLIPS*\\n\\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\\n\\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\\n\\n \\n\\nNOTES: \\n\\nExterior sky replacement = YES\\n\\nInterior sky replacement = YES\\n\\nCorrect Lens Distortion on SONY files\\n\\nLevel horizon on DJI files\\n\\nResize to 3,000 x 2,000 pixels&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:87}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:0,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q2te8tt3oJQqUD-Nuuakwt4S9vIS4s33?usp=drive_link&quot;}{&quot;1&quot;:87}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://drive.google.com/drive/folders/1q2te8tt3oJQqUD-Nuuakwt4S9vIS4s33?usp=drive_link\">https://drive.google.com/drive/folders/1q2te8tt3oJQqUD-Nuuakwt4S9vIS4s33?usp=drive_link</a></span><span style=\"font-size: 14pt;\"><br><br><br><br>INPUT FILE COUNTS:<br><br><br><br>5X DJI = 115<br><br>5X SONY = 136<br><br>VIDEO FILES = 23<br><br><br><br>AGENT BRANDED VIDEO REQUIRED<br><br>EDITOR CHOOSE MUSIC<br><br>NO HOMMATI SPLASH PAGE<br><br>*STABILIZE WINDY/BOUNCY CLIPS*<br><br>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP<br><br>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**<br><br><br><br>NOTES:<br><br>Exterior sky replacement = YES<br><br>Interior sky replacement = YES<br><br>Correct Lens Distortion on SONY files<br><br>Level horizon on DJI files<br><br>Resize to 3,000 x 2,000 pixels</span></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q2te8tt3oJQqUD-Nuuakwt4S9vIS4s33?usp=drive_link \\n\\n\\n\\nINPUT FILE COUNTS:\\n\\n \\n\\n5X DJI = 115\\n\\n5X SONY = 136\\n\\nVIDEO FILES = 23\\n\\n \\n\\nAGENT BRANDED VIDEO REQUIRED\\n\\nEDITOR CHOOSE MUSIC\\n\\nNO HOMMATI SPLASH PAGE\\n\\n*STABILIZE WINDY/BOUNCY CLIPS*\\n\\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\\n\\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\\n\\n \\n\\nNOTES: \\n\\nExterior sky replacement = YES\\n\\nInterior sky replacement = YES\\n\\nCorrect Lens Distortion on SONY files\\n\\nLevel horizon on DJI files\\n\\nResize to 3,000 x 2,000 pixels&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:87}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:0,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q2te8tt3oJQqUD-Nuuakwt4S9vIS4s33?usp=drive_link&quot;}{&quot;1&quot;:87}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://drive.google.com/drive/folders/1q2te8tt3oJQqUD-Nuuakwt4S9vIS4s33?usp=drive_link\">https://drive.google.com/drive/folders/1q2te8tt3oJQqUD-Nuuakwt4S9vIS4s33?usp=drive_link</a></span><span style=\"font-size: 14pt;\"><br><br><br><br>INPUT FILE COUNTS:<br><br><br><br>5X DJI = 115<br><br>5X SONY = 136<br><br>VIDEO FILES = 23<br><br><br><br>AGENT BRANDED VIDEO REQUIRED<br><br>EDITOR CHOOSE MUSIC<br><br>NO HOMMATI SPLASH PAGE<br><br>*STABILIZE WINDY/BOUNCY CLIPS*<br><br>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP<br><br>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**<br><br><br><br>NOTES:<br><br>Exterior sky replacement = YES<br><br>Interior sky replacement = YES<br><br>Correct Lens Distortion on SONY files<br><br>Level horizon on DJI files<br><br>Resize to 3,000 x 2,000 pixels</span></span>																\'', 6, '2023-09-13 08:16:55'),
(1171, 275, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                              INPUT FILE COUNTS:\r\n\r\n\r\n\r\n5X DJI = 115\r\n\r\n5X SONY = 136\r\n\r\nVIDEO FILES = 23\r\n\r\n\r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n\r\n\r\nNOTES:\r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels      \' to \'                                                  INPUT FILE COUNTS:\r\n\r\n\r\n\r\n5X DJI = 115\r\n\r\n5X SONY = 136\r\n\r\nVIDEO FILES = 23\r\n\r\n\r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n\r\n\r\nNOTES:\r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                      \'', 6, '2023-09-13 08:16:55'),
(1172, 276, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'88\' to \'77\'', 6, '2023-09-13 08:17:27');
INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(1173, 276, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link \\r\\n\\r\\n\\r\\n\\r\\nINPUT FILE COUNTS:\\r\\n\\r\\n \\r\\n\\r\\n5X DJI = 145\\r\\n\\r\\n5X SONY = 155\\r\\n\\r\\nVIDEO FILES = 23\\r\\n\\r\\n \\r\\n\\r\\nEDITOR CHOOSE MUSIC\\r\\n\\r\\nNO HOMMATI SPLASH PAGE\\r\\n\\r\\n*STABILIZE WINDY/BOUNCY CLIPS*\\r\\n\\r\\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\\r\\n\\r\\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\\r\\n\\r\\n \\r\\n\\r\\nNOTES: \\r\\n\\r\\nExterior sky replacement = YES\\r\\n\\r\\nInterior sky replacement = YES\\r\\n\\r\\nCorrect Lens Distortion on SONY files\\r\\n\\r\\nLevel horizon on DJI files\\r\\n\\r\\nResize to 3,000 x 2,000 pixels&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:87}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:0,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link&quot;}{&quot;1&quot;:87}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link\">https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link</a></span><span style=\"font-size: 14pt;\"><br><br><br><br>INPUT FILE COUNTS:<br><br><br><br>5X DJI = 145<br><br>5X SONY = 155<br><br>VIDEO FILES = 23<br><br><br><br>EDITOR CHOOSE MUSIC<br><br>NO HOMMATI SPLASH PAGE<br><br>*STABILIZE WINDY/BOUNCY CLIPS*<br><br>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP<br><br>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**<br><br><br><br>NOTES:<br><br>Exterior sky replacement = YES<br><br>Interior sky replacement = YES<br><br>Correct Lens Distortion on SONY files<br><br>Level horizon on DJI files<br><br>Resize to 3,000 x 2,000 pixels</span></span>																\' to \'												<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link \\r\\n\\r\\n\\r\\n\\r\\nINPUT FILE COUNTS:\\r\\n\\r\\n \\r\\n\\r\\n5X DJI = 145\\r\\n\\r\\n5X SONY = 155\\r\\n\\r\\nVIDEO FILES = 23\\r\\n\\r\\n \\r\\n\\r\\nEDITOR CHOOSE MUSIC\\r\\n\\r\\nNO HOMMATI SPLASH PAGE\\r\\n\\r\\n*STABILIZE WINDY/BOUNCY CLIPS*\\r\\n\\r\\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\\r\\n\\r\\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\\r\\n\\r\\n \\r\\n\\r\\nNOTES: \\r\\n\\r\\nExterior sky replacement = YES\\r\\n\\r\\nInterior sky replacement = YES\\r\\n\\r\\nCorrect Lens Distortion on SONY files\\r\\n\\r\\nLevel horizon on DJI files\\r\\n\\r\\nResize to 3,000 x 2,000 pixels&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:87}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:0,&quot;2&quot;:&quot;https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link&quot;}{&quot;1&quot;:87}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link\">https://drive.google.com/drive/folders/1q5Qc02ToKcBj9YW9ungdi3BZq3fVg2sL?usp=drive_link</a></span><span style=\"font-size: 14pt;\"><br><br><br><br>INPUT FILE COUNTS:<br><br><br><br>5X DJI = 145<br><br>5X SONY = 155<br><br>VIDEO FILES = 23<br><br><br><br>EDITOR CHOOSE MUSIC<br><br>NO HOMMATI SPLASH PAGE<br><br>*STABILIZE WINDY/BOUNCY CLIPS*<br><br>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP<br><br>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**<br><br><br><br>NOTES:<br><br>Exterior sky replacement = YES<br><br>Interior sky replacement = YES<br><br>Correct Lens Distortion on SONY files<br><br>Level horizon on DJI files<br><br>Resize to 3,000 x 2,000 pixels</span></span>																					\'', 6, '2023-09-13 08:17:27'),
(1174, 276, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                                    \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 145\r\n\r\n5X SONY = 155\r\n\r\nVIDEO FILES = 23\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                    \' to \'                                                                        \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 145\r\n\r\n5X SONY = 155\r\n\r\nVIDEO FILES = 23\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    \'', 6, '2023-09-13 08:17:27'),
(1175, 282, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1158 Forest Hill Rd, Woodland Park, CO 80863', 6, '2023-09-13 08:18:16'),
(1176, 275, 165, '0', 'Get task', 'Get task mới', 22, '2023-09-13 08:18:18'),
(1177, 283, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4416 N Delighted Cir, Colorado Springs, CO 80917', 6, '2023-09-13 08:18:51'),
(1178, 284, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 925 NW Bent Tree Dr', 6, '2023-09-13 08:19:29'),
(1179, 285, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1605 Marvin Ct', 6, '2023-09-13 08:20:56'),
(1180, 275, 166, '0', 'Get task', 'Get task mới', 51, '2023-09-13 08:21:13'),
(1181, 286, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: AFRICA EDIT', 6, '2023-09-13 08:21:43'),
(1182, 275, 167, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-13 08:21:51'),
(1183, 275, 167, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'thien.pd\'', 3, '2023-09-13 08:21:51'),
(1184, 287, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: \"54 Gold Finch Way, Crawfordville, FL 32327 – 90 photos \"', 6, '2023-09-13 08:22:18'),
(1185, 288, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 76 Harvey-Pitman St, Crawfordville, FL 32327 – 90 photos', 6, '2023-09-13 08:22:46'),
(1186, 275, 166, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 51, '2023-09-13 08:22:57'),
(1187, 275, 166, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 51, '2023-09-13 08:22:57'),
(1188, 289, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 13302 Egrets Marsh Dr Jacksonville FL 32224', 6, '2023-09-13 08:23:27'),
(1189, 290, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 18511 E 8 St N, Independence, MO 64056        ', 6, '2023-09-13 08:25:22'),
(1190, 291, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 13 Higgins Dr ME, Kennebunk, York 04043', 6, '2023-09-13 08:26:00'),
(1191, 291, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Total number of images with changes:\\n\\nTotal number of images without changes: 6\\n\\nTotal number of twilight enhancement images:\\n\\nTotal number of blue sky/green grass enhancement images:\\n\\nGoogle Photos account link: https://photos.app.goo.gl/GMEFsLkpE1g7GTgU7 \\n\\nProperty style: OR Let Hommati Team pick for you OR special project\\n\\nSpecial Instructions:#123 - Living room, dining room table and chairs in space near kitchen. Sitting room in far room with dark walls. #124 - Living Room angle #2 #132 - Dining room table and chairs in near foreground. Sitting room in background room with dark walls. #134 - Sitting room #141 - Primary bedroom #157 - Flexible space: office and workout room Please make sure to include greenery.\\n\\nOption\\n\\n&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:213,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:256}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:213,&quot;2&quot;:&quot;https://photos.app.goo.gl/GMEFsLkpE1g7GTgU7&quot;}{&quot;1&quot;:256}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Total number of images with changes:<br><br>Total number of images without changes: 6<br><br>Total number of twilight enhancement images:<br><br>Total number of blue sky/green grass enhancement images:<br><br>Google Photos account link: </span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://photos.app.goo.gl/GMEFsLkpE1g7GTgU7\">https://photos.app.goo.gl/GMEFsLkpE1g7GTgU7</a></span><span style=\"font-size: 14pt;\"><br><br>Property style: OR Let Hommati Team pick for you OR special project<br><br>Special Instructions:#123 - Living room, dining room table and chairs in space near kitchen. Sitting room in far room with dark walls. #124 - Living Room angle #2 #132 - Dining room table and chairs in near foreground. Sitting room in background room with dark walls. #134 - Sitting room #141 - Primary bedroom #157 - Flexible space: office and workout room Please make sure to include greenery.<br><br>Option<br><br></span></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Total number of images with changes:\\n\\nTotal number of images without changes: 6\\n\\nTotal number of twilight enhancement images:\\n\\nTotal number of blue sky/green grass enhancement images:\\n\\nGoogle Photos account link: https://photos.app.goo.gl/GMEFsLkpE1g7GTgU7 \\n\\nProperty style: OR Let Hommati Team pick for you OR special project\\n\\nSpecial Instructions:#123 - Living room, dining room table and chairs in space near kitchen. Sitting room in far room with dark walls. #124 - Living Room angle #2 #132 - Dining room table and chairs in near foreground. Sitting room in background room with dark walls. #134 - Sitting room #141 - Primary bedroom #157 - Flexible space: office and workout room Please make sure to include greenery.\\n\\nOption\\n\\n&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:213,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:256}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:213,&quot;2&quot;:&quot;https://photos.app.goo.gl/GMEFsLkpE1g7GTgU7&quot;}{&quot;1&quot;:256}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Total number of images with changes:<br><br>Total number of images without changes: 6<br><br>Total number of twilight enhancement images:<br><br>Total number of blue sky/green grass enhancement images:<br><br>Google Photos account link: </span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://photos.app.goo.gl/GMEFsLkpE1g7GTgU7\">https://photos.app.goo.gl/GMEFsLkpE1g7GTgU7</a></span><span style=\"font-size: 14pt;\"><br><br>Property style: OR Let Hommati Team pick for you OR special project<br><br>Special Instructions:#123 - Living room, dining room table and chairs in space near kitchen. Sitting room in far room with dark walls. #124 - Living Room angle #2 #132 - Dining room table and chairs in near foreground. Sitting room in background room with dark walls. #134 - Sitting room #141 - Primary bedroom #157 - Flexible space: office and workout room Please make sure to include greenery.<br><br>Option<br><br></span></span>																\'', 6, '2023-09-13 08:26:30'),
(1192, 291, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    \' to \'                                                                        \'', 6, '2023-09-13 08:26:30'),
(1193, 291, NULL, NULL, 'Update Project', 'Field \'start_date\' Thay đổi từ \'2023-09-13 08:25:00\' to \'2023-09-13 06:25:00\'', 6, '2023-09-13 08:26:30'),
(1194, 291, NULL, NULL, 'Update Project', 'Field \'end_date\' Thay đổi từ \'2023-09-13 16:25:00\' to \'2023-09-13 10:25:00\'', 6, '2023-09-13 08:26:30'),
(1195, 291, NULL, NULL, 'Update Project', 'Field \'urgent\' Thay đổi từ \'0\' to \'1\'', 6, '2023-09-13 08:26:30'),
(1196, 292, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1825 Beach Blvd NJ, Point Pleasant, Ocean 08742', 6, '2023-09-13 08:26:59'),
(1197, 293, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1205 E Fredrickson Dr, Olathe, KS 66061        ', 6, '2023-09-13 08:30:35'),
(1198, 294, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Photo edit 136 Phelps St', 6, '2023-09-13 08:31:34'),
(1199, 295, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Photo edit 154 Southerly Ln Fleming Island FL 32003', 6, '2023-09-13 08:32:04'),
(1200, 296, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 12 6th St S, Naples FL, 34102', 6, '2023-09-13 08:33:39'),
(1201, 297, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 86970 Sweet Creek Rd Mapleton DR', 6, '2023-09-13 08:35:48'),
(1202, 298, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 604 W Courtland St, Mundelein, IL 60060', 6, '2023-09-13 08:36:22'),
(1203, 299, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 112 Covered Bridge Ct', 6, '2023-09-13 08:36:55'),
(1204, 300, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 363 STRATHAVEN DRIVE, PELHAM, AL 35124', 6, '2023-09-13 08:37:33'),
(1205, 301, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 27 Frederiksted St, Toms River, NJ', 6, '2023-09-13 08:38:18'),
(1206, 302, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 823 Tall Oak Trail', 6, '2023-09-13 08:38:57'),
(1207, 282, 172, '0', 'Get task', 'Get task mới', 21, '2023-09-13 08:39:21'),
(1208, 303, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4039 Oak Grove Rd', 6, '2023-09-13 08:39:25'),
(1209, 282, 171, '0', 'Get task', 'Get task mới', 19, '2023-09-13 08:40:21'),
(1210, 283, 168, '0', 'Get task', 'Get task mới', 48, '2023-09-13 08:41:49'),
(1211, 304, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 444 Nahua Condos, Waikiki', 6, '2023-09-13 08:42:48'),
(1212, 295, 174, '0', 'Get task', 'Get task mới', 26, '2023-09-13 08:43:13'),
(1213, 294, 175, '0', 'Get task', 'Get task mới', 11, '2023-09-13 08:50:49'),
(1214, 279, 176, '0', 'Get task', 'Get task mới', 29, '2023-09-13 08:53:49'),
(1215, 296, 179, '0', 'Get task', 'Get task mới', 16, '2023-09-13 08:54:04'),
(1216, 290, 180, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-13 09:00:13'),
(1217, 293, 181, '0', 'Get task', 'Get task mới', 20, '2023-09-13 09:05:31'),
(1218, 290, 180, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'35\'', 13, '2023-09-13 09:05:38'),
(1219, 290, 180, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-13 09:05:49'),
(1220, 290, 180, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-13 09:05:49'),
(1221, 279, 177, '0', 'Get task', 'Get task mới', 50, '2023-09-13 09:14:02'),
(1222, 282, 172, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-13 09:14:12'),
(1223, 282, 172, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 21, '2023-09-13 09:14:12'),
(1224, 282, 172, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 21, '2023-09-13 09:14:12'),
(1225, 275, 165, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'50\'', 22, '2023-09-13 09:37:37'),
(1226, 275, 165, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-13 09:37:37'),
(1227, 275, 165, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-13 09:37:37'),
(1228, 275, 165, '0', 'Get task', 'Get task mới', 50, '2023-09-13 09:43:47'),
(1229, 275, 165, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-13 09:44:17'),
(1230, 282, 171, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'20\'', 19, '2023-09-13 10:18:47'),
(1231, 282, 171, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 19, '2023-09-13 10:18:47'),
(1232, 282, 171, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 19, '2023-09-13 10:18:47'),
(1233, 282, 171, '0', 'Get task', 'Get task mới', 9, '2023-09-13 10:43:50'),
(1234, 305, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 763 Tudor Ln, Youngstown, OH 44512,', 6, '2023-09-13 10:45:22'),
(1235, 282, 171, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-13 10:45:37'),
(1236, 306, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 5307 BOWLINE BEND, NEW PORT RICHEY, FL 34652', 6, '2023-09-13 10:46:12'),
(1237, 307, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 27100 Island View Ct CA, Santa Clarita, Los Angeles 91355', 6, '2023-09-13 10:47:05'),
(1238, 307, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Photo HDR        57\\nhttps://imaging.hommati.cloud/widget/download/editing-team/28316729  \\n\\nTwilight Images - 2         https://imaging.hommati.cloud/widget/download/editing-team/28316729 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:20,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:87}{&quot;1&quot;:112,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:179}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:20,&quot;2&quot;:&quot;https://imaging.hommati.cloud/widget/download/editing-team/28316729&quot;}{&quot;1&quot;:87}{&quot;1&quot;:112,&quot;2&quot;:&quot;https://imaging.hommati.cloud/widget/download/editing-team/28316729&quot;}{&quot;1&quot;:179}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Photo HDR 57<br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://imaging.hommati.cloud/widget/download/editing-team/28316729\">https://imaging.hommati.cloud/widget/download/editing-team/28316729</a></span><span style=\"font-size: 14pt;\"><br><br>Twilight Images - 2 </span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://imaging.hommati.cloud/widget/download/editing-team/28316729\">https://imaging.hommati.cloud/widget/download/editing-team/2</a></span><span style=\"font-size: 14pt;\">8316729</span></span>											\' to \'						<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;Photo HDR        57\\nhttps://imaging.hommati.cloud/widget/download/editing-team/28316729  \\n\\nTwilight Images - 2         https://imaging.hommati.cloud/widget/download/editing-team/28316729 &quot;}\" data-sheets-userformat=\"{&quot;2&quot;:1061885,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14,&quot;23&quot;:1}\" data-sheets-textstyleruns=\"{&quot;1&quot;:0}{&quot;1&quot;:20,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:87}{&quot;1&quot;:112,&quot;2&quot;:{&quot;2&quot;:{&quot;1&quot;:2,&quot;2&quot;:1136076},&quot;9&quot;:1}}{&quot;1&quot;:179}\" data-sheets-hyperlinkruns=\"{&quot;1&quot;:20,&quot;2&quot;:&quot;https://imaging.hommati.cloud/widget/download/editing-team/28316729&quot;}{&quot;1&quot;:87}{&quot;1&quot;:112,&quot;2&quot;:&quot;https://imaging.hommati.cloud/widget/download/editing-team/28316729&quot;}{&quot;1&quot;:179}\" style=\"color: rgb(0, 0, 0); font-size: 14pt; font-family: Arial;\"><span style=\"font-size: 14pt;\">Photo HDR 57<br></span><span style=\"font-size: 14pt; text-decoration-line: underline; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" target=\"_blank\" href=\"https://imaging.hommati.cloud/widget/download/editing-team/28316729\">https://imaging.hommati.cloud/widget/download/editing-team/28316729</a></span><span style=\"font-size: 14pt;\"><br><br><br></span></span>\'', 6, '2023-09-13 10:47:36'),
(1239, 307, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    \' to \'                                                                        \'', 6, '2023-09-13 10:47:36'),
(1240, 308, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 	 27100 Island View Ct CA, Santa Clarita, Los Angeles 91355', 6, '2023-09-13 10:49:50'),
(1241, 309, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 11814 Coldstream Dr. Potomac, MD 20854 Project 1', 6, '2023-09-13 10:50:47'),
(1242, 310, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 11814 Coldstream Dr. Potomac, MD 20854 Project 2', 6, '2023-09-13 10:51:20'),
(1243, 311, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 11814 Coldstream Dr. Potomac, MD 20854 Project 3', 6, '2023-09-13 10:51:57'),
(1244, 298, 184, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-13 10:52:53'),
(1245, 298, 185, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-13 10:53:50'),
(1246, 298, 185, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'cuong.nq\'', 3, '2023-09-13 10:53:50'),
(1247, 293, 182, '0', 'Get task', 'Get task mới', 9, '2023-09-13 10:54:01'),
(1248, 295, 187, NULL, 'Insert Task', 'Tạo Task mới', NULL, '2023-09-13 10:59:41'),
(1249, 299, 186, '0', 'Get task', 'Get task mới', 17, '2023-09-13 11:00:42'),
(1250, 295, 188, NULL, 'Insert Task', 'Tạo Task mới', 26, '2023-09-13 11:01:15'),
(1251, 295, 189, NULL, 'Insert Task', 'Tạo Task mới', 26, '2023-09-13 11:02:35'),
(1252, 295, 189, '0', 'Get task', 'Get task mới', 50, '2023-09-13 11:04:06'),
(1253, 275, 165, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 22, '2023-09-13 11:05:50'),
(1254, 275, 165, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-13 11:05:50'),
(1255, 295, 189, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'chu.dv\' sang \'binh.pn\'', 3, '2023-09-13 11:07:12'),
(1256, 302, 190, '0', 'Get task', 'Get task mới', 12, '2023-09-13 11:09:02'),
(1257, 290, 180, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 13, '2023-09-13 11:10:59'),
(1258, 295, 189, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-13 11:13:26'),
(1259, 303, 191, '0', 'Get task', 'Get task mới', 22, '2023-09-13 11:24:11'),
(1260, 295, 193, NULL, 'Insert Task', 'Tạo Task mới', 26, '2023-09-13 11:34:27'),
(1261, 283, 169, '0', 'Get task', 'Get task mới', 49, '2023-09-13 11:42:00'),
(1262, 312, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 149 Columbia Ave, Brunswick ME', 8, '2023-09-13 11:45:34'),
(1263, 313, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: \"16 Spring Street, Mechanic Falls, ME \"', 8, '2023-09-13 11:46:18'),
(1264, 275, 165, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-13 12:00:40'),
(1265, 296, 179, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'53\'', 16, '2023-09-13 12:03:27'),
(1266, 296, 179, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 16, '2023-09-13 12:03:27'),
(1267, 296, 179, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 16, '2023-09-13 12:03:27'),
(1268, 304, 194, '0', 'Get task', 'Get task mới', 16, '2023-09-13 12:05:05'),
(1269, 304, 195, '0', 'Get task', 'Get task mới', 50, '2023-09-13 12:14:56'),
(1270, 296, 179, '0', 'Get task', 'Get task mới', 50, '2023-09-13 12:15:08'),
(1271, 296, 179, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-13 12:16:10'),
(1272, 296, 179, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 16, '2023-09-13 12:24:36'),
(1273, 296, 179, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 16, '2023-09-13 12:24:36'),
(1274, 305, 192, '0', 'Get task', 'Get task mới', 15, '2023-09-13 12:30:03'),
(1275, 281, 197, '0', 'Get task', 'Get task mới', 36, '2023-09-13 12:57:20'),
(1276, 295, 187, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 36, '2023-09-13 13:04:43'),
(1277, 295, 187, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'\' sang \'binh.pn\'', 3, '2023-09-13 13:06:57'),
(1278, 295, 187, NULL, 'Update Task', 'Field \'idlevel\' Thay đổi từ \'0\' to \'\'', 3, '2023-09-13 13:06:57'),
(1279, 295, 188, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'\' sang \'binh.pn\'', 3, '2023-09-13 13:07:04'),
(1280, 295, 188, NULL, 'Update Task', 'Field \'idlevel\' Thay đổi từ \'0\' to \'\'', 3, '2023-09-13 13:07:04'),
(1281, 295, 193, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'\' sang \'binh.pn\'', 3, '2023-09-13 13:07:12'),
(1282, 295, 174, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-13 13:07:21'),
(1283, 295, 174, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'\' sang \'binh.pn\'', 3, '2023-09-13 13:07:21'),
(1284, 295, 187, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-13 13:07:46'),
(1285, 295, 188, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'0\'', 9, '2023-09-13 13:07:56'),
(1286, 295, 187, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 36, '2023-09-13 13:08:16'),
(1287, 295, 187, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 36, '2023-09-13 13:08:16'),
(1288, 299, 186, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'35\'', 17, '2023-09-13 13:08:46'),
(1289, 299, 186, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-13 13:08:46'),
(1290, 299, 186, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-13 13:08:46'),
(1291, 307, 199, '0', 'Get task', 'Get task mới', 17, '2023-09-13 13:08:50'),
(1292, 295, 189, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 26, '2023-09-13 13:09:03'),
(1293, 295, 189, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 26, '2023-09-13 13:09:03'),
(1294, 295, 193, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 26, '2023-09-13 13:09:20'),
(1295, 295, 187, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'23\' thành \'18\'', 36, '2023-09-13 13:11:19'),
(1296, 296, 179, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-13 13:11:30'),
(1297, 314, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: OUTLINE THE SCENES IN VIDEO 135 CONCORD', 8, '2023-09-13 13:16:59'),
(1298, 314, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'0\' to \'111\'', 8, '2023-09-13 13:17:16'),
(1299, 314, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"&nbsp; I REALLY WOULD LIKE TO FOR YOU TO DO ONE THING ON THIS PROJECT FOR ME. ALL I NEED IS THE VIDEO OUTLINED LIKE YOU DID FOR ME BEFORE. I HAVE THE SCENES WHERE I WANT YOU TO OULINE SO THE VIEWERS CAN SEE WHICH IS THE PROPERTY FROM ABOVE. I HAVE ATTACHED A PICTURE OF THE OUTLINED PROPERTY TO SHOW YOU WHATMI NEED DONE.... THE VIDEO CLIPS I NEED OUTLINED ARE: CLIP 2, 4, 7, 8, 9, 11, 13, 14, 15.&nbsp; I HAD COUNTED THEM ALL. THANK YOU.&nbsp; LINK TO VIDEO</div><div><br></div><div>https://drive.google.com/drive/folders/1o1EiSy5NkPs47Qe_JhiyR4VGz_t8QIpN?usp=sharing&nbsp;</div><div>dk https://drive.google.com/drive/folders/1JjwjWNKHxSSiD_Ktp4rv9x2eFcxnts3D?usp=sharing \"</div>											\' to \'						<div>\"&nbsp; I REALLY WOULD LIKE TO FOR YOU TO DO ONE THING ON THIS PROJECT FOR ME. ALL I NEED IS THE VIDEO OUTLINED LIKE YOU DID FOR ME BEFORE. I HAVE THE SCENES WHERE I WANT YOU TO OULINE SO THE VIEWERS CAN SEE WHICH IS THE PROPERTY FROM ABOVE. I HAVE ATTACHED A PICTURE OF THE OUTLINED PROPERTY TO SHOW YOU WHATMI NEED DONE.... THE VIDEO CLIPS I NEED OUTLINED ARE: CLIP 2, 4, 7, 8, 9, 11, 13, 14, 15.&nbsp; I HAD COUNTED THEM ALL. THANK YOU.&nbsp; LINK TO VIDEO</div><div><br></div><div>https://drive.google.com/drive/folders/1o1EiSy5NkPs47Qe_JhiyR4VGz_t8QIpN?usp=sharing&nbsp;</div><div>dk https://drive.google.com/drive/folders/1JjwjWNKHxSSiD_Ktp4rv9x2eFcxnts3D?usp=sharing \"</div>																\'', 8, '2023-09-13 13:17:16'),
(1300, 314, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \' I REALLY WOULD LIKE TO FOR YOU TO DO ONE THING ON THIS PROJECT FOR ME. ALL I NEED IS THE VIDEO OUTLINED LIKE YOU DID FOR ME BEFORE. I HAVE THE SCENES WHERE I WANT YOU TO OULINE SO THE VIEWERS CAN SEE WHICH IS THE PROPERTY FROM ABOVE. I HAVE ATTACHED A PICTURE OF THE OUTLINED PROPERTY TO SHOW YOU WHATMI NEED DONE.... THE VIDEO CLIPS I NEED OUTLINED ARE: CLIP 2, 4, 7, 8, 9, 11, 13, 14, 15.  I HAD COUNTED THEM ALL. THANK YOU.  LINK TO VIDEO\r\n\r\n                               \' to \'                     I REALLY WOULD LIKE TO FOR YOU TO DO ONE THING ON THIS PROJECT FOR ME. ALL I NEED IS THE VIDEO OUTLINED LIKE YOU DID FOR ME BEFORE. I HAVE THE SCENES WHERE I WANT YOU TO OULINE SO THE VIEWERS CAN SEE WHICH IS THE PROPERTY FROM ABOVE. I HAVE ATTACHED A PICTURE OF THE OUTLINED PROPERTY TO SHOW YOU WHATMI NEED DONE.... THE VIDEO CLIPS I NEED OUTLINED ARE: CLIP 2, 4, 7, 8, 9, 11, 13, 14, 15.  I HAD COUNTED THEM ALL. THANK YOU.  LINK TO VIDEO\r\n\r\n                                               \'', 8, '2023-09-13 13:17:16'),
(1301, 295, 189, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'23\' thành \'0\'', 3, '2023-09-13 13:17:27'),
(1302, 295, 189, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'1\'', 26, '2023-09-13 13:17:49'),
(1303, 295, 189, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 26, '2023-09-13 13:17:49'),
(1304, 295, 187, NULL, 'Update Task', 'Field \'idlevel\' Thay đổi từ \'0\' to \'1\'', 3, '2023-09-13 13:20:40'),
(1305, 313, NULL, NULL, 'Update Project', 'Field \'name\' Thay đổi từ \'\"16 Spring Street, Mechanic Falls, ME \"\' to \'16 Spring Street, Mechanic Falls, ME\'', 1, '2023-09-13 13:26:33'),
(1306, 313, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"https://drive.google.com/drive/folders/1v-JnyFFUgmRdpPLIs9ELQ7qSpQTTPoZR?usp=drive_link</div><div><br></div><div>DTE = DJI_0094-DJI_0098</div><div>&nbsp;</div><div><br></div><div>INPUT FILE COUNTS:</div><div><br></div><div>&nbsp;</div><div><br></div><div>5X DJI = 125</div><div><br></div><div>5X SONY = 294</div><div><br></div><div>VIDEO FILES = 25</div><div><br></div><div>&nbsp;</div><div><br></div><div>EDITOR CHOOSE MUSIC</div><div><br></div><div>NO HOMMATI SPLASH PAGE</div><div><br></div><div>*STABILIZE WINDY/BOUNCY CLIPS*</div><div><br></div><div>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP</div><div><br></div><div>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**</div><div><br></div><div>&nbsp;</div><div><br></div><div>NOTES:&nbsp;</div><div><br></div><div>Exterior sky replacement = YES (please use appropriate sky)</div><div><br></div><div>Interior sky replacement = YES</div><div><br></div><div>Correct Lens Distortion on SONY files</div><div><br></div><div>Level horizon on DJI files</div><div><br></div><div>Resize to 3,000 x 2,000 pixels\"</div>											\' to \'						<div>\"https://drive.google.com/drive/folders/1v-JnyFFUgmRdpPLIs9ELQ7qSpQTTPoZR?usp=drive_link</div><div><br></div><div>DTE = DJI_0094-DJI_0098</div><div>&nbsp;</div><div><br></div><div>INPUT FILE COUNTS:</div><div><br></div><div>&nbsp;</div><div><br></div><div>5X DJI = 125</div><div><br></div><div>5X SONY = 294</div><div><br></div><div>VIDEO FILES = 25</div><div><br></div><div>&nbsp;</div><div><br></div><div>EDITOR CHOOSE MUSIC</div><div><br></div><div>NO HOMMATI SPLASH PAGE</div><div><br></div><div>*STABILIZE WINDY/BOUNCY CLIPS*</div><div><br></div><div>REDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP</div><div><br></div><div>**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**</div><div><br></div><div>&nbsp;</div><div><br></div><div>NOTES:&nbsp;</div><div><br></div><div>Exterior sky replacement = YES (please use appropriate sky)</div><div><br></div><div>Interior sky replacement = YES</div><div><br></div><div>Correct Lens Distortion on SONY files</div><div><br></div><div>Level horizon on DJI files</div><div><br></div><div>Resize to 3,000 x 2,000 pixels\"</div>																\'', 1, '2023-09-13 13:26:33'),
(1307, 313, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'\r\n\r\nDTE = DJI_0094-DJI_0098\r\n \r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 125\r\n\r\n5X SONY = 294\r\n\r\nVIDEO FILES = 25\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES (please use appropriate sky)\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    \' to \'                    \r\n\r\nDTE = DJI_0094-DJI_0098\r\n \r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 125\r\n\r\n5X SONY = 294\r\n\r\nVIDEO FILES = 25\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES (please use appropriate sky)\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                                    \'', 1, '2023-09-13 13:26:33'),
(1308, 313, 200, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-13 13:26:50'),
(1309, 313, 200, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'thien.pd\'', 1, '2023-09-13 13:26:50'),
(1310, 298, 185, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 25, '2023-09-13 13:30:43'),
(1311, 298, 185, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 25, '2023-09-13 13:30:43'),
(1312, 298, 184, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 25, '2023-09-13 13:30:52'),
(1313, 298, 184, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 25, '2023-09-13 13:30:52'),
(1314, 312, 203, '0', 'Get task', 'Get task mới', 25, '2023-09-13 13:30:56'),
(1315, 294, 175, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'60\'', 11, '2023-09-13 13:32:31'),
(1316, 294, 175, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-13 13:32:44'),
(1317, 294, 175, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-13 13:32:44'),
(1318, 312, 203, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'52\'', 25, '2023-09-13 13:34:30'),
(1319, 298, 185, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'31\'', 25, '2023-09-13 13:34:38'),
(1320, 295, 189, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'0\'', 26, '2023-09-13 13:40:12'),
(1321, 314, 0, '0', 'Delete Project', 'OUTLINE THE SCENES IN VIDEO 135 CONCORD', 8, '2023-09-13 13:59:06'),
(1322, 305, 192, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'30\'', 15, '2023-09-13 14:06:13'),
(1323, 305, 192, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-13 14:06:13'),
(1324, 305, 192, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-13 14:06:13'),
(1325, 309, 207, '0', 'Get task', 'Get task mới', 15, '2023-09-13 14:06:17'),
(1326, 283, 169, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 49, '2023-09-13 14:11:46'),
(1327, 303, 191, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'55\'', 22, '2023-09-13 14:29:32'),
(1328, 303, 191, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-13 14:29:32'),
(1329, 303, 191, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-13 14:29:32'),
(1330, 311, 208, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-13 14:41:07'),
(1331, 311, 208, NULL, 'Update Task', 'Field \'status\' Thay đổi từ \'0\' to \'1\'', 3, '2023-09-13 14:41:07'),
(1332, 311, 208, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'thien.pd\'', 3, '2023-09-13 14:41:07'),
(1333, 311, 208, NULL, 'Update Task', 'Field \'idlevel\' Thay đổi từ \'1\' to \'3\'', 3, '2023-09-13 14:41:07'),
(1334, 311, 208, NULL, 'Update Task', 'Field \'soluong\' Thay đổi từ \'0\' to \'15\'', 3, '2023-09-13 14:41:07'),
(1335, 311, 208, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'\' sang \'dung.ha\'', 3, '2023-09-13 14:41:26'),
(1336, 299, 186, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 17, '2023-09-13 14:45:28'),
(1337, 306, 209, '0', 'Get task', 'Get task mới', 22, '2023-09-13 14:52:37'),
(1338, 310, 212, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-13 14:52:43'),
(1339, 295, 187, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 9, '2023-09-13 15:23:31'),
(1340, 295, 193, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 9, '2023-09-13 15:23:41'),
(1341, 293, 182, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-13 15:24:03'),
(1342, 293, 182, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-13 15:24:03'),
(1343, 293, 182, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-13 15:24:03'),
(1344, 315, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1542 Timber Dr, Helena, AL 35080', 8, '2023-09-13 16:00:42'),
(1345, 312, 203, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 25, '2023-09-13 16:06:25'),
(1346, 312, 203, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 25, '2023-09-13 16:06:25'),
(1347, 311, 208, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 49, '2023-09-13 16:15:22'),
(1348, 310, 212, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 49, '2023-09-13 16:15:32'),
(1349, 294, 175, '0', 'Get task', 'Get task mới', 49, '2023-09-13 16:15:35'),
(1350, 294, 175, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 49, '2023-09-13 16:15:52'),
(1351, 303, 191, '0', 'Get task', 'Get task mới', 49, '2023-09-13 16:15:56'),
(1352, 303, 191, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'0\'', 49, '2023-09-13 16:16:04'),
(1353, 303, 191, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 49, '2023-09-13 16:16:14'),
(1354, 302, 190, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'073\'', 12, '2023-09-13 16:16:33'),
(1355, 302, 190, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 12, '2023-09-13 16:16:44'),
(1356, 302, 190, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 12, '2023-09-13 16:16:44'),
(1357, 312, 203, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 25, '2023-09-13 16:19:53'),
(1358, 305, 192, '0', 'Get task', 'Get task mới', 49, '2023-09-13 16:23:55'),
(1359, 307, 199, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'57\'', 17, '2023-09-13 16:27:37'),
(1360, 307, 199, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-13 16:27:37'),
(1361, 307, 199, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-13 16:27:37'),
(1362, 307, 199, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 17, '2023-09-13 16:36:58'),
(1363, 275, 165, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:39:47'),
(1364, 293, 182, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:39:57'),
(1365, 294, 175, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:40:36'),
(1366, 282, 172, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:41:22'),
(1367, 295, 193, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:41:35'),
(1368, 295, 187, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:41:44'),
(1369, 296, 179, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:42:12'),
(1370, 303, 191, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:42:20'),
(1371, 310, 212, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:42:28'),
(1372, 311, 208, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-13 16:42:35'),
(1373, 283, 168, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'29\'', 48, '2023-09-13 16:58:14'),
(1374, 283, 168, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 48, '2023-09-13 16:58:14'),
(1375, 283, 168, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 48, '2023-09-13 16:58:14'),
(1376, 306, 209, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'40\'', 22, '2023-09-13 17:27:52'),
(1377, 306, 209, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-13 17:27:52'),
(1378, 306, 209, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 22, '2023-09-13 17:28:06'),
(1379, 313, 213, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-13 19:17:56'),
(1380, 299, 186, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-13 19:24:20'),
(1381, 283, 168, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-13 19:25:46'),
(1382, 290, 180, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-13 19:26:47'),
(1383, 298, 184, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'10\'', 3, '2023-09-13 19:28:38'),
(1384, 298, 185, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'6\'', 3, '2023-09-13 19:29:12');
INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(1385, 298, 185, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'6\' thành \'7\'', 3, '2023-09-13 19:29:37'),
(1386, 293, 183, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 3, '2023-09-13 19:31:52'),
(1387, 293, 183, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 19:31:52'),
(1388, 293, 181, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 19:35:39'),
(1389, 316, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 11814 Coldstream Dr. Potomac, MD 20854 Project 6', 8, '2023-09-13 19:40:09'),
(1390, 317, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 82 Greencastle Dr Southern Pines NC', 8, '2023-09-13 21:22:06'),
(1391, 295, 215, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-13 21:45:39'),
(1392, 295, 216, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-13 21:46:00'),
(1393, 295, 217, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-13 21:47:03'),
(1394, 295, 218, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-13 21:48:54'),
(1395, 295, 219, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-13 21:49:35'),
(1396, 295, 220, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-13 21:50:03'),
(1397, 295, 221, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-13 21:56:31'),
(1398, 295, 222, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-13 21:57:09'),
(1399, 295, 223, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-13 21:59:29'),
(1400, 295, 224, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-13 22:00:49'),
(1401, 295, 225, NULL, 'Insert Task', 'Tạo Task mới', 9, '2023-09-13 22:02:05'),
(1402, 318, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2111 River Turia Cir, Riverview FL ', 8, '2023-09-13 22:22:58'),
(1403, 319, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1119 Montcalm St NC, Charlotte, Mecklenburg 28208', 8, '2023-09-13 22:44:16'),
(1404, 316, 214, '0', 'Get task', 'Get task mới', 41, '2023-09-13 23:07:51'),
(1405, 316, 214, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 23:10:52'),
(1406, 312, 204, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-13 23:11:43'),
(1407, 317, 226, '0', 'Get task', 'Get task mới', 24, '2023-09-13 23:12:10'),
(1408, 317, 226, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 24, '2023-09-13 23:12:59'),
(1409, 317, 226, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 24, '2023-09-13 23:12:59'),
(1410, 317, 226, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'0\'', 24, '2023-09-13 23:13:56'),
(1411, 317, 226, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'100\'', 24, '2023-09-13 23:14:58'),
(1412, 317, 226, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 24, '2023-09-13 23:15:09'),
(1413, 317, 226, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'1\'', 24, '2023-09-13 23:15:35'),
(1414, 318, 227, '0', 'Get task', 'Get task mới', 45, '2023-09-13 23:26:50'),
(1415, 318, 228, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-13 23:29:20'),
(1416, 318, 228, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'2\'', 52, '2023-09-13 23:49:33'),
(1417, 320, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1825 Beach Blvd NJ, Point Pleasant, Ocean 08742', 7, '2023-09-14 00:43:04'),
(1418, 320, 229, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-14 00:43:48'),
(1419, 321, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: St Augustine Ocean & Raquet Club', 7, '2023-09-14 00:44:01'),
(1420, 322, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Vacant land Main Street Armada', 7, '2023-09-14 00:44:38'),
(1421, 323, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 743 Pineborough Rd NC, Charlotte, Mecklenburg 28212', 7, '2023-09-14 00:45:20'),
(1422, 324, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6031 Heckert Road OH, Westerville, Franklin 43081', 7, '2023-09-14 00:46:21'),
(1423, 325, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Photo edit for 525 3rd St Jax beach', 7, '2023-09-14 00:46:56'),
(1424, 321, 230, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-14 00:59:57'),
(1425, 321, 231, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-14 01:01:12'),
(1426, 326, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 13810 Rockhaven Dr. Chester, VA', 7, '2023-09-14 01:15:02'),
(1427, 325, 232, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-14 01:17:05'),
(1428, 327, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: ', 7, '2023-09-14 01:18:25'),
(1429, 327, NULL, NULL, 'Update Project', 'Field \'name\' Thay đổi từ \'\' to \'906 Forest Hills Drive SW Rochester, MN\'', 7, '2023-09-14 01:18:43'),
(1430, 327, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7											\' to \'						https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7																\'', 7, '2023-09-14 01:18:43'),
(1431, 327, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7\' to \'                    https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7                \'', 7, '2023-09-14 01:18:43'),
(1432, 328, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2610 Ridgewood Court SE Rochester, MN', 7, '2023-09-14 01:25:42'),
(1433, 329, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: ', 7, '2023-09-14 01:26:07'),
(1434, 329, NULL, NULL, 'Update Project', 'Field \'name\' Thay đổi từ \'\' to \'3918 Spring Valley Rd, Birmingham, AL 35223        \'', 7, '2023-09-14 01:41:55'),
(1435, 329, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve;\">3918 Spring Valley Rd, Birmingham, AL 35223        </span>											\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve;\">3918 Spring Valley Rd, Birmingham, AL 35223        </span>																\'', 7, '2023-09-14 01:41:55'),
(1436, 329, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    3918 Spring Valley Rd, Birmingham, AL 35223        \' to \'                                                        3918 Spring Valley Rd, Birmingham, AL 35223                        \'', 7, '2023-09-14 01:41:55'),
(1437, 329, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve;\">3918 Spring Valley Rd, Birmingham, AL 35223        </span>																\' to \'<font color=\"#000000\" face=\"Arial\"><span style=\"font-size: 14px; white-space-collapse: preserve;\">https://imaging.hommati.cloud/widget/download/editing-team/28324230</span></font>\'', 7, '2023-09-14 01:42:18'),
(1438, 329, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                                        3918 Spring Valley Rd, Birmingham, AL 35223                        \' to \'https://imaging.hommati.cloud/widget/download/editing-team/28324230\'', 7, '2023-09-14 01:42:18'),
(1439, 326, 233, '0', 'Get task', 'Get task mới', 32, '2023-09-14 01:58:28'),
(1440, 326, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<a href=\"https://drive.google.com/drive/folders/1LuytcyerPlH7Bkz5P9Q4cMOA_YFOKhrP?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1LuytcyerPlH7Bkz5P9Q4cMOA_YFOKhrP?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nDrone Pictures\r\n\r\n \r\n\r\n</span><a href=\"https://drive.google.com/drive/folders/1WewUV9m9kn_FncAtD0wUktWee8dOkesT?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1WewUV9m9kn_FncAtD0wUktWee8dOkesT?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nDrone Videos\r\n\r\n \r\n\r\n</span><a href=\"https://drive.google.com/drive/folders/1Rhfk4ZjceqcDvHtAHepHWzBfabffITSK?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1Rhfk4ZjceqcDvHtAHepHWzBfabffITSK?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\n2D Photographs</span>											\' to \'						<a href=\"https://drive.google.com/drive/folders/1LuytcyerPlH7Bkz5P9Q4cMOA_YFOKhrP?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1LuytcyerPlH7Bkz5P9Q4cMOA_YFOKhrP?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nDrone Pictures\r\n\r\n \r\n\r\n</span><a href=\"https://drive.google.com/drive/folders/1WewUV9m9kn_FncAtD0wUktWee8dOkesT?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1WewUV9m9kn_FncAtD0wUktWee8dOkesT?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nDrone Videos\r\n\r\n \r\n\r\n</span><a href=\"https://drive.google.com/drive/folders/1Rhfk4ZjceqcDvHtAHepHWzBfabffITSK?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1Rhfk4ZjceqcDvHtAHepHWzBfabffITSK?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\n2D Photographs</span>																\'', 7, '2023-09-14 02:01:17'),
(1441, 326, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    https://drive.google.com/drive/folders/1LuytcyerPlH7Bkz5P9Q4cMOA_YFOKhrP?usp=drive_link \r\n\r\nDrone Pictures\r\n\r\n \r\n\r\nhttps://drive.google.com/drive/folders/1WewUV9m9kn_FncAtD0wUktWee8dOkesT?usp=drive_link \r\n\r\nDrone Videos\r\n\r\n \r\n\r\nhttps://drive.google.com/drive/folders/1Rhfk4ZjceqcDvHtAHepHWzBfabffITSK?usp=drive_link \r\n\r\n2D Photographs\' to \'                                                        https://drive.google.com/drive/folders/1LuytcyerPlH7Bkz5P9Q4cMOA_YFOKhrP?usp=drive_link \r\n\r\nDrone Pictures\r\n\r\n \r\n\r\nhttps://drive.google.com/drive/folders/1WewUV9m9kn_FncAtD0wUktWee8dOkesT?usp=drive_link \r\n\r\nDrone Videos\r\n\r\n \r\n\r\nhttps://drive.google.com/drive/folders/1Rhfk4ZjceqcDvHtAHepHWzBfabffITSK?usp=drive_link \r\n\r\n2D Photographs                \'', 7, '2023-09-14 02:01:17'),
(1442, 326, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'1,3,8,10\' to \'1,8,10\'', 7, '2023-09-14 02:01:17'),
(1443, 327, 237, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-14 02:13:00'),
(1444, 328, 238, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-14 02:13:31'),
(1445, 329, 239, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-14 03:42:40'),
(1446, 330, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 50 Graystone Dr, Covington, GA 30014', 7, '2023-09-14 06:41:34'),
(1447, 331, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1817 Carmen Ct Junction City KS', 7, '2023-09-14 06:42:13'),
(1448, 332, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Photo edits for 8844 Heavengate Ln', 7, '2023-09-14 06:53:47'),
(1449, 333, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: COVENTRY EDIT', 7, '2023-09-14 06:54:25'),
(1450, 334, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 155 School Street, Berwick ME', 7, '2023-09-14 06:55:52'),
(1451, 335, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 602 Woodman Hill Road, Minot ME', 7, '2023-09-14 06:57:57'),
(1452, 336, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: ', 7, '2023-09-14 06:58:43'),
(1453, 336, NULL, NULL, 'Update Project', 'Field \'name\' Thay đổi từ \'\' to \'296 Trice Ln, Crawfordville, FL 32327\'', 7, '2023-09-14 06:58:54'),
(1454, 336, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">90 photos\r\n\r\n</span><a href=\"https://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\r\n\r\n</span>											\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">90 photos\r\n\r\n</span><a href=\"https://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\r\n\r\n</span>																\'', 7, '2023-09-14 06:58:54'),
(1455, 336, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    90 photos\r\n\r\nhttps://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\r\n\r\n\' to \'                                                        90 photos\r\n\r\nhttps://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\r\n\r\n                \'', 7, '2023-09-14 06:58:54'),
(1456, 337, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: MEADOW ASH EDIT', 7, '2023-09-14 06:59:25'),
(1457, 325, 232, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'26\'', 44, '2023-09-14 07:05:19'),
(1458, 325, 232, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 44, '2023-09-14 07:05:19'),
(1459, 325, 232, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 44, '2023-09-14 07:05:19'),
(1460, 338, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 5307 Bowline Bend PT2', 7, '2023-09-14 07:09:34'),
(1461, 295, 189, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-14 07:16:52'),
(1462, 298, 184, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-14 07:17:07'),
(1463, 302, 190, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-14 07:17:14'),
(1464, 306, 209, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-14 07:17:22'),
(1465, 307, 199, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-14 07:17:30'),
(1466, 282, 171, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'7\'', 3, '2023-09-14 07:17:39'),
(1467, 309, 207, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-14 07:17:52'),
(1468, 331, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --&gt; </span><a href=\"https://adobe.ly/3LnSgFo\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3LnSgFo</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --&gt; </span><a href=\"https://adobe.ly/3LnSgFo\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3LnSgFo</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>					\'', 8, '2023-09-14 07:27:21'),
(1469, 331, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --> https://adobe.ly/3LnSgFo \r\n\' to \'                    Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --> https://adobe.ly/3LnSgFo \r\n                \'', 8, '2023-09-14 07:27:21'),
(1470, 331, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:27:21'),
(1471, 337, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">I&#x2019;m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp &amp; crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\n</span><a href=\"https://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>											\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">I&#x2019;m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp &amp; crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\n</span><a href=\"https://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>																\'', 8, '2023-09-14 07:27:35'),
(1472, 337, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\nhttps://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&utm_campaign=TRN_TDL_01&utm_medium=email&utm_source=sendgrid \' to \'                                                        I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\nhttps://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&utm_campaign=TRN_TDL_01&utm_medium=email&utm_source=sendgrid                 \'', 8, '2023-09-14 07:27:35'),
(1473, 337, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:27:35'),
(1474, 337, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">I&#x2019;m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp &amp; crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\n</span><a href=\"https://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>																\' to \'												<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">I&#x2019;m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp &amp; crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\n</span><a href=\"https://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>																					\'', 8, '2023-09-14 07:27:44'),
(1475, 337, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                                        I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\nhttps://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&utm_campaign=TRN_TDL_01&utm_medium=email&utm_source=sendgrid                 \' to \'                                                                            I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\nhttps://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&utm_campaign=TRN_TDL_01&utm_medium=email&utm_source=sendgrid                                 \'', 8, '2023-09-14 07:27:44'),
(1476, 328, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<a href=\"https://photos.app.goo.gl/2KxQ5HiH5n9B2Ya36\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://photos.app.goo.gl/2KxQ5HiH5n9B2Ya36</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>\' to \'						<a href=\"https://photos.app.goo.gl/2KxQ5HiH5n9B2Ya36\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://photos.app.goo.gl/2KxQ5HiH5n9B2Ya36</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>					\'', 8, '2023-09-14 07:28:01'),
(1477, 328, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    https://photos.app.goo.gl/2KxQ5HiH5n9B2Ya36 \r\n\' to \'                                                        https://photos.app.goo.gl/2KxQ5HiH5n9B2Ya36 \r\n                \'', 8, '2023-09-14 07:28:01'),
(1478, 328, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:28:01'),
(1479, 332, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" </span><a href=\"https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" </span><a href=\"https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>					\'', 8, '2023-09-14 07:28:07'),
(1480, 332, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    \"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0 \r\n\' to \'                                                        \"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0 \r\n                \'', 8, '2023-09-14 07:28:07'),
(1481, 332, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:28:07'),
(1482, 332, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" </span><a href=\"https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>					\' to \'												<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" </span><a href=\"https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>										\'', 8, '2023-09-14 07:28:13'),
(1483, 332, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                                        \"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0 \r\n                \' to \'                                                                            \"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0 \r\n                                \'', 8, '2023-09-14 07:28:13'),
(1484, 331, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --&gt; </span><a href=\"https://adobe.ly/3LnSgFo\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3LnSgFo</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>					\' to \'												<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --&gt; </span><a href=\"https://adobe.ly/3LnSgFo\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3LnSgFo</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>										\'', 8, '2023-09-14 07:28:18'),
(1485, 331, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                    Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --> https://adobe.ly/3LnSgFo \r\n                \' to \'                                        Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --> https://adobe.ly/3LnSgFo \r\n                                \'', 8, '2023-09-14 07:28:18'),
(1486, 336, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">90 photos\r\n\r\n</span><a href=\"https://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\r\n\r\n</span>																\' to \'												<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">90 photos\r\n\r\n</span><a href=\"https://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\r\n\r\n</span>																					\'', 8, '2023-09-14 07:28:24'),
(1487, 336, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                                        90 photos\r\n\r\nhttps://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\r\n\r\n                \' to \'                                                                            90 photos\r\n\r\nhttps://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\r\n\r\n                                \'', 8, '2023-09-14 07:28:24'),
(1488, 336, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:28:24'),
(1489, 338, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">I had to return to this location to shoot this room today. 25 photos for 5307 Bowline Bend. \r\n\r\n\r\n</span><a href=\"https://adobe.ly/3Pjwzrf\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3Pjwzrf</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">I had to return to this location to shoot this room today. 25 photos for 5307 Bowline Bend. \r\n\r\n\r\n</span><a href=\"https://adobe.ly/3Pjwzrf\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3Pjwzrf</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><br></span></div>					\'', 8, '2023-09-14 07:28:32'),
(1490, 338, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    I had to return to this location to shoot this room today. 25 photos for 5307 Bowline Bend. \r\n\r\n\r\nhttps://adobe.ly/3Pjwzrf \r\n\' to \'                                                        I had to return to this location to shoot this room today. 25 photos for 5307 Bowline Bend. \r\n\r\n\r\nhttps://adobe.ly/3Pjwzrf \r\n                \'', 8, '2023-09-14 07:28:32'),
(1491, 338, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:28:32'),
(1492, 335, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<a href=\"https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 110\r\n\r\n5X SONY = 270\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels</span>											\' to \'						<a href=\"https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 110\r\n\r\n5X SONY = 270\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels</span>																\'', 8, '2023-09-14 07:28:38'),
(1493, 335, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 110\r\n\r\n5X SONY = 270\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\' to \'                    INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 110\r\n\r\n5X SONY = 270\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                \'', 8, '2023-09-14 07:28:38'),
(1494, 335, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:28:38'),
(1495, 334, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<a href=\"https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels</span>											\' to \'						<a href=\"https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels</span>																\'', 8, '2023-09-14 07:28:55'),
(1496, 334, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\' to \'                    INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                \'', 8, '2023-09-14 07:28:55'),
(1497, 334, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1,8,10\'', 8, '2023-09-14 07:28:55');
INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(1498, 333, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">I&#x2019;m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nThis home is newly built and very and VERY BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp &amp; crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n265 files . . . thank you\r\n\r\n</span><a href=\"https://staciemosley.wetransfer.com/downloads/7e0ce527a635e35f2562fe7fc2363ae420230913200051/456f796e1712da1b35d97644ed44b6a020230913200051/a78427?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://staciemosley.wetransfer.com/downloads/7e0ce527a635e35f2562fe7fc2363ae420230913200051/456f796e1712da1b35d97644ed44b6a020230913200051/a78427?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>											\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">I&#x2019;m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nThis home is newly built and very and VERY BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp &amp; crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n265 files . . . thank you\r\n\r\n</span><a href=\"https://staciemosley.wetransfer.com/downloads/7e0ce527a635e35f2562fe7fc2363ae420230913200051/456f796e1712da1b35d97644ed44b6a020230913200051/a78427?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://staciemosley.wetransfer.com/downloads/7e0ce527a635e35f2562fe7fc2363ae420230913200051/456f796e1712da1b35d97644ed44b6a020230913200051/a78427?trk=TRN_TDL_01&amp;utm_campaign=TRN_TDL_01&amp;utm_medium=email&amp;utm_source=sendgrid</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>																\'', 8, '2023-09-14 07:29:03'),
(1499, 333, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nThis home is newly built and very and VERY BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n265 files . . . thank you\r\n\' to \'                                                        I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nThis home is newly built and very and VERY BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n265 files . . . thank you\r\n                \'', 8, '2023-09-14 07:29:03'),
(1500, 333, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:29:03'),
(1501, 330, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<a href=\"https://adobe.ly/3PEoiQ0\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3PEoiQ0</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\nPhoto HDR , Aerial Video        35\r\n</span><a href=\"https://www.dropbox.com/t/NMpm3MXdqhtIxSNy\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/t/NMpm3MXdqhtIxSNy</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\nTwilight Images - 2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: </span><a href=\"https://www.dropbox.com/t/NMpm3MXdqhtIxSNy\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/t/NMpm3MXdqhtIxSNy</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\n\r\n</span>											\' to \'						<a href=\"https://adobe.ly/3PEoiQ0\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://adobe.ly/3PEoiQ0</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\nPhoto HDR , Aerial Video        35\r\n</span><a href=\"https://www.dropbox.com/t/NMpm3MXdqhtIxSNy\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/t/NMpm3MXdqhtIxSNy</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\nTwilight Images - 2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: </span><a href=\"https://www.dropbox.com/t/NMpm3MXdqhtIxSNy\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/t/NMpm3MXdqhtIxSNy</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\n\r\n</span>																\'', 8, '2023-09-14 07:29:19'),
(1502, 330, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    https://adobe.ly/3PEoiQ0 \r\nPhoto HDR , Aerial Video        35\r\nhttps://www.dropbox.com/t/NMpm3MXdqhtIxSNy \r\nTwilight Images - 2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: https://www.dropbox.com/t/NMpm3MXdqhtIxSNy \r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\n\r\n\' to \'                                                        https://adobe.ly/3PEoiQ0 \r\nPhoto HDR , Aerial Video        35\r\nhttps://www.dropbox.com/t/NMpm3MXdqhtIxSNy \r\nTwilight Images - 2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: https://www.dropbox.com/t/NMpm3MXdqhtIxSNy \r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\n\r\n                \'', 8, '2023-09-14 07:29:19'),
(1503, 330, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:29:19'),
(1504, 329, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<font color=\"#000000\" face=\"Arial\"><span style=\"font-size: 14px; white-space-collapse: preserve;\">https://imaging.hommati.cloud/widget/download/editing-team/28324230</span></font>\' to \'						<font color=\"#000000\" face=\"Arial\"><span style=\"font-size: 14px; white-space-collapse: preserve;\">https://imaging.hommati.cloud/widget/download/editing-team/28324230</span></font>					\'', 8, '2023-09-14 07:29:33'),
(1505, 329, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'https://imaging.hommati.cloud/widget/download/editing-team/28324230\' to \'                    https://imaging.hommati.cloud/widget/download/editing-team/28324230                \'', 8, '2023-09-14 07:29:33'),
(1506, 329, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:29:33'),
(1507, 321, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\"Hello, Here are the files to edit for the St Augustine Ocean &amp; Raquet Club. There are two units. Unit 5121 has 105 files. Unit 5324 has 110 files. Some files are still uploading to the folder. Thanks,\r\n</span><a href=\"https://www.dropbox.com/l/scl/AACMk8eCzucODKv0pm0huthniyPC1-IXYYM\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/l/scl/AACMk8eCzucODKv0pm0huthniyPC1-IXYYM</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>											\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\"Hello, Here are the files to edit for the St Augustine Ocean &amp; Raquet Club. There are two units. Unit 5121 has 105 files. Unit 5324 has 110 files. Some files are still uploading to the folder. Thanks,\r\n</span><a href=\"https://www.dropbox.com/l/scl/AACMk8eCzucODKv0pm0huthniyPC1-IXYYM\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/l/scl/AACMk8eCzucODKv0pm0huthniyPC1-IXYYM</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>																\'', 8, '2023-09-14 07:29:49'),
(1508, 321, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'\"Hello, Here are the files to edit for the St Augustine Ocean & Raquet Club. There are two units. Unit 5121 has 105 files. Unit 5324 has 110 files. Some files are still uploading to the folder. Thanks,\r\n\' to \'                    \"Hello, Here are the files to edit for the St Augustine Ocean & Raquet Club. There are two units. Unit 5121 has 105 files. Unit 5324 has 110 files. Some files are still uploading to the folder. Thanks,\r\n                \'', 8, '2023-09-14 07:29:49'),
(1509, 321, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:29:49'),
(1510, 327, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'						https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7																\' to \'												https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7																					\'', 8, '2023-09-14 07:29:59'),
(1511, 327, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                    https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7                \' to \'                                        https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7                                \'', 8, '2023-09-14 07:29:59'),
(1512, 327, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:29:59'),
(1513, 323, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve;\">Total number of images with changes: 0\r\n\r\nTotal number of images without changes: 3\r\n\r\nTotal number of twilight enhancement images: 0\r\n\r\nTotal number of blue sky/green grass enhancement images: 0\r\n\r\nGoogle Photos account link: https://photos.app.goo.gl/qqAYPggczPisGrtKA\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:Room names are located in the details section of the images in the link.\r\n\r\nOption\r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve;\"><br></span></div>\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve;\">Total number of images with changes: 0\r\n\r\nTotal number of images without changes: 3\r\n\r\nTotal number of twilight enhancement images: 0\r\n\r\nTotal number of blue sky/green grass enhancement images: 0\r\n\r\nGoogle Photos account link: https://photos.app.goo.gl/qqAYPggczPisGrtKA\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:Room names are located in the details section of the images in the link.\r\n\r\nOption\r\n</span>											<div><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve;\"><br></span></div>					\'', 8, '2023-09-14 07:30:15'),
(1514, 323, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'Total number of images with changes: 0\r\n\r\nTotal number of images without changes: 3\r\n\r\nTotal number of twilight enhancement images: 0\r\n\r\nTotal number of blue sky/green grass enhancement images: 0\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:Room names are located in the details section of the images in the link.\r\n\r\nOption\r\n\' to \'                    Total number of images with changes: 0\r\n\r\nTotal number of images without changes: 3\r\n\r\nTotal number of twilight enhancement images: 0\r\n\r\nTotal number of blue sky/green grass enhancement images: 0\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:Room names are located in the details section of the images in the link.\r\n\r\nOption\r\n                \'', 8, '2023-09-14 07:30:15'),
(1515, 323, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'9\'', 8, '2023-09-14 07:30:15'),
(1516, 322, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<a href=\"https://www.dropbox.com/scl/fi/9byeqga8bnj5gkaajv9nk/DJI_0816.JPG?rlkey=jms4ehcccrtdhnivi6d7wow07&amp;dl=0\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/scl/fi/9byeqga8bnj5gkaajv9nk/DJI_0816.JPG?rlkey=jms4ehcccrtdhnivi6d7wow07&amp;dl=0</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nGood afternoon. please find the attached photo link for Drone still shoots only. Please include property lines on photo 0814 vacant land is the wooded lot between the houses and the large adjacent behind the houses surrounded by trees. Also if possible please make only the vacant land in color on photo 0815 everything else black and white. any questions please call 586-663-0443  Thank you.  </span>											\' to \'						<a href=\"https://www.dropbox.com/scl/fi/9byeqga8bnj5gkaajv9nk/DJI_0816.JPG?rlkey=jms4ehcccrtdhnivi6d7wow07&amp;dl=0\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/scl/fi/9byeqga8bnj5gkaajv9nk/DJI_0816.JPG?rlkey=jms4ehcccrtdhnivi6d7wow07&amp;dl=0</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nGood afternoon. please find the attached photo link for Drone still shoots only. Please include property lines on photo 0814 vacant land is the wooded lot between the houses and the large adjacent behind the houses surrounded by trees. Also if possible please make only the vacant land in color on photo 0815 everything else black and white. any questions please call 586-663-0443  Thank you.  </span>																\'', 8, '2023-09-14 07:30:23'),
(1517, 322, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'Good afternoon. please find the attached photo link for Drone still shoots only. Please include property lines on photo 0814 vacant land is the wooded lot between the houses and the large adjacent behind the houses surrounded by trees. Also if possible please make only the vacant land in color on photo 0815 everything else black and white. any questions please call 586-663-0443  Thank you.  \' to \'                    Good afternoon. please find the attached photo link for Drone still shoots only. Please include property lines on photo 0814 vacant land is the wooded lot between the houses and the large adjacent behind the houses surrounded by trees. Also if possible please make only the vacant land in color on photo 0815 everything else black and white. any questions please call 586-663-0443  Thank you.                  \'', 8, '2023-09-14 07:30:23'),
(1518, 322, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:30:23'),
(1519, 325, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\"Here is the link for photo editing and there are 180 files in the folder Thanks,  \r\n</span><a href=\"https://www.dropbox.com/l/scl/AAAVA-m8mpI1K_anJXoJF_3VqvTX_qmc9e4\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/l/scl/AAAVA-m8mpI1K_anJXoJF_3VqvTX_qmc9e4</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>											\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">\"Here is the link for photo editing and there are 180 files in the folder Thanks,  \r\n</span><a href=\"https://www.dropbox.com/l/scl/AAAVA-m8mpI1K_anJXoJF_3VqvTX_qmc9e4\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/l/scl/AAAVA-m8mpI1K_anJXoJF_3VqvTX_qmc9e4</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span>																\'', 8, '2023-09-14 07:30:35'),
(1520, 325, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    \"Here is the link for photo editing and there are 180 files in the folder Thanks, \r\nhttps://www.dropbox.com/l/scl/AAAVA-m8mpI1K_anJXoJF_3VqvTX_qmc9e4 \' to \'                                                        \"Here is the link for photo editing and there are 180 files in the folder Thanks, \r\nhttps://www.dropbox.com/l/scl/AAAVA-m8mpI1K_anJXoJF_3VqvTX_qmc9e4                 \'', 8, '2023-09-14 07:30:35'),
(1521, 325, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'1\'', 8, '2023-09-14 07:30:35'),
(1522, 324, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Total number of images with changes:\r\n\r\nTotal number of images without changes: 1\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: </span><a href=\"https://photos.app.goo.gl/5WCZtoXYbKBuyLsH8\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://photos.app.goo.gl/5WCZtoXYbKBuyLsH8</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nProperty style: Transitional\r\n\r\nSpecial Instructions:Please label the photo as Virtually Staged. Please stage this photo with a desk and desk chair against the window. Please stage seating chairs on the left and right of the desk in the corners. Please stage a couch along the right wall with a picture above the couch that spans the length of the couch.\r\n\r\nOption\r\n\r\n</span>											\' to \'						<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Total number of images with changes:\r\n\r\nTotal number of images without changes: 1\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: </span><a href=\"https://photos.app.goo.gl/5WCZtoXYbKBuyLsH8\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://photos.app.goo.gl/5WCZtoXYbKBuyLsH8</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\nProperty style: Transitional\r\n\r\nSpecial Instructions:Please label the photo as Virtually Staged. Please stage this photo with a desk and desk chair against the window. Please stage seating chairs on the left and right of the desk in the corners. Please stage a couch along the right wall with a picture above the couch that spans the length of the couch.\r\n\r\nOption\r\n\r\n</span>																\'', 8, '2023-09-14 07:30:49'),
(1523, 324, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'Total number of images with changes:\r\n\r\nTotal number of images without changes: 1\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nProperty style: Transitional\r\n\r\nSpecial Instructions:Please label the photo as Virtually Staged. Please stage this photo with a desk and desk chair against the window. Please stage seating chairs on the left and right of the desk in the corners. Please stage a couch along the right wall with a picture above the couch that spans the length of the couch.\r\n\r\nOption\r\n\r\n\' to \'                    Total number of images with changes:\r\n\r\nTotal number of images without changes: 1\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nProperty style: Transitional\r\n\r\nSpecial Instructions:Please label the photo as Virtually Staged. Please stage this photo with a desk and desk chair against the window. Please stage seating chairs on the left and right of the desk in the corners. Please stage a couch along the right wall with a picture above the couch that spans the length of the couch.\r\n\r\nOption\r\n\r\n                \'', 8, '2023-09-14 07:30:49'),
(1524, 324, NULL, NULL, 'Update Project', 'Field \'idlevels\' Thay đổi từ \'\' to \'9\'', 8, '2023-09-14 07:30:49'),
(1525, 331, 240, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-14 07:31:21'),
(1526, 306, 210, '0', 'Get task', 'Get task mới', 52, '2023-09-14 07:34:21'),
(1527, 330, 241, '0', 'Get task', 'Get task mới', 15, '2023-09-14 07:35:14'),
(1528, 306, 210, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'01\'', 52, '2023-09-14 07:43:07'),
(1529, 306, 210, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 52, '2023-09-14 07:43:07'),
(1530, 332, 242, '0', 'Get task', 'Get task mới', 18, '2023-09-14 07:44:13'),
(1531, 333, 243, '0', 'Get task', 'Get task mới', 29, '2023-09-14 07:44:34'),
(1532, 337, 244, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-14 07:46:53'),
(1533, 337, 245, '0', 'Get task', 'Get task mới', 26, '2023-09-14 07:47:37'),
(1534, 339, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 12619 Stone Valley Dr, Peyton, CO 80831', 8, '2023-09-14 07:47:53'),
(1535, 340, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4515 Forsythe Dr, Colorado Springs, CO 80911', 8, '2023-09-14 07:48:28'),
(1536, 338, 246, '0', 'Get task', 'Get task mới', 37, '2023-09-14 07:48:50'),
(1537, 341, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4445 Gatewood Dr, Colorado Springs, CO 80916', 8, '2023-09-14 07:49:00'),
(1538, 342, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3149 Blake St 203, Denver, CO 80205', 8, '2023-09-14 07:49:37'),
(1539, 343, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1825 Elevation Way, Colorado Springs, CO 80921', 8, '2023-09-14 07:50:24'),
(1540, 344, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1720 Crest Pl, Colorado Springs, CO 80911', 8, '2023-09-14 07:50:50'),
(1541, 342, NULL, NULL, 'Update Project', 'Field \'idkh\' Thay đổi từ \'0\' to \'75\'', 8, '2023-09-14 07:51:07'),
(1542, 342, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"Photos + Drone NO DTE</div><div><br></div><div>Photos: 70 files</div><div><br></div><div>Drone: 12 files</div><div><br></div><div>Social Media: 15 files</div><div>https://www.dropbox.com/scl/fo/kq65mmg3flfwu78di0uxn/h?rlkey=7kl4ymakdvde5lcumla5b2mr2&amp;dl=0\"</div>											\' to \'						<div>\"Photos + Drone NO DTE</div><div><br></div><div>Photos: 70 files</div><div><br></div><div>Drone: 12 files</div><div><br></div><div>Social Media: 15 files</div><div>https://www.dropbox.com/scl/fo/kq65mmg3flfwu78di0uxn/h?rlkey=7kl4ymakdvde5lcumla5b2mr2&amp;dl=0\"</div>																\'', 8, '2023-09-14 07:51:07'),
(1543, 342, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'\"Photos + Drone NO DTE\r\n\r\nPhotos: 70 files\r\n\r\nDrone: 12 files\r\n\r\nSocial Media: 15 files\r\n                                 \' to \'                    \"Photos + Drone NO DTE\r\n\r\nPhotos: 70 files\r\n\r\nDrone: 12 files\r\n\r\nSocial Media: 15 files\r\n                                                 \'', 8, '2023-09-14 07:51:07'),
(1544, 345, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: SPRING HOLLOW EDIT', 8, '2023-09-14 07:54:29'),
(1545, 345, 247, '0', 'Get task', 'Get task mới', 11, '2023-09-14 07:59:33'),
(1546, 346, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 332 Sewell Street, Lebanon ME', 8, '2023-09-14 07:59:57'),
(1547, 347, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1615 Kapua Lane, Honolulu', 8, '2023-09-14 08:04:52'),
(1548, 348, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 Video Edit 5 Newburry Ct, Clifton Park, NY 12065', 8, '2023-09-14 08:08:45'),
(1549, 349, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit 5 Newburry Ct, Clifton Park, NY 12065', 8, '2023-09-14 08:09:09'),
(1550, 350, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit 491 Smith Rd, Salem, NY 12865', 8, '2023-09-14 08:09:34'),
(1551, 320, 229, '0', 'Get task', 'Get task mới', 21, '2023-09-14 08:11:06'),
(1552, 338, 246, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'05\'', 37, '2023-09-14 08:12:40'),
(1553, 338, 246, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 37, '2023-09-14 08:12:40'),
(1554, 338, 246, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 37, '2023-09-14 08:12:40'),
(1555, 325, 232, '0', 'Get task', 'Get task mới', 50, '2023-09-14 08:18:11'),
(1556, 325, 232, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 50, '2023-09-14 08:19:49'),
(1557, 338, 246, '0', 'Get task', 'Get task mới', 50, '2023-09-14 08:20:00'),
(1558, 325, 232, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-14 08:20:11'),
(1559, 338, 246, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 08:20:32'),
(1560, 338, 246, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 37, '2023-09-14 08:30:24'),
(1561, 338, 246, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 37, '2023-09-14 08:30:24'),
(1562, 346, 248, '0', 'Get task', 'Get task mới', 28, '2023-09-14 08:34:11'),
(1563, 320, 229, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 08:34:13'),
(1564, 351, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 22741 MARSH WREN DRIVE, LAND O\' LAKES, FL 34639', 8, '2023-09-14 08:39:26'),
(1565, 346, 248, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'5\'', 28, '2023-09-14 08:44:08'),
(1566, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-14 08:44:08'),
(1567, 346, 248, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-14 08:44:08'),
(1568, 346, 248, '0', 'Get task', 'Get task mới', 21, '2023-09-14 08:44:40'),
(1569, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 08:44:49'),
(1570, 320, 229, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-14 08:46:07'),
(1571, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 28, '2023-09-14 08:46:35'),
(1572, 346, 248, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-14 08:46:35'),
(1573, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 28, '2023-09-14 08:46:51'),
(1574, 335, 249, '0', 'Get task', 'Get task mới', 28, '2023-09-14 08:46:57'),
(1575, 336, 250, '0', 'Get task', 'Get task mới', 17, '2023-09-14 08:47:12'),
(1576, 352, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1925 Shenandoah Trail', 8, '2023-09-14 08:47:37'),
(1577, 353, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2525 Carmine St', 8, '2023-09-14 08:48:12'),
(1578, 354, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2730 Old Mathews Rd', 8, '2023-09-14 08:48:47'),
(1579, 355, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 704 Caraway Ln., Nashville, Tennessee, 37211', 8, '2023-09-14 08:49:30'),
(1580, 356, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 207 River Downs Blvd. Murfreesboro, TN 37128', 8, '2023-09-14 08:50:35'),
(1581, 339, 251, '0', 'Get task', 'Get task mới', 22, '2023-09-14 08:50:40'),
(1582, 357, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 8103 WINDING OAK LANE, SPRING HILL, FL 34606', 8, '2023-09-14 08:51:22'),
(1583, 357, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<div>\"Photo HDR , Aerial Video<span style=\"white-space:pre\">	</span>51</div><div>pt: https://adobe.ly/3PgiNpt</div><div>vid: https://drive.google.com/drive/folders/1TI6Orv3Tq7hDU2BEz_ESev-fb1gTtOkK?usp=sharing</div><div>Twilight Images - 2<span style=\"white-space:pre\">	</span>Total Images</div><div>2</div><div>Total number of images with changes:</div><div><br></div><div>Total number of images without changes:</div><div><br></div><div>Total number of twilight enhancement images: 2</div><div><br></div><div>Total number of blue sky/green grass enhancement images:</div><div><br></div><div>Google Photos account link: https://adobe.ly/3PgiNpt</div><div><br></div><div>Property style:</div><div><br></div><div>Special Instructions:NA</div><div><br></div><div>Option</div><div>Please keep our blue sky in the photos. Please use 2 images from fron of home for twilight. Thank You\"</div>											\' to \'						<div>\"Photo HDR , Aerial Video<span style=\"white-space:pre\">	</span>51</div><div>pt: https://adobe.ly/3PgiNpt</div><div>vid: https://drive.google.com/drive/folders/1TI6Orv3Tq7hDU2BEz_ESev-fb1gTtOkK?usp=sharing</div><div>Twilight Images - 2<span style=\"white-space:pre\">	</span>Total Images</div><div>2</div><div>Total number of images with changes:</div><div><br></div><div>Total number of images without changes:</div><div><br></div><div>Total number of twilight enhancement images: 2</div><div><br></div><div>Total number of blue sky/green grass enhancement images:</div><div><br></div><div>Google Photos account link: https://adobe.ly/3PgiNpt</div><div><br></div><div>Property style:</div><div><br></div><div>Special Instructions:NA</div><div><br></div><div>Option</div><div>Please keep our blue sky in the photos. Please use 2 images from fron of home for twilight. Thank You\"</div>																\'', 8, '2023-09-14 08:51:31'),
(1584, 357, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'  \"Photo HDR , Aerial Video	51\r\n\r\nTwilight Images - 2	Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\nPlease keep our blue sky in the photos. Please use 2 images from fron of home for twilight. Thank You\"                                  \' to \'                      \"Photo HDR , Aerial Video	51\r\n\r\nTwilight Images - 2	Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\nPlease keep our blue sky in the photos. Please use 2 images from fron of home for twilight. Thank You\"                                                  \'', 8, '2023-09-14 08:51:31'),
(1585, 357, NULL, NULL, 'Update Project', 'Field \'idcb\' Thay đổi từ \'0\' to \'3\'', 8, '2023-09-14 08:51:31'),
(1586, 337, 245, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'24\'', 26, '2023-09-14 09:00:58'),
(1587, 337, 245, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 26, '2023-09-14 09:00:58'),
(1588, 337, 245, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 26, '2023-09-14 09:00:58'),
(1589, 334, 253, '0', 'Get task', 'Get task mới', 26, '2023-09-14 09:01:03'),
(1590, 338, 246, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'2\'', 50, '2023-09-14 09:03:53'),
(1591, 337, 245, '0', 'Get task', 'Get task mới', 50, '2023-09-14 09:03:56'),
(1592, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'2\'', 21, '2023-09-14 09:04:22'),
(1593, 340, 252, '0', 'Get task', 'Get task mới', 20, '2023-09-14 09:05:52'),
(1594, 338, 246, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 37, '2023-09-14 09:08:10'),
(1595, 338, 246, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 37, '2023-09-14 09:08:10'),
(1596, 338, 246, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 37, '2023-09-14 09:08:21'),
(1597, 338, 246, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-14 09:08:31'),
(1598, 337, 245, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 09:09:27'),
(1599, 341, 256, '0', 'Get task', 'Get task mới', 42, '2023-09-14 09:11:49'),
(1600, 330, 241, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'21\'', 15, '2023-09-14 09:26:02'),
(1601, 330, 241, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-14 09:26:02'),
(1602, 330, 241, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-14 09:26:02'),
(1603, 337, 245, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 50, '2023-09-14 09:26:33'),
(1604, 343, 257, '0', 'Get task', 'Get task mới', 15, '2023-09-14 09:26:39'),
(1605, 337, 245, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'0\'', 26, '2023-09-14 09:26:45'),
(1606, 337, 245, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 26, '2023-09-14 09:26:45'),
(1607, 330, 241, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'21\' thành \'33\'', 15, '2023-09-14 09:28:02'),
(1608, 330, 241, '0', 'Get task', 'Get task mới', 50, '2023-09-14 09:28:22'),
(1609, 337, 245, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 50, '2023-09-14 09:28:40'),
(1610, 330, 241, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 09:28:54'),
(1611, 308, 206, '0', 'Get task', 'Get task mới', 51, '2023-09-14 09:29:30'),
(1612, 308, 206, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'2\'', 51, '2023-09-14 09:31:47'),
(1613, 308, 206, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 51, '2023-09-14 09:31:47'),
(1614, 308, 206, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 51, '2023-09-14 09:31:47'),
(1615, 312, 204, '0', 'Get task', 'Get task mới', 51, '2023-09-14 09:31:52'),
(1616, 313, 201, '0', 'Get task', 'Get task mới', 51, '2023-09-14 09:31:56'),
(1617, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-14 09:37:07'),
(1618, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'2\'', 21, '2023-09-14 09:37:13'),
(1619, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 28, '2023-09-14 09:37:41'),
(1620, 346, 248, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-14 09:37:41'),
(1621, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 28, '2023-09-14 09:37:59'),
(1622, 344, 260, '0', 'Get task', 'Get task mới', 46, '2023-09-14 09:38:09'),
(1623, 330, 241, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 15, '2023-09-14 09:38:17'),
(1624, 330, 241, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-14 09:38:17'),
(1625, 346, 248, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 21, '2023-09-14 09:38:26'),
(1626, 330, 241, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-14 09:38:55'),
(1627, 326, 235, '0', 'Get task', 'Get task mới', 51, '2023-09-14 09:43:25'),
(1628, 326, 235, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 51, '2023-09-14 09:44:04'),
(1629, 326, 235, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 51, '2023-09-14 09:44:11'),
(1630, 326, 235, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 51, '2023-09-14 09:44:34'),
(1631, 334, 254, '0', 'Get task', 'Get task mới', 51, '2023-09-14 09:44:37'),
(1632, 343, 258, '0', 'Get task', 'Get task mới', 21, '2023-09-14 09:50:03'),
(1633, 330, 241, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 09:56:25'),
(1634, 330, 241, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 15, '2023-09-14 09:57:25'),
(1635, 330, 241, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-14 09:57:25'),
(1636, 330, 241, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-14 10:03:20'),
(1637, 333, 243, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'53\'', 29, '2023-09-14 10:05:21'),
(1638, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 10:05:41'),
(1639, 333, 243, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 10:05:41'),
(1640, 358, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit 449 Madison St, Troy, NY 12180', 8, '2023-09-14 10:06:05'),
(1641, 359, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 Video Edit 449 Madison St, Troy, NY 12180', 8, '2023-09-14 10:06:38'),
(1642, 360, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit 170-176 Columbia Turnpike, Rensselaer, NY 12144', 8, '2023-09-14 10:08:46'),
(1643, 361, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 HDR Edit 131 Werking Rd, East Greenbush, NY 12061', 8, '2023-09-14 10:09:20'),
(1644, 333, 243, '0', 'Get task', 'Get task mới', 50, '2023-09-14 10:09:53'),
(1645, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 10:11:17'),
(1646, 362, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 189 Video Edit 131 Werking Rd, East Greenbush, NY 12061', 8, '2023-09-14 10:12:36'),
(1647, 339, 251, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'32\'', 22, '2023-09-14 10:13:00'),
(1648, 339, 251, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-14 10:13:00'),
(1649, 339, 251, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-14 10:13:00'),
(1650, 339, 251, '0', 'Get task', 'Get task mới', 21, '2023-09-14 10:13:03'),
(1651, 355, 261, '0', 'Get task', 'Get task mới', 22, '2023-09-14 10:13:19'),
(1652, 339, 251, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 10:13:23'),
(1653, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 29, '2023-09-14 10:16:40'),
(1654, 333, 243, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 10:16:40'),
(1655, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 29, '2023-09-14 10:17:27'),
(1656, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'1\'', 29, '2023-09-14 10:17:44'),
(1657, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 10:19:46'),
(1658, 341, 256, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'21\'', 42, '2023-09-14 10:32:48'),
(1659, 341, 256, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-14 10:32:48'),
(1660, 341, 256, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-14 10:32:48'),
(1661, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 29, '2023-09-14 10:34:20'),
(1662, 333, 243, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 10:34:20'),
(1663, 340, 252, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 20, '2023-09-14 10:37:57'),
(1664, 340, 252, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'24\'', 20, '2023-09-14 10:38:43'),
(1665, 340, 252, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 20, '2023-09-14 10:38:43'),
(1666, 356, 264, '0', 'Get task', 'Get task mới', 20, '2023-09-14 10:38:49'),
(1667, 336, 250, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'30\'', 17, '2023-09-14 10:47:19'),
(1668, 336, 250, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-14 10:47:19'),
(1669, 336, 250, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-14 10:47:19'),
(1670, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'0\'', 50, '2023-09-14 10:48:37'),
(1671, 336, 250, '0', 'Get task', 'Get task mới', 50, '2023-09-14 10:48:44'),
(1672, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 29, '2023-09-14 10:49:24'),
(1673, 333, 243, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 10:49:24'),
(1674, 333, 243, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-14 10:49:47'),
(1675, 340, 252, '0', 'Get task', 'Get task mới', 21, '2023-09-14 10:49:48'),
(1676, 340, 252, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 10:50:03'),
(1677, 345, 247, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'41\'', 11, '2023-09-14 10:50:04'),
(1678, 345, 247, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-14 10:50:04'),
(1679, 345, 247, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-14 10:50:04'),
(1680, 345, 247, '0', 'Get task', 'Get task mới', 21, '2023-09-14 10:50:07'),
(1681, 336, 250, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 10:50:39'),
(1682, 341, 256, '0', 'Get task', 'Get task mới', 50, '2023-09-14 10:50:41'),
(1683, 345, 247, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 10:50:47'),
(1684, 341, 256, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 10:50:54'),
(1685, 334, 253, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'66\'', 26, '2023-09-14 11:01:28'),
(1686, 334, 253, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 26, '2023-09-14 11:01:28'),
(1687, 334, 253, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 26, '2023-09-14 11:01:28'),
(1688, 334, 253, '0', 'Get task', 'Get task mới', 21, '2023-09-14 11:01:31'),
(1689, 363, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6015 Northview Ct, Aubrey, TX 76227', 8, '2023-09-14 11:04:26'),
(1690, 341, 256, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 42, '2023-09-14 11:06:34'),
(1691, 341, 256, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-14 11:06:34'),
(1692, 336, 250, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 17, '2023-09-14 11:10:21'),
(1693, 336, 250, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-14 11:10:21'),
(1694, 347, 267, '0', 'Get task', 'Get task mới', 30, '2023-09-14 11:16:28'),
(1695, 334, 253, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 11:16:40'),
(1696, 332, 242, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'45\'', 18, '2023-09-14 11:16:50'),
(1697, 332, 242, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-14 11:16:50'),
(1698, 332, 242, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-14 11:16:50'),
(1699, 349, 268, '0', 'Get task', 'Get task mới', 18, '2023-09-14 11:16:54'),
(1700, 355, 262, '0', 'Get task', 'Get task mới', 9, '2023-09-14 11:17:48'),
(1701, 332, 242, '0', 'Get task', 'Get task mới', 9, '2023-09-14 11:17:50'),
(1702, 332, 242, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-14 11:31:44'),
(1703, 332, 242, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'1\'', 18, '2023-09-14 11:31:47'),
(1704, 332, 242, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-14 11:31:47'),
(1705, 342, 269, '0', 'Get task', 'Get task mới', 48, '2023-09-14 11:32:46'),
(1706, 352, 272, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-14 11:39:19'),
(1707, 350, 271, '0', 'Get task', 'Get task mới', 25, '2023-09-14 11:41:55'),
(1708, 355, 261, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'39\'', 22, '2023-09-14 11:42:24'),
(1709, 355, 261, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-14 11:42:24'),
(1710, 355, 261, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-14 11:42:24'),
(1711, 355, 261, '0', 'Get task', 'Get task mới', 21, '2023-09-14 11:42:53'),
(1712, 341, 256, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'21\' thành \'20\'', 50, '2023-09-14 11:43:29'),
(1713, 341, 256, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-14 11:43:29'),
(1714, 355, 261, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 11:43:36');
INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(1715, 332, 242, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 18, '2023-09-14 11:43:54'),
(1716, 355, 261, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 22, '2023-09-14 11:44:58'),
(1717, 355, 261, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-14 11:44:58'),
(1718, 339, 251, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 22, '2023-09-14 11:45:07'),
(1719, 339, 251, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-14 11:45:07'),
(1720, 335, 249, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'75\'', 28, '2023-09-14 11:47:15'),
(1721, 335, 249, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-14 11:47:15'),
(1722, 335, 249, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-14 11:47:15'),
(1723, 336, 250, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-14 11:48:31'),
(1724, 335, 249, '0', 'Get task', 'Get task mới', 50, '2023-09-14 11:48:35'),
(1725, 335, 249, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 11:48:49'),
(1726, 344, 260, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 46, '2023-09-14 11:52:23'),
(1727, 344, 260, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 46, '2023-09-14 11:52:23'),
(1728, 344, 260, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'22\'', 46, '2023-09-14 11:52:44'),
(1729, 351, 273, '0', 'Get task', 'Get task mới', 29, '2023-09-14 11:59:41'),
(1730, 345, 247, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-14 12:30:11'),
(1731, 354, 276, '0', 'Get task', 'Get task mới', 37, '2023-09-14 12:33:59'),
(1732, 355, 261, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 21, '2023-09-14 12:43:06'),
(1733, 364, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 144 Jones Road, Shapleigh ME', 8, '2023-09-14 12:45:31'),
(1734, 330, 241, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-14 12:46:17'),
(1735, 365, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 4 Preble Street, Wells ME', 8, '2023-09-14 12:50:51'),
(1736, 344, 260, '0', 'Get task', 'Get task mới', 50, '2023-09-14 12:51:07'),
(1737, 344, 260, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-14 12:58:23'),
(1738, 357, 277, '0', 'Get task', 'Get task mới', 42, '2023-09-14 13:04:32'),
(1739, 339, 251, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 21, '2023-09-14 13:11:50'),
(1740, 334, 253, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-14 13:19:45'),
(1741, 326, 235, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-14 13:22:06'),
(1742, 326, 236, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-14 13:22:13'),
(1743, 326, 233, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-14 13:22:21'),
(1744, 343, 257, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'55\'', 15, '2023-09-14 13:22:25'),
(1745, 343, 257, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-14 13:22:25'),
(1746, 343, 257, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-14 13:22:25'),
(1747, 343, 257, '0', 'Get task', 'Get task mới', 21, '2023-09-14 13:22:53'),
(1748, 343, 257, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-14 13:23:32'),
(1749, 342, 269, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'14\'', 48, '2023-09-14 13:24:10'),
(1750, 342, 269, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 48, '2023-09-14 13:24:10'),
(1751, 342, 269, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 48, '2023-09-14 13:24:10'),
(1752, 342, 269, '0', 'Get task', 'Get task mới', 21, '2023-09-14 13:24:54'),
(1753, 342, 269, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-14 13:25:19'),
(1754, 334, 254, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 51, '2023-09-14 13:25:24'),
(1755, 334, 254, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 51, '2023-09-14 13:25:24'),
(1756, 342, 269, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'2\'', 21, '2023-09-14 13:25:57'),
(1757, 340, 252, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-14 13:31:10'),
(1758, 335, 249, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 28, '2023-09-14 13:44:13'),
(1759, 335, 249, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-14 13:44:13'),
(1760, 335, 249, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-14 13:44:27'),
(1761, 347, 267, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'35\'', 30, '2023-09-14 13:58:51'),
(1762, 347, 267, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 30, '2023-09-14 13:58:51'),
(1763, 347, 267, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 30, '2023-09-14 13:58:51'),
(1764, 358, 280, '0', 'Get task', 'Get task mới', 30, '2023-09-14 13:59:01'),
(1765, 332, 242, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 9, '2023-09-14 14:10:31'),
(1766, 355, 262, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-14 14:11:46'),
(1767, 355, 262, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-14 14:11:46'),
(1768, 355, 262, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-14 14:11:46'),
(1769, 360, 281, '0', 'Get task', 'Get task mới', 19, '2023-09-14 14:12:19'),
(1770, 351, 274, '0', 'Get task', 'Get task mới', 9, '2023-09-14 14:14:10'),
(1771, 351, 274, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'2\'', 9, '2023-09-14 14:16:09'),
(1772, 351, 274, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-14 14:16:09'),
(1773, 351, 274, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 9, '2023-09-14 14:16:09'),
(1774, 347, 267, '0', 'Get task', 'Get task mới', 21, '2023-09-14 14:24:50'),
(1775, 347, 267, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 14:25:08'),
(1776, 342, 269, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 48, '2023-09-14 14:25:29'),
(1777, 342, 269, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 48, '2023-09-14 14:25:29'),
(1778, 342, 269, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-14 14:27:54'),
(1779, 342, 269, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'son.vh\' sang \'duy.dd\'', 3, '2023-09-14 14:27:54'),
(1780, 361, 282, '0', 'Get task', 'Get task mới', 20, '2023-09-14 14:36:30'),
(1781, 351, 273, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'50\'', 29, '2023-09-14 14:39:15'),
(1782, 351, 273, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 14:39:32'),
(1783, 351, 273, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 14:39:32'),
(1784, 363, 283, '0', 'Get task', 'Get task mới', 29, '2023-09-14 14:40:14'),
(1785, 364, 286, '0', 'Get task', 'Get task mới', 17, '2023-09-14 14:40:33'),
(1786, 365, 289, '0', 'Get task', 'Get task mới', 22, '2023-09-14 14:41:49'),
(1787, 351, 273, '0', 'Get task', 'Get task mới', 21, '2023-09-14 14:43:18'),
(1788, 351, 273, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 14:43:29'),
(1789, 350, 271, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'67\'', 25, '2023-09-14 14:54:35'),
(1790, 343, 258, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-14 14:58:22'),
(1791, 343, 258, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'son.vh\' sang \'duy.dd\'', 3, '2023-09-14 14:58:22'),
(1792, 344, 260, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 46, '2023-09-14 15:01:25'),
(1793, 344, 260, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 46, '2023-09-14 15:01:25'),
(1794, 344, 260, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-14 15:02:01'),
(1795, 349, 268, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'39\'', 18, '2023-09-14 15:02:43'),
(1796, 349, 268, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-14 15:02:43'),
(1797, 349, 268, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-14 15:02:43'),
(1798, 354, 276, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'025\'', 37, '2023-09-14 15:06:00'),
(1799, 354, 276, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 37, '2023-09-14 15:06:00'),
(1800, 354, 276, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 37, '2023-09-14 15:06:00'),
(1801, 349, 268, '0', 'Get task', 'Get task mới', 21, '2023-09-14 15:11:06'),
(1802, 349, 268, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-14 15:11:36'),
(1803, 354, 276, '0', 'Get task', 'Get task mới', 21, '2023-09-14 15:11:40'),
(1804, 354, 276, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-14 15:12:18'),
(1805, 361, 282, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'38\'', 20, '2023-09-14 15:19:12'),
(1806, 361, 282, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 20, '2023-09-14 15:19:12'),
(1807, 361, 282, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 20, '2023-09-14 15:19:12'),
(1808, 361, 282, '0', 'Get task', 'Get task mới', 21, '2023-09-14 15:19:39'),
(1809, 361, 282, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-14 15:20:09'),
(1810, 350, 271, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 25, '2023-09-14 15:46:36'),
(1811, 350, 271, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 25, '2023-09-14 15:46:36'),
(1812, 347, 267, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-14 15:57:08'),
(1813, 351, 273, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-14 15:57:13'),
(1814, 366, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 221 N. Basilio', 5, '2023-09-14 16:01:45'),
(1815, 354, 276, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-14 16:16:20'),
(1816, 363, 283, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'34\'', 29, '2023-09-14 16:17:36'),
(1817, 363, 283, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 16:17:46'),
(1818, 363, 283, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-14 16:17:46'),
(1819, 365, 289, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'66\'', 22, '2023-09-14 16:48:40'),
(1820, 365, 289, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-14 16:48:40'),
(1821, 365, 289, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-14 16:48:40'),
(1822, 358, 280, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'53\'', 30, '2023-09-14 16:54:38'),
(1823, 358, 280, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 30, '2023-09-14 16:54:38'),
(1824, 358, 280, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 30, '2023-09-14 16:54:38'),
(1825, 365, 289, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 22, '2023-09-14 18:20:56'),
(1826, 329, 239, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'22\'', 41, '2023-09-14 23:04:49'),
(1827, 329, 239, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 41, '2023-09-14 23:04:49'),
(1828, 329, 239, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 41, '2023-09-14 23:04:49'),
(1829, 367, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 27 Fox Hill Rd, Middletown, NJ', 7, '2023-09-15 02:02:18'),
(1830, 368, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: GOODRICH EDIT', 7, '2023-09-15 02:03:00'),
(1831, 369, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: NOTTINGHAMSHIRE EDIT', 7, '2023-09-15 02:03:43'),
(1832, 370, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 51335 D W Seaton Drive', 7, '2023-09-15 02:04:22'),
(1833, 371, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 168 Earlmont Pl, Davenport FL', 7, '2023-09-15 02:16:30'),
(1834, 372, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 548 Ventura Dr, Forest Park, GA 30297        ', 7, '2023-09-15 04:31:40'),
(1835, 373, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 205 Durango Dr, Gilberts, IL 60136        ', 7, '2023-09-15 04:40:11'),
(1836, 374, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 10663 Lake Iamonia Dr, Tallahassee, FL 32312', 7, '2023-09-15 04:44:16'),
(1837, 375, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 54 Stony Hill Rd, Brookfield, CT 06804        ', 7, '2023-09-15 06:20:29'),
(1838, 376, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 124 Minter Dr, Griffith, IN 46319        ', 7, '2023-09-15 06:20:59'),
(1839, 377, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: ', 7, '2023-09-15 06:24:03'),
(1840, 377, NULL, NULL, 'Update Project', 'Field \'name\' Thay đổi từ \'\' to \'262 Morgan Valley Dr, Oswego, IL 60543        \'', 7, '2023-09-15 06:39:11'),
(1841, 377, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<p><a href=\"https://www.dropbox.com/t/Wy7WtMXu1Jh2Ol1t\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/t/Wy7WtMXu1Jh2Ol1t</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span></p><p><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Photo HDR , Aerial Video        43 </span></p><p><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">video: <a href=\"https://www.dropbox.com/t/XxKSh2l7aK8jolIJ\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); text-decoration-skip-ink: none;\">https://www.dropbox.com/t/XxKSh2l7aK8jolIJ</a><span style=\"text-decoration-skip-ink: none;\"> </span></span></p><p><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><span style=\"text-decoration-skip-ink: none;\"><br></span>\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account</span><a href=\"https://www.dropbox.com/t/v4iISEX9xAhNl5b5\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> link: https://www.dropbox.com/t/v4iISEX9x</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">AhNl5b5 \r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:NA\r\n\r\nOption</span>											</p>\' to \'						<p><a href=\"https://www.dropbox.com/t/Wy7WtMXu1Jh2Ol1t\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://www.dropbox.com/t/Wy7WtMXu1Jh2Ol1t</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> </span></p><p><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">Photo HDR , Aerial Video        43 </span></p><p><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">video: <a href=\"https://www.dropbox.com/t/XxKSh2l7aK8jolIJ\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); text-decoration-skip-ink: none;\">https://www.dropbox.com/t/XxKSh2l7aK8jolIJ</a><span style=\"text-decoration-skip-ink: none;\"> </span></span></p><p><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"><span style=\"text-decoration-skip-ink: none;\"><br></span>\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account</span><a href=\"https://www.dropbox.com/t/v4iISEX9xAhNl5b5\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> link: https://www.dropbox.com/t/v4iISEX9x</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">AhNl5b5 \r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:NA\r\n\r\nOption</span>											</p>					\'', 7, '2023-09-15 06:39:11'),
(1842, 377, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    Property style: OR Let Hommati Team pick for you OR special project\r\n\' to \'                                                        Property style: OR Let Hommati Team pick for you OR special project\r\n                \'', 7, '2023-09-15 06:39:11'),
(1843, 329, 239, '0', 'Get task', 'Get task mới', 50, '2023-09-15 07:18:05'),
(1844, 329, 239, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-15 07:18:20'),
(1845, 329, 239, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 50, '2023-09-15 07:18:52'),
(1846, 350, 271, '0', 'Get task', 'Get task mới', 50, '2023-09-15 07:18:56'),
(1847, 350, 271, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 50, '2023-09-15 07:19:07'),
(1848, 368, 292, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-15 07:23:53'),
(1849, 368, 292, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'thuy.ct\'', 3, '2023-09-15 07:23:53'),
(1850, 378, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 18 Simpson Lane, York ME', 6, '2023-09-15 07:50:00'),
(1851, 379, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 25 Logging Road, York ME', 6, '2023-09-15 07:50:52'),
(1852, 380, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 23 Fort Hill Ave Ext. York ME', 6, '2023-09-15 07:51:56'),
(1853, 378, 297, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-15 07:51:57'),
(1854, 378, 297, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'dat.vv\'', 3, '2023-09-15 07:51:57'),
(1855, 381, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 54 Stony Hill Rd, Brookfield, CT 06804        ', 6, '2023-09-15 07:52:44'),
(1856, 381, 0, '0', 'Delete Project', '54 Stony Hill Rd, Brookfield, CT 06804        ', 6, '2023-09-15 07:53:34'),
(1857, 382, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 10550 Baymeadows Rd Unit 929 Jacksonville FL', 6, '2023-09-15 07:54:59'),
(1858, 383, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Photos to edit 1505 Marsh Rabbit Way Fleming Island FL 32003', 6, '2023-09-15 07:55:39'),
(1859, 384, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 224 Edit - Caraway Event', 6, '2023-09-15 07:56:33'),
(1860, 385, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3289 Cypress Walk Pl Green Cove SPring 32043', 6, '2023-09-15 07:57:13'),
(1861, 386, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3217 River Rd Green Cove Springs FL 32043', 6, '2023-09-15 07:57:59'),
(1862, 358, 280, '0', 'Get task', 'Get task mới', 50, '2023-09-15 08:05:22'),
(1863, 358, 280, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 50, '2023-09-15 08:05:35'),
(1864, 363, 283, '0', 'Get task', 'Get task mới', 50, '2023-09-15 08:05:38'),
(1865, 363, 283, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 50, '2023-09-15 08:05:48'),
(1866, 365, 290, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:05:50'),
(1867, 365, 289, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-15 08:06:06'),
(1868, 327, 237, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:06:13'),
(1869, 342, 269, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-15 08:06:22'),
(1870, 328, 238, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:06:29'),
(1871, 334, 255, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:06:40'),
(1872, 334, 254, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:06:51'),
(1873, 331, 240, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:07:01'),
(1874, 342, 270, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:07:09'),
(1875, 343, 259, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:07:17'),
(1876, 343, 258, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:07:25'),
(1877, 352, 272, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:07:33'),
(1878, 351, 275, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:07:46'),
(1879, 355, 263, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:07:59'),
(1880, 360, 281, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:08:09'),
(1881, 363, 285, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:08:18'),
(1882, 363, 284, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:08:27'),
(1883, 364, 288, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:08:36'),
(1884, 364, 287, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:08:45'),
(1885, 364, 286, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:09:00'),
(1886, 365, 291, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 08:09:11'),
(1887, 334, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'						<a href=\"https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels</span>																\' to \'												<a href=\"https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link\" class=\"waffle-rich-text-link\" style=\"text-decoration-line: underline; color: rgb(17, 85, 204); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\">https://drive.google.com/drive/folders/1RD9D4Y9UI0QrpKmbvNOGmd1wgAOOaeFJ?usp=drive_link</a><span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 14px; white-space-collapse: preserve; text-decoration-skip-ink: none;\"> \r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels</span>																					\'', 6, '2023-09-15 08:10:20'),
(1888, 334, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                    INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                \' to \'                                        INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                                \'', 6, '2023-09-15 08:10:20'),
(1889, 329, 239, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 6, '2023-09-15 08:11:09'),
(1890, 363, 283, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 6, '2023-09-15 08:11:59'),
(1891, 358, 280, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 6, '2023-09-15 08:12:17'),
(1892, 376, 296, '0', 'Get task', 'Get task mới', 28, '2023-09-15 08:12:52'),
(1893, 361, 282, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 6, '2023-09-15 08:13:22'),
(1894, 354, 276, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 6, '2023-09-15 08:13:41'),
(1895, 378, 297, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'16\'', 13, '2023-09-15 08:15:50'),
(1896, 378, 297, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-15 08:15:50'),
(1897, 378, 297, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-15 08:15:50'),
(1898, 341, 256, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 6, '2023-09-15 08:17:25'),
(1899, 349, 268, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 6, '2023-09-15 08:17:42'),
(1900, 378, 297, '0', 'Get task', 'Get task mới', 21, '2023-09-15 08:19:25'),
(1901, 378, 297, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-15 08:19:34'),
(1902, 380, 304, '0', 'Get task', 'Get task mới', 17, '2023-09-15 08:29:46'),
(1903, 377, 293, '0', 'Get task', 'Get task mới', 42, '2023-09-15 08:40:05'),
(1904, 383, 303, '0', 'Get task', 'Get task mới', 20, '2023-09-15 09:17:28'),
(1905, 376, 296, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'7\' thành \'9\'', 3, '2023-09-15 09:20:53'),
(1906, 387, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1804 TWIN RIVERS TRAIL, PARRISH, FL 34219', 6, '2023-09-15 09:22:25'),
(1907, 384, 307, '0', 'Get task', 'Get task mới', 29, '2023-09-15 09:22:31'),
(1908, 388, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: Additional Pictures', 6, '2023-09-15 09:24:15'),
(1909, 389, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 215 Elton Hills Drive #9 Rochester, MN', 6, '2023-09-15 09:24:40'),
(1910, 390, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 8453 OLD POST ROAD, PORT RICHEY, FL 34668', 6, '2023-09-15 09:25:45'),
(1911, 391, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 254 Mountain Road, York ME', 6, '2023-09-15 09:26:27'),
(1912, 392, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 24 Blakely Court NW Oronoco, MN', 6, '2023-09-15 09:27:01'),
(1913, 388, 314, '0', 'Get task', 'Get task mới', 18, '2023-09-15 09:35:36'),
(1914, 389, 315, '0', 'Get task', 'Get task mới', 22, '2023-09-15 10:07:02'),
(1915, 389, 315, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'15\'', 22, '2023-09-15 10:14:25'),
(1916, 389, 315, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-15 10:14:25'),
(1917, 389, 315, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-15 10:14:25'),
(1918, 389, 315, '0', 'Get task', 'Get task mới', 21, '2023-09-15 10:14:40'),
(1919, 388, 314, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'11\'', 18, '2023-09-15 10:14:47'),
(1920, 388, 314, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-15 10:14:47'),
(1921, 388, 314, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-15 10:14:47'),
(1922, 389, 317, NULL, 'Insert Task', 'Tạo Task mới', 21, '2023-09-15 10:15:15'),
(1923, 388, 314, '0', 'Get task', 'Get task mới', 50, '2023-09-15 10:16:00'),
(1924, 388, 314, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-15 10:16:13'),
(1925, 375, 318, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-15 10:19:45'),
(1926, 375, 318, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'tinh.ph\'', 3, '2023-09-15 10:19:45'),
(1927, 388, 314, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 18, '2023-09-15 10:20:31'),
(1928, 388, 314, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-15 10:20:31'),
(1929, 389, 315, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 21, '2023-09-15 10:20:50'),
(1930, 379, 322, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-15 10:30:10'),
(1931, 387, 319, '0', 'Get task', 'Get task mới', 15, '2023-09-15 10:30:10'),
(1932, 374, 323, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-15 10:34:14'),
(1933, 384, 307, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'55\'', 29, '2023-09-15 10:39:30'),
(1934, 384, 307, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-15 10:39:30'),
(1935, 384, 307, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-15 10:39:30'),
(1936, 382, 300, '0', 'Get task', 'Get task mới', 29, '2023-09-15 10:39:34'),
(1937, 388, 314, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'2\'', 50, '2023-09-15 10:40:56'),
(1938, 384, 307, '0', 'Get task', 'Get task mới', 50, '2023-09-15 10:40:58'),
(1939, 388, 314, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 18, '2023-09-15 10:41:26'),
(1940, 388, 314, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-15 10:41:26'),
(1941, 388, 314, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-15 10:41:44'),
(1942, 385, 308, '0', 'Get task', 'Get task mới', 18, '2023-09-15 10:41:47'),
(1943, 384, 307, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-15 10:42:24'),
(1944, 386, 311, '0', 'Get task', 'Get task mới', 17, '2023-09-15 10:45:26'),
(1945, 389, 315, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'3\'', 22, '2023-09-15 10:45:28'),
(1946, 389, 315, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-15 10:45:28'),
(1947, 389, 317, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 22, '2023-09-15 10:45:38'),
(1948, 389, 317, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 22, '2023-09-15 10:45:38'),
(1949, 376, 296, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-15 10:47:35'),
(1950, 376, 296, NULL, 'Update Task', 'Field \'status\' Thay đổi từ \'9\' to \'1\'', 3, '2023-09-15 10:47:35'),
(1951, 376, 296, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'42\'', 28, '2023-09-15 10:47:48'),
(1952, 376, 296, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-15 10:47:48'),
(1953, 390, 324, '0', 'Get task', 'Get task mới', 28, '2023-09-15 10:56:00'),
(1954, 388, 314, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-15 10:58:34'),
(1955, 376, 296, '0', 'Get task', 'Get task mới', 50, '2023-09-15 10:58:36'),
(1956, 376, 296, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-15 10:58:55'),
(1957, 392, 316, '0', 'Get task', 'Get task mới', 30, '2023-09-15 11:03:17'),
(1958, 392, 316, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'16\'', 30, '2023-09-15 11:21:47'),
(1959, 392, 316, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 30, '2023-09-15 11:21:47'),
(1960, 392, 316, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 30, '2023-09-15 11:21:47'),
(1961, 389, 315, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 21, '2023-09-15 11:37:48'),
(1962, 389, 317, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 21, '2023-09-15 11:37:55'),
(1963, 392, 316, '0', 'Get task', 'Get task mới', 50, '2023-09-15 11:38:23'),
(1964, 391, 327, NULL, 'Insert Task', 'Tạo Task mới', 3, '2023-09-15 11:47:58'),
(1965, 393, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 113 Holly Ln, White House, TN 37188', 6, '2023-09-15 11:50:05'),
(1966, 394, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 113 Holly Ln, White House, TN 37188', 6, '2023-09-15 11:50:52'),
(1967, 392, 316, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-15 11:51:36'),
(1968, 393, 328, '0', 'Get task', 'Get task mới', 23, '2023-09-15 11:57:01'),
(1969, 384, 307, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 29, '2023-09-15 12:02:05'),
(1970, 384, 307, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-15 12:02:05'),
(1971, 382, 300, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'23\'', 29, '2023-09-15 12:04:58'),
(1972, 382, 300, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-15 12:04:58'),
(1973, 382, 300, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-15 12:04:58'),
(1974, 390, 324, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'28\'', 28, '2023-09-15 12:07:06'),
(1975, 390, 324, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-15 12:07:06'),
(1976, 390, 324, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-15 12:07:06'),
(1977, 376, 296, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 28, '2023-09-15 12:07:33'),
(1978, 376, 296, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 28, '2023-09-15 12:07:33'),
(1979, 384, 330, NULL, 'Insert Task', 'Tạo Task mới', 50, '2023-09-15 12:12:45'),
(1980, 395, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 40 Southport Drive', 6, '2023-09-15 12:12:58'),
(1981, 384, 331, NULL, 'Insert Task', 'Tạo Task mới', 50, '2023-09-15 12:13:50'),
(1982, 384, 331, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'2\'', 50, '2023-09-15 12:14:06'),
(1983, 384, 330, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'55\' thành \'\'', 29, '2023-09-15 12:14:37'),
(1984, 384, 330, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 29, '2023-09-15 12:14:37'),
(1985, 384, 330, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-15 12:14:37'),
(1986, 384, 331, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'55\' thành \'\'', 29, '2023-09-15 12:14:47'),
(1987, 384, 331, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'0\'', 29, '2023-09-15 12:14:47'),
(1988, 391, 327, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'17\'', 13, '2023-09-15 12:19:35'),
(1989, 391, 327, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-15 12:19:35'),
(1990, 391, 327, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-15 12:19:35'),
(1991, 390, 324, '0', 'Get task', 'Get task mới', 21, '2023-09-15 12:19:55'),
(1992, 390, 324, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-15 12:20:32'),
(1993, 382, 300, '0', 'Get task', 'Get task mới', 21, '2023-09-15 12:20:35'),
(1994, 382, 300, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-15 12:20:44'),
(1995, 391, 327, '0', 'Get task', 'Get task mới', 21, '2023-09-15 12:20:47'),
(1996, 391, 327, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 21, '2023-09-15 12:20:58'),
(1997, 384, 331, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'55\'', 29, '2023-09-15 12:21:12'),
(1998, 384, 331, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-15 12:21:12'),
(1999, 384, 307, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'55\' thành \'\'', 29, '2023-09-15 12:21:19'),
(2000, 384, 331, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-15 12:21:37'),
(2001, 384, 331, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 50, '2023-09-15 12:32:27'),
(2002, 384, 307, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-15 12:32:40'),
(2003, 384, 330, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 50, '2023-09-15 12:32:53'),
(2004, 392, 316, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 50, '2023-09-15 12:34:52'),
(2005, 382, 300, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-15 12:36:17'),
(2006, 390, 324, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-15 12:36:43'),
(2007, 378, 297, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-15 12:37:46'),
(2008, 377, 293, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'43\'', 42, '2023-09-15 12:55:45'),
(2009, 377, 293, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-15 12:55:45'),
(2010, 377, 293, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-15 12:55:45'),
(2011, 396, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 3658 S Granite Ln, Wasilla, AK 99654', 6, '2023-09-15 13:01:14'),
(2012, 385, 308, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'32\'', 18, '2023-09-15 13:20:25'),
(2013, 385, 308, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-15 13:20:25'),
(2014, 385, 308, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-15 13:21:31'),
(2015, 396, 335, '0', 'Get task', 'Get task mới', 11, '2023-09-15 13:24:47'),
(2016, 383, 303, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'30\'', 20, '2023-09-15 13:31:13'),
(2017, 383, 303, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 20, '2023-09-15 13:31:13'),
(2018, 383, 303, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 20, '2023-09-15 13:31:13'),
(2019, 395, 332, '0', 'Get task', 'Get task mới', 20, '2023-09-15 13:31:17'),
(2020, 376, 296, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'7\'', 3, '2023-09-15 13:46:36'),
(2021, 377, 293, '0', 'Get task', 'Get task mới', 50, '2023-09-15 13:52:34'),
(2022, 377, 293, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-15 13:52:48'),
(2023, 385, 308, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 18, '2023-09-15 13:54:02'),
(2024, 375, 318, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'7\'', 3, '2023-09-15 14:03:17'),
(2025, 391, 327, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 21, '2023-09-15 14:04:46'),
(2026, 386, 311, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'34\'', 17, '2023-09-15 14:06:16'),
(2027, 386, 311, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-15 14:06:16'),
(2028, 386, 311, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 17, '2023-09-15 14:06:16'),
(2029, 377, 293, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 42, '2023-09-15 14:11:46'),
(2030, 377, 293, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 42, '2023-09-15 14:11:46'),
(2031, 377, 293, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-15 14:19:35'),
(2032, 378, 297, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-15 14:30:52'),
(2033, 384, 307, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-15 14:41:38'),
(2034, 384, 331, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-15 14:41:48'),
(2035, 384, 330, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-15 14:41:55'),
(2036, 387, 319, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'67\'', 15, '2023-09-15 14:45:56'),
(2037, 387, 319, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-15 14:45:56'),
(2038, 387, 319, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-15 14:45:56'),
(2039, 389, 315, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'15\' thành \'0\'', 21, '2023-09-15 15:13:38'),
(2040, 388, 314, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 50, '2023-09-15 15:41:47'),
(2041, 396, 335, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'47\'', 11, '2023-09-15 16:30:08'),
(2042, 396, 335, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-15 16:30:08'),
(2043, 396, 335, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-15 16:30:08'),
(2044, 393, 328, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'60\'', 23, '2023-09-15 17:27:05'),
(2045, 393, 328, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 23, '2023-09-15 17:27:05'),
(2046, 393, 328, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 23, '2023-09-15 17:27:05'),
(2047, 397, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 83 Taylors Creek Way Godwin NC', 6, '2023-09-15 19:42:22'),
(2048, 398, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 6017 Shannon Woods Way Hope Mills NC', 6, '2023-09-15 20:38:00');
INSERT INTO `logs` (`id`, `project_id`, `tasklist_id`, `ccs`, `action`, `action_type`, `user_id`, `timestamp`) VALUES
(2049, 397, NULL, NULL, 'Update Project', 'Field \'description\' Thay đổi từ \'<span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:13309,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" data-sheets-hyperlink=\"https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c\" style=\"text-decoration-line: underline; font-size: 14pt; font-family: Arial; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" href=\"https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c\" target=\"_blank\">https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c</a></span>											\' to \'<p>						<a href=\"https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c\" target=\"_blank\">https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c</a><span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:13309,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" data-sheets-hyperlink=\"https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c\" style=\"text-decoration-line: underline; font-size: 14pt; font-family: Arial; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><a class=\"in-cell-link\" href=\"https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c\" target=\"_blank\"></a></span></p><p><span data-sheets-value=\"{&quot;1&quot;:2,&quot;2&quot;:&quot;https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c&quot;}\" data-sheets-userformat=\"{&quot;2&quot;:13309,&quot;3&quot;:{&quot;1&quot;:0},&quot;5&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;6&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;7&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;8&quot;:{&quot;1&quot;:[{&quot;1&quot;:2,&quot;2&quot;:0,&quot;5&quot;:{&quot;1&quot;:2,&quot;2&quot;:0}},{&quot;1&quot;:0,&quot;2&quot;:0,&quot;3&quot;:3},{&quot;1&quot;:1,&quot;2&quot;:0,&quot;4&quot;:1}]},&quot;9&quot;:0,&quot;10&quot;:2,&quot;11&quot;:4,&quot;12&quot;:0,&quot;15&quot;:&quot;Arial&quot;,&quot;16&quot;:14}\" data-sheets-hyperlink=\"https://lightroom.adobe.com/shares/90db7d3419174339820a871ee723238c\" style=\"text-decoration-line: underline; font-size: 14pt; font-family: Arial; text-decoration-skip-ink: none; color: rgb(17, 85, 204);\"><span style=\"color: rgb(0, 0, 0); font-family: Calibri, Arial, Helvetica, sans-serif; font-size: 16px;\">189 photos</span><br></span>																</p>\'', 6, '2023-09-15 20:38:21'),
(2050, 397, NULL, NULL, 'Update Project', 'Field \'instruction\' Thay đổi từ \'                                    \' to \'                     189 photos                                                   \'', 6, '2023-09-15 20:38:21'),
(2051, 399, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 40 Southport Dr, Howell Township, NJ 07731', 6, '2023-09-15 21:57:58'),
(2052, 400, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 26 Edgeware Close, Freehold NJ ', 6, '2023-09-15 22:18:53'),
(2053, 401, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 351 Wilmot Ave, Bridgeport, CT 06607        ', 8, '2023-09-16 07:29:28'),
(2054, 402, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 19 Iris Ave, York, ME', 8, '2023-09-16 07:30:05'),
(2055, 403, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 31 Linden Ave, Old Orchard Beach, ME ', 8, '2023-09-16 07:30:59'),
(2056, 404, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 922 Shadow Ln, Mt. Juliet, TN 37122	', 8, '2023-09-16 07:31:38'),
(2057, 405, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1638 West Abington Drive, Unit 203 Alexandria Project 1', 8, '2023-09-16 07:32:16'),
(2058, 406, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1638 West Abington Drive, Unit 203 Alexandria Project 2', 8, '2023-09-16 07:32:57'),
(2059, 407, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 8344 Cedar Chase Dr, Fountain, CO 80817', 8, '2023-09-16 07:33:32'),
(2060, 408, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 10 Penny Ln, Bethel, CT 06801', 8, '2023-09-16 07:51:35'),
(2061, 409, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 24126 K-& Hwy', 8, '2023-09-16 07:55:12'),
(2062, 409, 338, '0', 'Get task', 'Get task mới', 15, '2023-09-16 07:55:59'),
(2063, 401, 339, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-16 08:05:18'),
(2064, 401, 339, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'dat.vv\'', 3, '2023-09-16 08:05:18'),
(2065, 410, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 7118 Patton Park Rd. Lyles, TN 37098', 8, '2023-09-16 08:07:24'),
(2066, 402, 340, '0', 'Get task', 'Get task mới', 18, '2023-09-16 08:24:03'),
(2067, 403, 343, '0', 'Get task', 'Get task mới', 19, '2023-09-16 08:29:02'),
(2068, 403, 343, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 19, '2023-09-16 08:33:49'),
(2069, 404, 342, '0', 'Get task', 'Get task mới', 14, '2023-09-16 08:39:42'),
(2070, 407, 341, '0', 'Get task', 'Get task mới', 29, '2023-09-16 09:15:26'),
(2071, 405, 346, '0', 'Get task', 'Get task mới', 20, '2023-09-16 09:19:11'),
(2072, 401, 339, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'30\'', 13, '2023-09-16 09:43:28'),
(2073, 401, 339, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-16 09:43:35'),
(2074, 401, 339, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 13, '2023-09-16 09:43:35'),
(2075, 406, 347, '0', 'Get task', 'Get task mới', 36, '2023-09-16 09:48:14'),
(2076, 411, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 20033 Sancraft Ave, Port Charlotte, FL 33954', 8, '2023-09-16 09:49:47'),
(2077, 406, 347, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'3\'', 36, '2023-09-16 09:57:39'),
(2078, 406, 347, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 36, '2023-09-16 09:57:39'),
(2079, 408, 351, '0', 'Get task', 'Get task mới', 36, '2023-09-16 09:57:43'),
(2080, 402, 340, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'39\'', 18, '2023-09-16 10:08:26'),
(2081, 402, 340, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-16 10:08:26'),
(2082, 402, 340, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 18, '2023-09-16 10:08:26'),
(2083, 410, 348, '0', 'Get task', 'Get task mới', 18, '2023-09-16 10:08:29'),
(2084, 407, 341, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'25\'', 29, '2023-09-16 10:09:53'),
(2085, 407, 341, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-16 10:10:01'),
(2086, 407, 341, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-16 10:10:01'),
(2087, 401, 339, '0', 'Get task', 'Get task mới', 50, '2023-09-16 10:12:42'),
(2088, 401, 339, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-16 10:12:51'),
(2089, 402, 340, '0', 'Get task', 'Get task mới', 50, '2023-09-16 10:12:54'),
(2090, 402, 340, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-16 10:13:03'),
(2091, 407, 341, '0', 'Get task', 'Get task mới', 50, '2023-09-16 10:13:05'),
(2092, 407, 341, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 50, '2023-09-16 10:13:30'),
(2093, 407, 341, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'3\'', 29, '2023-09-16 10:23:18'),
(2094, 407, 341, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 29, '2023-09-16 10:23:18'),
(2095, 379, 322, NULL, 'Update Task', 'Field \'status\' Thay đổi từ \'0\' to \'7\'', 1, '2023-09-16 10:37:16'),
(2096, 379, 322, NULL, 'Update Task', 'Field \'soluong\' Thay đổi từ \'0\' to \'73\'', 1, '2023-09-16 10:38:05'),
(2097, 403, 343, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'43\'', 19, '2023-09-16 10:47:46'),
(2098, 403, 343, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 19, '2023-09-16 10:47:46'),
(2099, 412, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 35 CITRUS DRIVE, PALM HARBOR, FL 34684', 8, '2023-09-16 10:48:22'),
(2100, 413, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 13504 DUNWOODY DRIVE, SPRING HILL, FL 34609', 8, '2023-09-16 10:49:04'),
(2101, 411, 352, '0', 'Get task', 'Get task mới', 23, '2023-09-16 10:49:26'),
(2102, 412, 355, '0', 'Get task', 'Get task mới', 46, '2023-09-16 11:10:59'),
(2103, 413, 358, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 3, '2023-09-16 11:34:20'),
(2104, 413, 358, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'dat.vv\'', 3, '2023-09-16 11:34:20'),
(2105, 409, 338, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'76\'', 15, '2023-09-16 11:35:28'),
(2106, 409, 338, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-16 11:35:28'),
(2107, 409, 338, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 15, '2023-09-16 11:35:28'),
(2108, 401, 339, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 50, '2023-09-16 12:09:35'),
(2109, 404, 342, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'72\'', 14, '2023-09-16 12:18:21'),
(2110, 404, 342, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 14, '2023-09-16 12:18:21'),
(2111, 404, 342, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 14, '2023-09-16 12:18:21'),
(2112, 411, 352, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'29\'', 23, '2023-09-16 12:42:25'),
(2113, 411, 352, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 23, '2023-09-16 12:42:25'),
(2114, 411, 352, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 23, '2023-09-16 12:42:25'),
(2115, 414, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 87-190 Maaloa St, Waianae', 8, '2023-09-16 13:02:06'),
(2116, 402, 340, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 50, '2023-09-16 13:03:12'),
(2117, 407, 341, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'3\' thành \'4\'', 50, '2023-09-16 13:03:20'),
(2118, 415, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 87-179 Kahau St, Waianae', 8, '2023-09-16 13:13:24'),
(2119, 416, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 1867 Fairlawn Ct, Rock Hill, SC 29732', 8, '2023-09-16 13:15:26'),
(2120, 417, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 164 Fern Ave SW, Concord, NC 28025', 8, '2023-09-16 13:16:14'),
(2121, 416, 361, '0', 'Get task', 'Get task mới', 29, '2023-09-16 13:26:51'),
(2122, 418, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 2825 Pali Hwy, B, Honolulu', 8, '2023-09-16 13:35:47'),
(2123, 419, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 66 High Street, Bath ME', 8, '2023-09-16 13:36:42'),
(2124, 420, NULL, NULL, 'Insert Project', 'Tạo Job mới tên: 13 Ellsworth Street, Springvale ME', 8, '2023-09-16 13:37:33'),
(2125, 409, 338, '0', 'Get task', 'Get task mới', 50, '2023-09-16 13:41:05'),
(2126, 409, 338, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'0\'', 50, '2023-09-16 13:41:37'),
(2127, 409, 338, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 50, '2023-09-16 13:41:43'),
(2128, 417, 364, '0', 'Get task', 'Get task mới', 11, '2023-09-16 13:44:17'),
(2129, 419, 365, '0', 'Get task', 'Get task mới', 37, '2023-09-16 14:01:55'),
(2130, 405, 346, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'33\'', 20, '2023-09-16 14:04:15'),
(2131, 405, 346, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 20, '2023-09-16 14:04:15'),
(2132, 405, 346, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 20, '2023-09-16 14:04:15'),
(2133, 420, 366, '0', 'Get task', 'Get task mới', 20, '2023-09-16 14:04:20'),
(2134, 408, 351, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'45\'', 36, '2023-09-16 14:47:33'),
(2135, 408, 351, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 36, '2023-09-16 14:47:42'),
(2136, 408, 351, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 36, '2023-09-16 14:47:42'),
(2137, 416, 362, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-16 15:27:09'),
(2138, 416, 362, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'binh.pn\'', 1, '2023-09-16 15:27:09'),
(2139, 416, 362, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-16 15:28:33'),
(2140, 416, 361, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-16 15:28:43'),
(2141, 416, 361, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'\' sang \'binh.pn\'', 1, '2023-09-16 15:28:43'),
(2142, 416, 361, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-16 15:30:30'),
(2143, 416, 362, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'\' sang \'binh.pn\'', 1, '2023-09-16 15:38:04'),
(2144, 416, 362, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-16 15:40:23'),
(2145, 408, 351, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 36, '2023-09-16 16:49:19'),
(2146, 412, 355, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'55\'', 46, '2023-09-16 17:03:53'),
(2147, 412, 355, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 46, '2023-09-16 17:03:53'),
(2148, 412, 355, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 46, '2023-09-16 17:03:53'),
(2149, 412, 355, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'3\'', 46, '2023-09-16 17:19:06'),
(2150, 417, 364, NULL, 'Cập nhật Task', 'Trường \'soluong\' đã thay đổi từ \'0\' thành \'51\'', NULL, '2023-09-16 17:59:30'),
(2151, 417, 364, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-16 17:59:56'),
(2152, 417, 364, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 11, '2023-09-16 17:59:56'),
(2153, 355, 261, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-16 18:27:47'),
(2154, 355, 262, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-16 18:27:54'),
(2155, 404, 342, '0', 'Get task', 'Get task mới', 49, '2023-09-16 18:27:59'),
(2156, 377, 293, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-16 18:28:04'),
(2157, 409, 338, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-16 18:28:12'),
(2158, 404, 342, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'4\'', 49, '2023-09-16 18:28:17'),
(2159, 401, 339, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-16 18:28:18'),
(2160, 402, 340, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-16 18:28:26'),
(2161, 405, 346, '0', 'Get task', 'Get task mới', 49, '2023-09-16 18:28:39'),
(2162, 404, 342, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-16 18:28:46'),
(2163, 407, 341, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'4\' thành \'7\'', 3, '2023-09-16 18:28:54'),
(2164, 405, 346, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'0\'', 49, '2023-09-16 18:29:03'),
(2165, 411, 352, '0', 'Get task', 'Get task mới', 49, '2023-09-16 18:29:05'),
(2166, 417, 364, '0', 'Get task', 'Get task mới', 9, '2023-09-16 21:06:18'),
(2167, 417, 364, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-16 21:07:40'),
(2168, 417, 364, NULL, 'Update Task', 'Field \'qa\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-16 21:07:40'),
(2169, 356, 265, '0', 'Get task', 'Get task mới', 9, '2023-09-16 21:08:10'),
(2170, 357, 278, '0', 'Get task', 'Get task mới', 9, '2023-09-16 21:08:17'),
(2171, 363, 284, '0', 'Get task', 'Get task mới', 9, '2023-09-16 21:08:21'),
(2172, 364, 287, '0', 'Get task', 'Get task mới', 9, '2023-09-16 21:08:24'),
(2173, 365, 290, '0', 'Get task', 'Get task mới', 9, '2023-09-16 21:08:28'),
(2174, 378, 298, '0', 'Get task', 'Get task mới', 9, '2023-09-16 21:08:31'),
(2175, 377, 294, '0', 'Get task', 'Get task mới', 9, '2023-09-16 21:08:34'),
(2176, 377, 294, NULL, 'Update Task', 'Field \'task\' Thay đổi từ \'\' to \'\'', 1, '2023-09-16 21:12:17'),
(2177, 377, 294, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-16 21:12:17'),
(2178, 377, 294, '0', 'Get task', 'Get task mới', 9, '2023-09-16 22:37:23'),
(2179, 377, 294, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-16 22:38:15'),
(2180, 377, 294, '0', 'Get task', 'Get task mới', 9, '2023-09-16 22:40:25'),
(2181, 377, 294, NULL, 'Update Task', 'Field \'editor\' Thay đổi từ \'binh.pn\' sang \'\'', 1, '2023-09-16 22:41:09'),
(2182, 417, 364, '0', 'Get task (QA)', 'Get task mới cho QA', 9, '2023-09-16 22:47:31'),
(2183, 417, 364, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-16 22:47:47'),
(2184, 377, 294, '0', 'Get task', 'Get task mới', 9, '2023-09-16 22:59:14'),
(2185, 377, 294, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-17 08:44:46'),
(2186, 387, 320, '0', 'Get task', 'Get task mới', 9, '2023-09-17 08:45:05'),
(2187, 390, 325, '0', 'Get task', 'Get task mới', 9, '2023-09-17 08:45:13'),
(2188, 417, 364, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'2\' thành \'4\'', 9, '2023-09-17 08:45:41'),
(2189, 382, 301, '0', 'Get task', 'Get task mới', 9, '2023-09-17 09:01:09'),
(2190, 385, 309, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:02:25'),
(2191, 386, 312, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:02:29'),
(2192, 394, 329, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:02:39'),
(2193, 396, 336, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:03:01'),
(2194, 395, 333, '0', 'Get task', 'Get task mới', 9, '2023-09-17 09:06:16'),
(2195, 420, 367, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-17 09:11:12'),
(2196, 410, 349, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:12:11'),
(2197, 411, 353, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:13:21'),
(2198, 412, 356, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:13:32'),
(2199, 413, 359, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:13:46'),
(2200, 416, 362, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:13:57'),
(2201, 410, 349, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-17 09:23:45'),
(2202, 411, 353, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-17 09:23:50'),
(2203, 412, 356, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-17 09:23:55'),
(2204, 413, 359, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-17 09:24:01'),
(2205, 416, 362, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-17 09:24:14'),
(2206, 403, 344, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:25:32'),
(2207, 420, 368, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-17 09:46:09'),
(2208, 420, 368, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 09:48:13'),
(2209, 420, 368, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-17 09:48:22'),
(2210, 419, 365, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'1\'', 37, '2023-09-17 09:55:06'),
(2211, 419, 365, NULL, 'Cập nhật Task', 'Trường \'c_intruc\' đã thay đổi từ \'0\' thành \'1\'', 37, '2023-09-17 09:55:06'),
(2212, 419, 365, '0', 'Get task (QA)', 'Get task mới cho QA', 9, '2023-09-17 09:55:14'),
(2213, 419, 365, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'1\' thành \'2\'', 9, '2023-09-17 09:55:38'),
(2214, 420, 369, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-17 10:08:44'),
(2215, 420, 369, '0', 'Get task (Editor)', 'Get task mới cho Editor', 9, '2023-09-17 10:08:48'),
(2216, 420, 369, NULL, 'Cập nhật Task', 'Trường \'status\' đã thay đổi từ \'0\' thành \'4\'', 9, '2023-09-17 10:10:08'),
(2217, 405, 370, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-17 10:12:39'),
(2218, 412, 371, NULL, 'Insert Task', 'Tạo Task mới', 1, '2023-09-17 10:15:39'),
(2219, 405, 370, '0', 'Get task', 'Get task mới', 9, '2023-09-17 10:15:46');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `project_list`
--

CREATE TABLE `project_list` (
  `id` int(30) NOT NULL,
  `idkh` int(30) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `instruction` text DEFAULT NULL,
  `intruction1` text DEFAULT NULL,
  `intruction2` text DEFAULT NULL,
  `status` tinyint(2) NOT NULL DEFAULT 1,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `idlevels` varchar(20) NOT NULL,
  `id_invoice` varchar(11) NOT NULL,
  `link_done` varchar(255) DEFAULT NULL,
  `waite_note` varchar(255) DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp(),
  `urgent` int(11) DEFAULT 0,
  `idcb` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `project_list`
--

INSERT INTO `project_list` (`id`, `idkh`, `name`, `description`, `instruction`, `intruction1`, `intruction2`, `status`, `start_date`, `end_date`, `idlevels`, `id_invoice`, `link_done`, `waite_note`, `date_created`, `urgent`, `idcb`) VALUES
(112, 71, '1138 Meadowlark Ln', '', 'Could you please provide HDR Editing and 2D Editing for the above address.  There should be a total of 38 HDR photos and 8 2D photos.  These are the walls that have been coming back brown but are actually gray.  Thank you!\r\n\r\nHDR Photo Link:\r\n\r\n\r\n2D Photo Link:\r\n', NULL, NULL, 3, '2023-09-05 00:52:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1JgNgqVv6ziTHU8a0dRpgF7g3noZKX06E?usp=sharing', '', '2023-09-05 00:56:04', 0, 0),
(113, 72, '6948 Pickett Pl', '', '                        (135 images) 6948 Pickett Pl\r\n\r\nPlease edit the following….Thank you!            ', NULL, NULL, 3, '2023-09-05 01:11:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1k_x2ezANg5nCwJOi30vcTuHhUjWXseaR?usp=sharing', '', '2023-09-05 01:15:34', 0, 0),
(114, 73, '1130 Valley Ridge Ct, Marietta, GA 30067', '', '                  bên dashboard\r\n\r\nPhoto HDR 38                  ', NULL, NULL, 3, '2023-09-05 03:00:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1LbhouVWVnAxsI254d9OISVTI5EgJT64A?usp=sharing', '', '2023-09-05 03:05:12', 0, 0),
(115, 74, '1829 Thompsons Station Rd W', '', 'I would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n(186 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"                     ', NULL, NULL, 3, '2023-09-05 03:39:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/16y8aZF69aMVx8BILTuCTU-WMUR3JuPNm?usp=sharing', '', '2023-09-05 03:42:18', 0, 0),
(116, 75, '1006 Oak Ave, Cañon City, CO 81212', '', 'RUSH RUSH RUSH THIS JOB!!\r\n\r\nPhotos + Drone + DTE\r\n\r\nPhotos: 205 files plus DTE\r\n\r\nDrone: 12 files                 ', NULL, NULL, 3, '2023-09-05 04:26:00', '2023-09-29 20:04:07', '1,8,10', '', 'https://www.dropbox.com/scl/fo/l7hu44ubtlhqtxzpxl3va/h?rlkey=anegd1ds96gmfrd6wgf1orsbh&dl=0', '', '2023-09-05 04:31:49', 1, 3),
(117, 76, 'Listing 95 Wentworth St, Bridgeport, CT 06606', '', '                                              ', NULL, NULL, 3, '2023-09-05 08:36:00', '2023-09-29 20:04:07', '1', '', 'link 1', 'đang hỏi kh số lượng ảnh', '2023-09-05 08:37:20', 0, 0),
(118, 77, '25 Wine Time Cir, Lisbon ME', '', '                   DTE = 0301-0305\r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n\r\n\r\n5X DJI = 100\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 23\r\n\r\n\r\n\r\nUSE MUSIC PROVIDED\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n\r\n\r\nNOTES:\r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                 ', NULL, NULL, 3, '2023-09-05 11:39:00', '2023-09-29 20:04:07', '1,8,10', '', 'https://drive.google.com/drive/folders/1vLwTQ-MfVQkXYm3OETqqxlZypbWoR5qb?usp=drive_link', '', '2023-09-05 11:40:09', 0, 3),
(119, 72, '6948 Pickett Pl, Carmel, IN 46033, USA', '', 'Total number of images with changes:\r\n\r\nTotal number of images without changes: 2\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images: \r\n\r\nProperty style: Traditional\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\n\r\n', NULL, NULL, 3, '2023-09-05 18:22:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-05 18:27:00', 0, 0),
(120, 73, '1190 Watts Rd, Forest Park, GA 30297', '', 'Photo HDR 24\r\nbên dashboard      ', NULL, NULL, 3, '2023-09-05 23:13:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1uzeoFHMWYb-BMHFmIjyK2TSHVaoUYTGe?usp=sharing', '', '2023-09-05 23:16:50', 0, 0),
(121, 78, '2101 Meadowview Dr, Keller, TX 76248', '', '                              \"Hello,\r\nCan you please edit my photos, 4K branded and 4K unbranded videos.\r\n\r\nPhotos-\r\n\r\n\r\nVideo-Please DO NOT SHORTEN CLIP times and place the agent/address in the middle of clip 1 for 8 seconds. Put clips in labeled order Clip 1-10, Stabilize Shakey video, Color Correct and edit in 4K. Thank you!! \r\n\r\n', NULL, NULL, 3, '2023-09-05 23:58:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 00:04:22', 0, 1),
(122, 71, '13544 W 83rd St', '', '\"Could you please provide HDR Editing and 2D Editing for the above address.  There should be a total of 62 HDR photos and 8 2D photos.  Thank you!\r\n\r\nHDR Photo Link:\r\n\r\n\r\n\r\n2D Photo Link:\r\n\r\n                              ', NULL, NULL, 3, '2023-09-06 00:00:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1CKZ6Am98Uu1xs11q-cscTptu70aM0-ym?usp=sharing', '', '2023-09-06 00:07:20', 0, 0),
(123, 79, '18083 Elizabeth', '', '                     \"Good afternoon, Please find the attached photo link for editing. This is a photos and 3D only package. Please straighten all walls interior and exterior as needed. Thank you have a good day. \r\n                                                ', NULL, NULL, 3, '2023-09-06 00:41:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 00:47:31', 0, 0),
(124, 80, 'Photo edit for 1735 Forest Lake Cir W Unit 1', '', '                       Hello Photos to edit fro 1735 Forest Lake Cir W Unit 1 125 photo files Thank you             ', NULL, NULL, 3, '2023-09-06 00:54:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1TihRFosZAYVMBRLMwj6G1RPEsybZknES?usp=sharing', '', '2023-09-06 01:07:25', 0, 0),
(125, 80, 'pictures to edit', '', '   Photos to edit for unit 4307 60 photo files\r\n\r\n\r\n\r\nkh báo: There are 120 photo files not 60                                 ', NULL, NULL, 3, '2023-09-06 01:01:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1U9x4o-ZSG2SdqL9FUXdUdIyOh5hPLMne?usp=sharing', '', '2023-09-06 01:08:17', 0, 0),
(126, 80, 'pictures to edit for 7108', '', '                                    \"Hello Photos to edit for unit 7108 135 photo files \r\n\r\n', NULL, NULL, 3, '2023-09-06 01:05:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1i3Cro0ofFFguIrVIGqSX_dyyH8zsJ3fw?usp=sharing', '', '2023-09-06 01:13:19', 0, 0),
(127, 80, 'pictures to edit for 8314', '', '              Hello Photos to edit for unit 8314 105 photo files                      ', NULL, NULL, 3, '2023-09-06 01:06:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 01:14:42', 0, 0),
(128, 81, '6417 Basil Ct. Fredericksburg, VA', '', '\"Hello Team, \r\n\r\nPlease proceed to do the photo editing, color correction, resizing, stacking and creating HDR Bracket photos, straighten all verticals. \r\n\r\n\r\n\r\nThank you! \"                                    ', NULL, NULL, 3, '2023-09-06 01:46:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 01:49:53', 0, 1),
(129, 82, '1256 Hensfield Dr. Murfreesboro, TN 37128', '', '                                    ', NULL, NULL, 3, '2023-09-06 02:17:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 02:23:03', 0, 1),
(130, 83, '3114 Noe Bixby Rd, Columbus, OH 43232', '', '                      Photo HDR 25\r\n\r\n\r\n\r\n\r\nbên dashboard              ', NULL, NULL, 3, '2023-09-06 02:55:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1KxWfZA73KUmtn1Kpc2p_jgQVyA6X5LXH?usp=sharing', '', '2023-09-06 02:58:30', 0, 0),
(131, 84, '189 HDR Edit 74 McNtt Ave, Albany, NY 12205', '', '                                    ', NULL, NULL, 3, '2023-09-06 04:19:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/16fT5Znpw_mLCSUMa0w5hV9GR_rayd4rh?usp=sharing', '', '2023-09-06 03:19:37', 0, 0),
(132, 85, '1446 NW Lawnridge, Grants Pass, OR', '', '                                    ', NULL, NULL, 3, '2023-09-06 05:02:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 05:09:48', 0, 3),
(133, 77, '18 Simpson Lane, York, ME', '', 'INPUT FILE COUNTS:\r\n5X DJI = 141\r\n5X SONY = 226\r\nVIDEO FILES = 27\r\n\r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                       ', NULL, NULL, 3, '2023-09-06 05:03:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 05:18:21', 0, 3),
(134, 77, '31 Middle Road, Acton, ME', '', '                    INPUT FILE COUNTS:\r\n5X DJI = 239\r\n5X SONY = 231\r\nVIDEO FILES = 28\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                                      ', NULL, NULL, 3, '2023-09-06 05:03:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 05:21:36', 0, 3),
(135, 86, '1606 JOHNSTON - HOMMATI 169', '', 'There are 2 photos with spots (bathroom & bedroom) please remove.                                  ', NULL, NULL, 3, '2023-09-06 05:16:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 05:42:00', 0, 0),
(136, 87, 'TWP 191 EDIT', '', 'TWP 191 EDIT\r\nI\'m requesting an EXPERIENCED EDITOR please . . .\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . . THIS HOME IS BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n175 files . . . thank you                               ', NULL, NULL, 3, '2023-09-06 05:44:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 05:48:54', 0, 0),
(137, 88, '3002 Lime Kiln Ln - Photos', '', '                                    ', NULL, NULL, 3, '2023-09-06 06:02:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 06:06:56', 0, 0),
(138, 88, '4809 Cedar Forest Pl - Photos', '', '                                    ', NULL, NULL, 3, '2023-09-06 06:03:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 06:09:56', 0, 0),
(139, 88, '6008 Robinhood Ln - Photos', '', '                                    ', NULL, NULL, 3, '2023-09-06 06:04:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 06:10:19', 0, 0),
(140, 71, '631 W 59th Terr', '', 'Could you please provide HDR Editing and 2D Editing for the above address.  There should be a total of 48 HDR photos and 9 2D photos.  Thank you!                              ', NULL, NULL, 3, '2023-09-06 06:39:00', '2023-09-29 20:04:07', '', '', '', '', '2023-09-06 06:42:56', 0, 0),
(141, 89, '4939 Floramar Terrace 605N', '', 'We have 240 Photos for 4939 Floramar Terrace 605 N . Please keep our blue sky.\r\nThank You!                                ', NULL, NULL, 3, '2023-09-06 06:55:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 07:00:04', 0, 0),
(142, 74, '516 Doral Country Dr', '', '  \"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n(72 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\r\n\r\n\"            ', NULL, NULL, 3, '2023-09-06 07:44:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1S9WiSzYgtZoJZJxoEq8rlupM-f_owZ8E?usp=sharing', '', '2023-09-06 08:05:50', 0, 0),
(143, 74, '1808 State St apt 207', '', '                                   \"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n\r\n(111 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\" ', NULL, NULL, 3, '2023-09-06 10:13:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 10:13:53', 0, 0),
(144, 90, '1020 Church St, Evanston, IL 60201        ', '', '                           Photo HDR 18         ', NULL, NULL, 3, '2023-09-06 08:16:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1_yBXe0qOdU9DuaXfeT6UYWkH21TwE9Ut?usp=sharing', '', '2023-09-06 10:16:53', 0, 0),
(145, 80, '213 Ventura Rd St Augustine FL 32080', '', '                                              \"\"\"SORRY!!! The count i sent earlier was wrong. This is for 213 Ventura Rd St Augustine FL 32080 145 photo files 17 videos files and 1 agent file Thank you Grace \"\"\r\n                          ', NULL, NULL, 3, '2023-09-06 08:17:00', '2023-09-29 20:04:07', '1,10', '', 'https://drive.google.com/drive/folders/1bZFnlkt5wD7Ym3Ux258Tf0d7O0qKplgr?usp=sharing', '', '2023-09-06 10:17:45', 0, 0),
(146, 75, '5519 Rose Ridge Ln, Colorado Springs, CO 80917', '', '                           \"Photos + Drone + DTE\r\n\r\nPhotos: 135 plus DTE\r\n\r\nDrone: 11 files\r\n ', NULL, NULL, 3, '2023-09-06 08:18:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 10:19:27', 0, 3),
(147, 75, '4576 Seton Hall Rd, Colorado Springs, CO 80918', '', '                                   \"Photos + Drone + DTE + Social media\r\n\r\nPhotos: 225 plus DTE\r\n\r\nDrone: 11 files\r\n\r\nSocial Media: 26 files\r\n', NULL, NULL, 3, '2023-09-06 08:19:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 10:20:06', 0, 3),
(148, 75, '270 Dixie St, Palmer Lake, CO 80133', '', '                                    \"Photos + Drone \r\n\r\nPhotos: 145 files NO DTE\r\n\r\nDrone:  14 files\r\n', NULL, NULL, 3, '2023-09-06 08:20:00', '2023-09-29 20:04:07', '1,10', '', '', '', '2023-09-06 10:20:48', 0, 0),
(149, 75, '15847 Long Valley Dr, Colorado Springs, CO 80921', '', '                              \"Photos + Drone + DTE + Social Media\r\n\r\nPhotos: 191 files\r\n\r\nDrone: 10 files\r\n\r\nSocial Media: 15 files\r\n', NULL, NULL, 3, '2023-09-06 10:21:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 10:21:38', 0, 3),
(150, 75, '8978 Braemore Hts, Colorado Springs, CO 80927', '', '                                  \"Photos + Drone + DTE + Social Media\r\n\r\nPhotos: 120 Files\r\n\r\nDrone: 9 files\r\n\r\nSocial Media:  19 files\r\n', NULL, NULL, 3, '2023-09-06 10:21:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 10:22:10', 0, 3),
(151, 85, '1032 Thelma ln, Grants Pass, OR', '', '                  \"Plat Pak\"                  ', NULL, NULL, 3, '2023-09-06 10:22:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 10:22:53', 0, 3),
(152, 87, 'HILTON EDIT', '', 'HILTON EDIT\r\nI\'m requesting an EXPERIENCED EDITOR please . . .\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . . THIS HOME IS BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n250 files . . . thank you\r\n', NULL, NULL, 3, '2023-09-06 10:23:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 10:23:48', 0, 0),
(153, 87, 'WITHERSPOON EDIT', '', '                                    ', NULL, NULL, 3, '2023-09-06 10:24:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 10:24:45', 0, 0),
(154, 87, 'UPPER ALBANY EDIT', '', '                               \"UPPER ALBANY EDIT\r\nI\'m requesting an EXPERIENCED EDITOR please . . .\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . . THIS PROPERTY IS BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n55 files . . . thank you\r\n\r\n', NULL, NULL, 3, '2023-09-06 10:24:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 10:25:12', 0, 0),
(155, 87, 'HECKERT EDIT', '', '                        HECKERT EDIT\r\nI\'m requesting an EXPERIENCED EDITOR please . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n205 files . . . thank you\r\n           ', NULL, NULL, 3, '2023-09-06 10:25:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 10:25:49', 0, 0),
(156, 77, '181 York Woods Rd, South Berwick ME', '', '                    \r\n\r\n                     DTE = 0006-0010\r\n\r\n \r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 115\r\n\r\n5X SONY = 292\r\n\r\nVIDEO FILES = 23\r\n\r\n \r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nUSE MUSIC PROVIDED\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"              ', NULL, NULL, 3, '2023-09-06 12:30:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 12:30:51', 0, 3),
(157, 88, '738 Old Hillsboro Rd, Henniker NH', '', '                               \r\n \r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 80\r\n\r\n5X SONY = 150\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\r\n\r\n\" ', NULL, NULL, 3, '2023-09-06 12:33:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 12:34:05', 0, 0),
(158, 92, '8836 Glendale Cir Manhattan KS', '', 'Hello, I have shared:\r\n-40 photos for HD editing\r\nPhotos are currently uploading in the shared album                         ', NULL, NULL, 3, '2023-09-06 23:16:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-06 23:22:25', 0, 0),
(159, 83, '2633 Tally Ho Dr, Blacklick, OH 43004', '', 'Photo HDR , Aerial Video        52 \r\nTwilight Images - 2                           ', NULL, NULL, 3, '2023-09-06 23:46:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-06 23:49:44', 0, 3),
(160, 80, 'photos to edit 13 Arbor Club Dr Unit 101 Ponte Vedra Beach FL 32082', '', 'Hello, Here are the files to be edited for 13 Arbor Club Dr, unit 101. There are 110 pictures in the folder.                                 ', NULL, NULL, 3, '2023-09-06 23:54:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 00:01:24', 0, 0),
(161, 93, '10361 Champions Cir', '', 'Could you please edit these bracketed photos.  I shot 5 brackets one stop apart using a Sony a7RIII with a Sigma 14-24mm F2.8 lens. \r\n\r\nThere should be 115 raw bracketed photos, meaning there will be 23 edited photos.                                   ', NULL, NULL, 3, '2023-09-07 00:42:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 00:51:35', 0, 0),
(162, 94, '6031 Heckert Rd, Westerville, OH 43081, USA', '', 'Total number of images without changes: 1\r\n\r\nProperty style: Transitional\r\n\r\nSpecial Instructions:Please label this photo as Virtually Staged. Please stage this photo as a Great Room. Please stage a t.v. on the wall immediately to the left of the fireplace with a narrow depth table underneath the t.v. Please use neutral colors for the furniture. Please stage a picture above any furniture that is placed on the left wall. Please fill in the room with any Great Room accessories.                      ', NULL, NULL, 3, '2023-09-07 00:42:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-07 00:54:34', 0, 0),
(163, 81, '611 Truslow Rd. Fredericksburg, VA', '', 'Please proceed to do the photo editing, color correction, resizing, stacking and creating HDR Bracket photos, straighten all verticals.                                   ', NULL, NULL, 3, '2023-09-07 01:36:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 01:43:54', 0, 3),
(164, 95, '2311 Kala St, Helena, AL 35080', '', 'Photo HDR        42                                  ', NULL, NULL, 3, '2023-09-07 01:55:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 01:59:19', 0, 0),
(165, 94, '141 Canaan Rd NH, Strafford, Strafford 03884', '', 'Total number of twilight enhancement images: 1\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\"                                    ', NULL, NULL, 3, '2023-09-07 02:09:00', '2023-09-29 20:04:07', '', '', '', '', '2023-09-07 02:23:33', 0, 0),
(166, 88, '3209 Radiance Rd', '', '                                    ', NULL, NULL, 3, '2023-09-07 02:38:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 02:47:01', 0, 0),
(167, 96, '169 Oak Glen Road, Howell, NJ', '', '   Please complete a plat pak+ HDR.  Please add fire to indoor fireplace.                          ', NULL, NULL, 3, '2023-09-07 02:50:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 02:57:51', 0, 3),
(168, 97, '1925 Ruckle St. Indianapolis, IN 46202', '', '\"I need HDR Bracketed editing for 1925 Ruckle St. Indianapolis, IN 46202\r\nPhoto edit, color correction, add blue sky (if needed), resizing, stacking, and creating HDR Bracket photos (58 images total).\r\n  (290 files).\r\n\r\nPlease let me know if you have any questions.\"                                    ', NULL, NULL, 3, '2023-09-07 03:42:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 03:45:35', 0, 0),
(169, 98, '11 Nancy Allen St, Crawfordville, FL 32327', '', '90 photos                        ', NULL, NULL, 3, '2023-09-07 03:52:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 04:17:15', 0, 0),
(170, 72, '792 Daybreak Dr', '', 'Please edit the following….Thank you!\r\nHDR (115) Single (5)                                ', NULL, NULL, 3, '2023-09-07 03:54:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 04:17:48', 0, 0),
(171, 73, '1981 North Rd SW, Snellville, GA 30078', '', '\"Photo HDR        35                            ', NULL, NULL, 3, '2023-09-07 04:10:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 04:24:42', 0, 0),
(172, 76, '39 Cherry St, Newtown, CT 06482', '', '\"Photo HDR        36 \r\nPlease straighten and enhance these RAW files to HDR photos.                      ', NULL, NULL, 3, '2023-09-07 04:19:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 04:26:22', 0, 0),
(173, 80, 'Photo edit 12948 Gillespie Ave', '', '\"Hello, Here is the link for photo editing and there are 125 files in this folder. Thanks                                  ', NULL, NULL, 3, '2023-09-07 04:22:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 04:33:55', 0, 0),
(174, 80, '189 Greencrest Dr Ponte Vedra Beach FL 32082', '', '\"Hello, Here is the link for a Plat Pak. There are 195 files in the photo editing folder There are 20 files in the video folder. Thanks                                ', NULL, NULL, 3, '2023-09-07 04:24:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 04:35:18', 0, 3),
(175, 93, '6514 Prairie Dunes Dr', '', 'Could you please edit these bracketed photos.  I shot 5 brackets one stop apart using a Sony a7RIII with a Sigma 14-24mm F2.8 lens. \r\n\r\nThere should be 110 raw bracketed photos, meaning there will be 22 edited photos. \r\n\r\nThe photos start at DSC09971.                                 ', NULL, NULL, 3, '2023-09-07 04:33:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 04:36:28', 0, 0),
(176, 73, '514 Mehaffey Dr, Fairburn, GA 30213', '', '  \"Photo HDR        27                            ', NULL, NULL, 3, '2023-09-07 04:38:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 04:42:38', 0, 0),
(177, 71, '3013 Westdale Rd', '', 'Could you please provide HDR Editing and 2D Editing for the above address.  There should be a total of 65 HDR photos and 8 2D photos.  Thank you!                               ', NULL, NULL, 3, '2023-09-07 04:43:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 04:45:37', 0, 0),
(178, 89, '3509 Seaway Drive', '', '\"We have 330 photos foe 3509 Seaway Drive. Please leave our blue sky in the shots.                               ', NULL, NULL, 3, '2023-09-07 05:04:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 05:11:46', 0, 0),
(179, 94, '2047 Sicily Ln TX, Haslet, Tarrant 76052', '', 'Total number of blue sky/green grass enhancement images: 13\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:Please add green grass to all areas with yellow grass or dirt. Thank you!                                  ', NULL, NULL, 3, '2023-09-07 05:07:00', '2023-09-29 20:04:07', '', '', '', '', '2023-09-07 05:12:35', 0, 0),
(180, 99, '39347 Corte Alisos, Murrieta, CA 92563', '', '\"Photo HDR        35\r\nPlease remove 2 dots on most pictures. 1 dot top middle right of picture, 2nd dot left side 3/4 of way up picture.                                 ', NULL, NULL, 3, '2023-09-07 05:46:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 05:50:49', 0, 0),
(181, 87, 'CLEARFORK EDIT', '', '\"CLEARFORK EDIT\r\nI\'m requesting an EXPERIENCED EDITOR please . . .\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . . THIS HOME HAS LOTS OF WHITE . . . NO YELLOW TONES\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n230 files . . . thank you                             ', NULL, NULL, 3, '2023-09-07 06:12:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 06:27:34', 0, 0),
(182, 75, '341 Plainview Pl, Manitou Springs, CO 80829', '', '  \"Photos + Drone  + Social Media NO DTE\r\n\r\nPhotos: 130 files\r\n\r\nDrone: 13 files\r\n\r\nSocial Media: 17 files                                ', NULL, NULL, 3, '2023-09-07 06:27:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 06:44:06', 0, 3),
(183, 77, '867 Harpswell Island Road, Harpswell, ME', '', 'INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 142 jpegs\r\n\r\n5X SONY = 151\r\n\r\nVIDEO FILES = 24\r\n\r\n \r\n\r\nONLY SENDING JPEG FILES FOR DJI ON THIS JOB, NO DNG\r\n\r\n\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-07 06:30:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 06:44:48', 0, 3),
(184, 95, '176 New Hope Mountain Rd, Pelham, AL 35124', '', '\"Photo HDR , Aerial Video        57\r\nDTE Front shot of house\"                                    ', NULL, NULL, 3, '2023-09-07 06:34:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 06:45:31', 0, 3),
(185, 77, '4 Honeysuckle Lane, Old Orchard Beach, ME', '', 'INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 96\r\n\r\n5X SONY = 171\r\n\r\nVIDEO FILES = 22\r\n\r\n\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-07 06:34:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 06:46:10', 0, 3),
(186, 75, '4999 Rusty Nail Point, Colorado Springs, CO 80916', '', '\"Photos + Drone + DTE + Social Media\r\n\r\nPhotos: 145 plus DTE\r\n\r\nDrone: 11 files\r\n\r\nSocial Media: 16 files                              ', NULL, NULL, 3, '2023-09-07 06:31:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 06:59:06', 0, 3),
(187, 100, '1550 S Blue Island Ave 1108 Chicago IL', '', '\"I have a photo editing job for a listing that is already live on the MLS, so I can\'t create a project and order it through there. Will you please respond to this email to let me know that you\'ve received this and can do it in the normal turnaround time? I\'ve included a link to the files below. There are 16 photos.\r\nThank you!!                                 ', NULL, NULL, 3, '2023-09-07 06:52:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 07:00:21', 0, 0),
(188, 87, 'FREEDOM RIDGE EDIT', '', '\"FREEDOM RIDGE EDIT\r\nI\'m requesting an EXPERIENCED EDITOR please . . .\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n175 files . . . thank you                         ', NULL, NULL, 3, '2023-09-07 06:58:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 07:02:53', 0, 0),
(189, 101, '140 West G St. Benicia, CA', '', '                    \"Hi,\r\n\r\nHere\'s the link for HDR editing for 140 West G St.\r\n\r\n\r\n\r\nThanks,\r\n\r\n                ', NULL, NULL, 3, '2023-09-07 07:16:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 07:17:45', 0, 0),
(190, 87, 'OH 180 EDIT', '', '\"OH 180 EDIT\r\nI\'m requesting an EXPERIENCED EDITOR please . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n200 files . . . thank you\r\n\r\n1 item\r\nOH 180 EDIT\r\n Folder・200 items\"                                    ', NULL, NULL, 3, '2023-09-07 07:39:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 07:40:00', 0, 0),
(191, 102, '2800 Keller Dr, Tustin CA 92782', '', '      \"There are a total of 28, 5-Bracketed images.\r\n\r\nPlease edit and deliver these photos in maximum size (20-40MB) and dimension (7968 x 5320).  \r\n\r\n\r\n\r\nThank you for your assistance,\"                              ', NULL, NULL, 3, '2023-09-07 07:42:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 07:43:03', 0, 0),
(192, 91, '5936 Downfield Wood Dr, Charlotte, NC 28269', '', '  \"Photo HDR , Aerial Video        47 \r\n\r\nTwilight Images - 2        Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"                                  ', NULL, NULL, 3, '2023-09-07 08:50:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 08:50:58', 0, 3),
(193, 103, '16828 Heather Moor Dr, Florissant, MO 63034', '', '                  \r\nPhoto HDR , Aerial Video 35\r\n\r\nPH, Please edit 175 RAW images for 35 total photos. Create unbranded and branded aerial video w/ usable footage from 27 clips in accordance w/ Hommati standard, Headshot and logo provided and splash vid. DTE for images DJI_0756 & DJI_0796.                  ', NULL, NULL, 3, '2023-09-07 08:52:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 08:52:50', 0, 3),
(194, 104, 'HDR 3-1 202 Harrison St. SE Leesburg, VA Project 1', '', '\"Hi to everyone at Photohome, \r\n\r\nPlease find the link below for our album - HDR 3-1 202 Harrison St. SE Leesburg, VA Project 1. This album should contain 63 exposures of 21 images. \r\n\r\n                               ', NULL, NULL, 3, '2023-09-07 08:54:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 08:55:09', 0, 0),
(195, 104, 'Aerial Stills 202 Harrison St. SE Leesburg, VA Project 2', '', '    \"Hello to everyone at Photohome,\r\n\r\n\r\nPlease find the link below for our album – Aerial Stills 202 Harrison St. SE Leesburg, VA Project 2. This album should contain 98 images. \r\n\r\n                         ', NULL, NULL, 3, '2023-09-07 08:55:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 08:55:37', 0, 0),
(196, 91, '4320 NC-73, Concord, NC 28025', '', '                2D Snapshot        34\"                    ', NULL, NULL, 3, '2023-09-07 09:56:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 09:57:04', 0, 0),
(197, 89, '1713 GULF BEACH BLVD, TARPON SPRINGS, FL 34689', '', ' \"Photo HDR , Aerial Video        37\r\n\r\nTwilight Images - 2        Total Images\r\n2 \r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"                                   ', NULL, NULL, 3, '2023-09-07 09:57:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 09:58:01', 0, 3),
(198, 103, '3985 Nara Dr, Florissant, MO 63033', '', '                               \r\nPhoto HDR	33\r\nPH, Please edit 165 RAW files for a total of 33 images.\"', NULL, NULL, 3, '2023-09-07 09:58:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 09:58:58', 0, 0),
(199, 105, '387 Hunington Ave, Eugene, OR 97405', '', '            \r\nPhoto HDR        28\r\nPlease do not replace sky, These are urgent - I need within the 2-4 hours please and if at all possible, closer to 2. I\"    ', NULL, NULL, 3, '2023-09-07 10:00:00', '2023-09-29 20:04:07', '', '', '', '', '2023-09-07 10:01:17', 1, 0),
(200, 75, 'Twilight Shoot', '', 'Thank you for the hard work on this job.  Everything looks awesome.  The agent requested that I go back and capture some night time shots.  In this folder there are some drone video clips and some social media clips.   Can you integrate a few of each into the perspective videos please?  A couple drone clips in the drone videos and a couple social media clips in the social media videos?\r\n\r\nAlso, I added a few twighlight photos to be added to this job.\r\n\r\nThank you!!\r\n\r\nPhotos: 50 files\r\n', NULL, NULL, 3, '2023-09-07 10:01:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 10:02:08', 0, 3),
(201, 105, '3 Lots Coburg, Or DR', '', '   \"Please do not replace sky.\r\nIf you can remove some of the haze from the wild fires in the distance that would be great.\r\n\r\n\r\n\r\n\r\nTotal Photos = 24\r\n\r\nThanks\r\n\"', NULL, NULL, 3, '2023-09-07 10:22:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 10:23:15', 0, 0),
(202, 105, '3990 Terrace Trail, Eugene, OR 97405 DR', '', '                 \"Please edit.\r\n\r\nDo not replace sky.\r\nPlease see if you can decrease the haze in the distant shots.\r\n\r\n\r\n\r\n\r\n11 Photos\"                   ', NULL, NULL, 3, '2023-09-07 10:10:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 11:00:39', 0, 0),
(203, 84, '189 video Edit 167 Wood Dale Dr, Ballston Lake, NY 12019', '', '                                  ', NULL, NULL, 3, '2023-09-07 10:10:00', '2023-09-29 20:04:07', '10', '', '', '', '2023-09-07 11:01:50', 0, 0),
(204, 84, '189 HDR Edit 167 Wood Dale Dr, Ballston Lake, NY 12019', '', '                                                                        ', NULL, NULL, 3, '2023-09-07 10:10:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 11:02:20', 0, 0),
(205, 84, '189 HDR Edit 267 West Deans Mill Road, Coxsackie, NY 12192', '', '                                    ', NULL, NULL, 3, '2023-09-07 10:10:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-07 11:02:53', 0, 0),
(206, 106, ' 7 Wilmot St', '', '                    \"Hi, \r\n\r\nGood Morning! Here are the details for this listing 7 Wilmot St\r\n\r\n \r\n\r\nPackage Type : PlatPak+ Video And Photo Editing Package\r\n\r\nDrive Information:\r\n\r\n\r\nTotal Number of Regular Photos: 33\r\nTotal Number of Twilight Photos: 2\r\nTotal Number of Video files: 9\r\nTotal Number of Photos to be used in Videos: 6\r\n \r\n\r\nPhoto Requirement:\r\n\r\nFinal Photo output size  - 7MB -10MB, we are allowed upto 12 MB files.\r\nWindow Treatment – Blue sky to all window pull\r\n\r\nPhoto Editing:\r\nPlease refer to images in this folder for corrections:\r\n\r\nhttps://drive.google.com/drive/folders/1z2JkV6etiUKb5ZjLuJjwZLAspA16OZxK?usp=sharing\r\n\r\ndsc_5132 - remove fan and wire on the floor, remove everything by the window.\r\ndsc_5141 - remove all visible wires and remove fan on the floor.\r\ndsc_5144 - remove white wire on the floor, remove vacuum cleaner and all blankets near the couch.\r\ndsc_5156 - remove everything including wire in the landing area.\r\ndsc_5159 - fix fan \r\ndsc_5174 - fix fan \r\ndsc_5185 - remove everything on the table and the corner shelf and the center table with stuff on it  \r\ndsc_5196 - fix fan \r\ndsc_5199 - remove sun light from ceiling\r\ndsc_5211 - remove sunlight from ceiling and remove purple patch on the wall.\r\ndsc_5256 - remove green coat rack and fix fan\r\ndsc_5273 - remove everything in basement - make basement empty except washer and dryer.\r\ndsc_5284 - remove everything in the basement except the washer and dryer.\r\ndsc_5294 - remove red bricks and broom on the back wall and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon\r\ndsc_5304 - remove red bricks on the wall and broom and remove clutter on top of the fire pit, remove vehicles, remove decoration ribbon\r\ndsc_5322 - remove cars\r\ndsc_5331 - remove cars\r\n\r\nVideo Requirement:  \r\n\r\nClip 1 – Photo of the property with client information\r\nClient Info : https://drive.google.com/drive/folders/1aEmXYwav_8GoozSx3XcQ40aSetgnTkYM?usp=share_link\r\nHouse Address to be added on clip 1 – 7 Wilmot St, East Brunswick, NJ\r\nAfter few clips, Insert Photos\r\nAfter photos combine these videos for the flow\r\nHommati splash video at the end  ( Do not add client details at the end)\r\n \r\n\r\nThanks\"                ', NULL, NULL, 3, '2023-09-07 10:36:00', '2023-09-29 20:04:07', '1,8,9', '', '', '', '2023-09-07 11:06:44', 0, 3),
(207, 78, '4234 N I35, Denton, TX 76207', '', '                                 \"Hello,\r\nCan you please edit my photos, 4K branded and 4K unbranded videos.\r\n\r\nPhotos-\r\n\r\n\r\n4234 N Interstate 35, Denton, TX 76207\r\nadobe.ly\r\n\r\nVideo-Please DO NOT SHORTEN CLIP times and place the agent/address in the middle of clip 1 for 8 seconds. Put clips in labeled order Clip 1-10, Stabilize Shakey video, Color Correct and edit in 4K. Thank you!! \r\n\r\nhttps://we.tl/t-ulOxbAPdOD \r\nJohn Torres Branded Video Intro Template Elements.psd\r\n3 files sent via WeTransfer, the simplest way to send your files around the world\r\nwe.tl\r\n\r\nThank you,\r\n\"   ', NULL, NULL, 3, '2023-09-07 10:36:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 11:08:07', 0, 3),
(208, 94, '181 York Woods Rd ME, South Berwick, York 03908', '', '     0001MT / 0110MT                         \"Total number of images with changes: 0\r\n\r\nTotal number of images without changes: 3\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:3 Photos to Stage #123 - Living Room (see reference for other view) #143 - Family Room (see reference for other view) #148 - Primary Bedroom (see reference for other view)\r\n\r\nOption\r\n\r\n \"      ', NULL, NULL, 3, '2023-09-07 10:45:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-07 11:09:41', 0, 0),
(209, 107, '13600 Thornhill Place Chester, VA', '', '\r\n\r\nPhotographs\r\n\r\nDrone Videos\r\n\r\n Drone Pictures\r\n\r\n \"                        ', NULL, NULL, 3, '2023-09-07 10:54:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-07 11:12:20', 0, 0),
(210, 94, '1561 Upper Woods Rd PA, Pleasant Mount, Wayne 18453', '', 'Total number of images without changes: 4\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nProperty style: Farm House\r\n\r\nSpecial Instructions:File 1: Add Kitchen Stool at the Counter and a Family Room in the rear of the photo File 2: Primary Bedroom Suite with Bed, dressers and night tables File 3: Formal Living Room with Couch, chairs and coffee table File 4: Formal Dining Room with Table, chairs and Wall decorations Outdoor Photos for Twighlight enhancement                                ', NULL, NULL, 3, '2023-09-07 23:56:00', '2023-09-29 20:04:07', '8,9', '', '', '', '2023-09-07 23:59:44', 0, 0),
(211, 97, '743 N Emerson Ave, Indianapolis, IN 46219', '', '                      Photo HDR , Aerial Video 40\r\nGoogle Drive folder includes Drone Videos and 14 Drone still images for editing.              ', NULL, NULL, 3, '2023-09-08 11:39:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-08 11:40:26', 0, 3),
(212, 80, 'Photo edit 104 Elk Grove Ln', '', '                                    ', NULL, NULL, 3, '2023-09-08 11:40:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-08 11:40:56', 0, 0),
(213, 72, '1302 Wyoming Dr', '', '                                    ', NULL, NULL, 3, '2023-09-08 11:41:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-08 11:41:51', 0, 0),
(214, 87, 'GLEN MAWR 94 EDIT ', '', '                     GLEN MAWR 94 EDIT\r\nI\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nTHIS HOME IS BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES . . .\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n135 files . . . thank you               ', NULL, NULL, 3, '2023-09-08 11:42:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-08 11:42:22', 0, 0),
(215, 88, '8803 KY-401, Custer, KY 40115', '', '                              Photo HDR 33      ', NULL, NULL, 3, '2023-09-08 11:42:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-08 11:42:46', 0, 0),
(216, 102, '1454 Lovers Ln, Lake Arrowhead CA 92352', '', '                             There are a total of 57, 5-Bracketed images.\r\n\r\nPlease edit and deliver these photos in maximum size (20-40MB) and dimension (7968 x 5320).       ', NULL, NULL, 3, '2023-09-08 11:42:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-08 11:43:13', 0, 0),
(217, 94, '213 Inverness Dr TX, Trophy Club, Denton 76262', '', '   \"Total number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 1\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:Please no gold windows and not to dark. I have some examples in the link. https://photos.app.goo.gl/kQHcfXBDwu2VQFWu8 \r\n\r\nOption 0001MT(0108MT)\r\n\r\n \"                                 ', NULL, NULL, 3, '2023-09-09 23:20:00', '2023-09-29 20:04:07', '8', '', '', '', '2023-09-09 00:15:36', 0, 0),
(218, 77, '67 Welch\'s Point Road, East Winthrop, ME', '', '\r\n\r\nINPUT FILE COUNTS:\r\n\r\n 5X DJI = 146\r\n\r\n5X SONY = 151\r\n\r\nVIDEO FILES = 25\r\n\r\n \r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nUSE MUSIC PROVIDED\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-09 07:38:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 00:17:24', 0, 3),
(219, 77, '22 Fernwood Drive, West Bath, ME22 Fernwood Drive, West Bath, ME', '', '\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 182\r\n\r\n5X SONY = 236\r\n\r\nVIDEO FILES = 21\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-08-09 07:39:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 00:19:43', 0, 3),
(220, 0, '675 River Road, Leeds, ME', '', '\r\n\r\nINPUT FILE COUNTS:\r\n\r\n5X DJI = 157\r\n\r\n5X SONY = 241\r\n\r\nVIDEO FILES = 21\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                 ', NULL, NULL, 3, '2023-08-09 07:37:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 00:20:57', 0, 3),
(221, 98, '242 Royal Tern Way, Carrabelle, FL 32322', '', '                  90 photos                  ', NULL, NULL, 3, '2023-09-09 00:15:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 00:23:43', 0, 0),
(222, 73, '210 Flowers Dr, Covington, GA 30016', '', '                          \"Photo HDR , Aerial Video     35\r\n\r\nTwilight Images - 2        Total Images\r\n2  \r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"                                              ', NULL, NULL, 3, '2023-09-09 01:34:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 02:41:31', 0, 3),
(223, 83, '137 W Church St, Newark, OH 43055', '', '                          \"Photo HDR , Aerial Video        77\r\n\r\nTwilight Images - 2        Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"          ', NULL, NULL, 3, '2023-09-09 02:00:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 02:43:04', 0, 3),
(224, 82, '4125 Cider Dr. Murfreesboro, TN 37129', '', '                                    ', NULL, NULL, 3, '2023-09-09 03:04:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 03:27:36', 0, 3),
(225, 82, '505 Douglas', '', '                                                                        ', NULL, NULL, 3, '2023-09-09 03:04:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 03:28:04', 0, 0),
(226, 102, '231 Crest Cir, Lake Arrowhead CA 92352', '', '   \"There are a total of 39, 5-Bracketed images.\r\n\r\nPlease edit and deliver these photos in maximum size (20-40MB) and dimension (7968 x 5320).  \r\n\r\nThank you for your assistance,\"                                 ', NULL, NULL, 3, '2023-09-09 03:32:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 03:34:39', 0, 0),
(227, 72, '16571 Lakeville Crossing', '', ' Editing 145 (HDR) 7 (Singles) 16571 Lakeville Crossing\r\nHello!\r\n\r\n \r\n\r\nPlease edit the following.  Thank you!!\r\n\r\n \r\n\r\n                        ', NULL, NULL, 3, '2023-09-09 03:42:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 03:45:00', 0, 0),
(228, 71, '102 NW 2nd St', '', '            \"Hello,\r\n\r\nCould you please provide HDR Editing and 2D Editing for the above address.  There should be a total of 30 HDR photos and 8 2D photos.  Thank you!\r\n\r\n                   ', NULL, NULL, 3, '2023-09-09 03:53:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 04:04:01', 0, 0);
INSERT INTO `project_list` (`id`, `idkh`, `name`, `description`, `instruction`, `intruction1`, `intruction2`, `status`, `start_date`, `end_date`, `idlevels`, `id_invoice`, `link_done`, `waite_note`, `date_created`, `urgent`, `idcb`) VALUES
(229, 87, 'CHELSEA GREEN EDIT', '', '          \"CHELSEA GREEN EDIT\r\nI\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nTHIS HOME IS VERY BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n305 files . . . thank you\r\n\r\n                 ', NULL, NULL, 3, '2023-09-09 04:07:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 04:09:57', 0, 0),
(230, 108, '2203 Dawn Way by Timothy Wallace', '', '    \r\n\r\nPlease edit the HDR and bracketed aerial photos for the following link:                             ', NULL, NULL, 3, '2023-09-09 04:15:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 04:18:56', 0, 0),
(231, 71, '609 SE 21st St', '', '   \"Hello,\r\n\r\nCould you please provide HDR Editing only for the above address.  There should be a total of 42 HDR photos.  Thank you!\r\n\r\n\r\n\"                                 ', NULL, NULL, 3, '2023-09-09 04:24:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 04:32:02', 0, 0),
(232, 109, '480 Frisco Ct', '', '                                    ', NULL, NULL, 3, '2023-09-09 04:28:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 04:33:39', 0, 0),
(233, 0, '306 N Yadkin Ave, Spencer, NC 28159', '', '                                    2D Snapshot        35\"', NULL, NULL, 3, '2023-09-09 04:43:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 05:30:42', 1, 0),
(234, 103, '211 Pearl Vista Dr, O\'Fallon, MO 63376', '', '\r\n Photo HDR , Aerial Video        35\r\n\r\nPH, Please edit 175 RAW files for a total of 35 photos. Please create aerial video using all usable footage from 18 video clips in accordance with Hommati standard. DTE for images DJI_0908 and DJI_0933 Please confirm receipt.\"                                   ', NULL, NULL, 3, '2023-09-09 04:40:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 05:31:48', 1, 3),
(235, 89, '202 Callaway Avenue', '', '   \"Hi!\r\n\r\nWe have 325 photos for 202 Callaway Avenue. Please add Blue Sky only when needed... we had blue skies in one direction and gray sky in another direction.\r\n\r\n\r\n                   ', NULL, NULL, 3, '2023-09-09 05:25:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 05:32:29', 0, 0),
(236, 92, '3588 Colorado Rd Pomona KS', '', '                                   \"Hello, I have shared:\r\n-270 photos for HDR Bracketed editing\r\n-5 photos for HD editing\r\nThank you!\"                                     ', NULL, NULL, 3, '2023-09-09 05:26:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 05:33:22', 0, 0),
(237, 90, '6700 S South Shore Dr, 8H, Chicago, IL 60649', '', '                                    Photo HDR , Aerial Video	35', NULL, NULL, 3, '2023-09-09 05:32:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 05:37:32', 0, 0),
(238, 90, '333 E Center St, Glenwood, IL 60425', '', '          \"Photo HDR , Aerial Video	35\r\n\r\nTwilight Images - 2	Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"                          ', NULL, NULL, 3, '2023-09-09 05:36:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 06:01:59', 0, 3),
(239, 90, '9847 Huber Ln, Niles, IL 60714', '', '  \"Photo HDR , Aerial Video	35\r\n\r\nTwilight Images - 2	Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"                                  ', NULL, NULL, 3, '2023-09-09 05:38:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 06:03:02', 0, 3),
(240, 77, '1072 Post Road, Wells ME, Unit 129', '', '\r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n\r\n\r\n5X SONY = 150\r\n\r\n\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"\r\nNo, there is no video for this request.                                 ', NULL, NULL, 3, '2023-09-09 05:47:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 06:04:58', 0, 0),
(241, 77, '188 North Street, Bath ME', '', '                    \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 50\r\n\r\n5X SONY = 240 \r\n\r\n \r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\r\n\r\nNo, there is no video for this request.                                                   ', NULL, NULL, 3, '2023-09-09 05:48:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-09 06:06:03', 0, 3),
(242, 110, '2601 La Honda Dr, Anchorage, AK 99517', '', '\"Photo HDR	31\r\n\r\nI don\'t think we can add fire to the fireplaces in this one, they had some candles stored in there, to add fire would probably look strange... On the shot in the living room towards the TV I am visible in the TV reflection, can you please make sure to make the TV screen just black and get rid of the reflection? Thanks!\"                 ', NULL, NULL, 3, '2023-09-09 05:52:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-09 06:08:38', 0, 0),
(243, 77, '332 Sewell Street, Lebanon ME ', '', '\r\n\r\nINPUT FILE COUNTS:\r\n\r\n\r\n\r\n5X SONY = 70\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                                    ', NULL, NULL, 3, '2023-09-10 00:46:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-10 00:50:43', 0, 0),
(244, 111, '135 Concord Ave NY, White Plains, Westchester 10606', '', '\"Total number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: \r\n\r\nProperty style:\r\n\r\nSpecial Instructions:please do a nice twilight for for the front and back. I do need it as soon as possible. Thank you\r\n\r\nOption\"                                    ', NULL, NULL, 3, '2023-09-10 01:24:00', '2023-09-29 20:04:07', '8', '', '', '', '2023-09-10 01:29:08', 1, 0),
(245, 111, '135 Concord Ave NY, White Plains, Westchester 10606', '', '\"Total number of images with changes: 3\r\n\r\nTotal number of images without changes: 0\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: \r\n\r\nProperty style: Modern\r\n\r\nSpecial Instructions:PLEASE TAKE CARE OF THAT FOR ME AS SOON AS POSSIBLE. CLEAN ALL ROOMS AND VIRTUAL STAGED THE 3 ROOMS WITH MODERN STYLES FOR ME PLEASE. THANKS\r\n\r\nOption\"                                    ', NULL, NULL, 3, '2023-09-10 01:49:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-10 01:54:24', 1, 0),
(246, 112, '4750 South Glenhaven Avenue, Springfield, MO 65804', '', '\"Photo HDR , Aerial Video  64\r\n	\r\n\r\nvideo: \r\n\r\nproperty has a clubhouse. When making the video, please transition from the driveway, sidewalk, door, then up and over the house. Then use the master shot for remaining. Near the end, please use the amenities/clubhouse by starting with the Springcreek sign, then the remaining clips of the grounds, pool, and tennis/pickleball courts.\"                                    ', NULL, NULL, 3, '2023-09-10 04:29:00', '2023-09-29 20:04:07', '1,10', '', '', '', '2023-09-10 04:50:40', 0, 0),
(247, 110, '7879 W Sally Ct, Wasilla, AK 99623', '', '\"Photo HDR , Aerial Video 47\r\n\r\n\r\nvideo: \r\n\r\nPlease provide DTEs on what you think are the best photos. Please make a ~1:20 video, please use natural flowing sequence of clips. Ensure to use the proper transition between clips (on the last few videos towards the end of the final video some of the scene changes were very abrupt and didn\'t use the cross fade tool. There were also some split second pop ups of out of sequence shots, please watch the final video and ensure those errors aren\'t present.) This is a limited agent, no finale slide, but please do include the Hommati splash screen at the end.\"                                    ', NULL, NULL, 3, '2023-09-10 06:17:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-10 06:24:55', 0, 1),
(248, 89, '9903 BAY DRIVE, GIBSONTON, FL 33534', '', '\"Photo HDR , Aerial Videô 60\r\n\r\n\r\nvideo:\r\n\r\nTwilight Images - 2\r\n\r\n\r\nPlease have 2 twilights for this property... one from the waterside please. A note for the video... the front of the home faces the water so please edit the video as if the lanai and pool are the front entrance (They Are) of the home. Please keep the video to around 90 seconds.... I have some extra footage because I wanted to capture some boating activity on the river. Thank You!\"                                    ', NULL, NULL, 3, '2023-09-10 06:42:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-10 06:51:27', 0, 1),
(249, 105, '1920 Chambers St, Eugene, OR 97405', '', 'Photo HDR        30\r\n\r\nDo not replace sky. thank you\"', NULL, NULL, 3, '2023-09-10 07:39:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-10 08:47:56', 0, 0),
(250, 94, '1920 Chambers St, Eugene, OR 97405', '', '                     cua 0062MT             \"Twilight Images - 1        Total Images\r\n1\r\nDo not replace sky. thank you\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 1\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: [http://Please use DSC3638 for DTE]http://Please use DSC3638 for DTE\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:Please enhance with DTE photos DSC3638\r\n\r\nOption\"                                      ', NULL, NULL, 3, '2023-09-10 07:39:00', '2023-09-29 20:04:07', '8', '', '', '', '2023-09-10 08:49:41', 0, 0),
(251, 75, '341 Indian Grass St, Calhan, CO 80808', '', '       \"Photos + Drone + Social Media NO DTE\r\n\r\nPhotos: 125 files\r\n\r\nDrone: 10 files\r\n\r\nSocial Media: 13 files\r\n                             ', NULL, NULL, 3, '2023-09-10 09:16:00', '2023-09-29 20:04:07', '1,10', '', '', '', '2023-09-10 09:37:29', 0, 0),
(252, 75, '365 Gdn Pk Ave, Calhan, CO 80808', '', '  \"Photos + Drone + Social Media NO DTE\r\n\r\nPhotos: 85 files\r\n\r\nDrone: 9 files\r\n\r\nSocial Media: 11 files\r\n                                ', NULL, NULL, 3, '2023-09-10 09:17:00', '2023-09-29 20:04:07', '1,10', '', '', '', '2023-09-10 09:38:07', 0, 0),
(253, 75, '369 Indian Grass St, Calhan, CO 80808', '', '  \"Photos + Drone + Social Media NO DTE\r\n\r\nPhotos: 120 files\r\n\r\nDrone: 11 files\r\n\r\nSocial Media:  16 files\r\n                         ', NULL, NULL, 3, '2023-09-10 09:19:00', '2023-09-29 20:04:07', '1,10', '', '', '', '2023-09-10 09:38:52', 0, 0),
(254, 75, '15828 Cala Rojo Dr, Colorado Springs, CO 80926', '', '                        \"Photos + Drone + Social Media\r\n\r\nPhotos: 205 plus DTE\r\n\r\nDrone: 9 files\r\n\r\nSocial Media: 21 files                                 ', NULL, NULL, 3, '2023-09-10 09:20:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-10 09:39:25', 0, 0),
(255, 74, '1622 Southhampton Way', '', '\"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n(192 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"                                    ', NULL, NULL, 3, '2023-09-10 09:38:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-10 09:42:14', 0, 0),
(256, 74, '1710 Canoe Branch Rd', '', '  \"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n(123 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"                                  ', NULL, NULL, 3, '2023-09-10 09:41:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-10 09:44:33', 0, 0),
(257, 113, '13778 Hillcrest', '', '                Once again, work your magic. Crop any that need it. Ned anything else, let me know. Could you also check and make sure I\'m all paid up.                    ', NULL, NULL, 3, '2023-09-11 08:04:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1OxyVB_f2U7VtyV_b6w5hfkSwo9Y4PJ-j?usp=sharing', '', '2023-09-11 08:07:36', 0, 0),
(258, 96, '977 Jamaica Blvd, Toms River, NJ', '', ' Please edit a plat pak+ HDR package. Here is the link:                                   ', NULL, NULL, 3, '2023-09-12 07:59:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-12 08:06:52', 0, 1),
(259, 96, '1825 Beach Blvd, Point Pleasant, NJ', '', '    Please edit a plat pak+ HDR package. Here is the link:                                ', NULL, NULL, 3, '2023-09-12 08:14:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-12 08:17:58', 0, 1),
(260, 96, '243 Barbados Drive N, Toms River, NJ ', '', '   Please edit HDR photos.  Here is the link                 ', NULL, NULL, 3, '2023-09-12 08:32:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-12 08:40:29', 0, 0),
(261, 114, '153 Beacon Ridge Dr Seven Lakes NC', '', '                        275 photos            ', NULL, NULL, 3, '2023-09-12 08:48:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-12 08:52:46', 0, 0),
(262, 114, '612 Dowd Rd Carthage NC', '', '223 photos                                    ', NULL, NULL, 3, '2023-09-12 08:49:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-12 08:54:09', 0, 0),
(263, 115, '313 Zimmerman St, Arvin, CA 93203', '', '                                Photo HDR 30 dashboard                                        ', NULL, NULL, 3, '2023-09-12 09:28:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-12 09:31:28', 0, 0),
(264, 74, '4108 Trinity Rd', '', '         \"I would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n\r\n(120total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"                           ', NULL, NULL, 3, '2023-09-12 09:33:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-12 09:35:24', 0, 0),
(265, 84, '189 HDR Edit Life style photos 9 Bingham St, Saratoga, NY 12866', '', '                                    ', NULL, NULL, 3, '2023-09-12 09:33:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-12 09:39:07', 0, 0),
(266, 74, '753 Belfast Farmington Rd', '', '\"I would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n(132 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\r\n\"                                    ', NULL, NULL, 3, '2023-09-12 09:40:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-12 09:42:12', 0, 0),
(267, 94, '3009 Lake Vista Dr KY, Louisville, Jefferson 40241', '', '                               \"Total number of images with changes:\r\n\r\nTotal number of images without changes: 4\r\n\r\nTotal number of twilight enhancement images: 1\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:The 2 photos of a Beige Room, is the large common room. It is open to a dining area and the kitchen with a breakfast nook. The 2 Photos of a green room are of the same Primary Suite.\r\n\r\nOption\"     ', NULL, NULL, 3, '2023-09-12 22:51:00', '2023-09-29 20:04:07', '8,9', '', '', '', '2023-09-13 07:53:11', 0, 0),
(268, 108, '328 Montgomery Avenue', '', '                                    ', NULL, NULL, 3, '2023-09-13 01:53:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 07:53:47', 0, 0),
(269, 88, '7670 Hwy 245', '', '                                    ', NULL, NULL, 3, '2023-09-13 01:00:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 07:55:27', 0, 0),
(270, 116, '3806 W Empedrado St, Tampa FL', '', '                                    ', NULL, NULL, 3, '2023-09-13 01:57:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 07:58:00', 0, 3),
(271, 116, '9538 Rolling Cir, San Antonio FL', '', '                                    ', NULL, NULL, 3, '2023-09-13 02:58:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 07:58:31', 0, 0),
(272, 116, '901 Bayshore Blvd, Tampa FL', '', '                                    ', NULL, NULL, 3, '2023-09-13 02:20:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 07:59:05', 0, 0),
(273, 117, '4117 2nd Place NW Rochester, MN', '', '                                    ', NULL, NULL, 3, '2023-09-13 02:00:00', '2023-09-29 20:04:07', '1', '', 'acb', '', '2023-09-13 08:00:45', 0, 0),
(274, 73, '208 Abigaile Ct, McDonough, GA 30252        ', '', '                                    ', NULL, NULL, 3, '2023-09-13 02:01:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:01:24', 0, 0),
(275, 77, '10 Hillcrest Court Road, August ME', '', '                                                  INPUT FILE COUNTS:\r\n\r\n\r\n\r\n5X DJI = 115\r\n\r\n5X SONY = 136\r\n\r\nVIDEO FILES = 23\r\n\r\n\r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n\r\n\r\nNOTES:\r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                      ', NULL, NULL, 3, '2023-09-13 03:02:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 08:02:47', 0, 0),
(276, 77, '130 Bradford Point Road, Friendship ME', '', '                                                                        \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 145\r\n\r\n5X SONY = 155\r\n\r\nVIDEO FILES = 23\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-13 05:03:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 08:03:48', 1, 0),
(277, 79, '4775 Northway', '', '\r\n\r\nGood afternoon, Please find the attached photo links for editing, this is an first time customer Plat Pack Plus package. Please include 1 twilight photo and please straighten all exterior walls also this is a water front property so please allow video to run longer if needed.\"', NULL, NULL, 3, '2023-09-13 05:06:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 08:06:47', 0, 3),
(278, 101, '372 Alhambra Vallejo, CA', '', '                        \"Here\'s the link for HDR editing for 372 Alhambra. I also sent an email about getting some virtual stagging redone earlier this morning and didn\'t hear anything back.\r\n     ', NULL, NULL, 3, '2023-09-13 05:06:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:07:24', 0, 0),
(279, 96, '16 Lippincott Dr, Little Egg Harbor, NJ', '', '                             \"Please edit a plat pak+ hdr package.  Please add fire to fireplace.  \r\n\"       ', NULL, NULL, 3, '2023-09-13 05:08:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 08:08:25', 0, 3),
(280, 75, '5430 Saxton Hollow Rd, Colorado Springs, CO 80917', '', '                     \"Added exterior shots\r\n\r\n15 files \r\n', NULL, NULL, 3, '2023-09-13 06:08:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:09:11', 0, 0),
(281, 75, '1624 W Colorado Ave, Colorado Springs, CO 80904', '', '                            \"Added files.  \r\n\r\nDrone: 11 files\r\n\r\nPhotos: 11 files\r\n                                          ', NULL, NULL, 3, '2023-09-13 06:11:00', '2023-09-29 20:04:07', '1,10', '', '', '', '2023-09-13 08:11:42', 0, 0),
(282, 75, '1158 Forest Hill Rd, Woodland Park, CO 80863', '', '                                    \"Photos + Drone + DTE\r\n\r\nPhotos: 100 files plus DTE\r\n\r\nDrone: 12 files \r\n', NULL, NULL, 3, '2023-09-13 06:17:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 08:18:16', 0, 3),
(283, 75, '4416 N Delighted Cir, Colorado Springs, CO 80917', '', '                                    \"Photos + Drone + DTE\r\n\r\nPhotos: 140 files puls DTE\r\n\r\nDrone: 9 files \r\n', NULL, NULL, 3, '2023-09-13 06:18:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 08:18:51', 0, 3),
(284, 71, '925 NW Bent Tree Dr', '', '                              \"Could you please provide HDR Editing only for the above address.  There should be a total of 55 HDR photos.  Thank you!\r\n\r\n\r\n\"	\"I’m sorry, the realtor just told me she needs them tonight.  Can we put a rush on this one?\r\n\"      ', NULL, NULL, 3, '2023-09-13 06:18:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:19:29', 1, 0),
(285, 71, '1605 Marvin Ct', '', '                                    ', NULL, NULL, 3, '2023-09-13 04:20:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:20:56', 0, 0),
(286, 87, 'AFRICA EDIT', '', '                         \"I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nThis home is newly renovated and very and VERY BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n110 files . . . thank you\r\n     ', NULL, NULL, 3, '2023-09-13 02:21:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:21:43', 0, 0),
(287, 98, '\"54 Gold Finch Way, Crawfordville, FL 32327 – 90 photos \"', '', '                                    ', NULL, NULL, 3, '2023-09-13 02:21:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:22:18', 0, 0),
(288, 98, '76 Harvey-Pitman St, Crawfordville, FL 32327 – 90 photos', '', '                                    ', NULL, NULL, 3, '2023-09-13 02:22:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:22:46', 0, 0),
(289, 80, '13302 Egrets Marsh Dr Jacksonville FL 32224', '', '                              Hello, Here are the photos to edit for 13302 Egrets Marsh Dr Jacksonville FL 32224. There are 160 files in the folder, some are still uploading. Thanks ', NULL, NULL, 3, '2023-09-13 05:22:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:23:27', 0, 0),
(290, 118, '18511 E 8 St N, Independence, MO 64056        ', '', '                                    ', NULL, NULL, 3, '2023-09-13 05:24:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 08:25:22', 0, 3),
(291, 94, '13 Higgins Dr ME, Kennebunk, York 04043', '', '                                                                        ', NULL, NULL, 3, '2023-09-13 06:25:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-13 08:26:00', 1, 0),
(292, 94, '1825 Beach Blvd NJ, Point Pleasant, Ocean 08742', '', '                                    ', NULL, NULL, 3, '2023-09-13 06:26:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-13 08:26:59', 0, 0),
(293, 118, '1205 E Fredrickson Dr, Olathe, KS 66061        ', '', '                                    ', NULL, NULL, 3, '2023-09-13 05:30:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 08:30:35', 0, 3),
(294, 80, 'Photo edit 136 Phelps St', '', '                          \"\"\"Here is the link for photo editing and there are 300 files in this folder Thank Dan Hommati 150       ', NULL, NULL, 3, '2023-09-13 05:30:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:31:34', 0, 0),
(295, 80, 'Photo edit 154 Southerly Ln Fleming Island FL 32003', '', '                                    ', NULL, NULL, 3, '2023-09-13 06:31:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:32:04', 0, 0),
(296, 119, '12 6th St S, Naples FL, 34102', '', '                                   \"Please process the 5 bracketed image shots (265 photos or 53 HDR pictures) in the mirrorless folder\r\n\r\nPlease include a Twighlight shot from the front\r\n\" ', NULL, NULL, 3, '2023-09-13 06:33:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:33:39', 0, 0),
(297, 105, '86970 Sweet Creek Rd Mapleton DR', '', '                                    \"Please do not change the sky,\r\nKeep the exteriors natural, and do not over-saturate.\r\n\r\n\r\n11 Items = 11 Photos\r\n\r\nThanks\"', NULL, NULL, 3, '2023-09-13 06:35:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:35:48', 0, 0),
(298, 90, '604 W Courtland St, Mundelein, IL 60060', '', '                                    ', NULL, NULL, 3, '2023-09-13 06:36:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:36:22', 0, 0),
(299, 108, '112 Covered Bridge Ct', '', '                                    ', NULL, NULL, 3, '2023-09-13 06:36:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:36:55', 0, 0),
(300, 95, '363 STRATHAVEN DRIVE, PELHAM, AL 35124', '', '                                    ', NULL, NULL, 3, '2023-09-13 06:37:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:37:33', 0, 0),
(301, 96, '27 Frederiksted St, Toms River, NJ', '', '                                    ', NULL, NULL, 3, '2023-09-13 06:37:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:38:18', 0, 0),
(302, 74, '823 Tall Oak Trail', '', '                                    \"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n\r\n(219 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"', NULL, NULL, 3, '2023-09-13 06:38:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:38:57', 0, 0),
(303, 74, '4039 Oak Grove Rd', '', '                                    \"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n(165 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"', NULL, NULL, 3, '2023-09-13 06:39:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 08:39:25', 0, 0),
(304, 120, '444 Nahua Condos, Waikiki', '', '                                  \"Please complete my order for the PLAT PACK PLUS HDR.\r\n\r\nFiles are still uploading. Please wait for all files to upload.\r\n\r\n This link has both photos and videos \r\n\r\n VIDEO:\r\n\r\nThere are 6 video files to make UNBRANDED video.\r\nTrim, cut, edit and use different speeds as necessary.\r\nPlease add background music.\r\n \r\nPHOTOS:\r\n\r\nThere are 175 bracketed image files\r\nTotal 35 composition images\r\nPlease make 1ST DTE with the INTERIOR image CAM05593 (sunset is LEFT SIDE of the image)\r\nPlease make 2ND DTE with the AERIAL image DJI_0316 (sunset is LEFT SIDE the image)\r\nKEEP ORIGINAL SKIES\r\n \"  ', NULL, NULL, 3, '2023-09-13 07:42:00', '2023-09-29 20:04:07', '1,8,10', '', 'https://drive.google.com/drive/folders/1lDBZMroMCZtw2TNbJ4Lkmv3VVZYOpiwu', '', '2023-09-13 08:42:48', 0, 3),
(305, 121, '763 Tudor Ln, Youngstown, OH 44512,', '', '      Photo HDR 31                              ', NULL, NULL, 3, '2023-09-13 08:44:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 10:45:22', 0, 0),
(306, 89, '5307 BOWLINE BEND, NEW PORT RICHEY, FL 34652', '', '                                    \"Photo HDR , Aerial Video        40\r\n\r\n\r\n\r\n\r\nTwilight Images \r\nHi! The videos have been fabulous! I have a request for this one because the home was not in great shape. Please keep video to around 1 minute for the unbranded version.... you don\'t have to use all the shots. Also, there are 2 shots from the Community Beach club.... can we add a fun graphic over those 2 shot -- GULF HARBORS BEACH CLUB -- The shots are stock footage and labeled. For the Twilight photos, can we have the second 1 be from inside the lanai and facing the water. As a note: This house faces EAST and anything facing the canal would geet great looking sunsets. Thank You! Jim\"', NULL, NULL, 3, '2023-09-13 08:45:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 10:46:12', 0, 3),
(307, 115, '27100 Island View Ct CA, Santa Clarita, Los Angeles 91355', '', '                                                                        ', NULL, NULL, 3, '2023-09-13 08:46:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 10:47:05', 0, 0),
(308, 94, '	 27100 Island View Ct CA, Santa Clarita, Los Angeles 91355', '', '                                    ', NULL, NULL, 3, '2023-09-13 08:48:00', '2023-09-29 20:04:07', '8', '', '', '', '2023-09-13 10:49:50', 0, 0),
(309, 104, '11814 Coldstream Dr. Potomac, MD 20854 Project 1', '', '                                    \"Hello to everyone at PhotoHome,\r\n\r\nPlease find the link below for our album HDR 3-1 11814 Coldstream Dr. Potomac, MD Project 1. This album should contain 186 exposures of 62 images \r\n\r\n', NULL, NULL, 3, '2023-09-13 09:50:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 10:50:47', 0, 0),
(310, 104, '11814 Coldstream Dr. Potomac, MD 20854 Project 2', '', '                            \"Hello to everyone at PhotoHome,\r\n\r\nPlease find the link below for our album HDR 5-1 11814 Coldstream Dr. Potomac, MD Project 2. This album should contain 30 exposures of 6 images. \r\n\r\n      ', NULL, NULL, 3, '2023-09-13 09:50:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 10:51:20', 0, 0),
(311, 104, '11814 Coldstream Dr. Potomac, MD 20854 Project 3', '', '                                    \"Hello to everyone at PhotoHome,\r\n\r\nPlease find the link below for our album Single JPG 11814 Coldstream Dr. Potomac, MD Project 3. This album should contain 15 images. \r\n\r\n', NULL, NULL, 3, '2023-09-13 09:51:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 10:51:57', 0, 0),
(312, 77, '149 Columbia Ave, Brunswick ME', '', '\r\n\r\nDTE = DSC02697-DSC002701\r\n\r\n \r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 50\r\n\r\n5X SONY = 210\r\n\r\nVIDEO FILES = 23\r\n\r\n \r\n\r\nEDITOR PROVIDE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-13 11:34:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-13 11:45:34', 0, 3),
(313, 77, '16 Spring Street, Mechanic Falls, ME', '', '                    \r\n\r\nDTE = DJI_0094-DJI_0098\r\n \r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 125\r\n\r\n5X SONY = 294\r\n\r\nVIDEO FILES = 25\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES (please use appropriate sky)\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                                    ', NULL, NULL, 3, '2023-09-13 11:40:00', '2023-09-29 20:04:07', '1,8,10', '', 'acb', '', '2023-09-13 11:46:18', 0, 3),
(315, 95, '1542 Timber Dr, Helena, AL 35080', '', ' Photo HDR        38                             ', NULL, NULL, 3, '2023-09-13 07:21:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 16:00:42', 0, 0),
(316, 71, '11814 Coldstream Dr. Potomac, MD 20854 Project 6', '', '            dfh                        ', NULL, NULL, 3, '2023-09-13 19:39:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-13 19:40:09', 1, 0),
(317, 114, '82 Greencastle Dr Southern Pines NC', '', '                     355 photos               ', NULL, NULL, 3, '2023-09-13 21:19:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1lO0_oP33zuaWkQk2OKv4DcZxkQiClNjs?usp=sharing', '', '2023-09-13 21:22:06', 0, 0),
(318, 116, '2111 River Turia Cir, Riverview FL ', '', '                            HDR Brackets (99 brackets for 33 photos) –        ', NULL, NULL, 3, '2023-09-13 22:14:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1-4lCMrSdnphLTC6599QfG67ByZ6Q7X8Q?usp=sharing', '', '2023-09-13 22:22:58', 0, 0),
(319, 94, '1119 Montcalm St NC, Charlotte, Mecklenburg 28208', '', '\"Total number of images with changes: 0\r\n\r\nTotal number of images without changes: 3\r\n\r\nTotal number of twilight enhancement images: 0\r\n\r\nTotal number of blue sky/green grass enhancement images: 0\r\n\r\nGoogle Photos account link: \r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:Room name is in the photo details in the link.\r\n\r\nOption\"                                    ', NULL, NULL, 3, '2023-09-13 22:36:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-13 22:44:16', 0, 0),
(320, 94, '1825 Beach Blvd NJ, Point Pleasant, Ocean 08742', '', 'Total number of images with changes:\r\n\r\nTotal number of images without changes: 2\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nProperty style: Coastal\r\n\r\nSpecial Instructions:Deck - Please add grill, table and chairs, plant Patio/Yard - please add items to deck above, under deck put a porch swing (sample included) lounge chair table and plants, some kids toys on the lawn. Please rush\r\n\r\nOption\r\n\r\n', NULL, NULL, 3, '2023-09-14 00:42:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-14 00:43:04', 0, 0),
(321, 80, 'St Augustine Ocean & Raquet Club', '', '                    \"Hello, Here are the files to edit for the St Augustine Ocean & Raquet Club. There are two units. Unit 5121 has 105 files. Unit 5324 has 110 files. Some files are still uploading to the folder. Thanks,\r\n                ', NULL, NULL, 3, '2023-09-14 00:43:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 00:44:01', 0, 0),
(322, 79, 'Vacant land Main Street Armada', '', '                    Good afternoon. please find the attached photo link for Drone still shoots only. Please include property lines on photo 0814 vacant land is the wooded lot between the houses and the large adjacent behind the houses surrounded by trees. Also if possible please make only the vacant land in color on photo 0815 everything else black and white. any questions please call 586-663-0443  Thank you.                  ', NULL, NULL, 3, '2023-09-14 00:44:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 00:44:38', 0, 0),
(323, 94, '743 Pineborough Rd NC, Charlotte, Mecklenburg 28212', '', '                    Total number of images with changes: 0\r\n\r\nTotal number of images without changes: 3\r\n\r\nTotal number of twilight enhancement images: 0\r\n\r\nTotal number of blue sky/green grass enhancement images: 0\r\n\r\nProperty style: OR Let Hommati Team pick for you OR special project\r\n\r\nSpecial Instructions:Room names are located in the details section of the images in the link.\r\n\r\nOption\r\n                ', NULL, NULL, 3, '2023-09-14 00:44:00', '2023-09-29 20:04:07', '9', '', '', '', '2023-09-14 00:45:20', 0, 0),
(324, 94, '6031 Heckert Road OH, Westerville, Franklin 43081', '', '                    Total number of images with changes:\r\n\r\nTotal number of images without changes: 1\r\n\r\nTotal number of twilight enhancement images:\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nProperty style: Transitional\r\n\r\nSpecial Instructions:Please label the photo as Virtually Staged. Please stage this photo with a desk and desk chair against the window. Please stage seating chairs on the left and right of the desk in the corners. Please stage a couch along the right wall with a picture above the couch that spans the length of the couch.\r\n\r\nOption\r\n\r\n                ', NULL, NULL, 1, '2023-09-14 00:45:00', '2023-09-29 20:04:07', '9', '', NULL, NULL, '2023-09-14 00:46:21', 0, 0),
(325, 80, 'Photo edit for 525 3rd St Jax beach', '', '                                                        \"Here is the link for photo editing and there are 180 files in the folder Thanks, \r\nhttps://www.dropbox.com/l/scl/AAAVA-m8mpI1K_anJXoJF_3VqvTX_qmc9e4                 ', NULL, NULL, 3, '2023-09-14 00:46:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1dIgLqHVNR9KQuLS4bfOBzuR9K82P6tWG?usp=sharing', '', '2023-09-14 00:46:56', 0, 0),
(326, 107, '13810 Rockhaven Dr. Chester, VA', '', '                                                        https://drive.google.com/drive/folders/1LuytcyerPlH7Bkz5P9Q4cMOA_YFOKhrP?usp=drive_link \r\n\r\nDrone Pictures\r\n\r\n \r\n\r\nhttps://drive.google.com/drive/folders/1WewUV9m9kn_FncAtD0wUktWee8dOkesT?usp=drive_link \r\n\r\nDrone Videos\r\n\r\n \r\n\r\nhttps://drive.google.com/drive/folders/1Rhfk4ZjceqcDvHtAHepHWzBfabffITSK?usp=drive_link \r\n\r\n2D Photographs                ', NULL, NULL, 3, '2023-09-14 01:06:00', '2023-09-29 20:04:07', '1,8,10', '', 'https://drive.google.com/drive/folders/1-1P5KVI-Xy_-7agp9WU2IJ9xqxm7bIcO?usp=sharing', '', '2023-09-14 01:15:02', 0, 1),
(327, 117, '906 Forest Hills Drive SW Rochester, MN', '', '                                        https://photos.app.goo.gl/VJqLwiVGC1VcBLhw7                                ', NULL, NULL, 3, '2023-09-14 01:17:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 01:18:25', 0, 0),
(328, 117, '2610 Ridgewood Court SE Rochester, MN', '', '                                                        https://photos.app.goo.gl/2KxQ5HiH5n9B2Ya36 \r\n                ', NULL, NULL, 3, '2023-09-14 01:20:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 01:25:42', 0, 0),
(329, 95, '3918 Spring Valley Rd, Birmingham, AL 35223        ', '', '                    https://imaging.hommati.cloud/widget/download/editing-team/28324230                ', NULL, NULL, 3, '2023-09-14 01:20:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 01:26:07', 0, 0),
(330, 73, '50 Graystone Dr, Covington, GA 30014', '', '                                                        https://adobe.ly/3PEoiQ0 \r\nPhoto HDR , Aerial Video        35\r\nhttps://www.dropbox.com/t/NMpm3MXdqhtIxSNy \r\nTwilight Images - 2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: https://www.dropbox.com/t/NMpm3MXdqhtIxSNy \r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\n\r\n                ', NULL, NULL, 3, '2023-09-14 03:04:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1Xgvu_roB6q1u1yKX3Z6PVQ8KU253WFW-?usp=drive_link', '', '2023-09-14 06:41:34', 0, 0),
(331, 92, '1817 Carmen Ct Junction City KS', '', '                                        Hello, I have shared:\r\n-200 photos for HDR Bracketed editing\r\n-7 photos for HD editing\r\n-Shared link --> https://adobe.ly/3LnSgFo \r\n                                ', NULL, NULL, 1, '2023-09-14 06:42:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-14 06:42:13', 0, 0),
(332, 80, 'Photo edits for 8844 Heavengate Ln', '', '                                                                            \"Hello Photos to edit for 8844 Heavengate Ln 225 photo files still uploading Thank you Grace\" https://www.dropbox.com/l/scl/AABTVQT8p4KRXKyygEjDDaHoaZlRgWh4qc0 \r\n                                ', NULL, NULL, 3, '2023-09-14 04:07:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 06:53:47', 0, 0),
(333, 87, 'COVENTRY EDIT', '', '                                                        I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nThis home is newly built and very and VERY BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n265 files . . . thank you\r\n                ', NULL, NULL, 3, '2023-09-14 04:11:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 06:54:25', 0, 0),
(334, 77, '155 School Street, Berwick ME', '', '                                        INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 146\r\n\r\n5X SONY = 185\r\n\r\nVIDEO FILES = 20\r\n\r\n \r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                                ', NULL, NULL, 3, '2023-09-14 04:49:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 06:55:52', 0, 1),
(335, 77, '602 Woodman Hill Road, Minot ME', '', '                    INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 110\r\n\r\n5X SONY = 270\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels                ', NULL, NULL, 3, '2023-09-14 04:53:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 06:57:57', 0, 0),
(336, 98, '296 Trice Ln, Crawfordville, FL 32327', '', '                                                                            90 photos\r\n\r\nhttps://drive.google.com/drive/folders/1PfOzHG9sJRSxlYCL9BmhbcQIVQ7OhTCn?usp=sharing\r\n\r\n                                ', NULL, NULL, 3, '2023-09-14 05:22:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 06:58:43', 0, 0),
(337, 87, 'MEADOW ASH EDIT', '', '                                                                            I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease darken TVs . . .\r\n\r\nThis home is newly built and very and bright and white throughout - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n120 files . . . thank you\r\n\r\nhttps://staciemosley.wetransfer.com/downloads/c0bdac85cd9e071be4938880bd9050da20230913225511/53ab3a81963de9a3c40b88920e515fda20230913225511/6a1aed?trk=TRN_TDL_01&utm_campaign=TRN_TDL_01&utm_medium=email&utm_source=sendgrid                                 ', NULL, NULL, 3, '2023-09-14 06:08:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 06:59:25', 0, 0),
(338, 89, '5307 Bowline Bend PT2', '', '                                                        I had to return to this location to shoot this room today. 25 photos for 5307 Bowline Bend. \r\n\r\n\r\nhttps://adobe.ly/3Pjwzrf \r\n                ', NULL, NULL, 3, '2023-09-14 06:59:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 07:09:34', 0, 0),
(339, 75, '12619 Stone Valley Dr, Peyton, CO 80831', '', ' \"Photos Only NO DTE\r\n\r\nPhotos: 160 files \r\n                            ', NULL, NULL, 3, '2023-09-14 07:06:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 07:47:53', 0, 0),
(340, 75, '4515 Forsythe Dr, Colorado Springs, CO 80911', '', '\"Photos only NO DTE\r\n\r\nPhotos: 120 files\r\n                               ', NULL, NULL, 3, '2023-09-14 07:07:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 07:48:28', 0, 0),
(341, 75, '4445 Gatewood Dr, Colorado Springs, CO 80916', '', ' \"Photos Only NO DTE\r\n\r\nPhotos: 105 files\r\n                                ', NULL, NULL, 3, '2023-09-14 07:48:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 07:49:00', 0, 0),
(342, 75, '3149 Blake St 203, Denver, CO 80205', '', '                    \"Photos + Drone NO DTE\r\n\r\nPhotos: 70 files\r\n\r\nDrone: 12 files\r\n\r\nSocial Media: 15 files\r\n                                                 ', NULL, NULL, 3, '2023-09-14 07:07:00', '2023-09-29 20:04:07', '1,10', '', '', '', '2023-09-14 07:49:37', 0, 0),
(343, 75, '1825 Elevation Way, Colorado Springs, CO 80921', '', '\"Photos + Drone + DTE\r\n\r\nPhotos: 275 plus DTE\r\n\r\nDrone: 10 files  \r\n\"                                    ', NULL, NULL, 3, '2023-09-14 07:08:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 07:50:24', 0, 3),
(344, 75, '1720 Crest Pl, Colorado Springs, CO 80911', '', ' \"Photos Only\r\n\r\nPhotos: 115 files\r\n                        ', NULL, NULL, 3, '2023-09-14 07:08:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 07:50:50', 0, 0),
(345, 87, 'SPRING HOLLOW EDIT', '', '  \"I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n205 files . . . thank you\r\n\r\n                              ', NULL, NULL, 3, '2023-09-14 06:32:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 07:54:29', 0, 0),
(346, 77, '332 Sewell Street, Lebanon ME', '', '\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X SONY = 25\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-14 04:50:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 07:59:57', 0, 0),
(347, 120, '1615 Kapua Lane, Honolulu', '', '\"PhotoHome Reps,\r\n\r\n \r\n\r\nPlease complete my order for the HDR PHOTOS ONLY Files are still uploading. Please wait for all files to upload.\r\n\r\n \r\n\r\n\r\nThere are 175 bracketed images for 35 photos.\r\nKEEP ORIGINAL SKIES\"                                    ', NULL, NULL, 3, '2023-09-14 07:29:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 08:04:52', 0, 0),
(348, 84, '189 Video Edit 5 Newburry Ct, Clifton Park, NY 12065', '', '                                    ', NULL, NULL, 1, '2023-09-14 08:05:00', '2023-09-29 20:04:07', '10', '', NULL, NULL, '2023-09-14 08:08:45', 0, 0);
INSERT INTO `project_list` (`id`, `idkh`, `name`, `description`, `instruction`, `intruction1`, `intruction2`, `status`, `start_date`, `end_date`, `idlevels`, `id_invoice`, `link_done`, `waite_note`, `date_created`, `urgent`, `idcb`) VALUES
(349, 84, '189 HDR Edit 5 Newburry Ct, Clifton Park, NY 12065', '', '                                    ', NULL, NULL, 3, '2023-09-14 08:05:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 08:09:09', 0, 0),
(350, 84, '189 HDR Edit 491 Smith Rd, Salem, NY 12865', '', '                                    ', NULL, NULL, 3, '2023-09-14 08:05:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 08:09:34', 0, 0),
(351, 89, '22741 MARSH WREN DRIVE, LAND O\' LAKES, FL 34639', '', '\"Photo HDR , Aerial Video	50\r\n\r\nTwilight Images - 2	Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\nPlease keep the video to around 1 minute. Please keep our blue sky for photos and lets have the Twilight shots both be from the front. One angled and one straight on. Thank You! \"                                    ', NULL, NULL, 3, '2023-09-14 08:13:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 08:39:26', 0, 3),
(352, 74, '1925 Shenandoah Trail', '', '\"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n\r\n(156 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"                                    ', NULL, NULL, 1, '2023-09-14 08:11:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-14 08:47:37', 0, 0),
(353, 74, '2525 Carmine St', '', '   \"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n\r\n(102 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"                                 ', NULL, NULL, 1, '2023-09-14 08:19:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-14 08:48:12', 0, 0),
(354, 74, '2730 Old Mathews Rd', '', '\"Hi,\r\n\r\nI would like to get HDR photo editing on the photos included in the link below.  Let me know if you have any issues accessing the folder.\r\n\r\n(123 total files)\r\n\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV.\r\n\r\nCould I get the edited images in the following dimensions/size in case I need to crop the images.\r\n5400 pixels x 3600 pixels - 5MB\"                                    ', NULL, NULL, 2, '2023-09-14 08:29:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 08:48:47', 0, 0),
(355, 82, '704 Caraway Ln., Nashville, Tennessee, 37211', '', '\"Please make the drone clips in the video cropped to fit vertical format like the rest of the clips.\r\n\r\nAlso, any font that is used (dte photos, address on video, etc.) please use Montserrat font.\r\n\r\n                                 ', NULL, NULL, 2, '2023-09-14 08:28:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 08:49:30', 0, 3),
(356, 82, '207 River Downs Blvd. Murfreesboro, TN 37128', '', '                                    ', NULL, NULL, 3, '2023-09-14 08:30:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 08:50:35', 0, 3),
(357, 89, '8103 WINDING OAK LANE, SPRING HILL, FL 34606', '', '                      \"Photo HDR , Aerial Video	51\r\n\r\nTwilight Images - 2	Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\nPlease keep our blue sky in the photos. Please use 2 images from fron of home for twilight. Thank You\"                                                  ', NULL, NULL, 3, '2023-09-14 08:32:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 08:51:22', 0, 3),
(358, 84, '189 HDR Edit 449 Madison St, Troy, NY 12180', '', '                                    ', NULL, NULL, 3, '2023-09-14 09:54:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 10:06:05', 0, 0),
(359, 84, '189 Video Edit 449 Madison St, Troy, NY 12180', '', '                                    ', NULL, NULL, 1, '2023-09-14 09:54:00', '2023-09-29 20:04:07', '10', '', NULL, NULL, '2023-09-14 10:06:38', 0, 0),
(360, 84, '189 HDR Edit 170-176 Columbia Turnpike, Rensselaer, NY 12144', '', '                                    ', NULL, NULL, 3, '2023-09-14 09:54:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 10:08:46', 0, 0),
(361, 84, '189 HDR Edit 131 Werking Rd, East Greenbush, NY 12061', '', '                                    ', NULL, NULL, 3, '2023-09-14 09:54:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 10:09:20', 0, 0),
(362, 84, '189 Video Edit 131 Werking Rd, East Greenbush, NY 12061', '', '                                    ', NULL, NULL, 1, '2023-09-14 09:54:00', '2023-09-29 20:04:07', '10', '', NULL, NULL, '2023-09-14 10:12:36', 0, 0),
(363, 78, '6015 Northview Ct, Aubrey, TX 76227', '', '\"Hello,\r\nCan you please edit my photos, 4K branded and 4K unbranded videos.\r\n\r\nVideo-Please DO NOT SHORTEN CLIP times and place the agent/address in the middle of clip 1 for 8 seconds. Put clips in labeled order Clip 1-12, Stabilize Shakey video, Color Correct and edit in 4K. Thank you!! \r\n                         ', NULL, NULL, 3, '2023-09-14 10:25:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 11:04:26', 0, 3),
(364, 77, '144 Jones Road, Shapleigh ME', '', '\r\n\r\n\r\n\r\nDTE = DJI_0235 - DJI_0239\r\n\r\n \r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 105\r\n\r\n5X SONY = 235\r\n\r\nVIDEO FILES = 23\r\n\r\n \r\n\r\nEDITOR SELECT MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-14 12:40:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 12:45:31', 0, 3),
(365, 77, '4 Preble Street, Wells ME', '', '\r\n\r\nDTE =  DJI_0417-DJI_0421\r\n \r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 105\r\n\r\n5X SONY = 235\r\n\r\nVIDEO FILES = 31\r\n\r\n \r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nEDITOR SELECT MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-14 12:47:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-14 12:50:51', 0, 3),
(366, 113, '221 N. Basilio', '', '    Crop anything that is needed. Do the best you can w3ith the aerials.                                ', NULL, NULL, 3, '2023-09-14 15:52:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-14 16:01:45', 0, 0),
(367, 96, '27 Fox Hill Rd, Middletown, NJ', '', '                                    Please edit a plat pak+ HDR package.  Please add fire to the fireplace.  \r\n', NULL, NULL, 3, '2023-09-15 01:26:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 02:02:18', 0, 1),
(368, 87, 'GOODRICH EDIT', '', '                                    I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPLEASE DARKEN TVs . . .\r\n\r\nThis home is newly renovated and very and VERY BRIGHT AND WHITE THROUGHOUT - NO YELLOW TONES!!!!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n105 files . . . thank you\r\n\r\n', NULL, NULL, 3, '2023-09-15 01:26:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-15 02:03:00', 0, 0),
(369, 87, 'NOTTINGHAMSHIRE EDIT', '', '                                    I\'m requesting an EXPERIENCED EDITOR PLEASE!\r\n\r\nPlease make sure photos are bright, sharp & crisp . . .\r\n\r\nPlease make sure edits are not too yellow . . .\r\n\r\nPlease pay attention to proper white balance . . . please enhance whites and pull windows.\r\n\r\n195 files . . . thank you\r\n', NULL, NULL, 1, '2023-09-15 01:48:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-15 02:03:43', 0, 0),
(370, 79, '51335 D W Seaton Drive', '', '                                    Good afternoon, Please find the attached photo link for editing. This is a photos only package, please blur the brown area above the fireplace, also please straighten exterior walls as needed. Thank you', NULL, NULL, 1, '2023-09-15 01:50:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-15 02:04:22', 0, 0),
(371, 116, '168 Earlmont Pl, Davenport FL', '', '                                    ', NULL, NULL, 1, '2023-09-15 02:14:00', '2023-09-29 20:04:07', '1,8,10', '', NULL, NULL, '2023-09-15 02:16:30', 0, 1),
(372, 73, '548 Ventura Dr, Forest Park, GA 30297        ', '', '                                    ', NULL, NULL, 1, '2023-09-15 04:31:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-15 04:31:40', 0, 0),
(373, 100, '205 Durango Dr, Gilberts, IL 60136        ', '', '                                    ', NULL, NULL, 1, '2023-09-15 04:39:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-15 04:40:11', 0, 0),
(374, 98, '10663 Lake Iamonia Dr, Tallahassee, FL 32312', '', '                                    ', NULL, NULL, 3, '2023-09-15 04:43:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-15 04:44:16', 0, 0),
(375, 76, '54 Stony Hill Rd, Brookfield, CT 06804        ', '', '                                    Hello Team, Please straighten and enhance these RAW and DNG files. Can you please add fire to the fireplace? Also can I get copies of those photos with and without fire in the fireplace? Thank you! TJ ', NULL, NULL, 3, '2023-09-15 06:12:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1RWThCMTh3aX69UjoeiWZIjhbbcc8PFFi?usp=sharing', '', '2023-09-15 06:20:29', 0, 0),
(376, 90, '124 Minter Dr, Griffith, IN 46319        ', '', '                                    ', NULL, NULL, 3, '2023-09-15 06:18:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1JgIInDAWeOj4wCPQ5qpLdccm5VVv1zkD?usp=sharing', '', '2023-09-15 06:20:59', 0, 0),
(377, 90, '262 Morgan Valley Dr, Oswego, IL 60543        ', '', '                                                        Property style: OR Let Hommati Team pick for you OR special project\r\n                ', NULL, NULL, 2, '2023-09-15 06:20:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 06:24:03', 0, 1),
(378, 77, '18 Simpson Lane, York ME', '', '                          \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 30\r\n\r\n5X SONY = 50\r\n\r\nVIDEO FILES = 17\r\n\r\n \r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"          ', NULL, NULL, 3, '2023-09-15 05:49:00', '2023-09-29 20:04:07', '1,8,10', '', 'https://drive.google.com/drive/folders/12fjUJHxODHbsVL9s1bvx3W1bzlHzxYZ7?usp=sharing', '', '2023-09-15 07:50:00', 0, 3),
(379, 77, '25 Logging Road, York ME', '', '                         \r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 145\r\n\r\n5X SONY = 220\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"           ', NULL, NULL, 3, '2023-09-15 05:50:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1yLqMBgrknyFsWdKLcPpwHGb7GuKxPdDp', '', '2023-09-15 07:50:52', 0, 0),
(380, 77, '23 Fort Hill Ave Ext. York ME', '', '                              \r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 110\r\n\r\n5X SONY = 160\r\n\r\nVIDEO FILES = 21\r\n\r\n \r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\" ', NULL, NULL, 3, '2023-09-15 05:51:00', '2023-09-29 20:04:07', '1,6,10', '', 'https://drive.google.com/drive/folders/1Dub9QKVI-LUR9mh9lvm1z0jSbmm4vHPG?usp=sharing', '', '2023-09-15 07:51:56', 0, 3),
(382, 80, '10550 Baymeadows Rd Unit 929 Jacksonville FL', '', '                     \"\"\"Hello Photo and Video edit for 10550 Baymeadows RD # 929 Jacksonville FL 32256 115 Photo files 13 video files Thank you \r\n               ', NULL, NULL, 3, '2023-09-15 07:54:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 07:54:59', 0, 3),
(383, 80, 'Photos to edit 1505 Marsh Rabbit Way Fleming Island FL 32003', '', '                                    \"Hello Photos to edit for 1505 Marsh Rabbit Way Fleming Island 32003 120 phot files Thank you \r\n', NULL, NULL, 3, '2023-09-15 06:55:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-15 07:55:39', 0, 0),
(384, 82, '224 Edit - Caraway Event', '', '                \"Can you please edit the photos from the event with the people in them to make them bright and lively?\r\n\r\n           ', NULL, NULL, 3, '2023-09-15 06:55:00', '2023-09-29 20:04:07', '1', '', 'https://drive.google.com/drive/folders/1fH6NTN_75RvoppWf0xVunOVfO20buv3n?usp=sharing', '', '2023-09-15 07:56:33', 0, 0),
(385, 80, '3289 Cypress Walk Pl Green Cove SPring 32043', '', '                  \"\"\"Hello Plat Pak for 3289 Cypress Walk Pl Green Cove Springs FL 32042 160 photo files 14 video file \r\n\r\n                  ', NULL, NULL, 3, '2023-09-15 07:56:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 07:57:13', 0, 3),
(386, 80, '3217 River Rd Green Cove Springs FL 32043', '', '                                    \"\"\"Hello Plat Pak for 3217 River Rd Green Cove Springs FL 32042 173 photo files 20 video files\r\n', NULL, NULL, 3, '2023-09-15 07:57:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 07:57:59', 0, 3),
(387, 89, '1804 TWIN RIVERS TRAIL, PARRISH, FL 34219', '', '            \"Photo HDR , Aerial Video        67\r\n\r\n\r\n\r\n\r\nTwilight Images - 2 \r\n\r\nBeaituful home... overshot on video because I wanted to try and eliminate some large construction traffic. Please keep video to about 90 Seconds. Please keep our blue skies. Thank You!\"                        ', NULL, NULL, 3, '2023-09-15 07:21:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 09:22:25', 0, 3),
(388, 122, 'Additional Pictures', '', '                                    ', NULL, NULL, 3, '2023-09-15 07:23:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-15 09:24:15', 0, 0),
(389, 117, '215 Elton Hills Drive #9 Rochester, MN', '', '                                    ', NULL, NULL, 3, '2023-09-15 07:24:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-15 09:24:40', 0, 0),
(390, 89, '8453 OLD POST ROAD, PORT RICHEY, FL 34668', '', '                      \"Photo HDR , Aerial Video        67\r\n\r\n\r\n\r\n\r\nTwilight Images - 2   \r\n\r\nBeaituful home... overshot on video because I wanted to try and eliminate some large construction traffic. Please keep video to about 90 Seconds. Please keep our blue skies. Thank You!\"              ', NULL, NULL, 3, '2023-09-15 07:24:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 09:25:45', 0, 3),
(391, 77, '254 Mountain Road, York ME', '', '\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 85\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                ', NULL, NULL, 3, '2023-09-15 08:26:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-15 09:26:27', 0, 0),
(392, 117, '24 Blakely Court NW Oronoco, MN', '', '                                    ', NULL, NULL, 3, '2023-09-15 08:26:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-15 09:27:01', 0, 0),
(393, 74, '113 Holly Ln, White House, TN 37188', '', '                                    ', NULL, NULL, 3, '2023-09-15 09:49:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-15 11:50:05', 0, 0),
(394, 94, '113 Holly Ln, White House, TN 37188', '', '                                    ', NULL, NULL, 3, '2023-09-15 09:50:00', '2023-09-29 20:04:07', '8', '', '', '', '2023-09-15 11:50:52', 0, 0),
(395, 106, '40 Southport Drive', '', '                                    \"Good Morning! Here are the details for this listing 40 Southport Dr.\r\n\r\n \r\n\r\nPackage Type : PlatPak+ Video And Photo Editing Package\r\n\r\nDrive Information:\r\n\r\nDrive Location\r\nTotal Number of Regular Photos: 79\r\nTotal Number of Twilight Photos: 3\r\nTotal Number of Video files: 9\r\nTotal Number of Photos to be used in Videos: 9\r\n\r\nPhoto Requirement:\r\n\r\nFinal Photo output size  - 7MB -10MB, we are allowed upto 12 MB files.\r\nWindow Treatment – Blue sky to all window pull\r\nadd fire to fire pit in twilight for  dsc_5985\r\n\r\n\r\nVideo Requirement: \r\n\r\nHouse Address to be added on clip 1 – 40 Southport Drive, Howell, NJ\r\nAfter three clips, Insert Photos\r\nBackyard photo showcasing all features\r\nHommati splash video at the end  ( Do not add client details at the end)\r\n\"', NULL, NULL, 3, '2023-09-15 12:12:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 12:12:58', 0, 3),
(396, 110, '3658 S Granite Ln, Wasilla, AK 99654', '', '                   \r\nPhotos: Please add fire to the fireplace. Videos: Please make a ~1:00 video. Limited agent, no finale slide. Add Hommati Splash screen. Some clips have a bit of a wobble, I had to rush, there was only a short break in the rain. The front fly out and the far away half moons feature me and the Hommati car prominently. Try to either speed through that part (fly out) or cut out (half-moons). Please don\'t hop between front and back too much and don\'t use opposite movements back to back and please ensure that all transitions between clips use the proper fading transition and there are no ghost clips hiding on another video track that pop through for a fraction of a second. Thanks!\"                ', NULL, NULL, 3, '2023-09-15 11:59:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-15 13:01:14', 0, 3),
(397, 114, '83 Taylors Creek Way Godwin NC', '', '                     189 photos                                                   ', NULL, NULL, 1, '2023-09-15 19:39:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-15 19:42:22', 0, 0),
(398, 114, '6017 Shannon Woods Way Hope Mills NC', '', '          305 photos                          ', NULL, NULL, 1, '2023-09-15 20:23:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-15 20:38:00', 0, 0),
(399, 94, '40 Southport Dr, Howell Township, NJ 07731', '', '            \"Total number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 1\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\nGoogle Photos account link: \r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\"                        ', NULL, NULL, 3, '2023-09-15 21:31:00', '2023-09-29 20:04:07', '8', '', '', '', '2023-09-15 21:57:58', 1, 0),
(400, 96, '26 Edgeware Close, Freehold NJ ', '', '       Please edit HDR Photos. Here is the link:                             ', NULL, NULL, 1, '2023-09-15 22:09:00', '2023-09-29 20:04:07', '1', '', NULL, NULL, '2023-09-15 22:18:53', 0, 0),
(401, 76, '351 Wilmot Ave, Bridgeport, CT 06607        ', '', '\r\nPhoto HDR        31\r\nHello Team, Please straighten and enhance these ARW Files. Can you add fire to the fireplace? Thank you! TJ\r\n\"                                 ', NULL, NULL, 2, '2023-09-16 04:20:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 07:29:28', 0, 0),
(402, 77, '19 Iris Ave, York, ME', '', '\r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 120\r\n\r\n5X SONY = 75\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\r\n\r\n\"                                    ', NULL, NULL, 2, '2023-09-16 05:25:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 07:30:05', 0, 0),
(403, 77, '31 Linden Ave, Old Orchard Beach, ME ', '', '\r\n\r\n\r\n\r\nINPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 110\r\n\r\n5X SONY = 105\r\n\r\nVIDEO FILES = 19\r\n\r\n \r\n\r\nAGENT BRANDED VIDEO REQUIRED\r\n\r\nEDITOR CHOOSE MUSIC\r\n\r\nNO HOMMATI SPLASH PAGE\r\n\r\n*STABILIZE WINDY/BOUNCY CLIPS*\r\n\r\nREDUCE LENGTH OF CLIPS RATHER THAN SPEED THEM UP\r\n\r\n**IT IS NOT NECESSARY TO USE ALL CLIPS PROVIDED**\r\n\r\n \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels\"                                    ', NULL, NULL, 3, '2023-09-16 05:27:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-16 07:30:59', 0, 3),
(404, 74, '922 Shadow Ln, Mt. Juliet, TN 37122	', '', '\r\nPhoto HDR        72\r\nThese are raw images that already have lens corrections applied taken on the Sony A7RIIIa with the Sony 16-35mm F2.8 lens, using 3 bracketed shots at -3,0,+3 EV. Could I get the edited images in the following dimensions/size in case I need to crop the images. 5400 pixels x 3600 pixels - 5MB\r\n\"                                    ', NULL, NULL, 2, '2023-09-16 06:07:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 07:31:38', 0, 0),
(405, 104, '1638 West Abington Drive, Unit 203 Alexandria Project 1', '', ' \"Please find the link below for our album - HDR 3-1 1638 West Abington Drive, Unit 203 Alexandria Project 1. This album should contain 99 exposures of 33 images.\r\n\r\n\r\n\r\n\"                                   ', NULL, NULL, 2, '2023-09-16 06:51:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 07:32:16', 0, 0),
(406, 104, '1638 West Abington Drive, Unit 203 Alexandria Project 2', '', '     \"Please find the link below for our album - Single JPG 1638 West Abington Drive, Unit 203 Alexandria Project 2. This album should contain 11 images.\r\n\r\n\"                               ', NULL, NULL, 2, '2023-09-16 06:54:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 07:32:57', 0, 0),
(407, 75, '8344 Cedar Chase Dr, Fountain, CO 80817', '', '   \"Photos only\r\n\r\nPhotos: 135 files \r\n                       ', NULL, NULL, 2, '2023-09-16 06:50:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 07:33:32', 0, 0),
(408, 76, '10 Penny Ln, Bethel, CT 06801', '', ' \"Photo HDR        45\r\n   \r\nHello Team, Please straighten and enhance these ARW files. Please add fire to the fireplace. Thank you\"                                   ', NULL, NULL, 2, '2023-09-16 07:41:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 07:51:35', 0, 0),
(409, 71, '24126 K-& Hwy', '', '  \"Could you please provide HDR Editing and 2D Editing for the above address.  There should be a total of 60 HDR photos and 16 2D photos.  Thank you!\r\n\r\nHDR Photo Link:\r\n\r\n\r\n2D Photo Link:\r\n                              ', NULL, NULL, 2, '2023-09-16 05:22:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 07:55:12', 0, 0),
(410, 82, '7118 Patton Park Rd. Lyles, TN 37098', '', '                                    ', NULL, NULL, 2, '2023-09-16 08:05:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-16 08:07:24', 0, 3),
(411, 123, '20033 Sancraft Ave, Port Charlotte, FL 33954', '', '\"Photo HDR , Aerial Video	35\r\nEditing Team, For DTE please remove the hose and black table top on the left side of the neighboring house, and the garbage cans on the right side. For the video, please use a picture of the living room, one of the kitchen and one of the master bedroom. Thank you, and Best Regards \"                                    ', NULL, NULL, 2, '2023-09-16 09:42:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-16 09:49:47', 0, 3),
(412, 89, '35 CITRUS DRIVE, PALM HARBOR, FL 34684', '', '\"Photo HDR , Aerial Video        55\r\n\r\nTwilight Images - 2        Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:I would like DSC04152.ARW be one of the Twilights Please\r\n\r\nOption\"                                    ', NULL, NULL, 2, '2023-09-16 10:12:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-16 10:48:22', 0, 3),
(413, 89, '13504 DUNWOODY DRIVE, SPRING HILL, FL 34609', '', ' \"Photo HDR , Aerial Video	72\r\n\r\nTwilight Images - 2	Total Images\r\n2\r\nTotal number of images with changes:\r\n\r\nTotal number of images without changes:\r\n\r\nTotal number of twilight enhancement images: 2\r\n\r\nTotal number of blue sky/green grass enhancement images:\r\n\r\n\r\n\r\nProperty style:\r\n\r\nSpecial Instructions:NA\r\n\r\nOption\r\nA few aerial shots of the clubhouse and rec center please in the video. Keep up the great work... the videos have been very well edited! Please keep our sky for HDRs.... Thank You!\"                                   ', NULL, NULL, 2, '2023-09-16 10:27:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-16 10:49:04', 0, 3),
(414, 120, '87-190 Maaloa St, Waianae', '', 'Please complete my order for the PLAT PACK PLUS HDR.\r\n\r\nFiles are still uploading. Please wait for all files to upload.\r\n\r\n \r\n\r\nThis link has both photos and videos https://adobe.ly/3PF7gRT\r\n\r\n \r\n\r\nVIDEO:\r\n\r\nThere are 9 video files to make UNBRANDED video.\r\nTrim, cut, edit and use different speeds as necessary.\r\nPlease use the attached music.\r\n \r\n\r\nPHOTOS:\r\n\r\nThere are 170 bracketed image files\r\nTotal 34 composition images\r\nPlease make 1ST DTE with the INTERIOR image CAM05948 (sunset is LEFT SIDE of the image)\r\nPlease make 2ND DTE with the AERIAL image DJI_0429 (sunset is RIGHT SIDE the image)\r\nKEEP ORIGINAL SKIES\r\n \r\nAlso, please highlight the property.\r\n       ', NULL, NULL, 1, '2023-09-16 11:44:00', '2023-09-29 20:04:07', '1,8,10', '', NULL, NULL, '2023-09-16 13:02:06', 0, 3),
(415, 120, '87-179 Kahau St, Waianae', '', '                                    Please complete my order for the PLAT PACK PLUS HDR.\r\n\r\nFiles are still uploading. Please wait for all files to upload.\r\n\r\n \r\n\r\nThis link has both photos and videos \r\n\r\n \r\n\r\nVIDEO:\r\n\r\nThere are 8 video files to make UNBRANDED video.\r\nTrim, cut, edit and use different speeds as necessary.\r\nPlease use the attached music.\r\nPlease highlight the property.\r\n \r\n\r\nPHOTOS:\r\n\r\nThere are 175 bracketed image files\r\nTotal 35 composition images\r\nPlease make 1ST DTE with the EXTERIOR image CAM06343 (sunset is RIGHT SIDE of the image)\r\nPlease make 2ND DTE with the AERIAL image DJI_0467 (sunset is RIGHT SIDE of the image)\r\nKEEP ORIGINAL SKIES', NULL, NULL, 1, '2023-09-16 11:53:00', '2023-09-29 20:04:07', '1,8,10', '', NULL, NULL, '2023-09-16 13:13:24', 0, 3),
(416, 91, '1867 Fairlawn Ct, Rock Hill, SC 29732', '', 'Photo HDR , 35\r\nAerial Video \r\nTwilight Images - 2', NULL, NULL, 2, '2023-09-16 13:00:00', '2023-09-29 20:04:07', '1,8,10', '', '', '', '2023-09-16 13:15:26', 0, 3),
(417, 91, '164 Fern Ave SW, Concord, NC 28025', '', 'Photo HDR 61                    ', NULL, NULL, 2, '2023-09-16 13:15:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 13:16:14', 0, 0),
(418, 120, '2825 Pali Hwy, B, Honolulu', '', ' Please complete my order for the PLAT PACK PLUS HDR.\r\n\r\nFiles are still uploading. Please wait for all files to upload.\r\n\r\n \r\n\r\nThis link has both photos and videos https://adobe.ly/3ZrWlyj\r\n\r\n \r\n\r\nVIDEO:\r\n\r\nThere are 9 video files to make UNBRANDED video.\r\nTrim, cut, edit and use different speeds as necessary.\r\nPlease use the attached music.\r\nPlease highlight the property. The property has an unusual layout – PLEASE REFER TO THE ATTACHED PICTURE TO HIGHLIGHT IT CORRECTLY!\r\n \r\n\r\nPHOTOS:\r\n\r\nThere are 175 bracketed image files\r\nTotal 35 composition images\r\nPlease make 1ST DTE with the EXTERIOR image CAM06393 (sunset is RIGHT SIDE of the image). Please make sure shadows are not visible.\r\nPlease make 2ND DTE with the AERIAL image DJI_0525 (sunset is RIGHT SIDE of the image)\r\nKEEP ORIGINAL SKIES', NULL, NULL, 1, '2023-09-16 12:24:00', '2023-09-29 20:04:07', '1,8,10', '', NULL, NULL, '2023-09-16 13:35:47', 0, 3),
(419, 77, '66 High Street, Bath ME', '', '                                    INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 100\r\n\r\n5X SONY = 270\r\n\r\n  \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES (GOOD SKY PLEASE!!)\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels', NULL, NULL, 2, '2023-09-16 12:36:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 13:36:42', 0, 0),
(420, 77, '13 Ellsworth Street, Springvale ME', '', 'INPUT FILE COUNTS:\r\n\r\n \r\n\r\n5X DJI = 85\r\n\r\n5X SONY = 180\r\n\r\n  \r\n\r\nNOTES: \r\n\r\nExterior sky replacement = YES\r\n\r\nInterior sky replacement = YES\r\n\r\nCorrect Lens Distortion on SONY files\r\n\r\nLevel horizon on DJI files\r\n\r\nResize to 3,000 x 2,000 pixels', NULL, NULL, 2, '2023-09-16 12:37:00', '2023-09-29 20:04:07', '1', '', '', '', '2023-09-16 13:37:33', 0, 0),
(424, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '6', '', NULL, NULL, '2023-09-30 12:53:31', 0, 3),
(425, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '2,4,6', '', NULL, NULL, '2023-09-30 13:01:52', 0, 3),
(426, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '2,4,6', '', NULL, NULL, '2023-09-30 13:01:54', 0, 3),
(427, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '2,4,6', '', NULL, NULL, '2023-09-30 13:05:03', 0, 3),
(428, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '', '', NULL, NULL, '2023-09-30 13:05:12', 0, 3),
(429, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '', '', NULL, NULL, '2023-09-30 13:13:39', 0, 3),
(430, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:13:43', 0, 3),
(431, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:14:30', 0, 3),
(432, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:14:57', 0, 3),
(433, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:15:15', 0, 3),
(434, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:15:24', 0, 3),
(435, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:15:51', 0, 3),
(436, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:16:13', 0, 3),
(437, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:17:26', 0, 3),
(438, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:18:04', 0, 3),
(439, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:18:15', 0, 3),
(440, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:18:41', 0, 3),
(441, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:19:04', 0, 3),
(442, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:19:30', 0, 3),
(443, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:22:51', 0, 3),
(444, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1', '', NULL, NULL, '2023-09-30 13:23:10', 0, 3),
(445, 73, 'project name here', 'description here		\n', 'instruction for editor here\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1,2,4', '', NULL, NULL, '2023-09-30 13:23:38', 0, 3),
(446, 111, 'project name here', 'description for project\n', 'instruction for editor\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '2,4,7', '', NULL, NULL, '2023-09-30 13:26:35', 0, 1),
(447, 73, 'project test', 'project description here\n', 'instruction for editor on this project\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1,3,6', '', NULL, NULL, '2023-09-30 13:27:33', 0, 2),
(448, 117, 'project name test', 'this is a project\'s description\n', 'this is an instruction for editor\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1,3,5', '', NULL, NULL, '2023-09-30 13:29:36', 0, 2),
(449, 117, 'project test', 'description	\n', 'instruction\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '', '', NULL, NULL, '2023-09-30 13:31:01', 0, 0),
(450, 86, 'project test with default status is 1', 'this is a description	\n', 'this is an instruction\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '1,4,6', '', NULL, NULL, '2023-09-30 13:37:09', 0, 3),
(451, 99, 'project test with default choosen status', 'fasfdsa\n', 'fsdafsd\n', NULL, NULL, 1, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '2,7', '', NULL, NULL, '2023-09-30 13:46:15', 0, 3),
(452, 77, 'project test with default status choosen', '\n', '\n', NULL, NULL, 5, '2023-09-30 00:00:00', '2023-09-30 00:00:00', '3', '', NULL, NULL, '2023-09-30 13:48:05', 0, 1),
(453, 118, 'fdsấ', '\n', '\n', NULL, NULL, 1, '2023-09-30 15:32:00', '2023-09-30 15:32:00', '', '', NULL, NULL, '2023-09-30 15:33:10', 0, 0),
(454, 97, 'test thien', 'https://drive.google.com/drive/folders/1v5uwbiS_hAbKV_TCY5jFa23tHymA196N?usp=drive_link\n\n\n\nINPUT FILE COUNTS:\n\n\n\n5X DJI = 120\n\n5X SONY = 165\n\n\n\nNOTES:\n\nExterior sky replacement = YES\n\nInterior sky replacement = YES\n\nCorrect Lens Distortion on SONY files\n\nLevel horizon on DJI files\n\nResize to 3,000 x 2,000 pixels\n', 'INPUT FILE COUNTS:\n\n\n\n5X DJI = 120\n\n5X SONY = 165\n\n\n\nNOTES:\n\nExterior sky replacement = YES\n\nInterior sky replacement = YES\n\nCorrect Lens Distortion on SONY files\n\nLevel horizon on DJI files\n\nResize to 3,000 x 2,000 pixels\n', NULL, NULL, 1, '2023-09-20 21:10:00', '2023-09-21 05:10:00', '2,3,4', '', NULL, NULL, '2023-09-30 20:58:56', 0, 1),
(455, 110, 'test thien2', 'https://drive.google.com/drive/folders/1v5uwbiS_hAbKV_TCY5jFa23tHymA196N?usp=drive_link\n\n\n\nINPUT FILE COUNTS:\n\n\n\n5X DJI = 120\n\n5X SONY = 165\n\n\n\nNOTES:\n\nExterior sky replacement = YES\n\nInterior sky replacement = YES\n\nCorrect Lens Distortion on SONY files\n\nLevel horizon on DJI files\n\nResize to 3,000 x 2,000 pixels\n', 'INPUT FILE COUNTS:\n\n\n\n5X DJI = 120\n\n5X SONY = 165\n\n\n\nNOTES:\n\nExterior sky replacement = YES\n\nInterior sky replacement = YES\n\nCorrect Lens Distortion on SONY files\n\nLevel horizon on DJI files\n\nResize to 3,000 x 2,000 pixels\n', NULL, NULL, 1, '2023-09-30 21:01:00', '2023-10-01 05:01:00', '', '', NULL, NULL, '2023-09-30 21:02:16', 0, 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `status_invoice`
--

CREATE TABLE `status_invoice` (
  `id` int(11) NOT NULL,
  `stt_iv_name` varchar(12) NOT NULL,
  `color_sttiv` varchar(50) NOT NULL,
  `ngay_tao` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `status_invoice`
--

INSERT INTO `status_invoice` (`id`, `stt_iv_name`, `color_sttiv`, `ngay_tao`) VALUES
(1, 'wait', 'badge badge-secondary', '2023-04-16'),
(2, 'Sent', 'badge badge-success', '2023-04-16'),
(3, 'Paid', 'badge badge-info', '2023-04-16');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `status_job`
--

CREATE TABLE `status_job` (
  `id` int(11) NOT NULL,
  `stt_job_name` varchar(30) NOT NULL,
  `color_sttj` varchar(50) NOT NULL,
  `group_sttj` varchar(10) NOT NULL,
  `ngay_tao_sttj` date NOT NULL,
  `nguoi_tao_sttj` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `status_job`
--

INSERT INTO `status_job` (`id`, `stt_job_name`, `color_sttj`, `group_sttj`, `ngay_tao_sttj`, `nguoi_tao_sttj`) VALUES
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
-- Cấu trúc bảng cho bảng `status_task`
--

CREATE TABLE `status_task` (
  `id` int(11) NOT NULL,
  `stt_task_name` varchar(30) NOT NULL,
  `color_sttt` varchar(50) NOT NULL,
  `group_sttt` varchar(10) NOT NULL,
  `ngay_tao_sttt` date NOT NULL,
  `nguoi_tao_sttt` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `status_task`
--

INSERT INTO `status_task` (`id`, `stt_task_name`, `color_sttt`, `group_sttt`, `ngay_tao_sttt`, `nguoi_tao_sttt`) VALUES
(1, 'Done', 'badge badge-success', '0', '0000-00-00', ''),
(2, 'Reject', 'badge badge-dark', '', '0000-00-00', ''),
(3, 'Fixed', 'badge badge-info', '', '0000-00-00', ''),
(4, 'QA-Done', 'badge badge-warning', '', '0000-00-00', ''),
(5, 'DC-RJ', 'badge badge-secondary', '', '0000-00-00', ''),
(6, 'OK-DC', 'badge badge-danger', '', '0000-00-00', ''),
(7, 'Upload', 'badge badge-warning', '', '0000-00-00', ''),
(8, 'DC-FIX', 'badge badge-ligh', '', '0000-00-00', ''),
(9, 'Wait', 'badge badge-dark', '', '0000-00-00', '');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `system_settings`
--

CREATE TABLE `system_settings` (
  `id` int(30) NOT NULL,
  `name` text NOT NULL,
  `email` varchar(200) NOT NULL,
  `contact` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `cover_img` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `system_settings`
--

INSERT INTO `system_settings` (`id`, `name`, `email`, `contact`, `address`, `cover_img`) VALUES
(1, 'Quản lý công việc', 'contactphotohome@gmail.com', '+84845618456', 'Hà nội', '');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `task_list`
--

CREATE TABLE `task_list` (
  `id` int(30) NOT NULL,
  `project_id` int(30) NOT NULL,
  `task` varchar(200) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `editor` int(11) NOT NULL,
  `qa` int(11) NOT NULL,
  `idlevel` int(30) NOT NULL,
  `soluong` int(11) NOT NULL,
  `c_intruc` int(11) NOT NULL,
  `q_intruc` int(11) NOT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `task_list`
--

INSERT INTO `task_list` (`id`, `project_id`, `task`, `description`, `status`, `editor`, `qa`, `idlevel`, `soluong`, `c_intruc`, `q_intruc`, `date_created`) VALUES
(82, 112, '2 anh 130-DSC02985,165-DSC03020 bi mo', NULL, 7, 4, 0, 1, 46, 1, 0, '2023-09-05 01:33:18'),
(83, 113, '', NULL, 7, 4, 0, 1, 27, 1, 0, '2023-09-05 01:36:57'),
(84, 114, NULL, NULL, 7, 4, 0, 1, 38, 1, 0, '2023-09-05 04:19:15'),
(85, 115, NULL, NULL, 7, 4, 0, 1, 62, 1, 0, '2023-09-05 04:19:23'),
(86, 116, '', NULL, 7, 4, 0, 1, 39, 1, 0, '2023-09-05 04:33:13'),
(87, 116, '', NULL, 7, 9, 0, 8, 1, 1, 0, '2023-09-05 04:33:13'),
(88, 116, NULL, NULL, 7, 0, 0, 10, 1, 1, 0, '2023-09-05 04:33:13'),
(89, 117, '', NULL, 7, 4, 0, 1, 50, 0, 0, '2023-09-05 08:38:45'),
(91, 118, '', NULL, 7, 4, 9, 1, 57, 1, 0, '2023-09-05 13:36:47'),
(92, 118, '', NULL, 7, 4, 9, 8, 1, 1, 0, '2023-09-05 13:36:47'),
(93, 118, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-05 13:36:47'),
(95, 120, NULL, NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-06 01:10:02'),
(96, 121, NULL, NULL, 7, 4, 9, 1, 30, 0, 0, '2023-09-06 01:10:15'),
(97, 121, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-06 01:10:15'),
(98, 121, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-06 01:10:15'),
(99, 119, NULL, NULL, 7, 0, 0, 9, 1, 0, 0, '2023-09-06 01:10:45'),
(100, 122, NULL, NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-06 01:13:32'),
(101, 217, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-09 16:05:02'),
(102, 218, NULL, NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-09 16:07:30'),
(103, 218, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-09 16:07:30'),
(104, 218, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-09 16:07:30'),
(105, 242, NULL, NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-09 16:07:32'),
(106, 241, NULL, NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-09 16:07:37'),
(107, 241, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-09 16:07:37'),
(108, 241, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-09 16:07:37'),
(109, 240, NULL, NULL, 7, 4, 0, 1, 38, 0, 0, '2023-09-09 16:07:40'),
(110, 239, NULL, NULL, 7, 4, 9, 1, 78, 0, 0, '2023-09-09 16:07:43'),
(111, 239, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-09 16:07:43'),
(112, 239, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-09 16:07:43'),
(113, 238, NULL, NULL, 7, 4, 9, 1, 25, 0, 1, '2023-09-09 16:07:46'),
(114, 238, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-09 16:07:46'),
(115, 238, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-09 16:07:46'),
(116, 237, NULL, NULL, 7, 4, 9, 1, 75, 0, 1, '2023-09-09 16:07:51'),
(117, 237, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-09 16:07:51'),
(118, 237, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-09 16:07:51'),
(119, 236, NULL, NULL, 7, 4, 9, 1, 40, 0, 1, '2023-09-09 16:07:55'),
(120, 235, NULL, NULL, 7, 4, 9, 1, 50, 0, 0, '2023-09-09 16:07:58'),
(121, 240, '', NULL, 7, 4, 0, 2, 2, 0, 0, '2023-09-09 16:27:39'),
(122, 239, '', NULL, 7, 4, 0, 3, 15, 0, 0, '2023-09-09 16:29:03'),
(123, 235, '', NULL, 7, 9, 9, 8, 2, 0, 0, '2023-09-09 19:03:07'),
(124, 235, '', NULL, 7, 7, 9, 6, 3, 0, 0, '2023-09-09 19:11:12'),
(125, 256, NULL, NULL, 7, 17, 21, 1, 40, 0, 1, '2023-09-10 10:22:19'),
(126, 255, NULL, NULL, 7, 17, 21, 1, 30, 0, 1, '2023-09-10 10:22:22'),
(127, 254, NULL, NULL, 7, 19, 21, 1, 23, 0, 1, '2023-09-10 10:22:25'),
(128, 254, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-10 10:22:25'),
(129, 254, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-10 10:22:25'),
(130, 253, NULL, NULL, 7, 13, 21, 1, 24, 0, 1, '2023-09-10 10:22:27'),
(131, 253, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-10 10:22:27'),
(132, 252, NULL, NULL, 7, 14, 21, 1, 1, 0, 1, '2023-09-10 10:22:30'),
(133, 252, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-10 10:22:30'),
(134, 251, NULL, NULL, 7, 13, 21, 1, 30, 0, 0, '2023-09-10 10:22:34'),
(135, 251, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-10 10:22:34'),
(136, 249, NULL, NULL, 7, 13, 21, 1, 54, 0, 1, '2023-09-10 10:22:36'),
(137, 250, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-10 10:22:38'),
(138, 248, NULL, NULL, 7, 19, 21, 1, 21, 0, 1, '2023-09-10 10:22:40'),
(139, 248, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-10 10:22:40'),
(140, 248, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-10 10:22:40'),
(141, 247, NULL, NULL, 7, 12, 21, 1, 47, 0, 1, '2023-09-10 10:22:42'),
(142, 247, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-10 10:22:42'),
(143, 247, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-10 10:22:42'),
(144, 246, NULL, NULL, 7, 15, 21, 1, 1, 0, 1, '2023-09-10 10:22:51'),
(145, 246, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-10 10:22:51'),
(146, 243, NULL, NULL, 7, 18, 21, 1, 14, 0, 1, '2023-09-10 10:23:01'),
(147, 245, NULL, NULL, 7, 0, 0, 9, 1, 0, 0, '2023-09-10 15:00:47'),
(148, 244, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-10 15:00:57'),
(149, 243, '', NULL, 7, 18, 21, 2, 5, 0, 1, '2023-09-10 15:03:21'),
(150, 257, '', NULL, 7, 36, 50, 1, 38, 0, 1, '2023-09-11 10:32:36'),
(151, 258, '', NULL, 7, 42, 21, 1, 49, 0, 1, '2023-09-12 09:32:12'),
(152, 258, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-12 09:32:12'),
(153, 258, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-12 09:32:12'),
(154, 259, '', NULL, 7, 43, 0, 1, 1, 0, 0, '2023-09-12 09:32:22'),
(155, 259, NULL, NULL, 7, 50, 0, 8, 1, 0, 0, '2023-09-12 09:32:22'),
(156, 259, '', NULL, 7, 4, 0, 10, 1, 0, 0, '2023-09-12 09:32:22'),
(157, 260, NULL, NULL, 7, 18, 9, 1, 19, 0, 1, '2023-09-12 09:32:28'),
(158, 261, NULL, NULL, 7, 11, 0, 1, 54, 0, 0, '2023-09-12 09:32:36'),
(159, 262, NULL, NULL, 7, 20, 0, 1, 1, 0, 0, '2023-09-12 09:32:43'),
(160, 263, NULL, NULL, 7, 10, 0, 1, 1, 0, 0, '2023-09-12 09:46:29'),
(161, 266, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-12 09:53:03'),
(162, 264, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-12 10:33:47'),
(163, 265, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-12 10:35:23'),
(164, 261, '', NULL, 7, 11, 0, 2, 5, 0, 0, '2023-09-12 15:30:33'),
(165, 275, NULL, NULL, 7, 22, 50, 1, 50, 0, 1, '2023-09-13 08:17:21'),
(166, 275, NULL, NULL, 7, 51, 0, 8, 1, 1, 0, '2023-09-13 08:17:21'),
(167, 275, '', NULL, 7, 4, 0, 10, 1, 0, 0, '2023-09-13 08:17:21'),
(168, 283, NULL, NULL, 7, 48, 0, 1, 29, 0, 0, '2023-09-13 08:23:39'),
(169, 283, NULL, NULL, 7, 49, 0, 8, 1, 0, 0, '2023-09-13 08:23:39'),
(170, 283, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 08:23:39'),
(171, 282, NULL, NULL, 7, 19, 9, 1, 20, 0, 1, '2023-09-13 08:23:51'),
(172, 282, NULL, NULL, 7, 21, 0, 8, 1, 0, 0, '2023-09-13 08:23:51'),
(173, 282, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 08:23:51'),
(175, 294, NULL, NULL, 7, 11, 49, 1, 60, 0, 1, '2023-09-13 08:50:41'),
(176, 279, NULL, NULL, 7, 29, 0, 1, 1, 0, 0, '2023-09-13 08:53:41'),
(177, 279, NULL, NULL, 7, 50, 0, 8, 1, 0, 0, '2023-09-13 08:53:41'),
(178, 279, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 08:53:41'),
(179, 296, NULL, NULL, 7, 16, 50, 1, 53, 0, 1, '2023-09-13 08:54:04'),
(180, 290, '', NULL, 7, 13, 0, 0, 35, 0, 0, '2023-09-13 09:00:13'),
(181, 293, NULL, NULL, 7, 20, 0, 1, 1, 0, 0, '2023-09-13 09:02:36'),
(182, 293, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-13 09:02:36'),
(183, 293, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 09:02:36'),
(184, 298, '', NULL, 7, 25, 0, 0, 10, 0, 0, '2023-09-13 10:52:53'),
(185, 298, '', NULL, 7, 25, 0, 1, 31, 0, 0, '2023-09-13 10:53:23'),
(186, 299, NULL, NULL, 7, 17, 0, 1, 35, 0, 0, '2023-09-13 10:59:07'),
(187, 295, '', NULL, 7, 36, 9, 1, 18, 0, 1, '2023-09-13 10:59:41'),
(189, 295, '', NULL, 7, 26, 9, 1, 1, 0, 1, '2023-09-13 11:02:35'),
(190, 302, NULL, NULL, 7, 12, 0, 1, 73, 0, 0, '2023-09-13 11:08:45'),
(191, 303, NULL, NULL, 7, 22, 49, 1, 55, 0, 1, '2023-09-13 11:16:02'),
(192, 305, NULL, NULL, 7, 15, 49, 1, 30, 1, 0, '2023-09-13 11:32:30'),
(193, 295, '', NULL, 7, 26, 9, 1, 28, 0, 1, '2023-09-13 11:34:27'),
(194, 304, NULL, NULL, 7, 16, 0, 1, 1, 0, 0, '2023-09-13 11:42:41'),
(195, 304, NULL, NULL, 7, 50, 0, 8, 1, 0, 0, '2023-09-13 11:42:41'),
(196, 304, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 11:42:41'),
(197, 281, NULL, NULL, 7, 36, 0, 1, 1, 0, 0, '2023-09-13 12:46:59'),
(198, 281, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 12:46:59'),
(199, 307, NULL, NULL, 7, 17, 0, 1, 57, 0, 0, '2023-09-13 12:56:40'),
(200, 313, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-13 13:26:41'),
(201, 313, NULL, NULL, 7, 51, 0, 8, 1, 0, 0, '2023-09-13 13:26:41'),
(202, 313, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 13:26:41'),
(203, 312, NULL, NULL, 7, 25, 0, 1, 52, 1, 0, '2023-09-13 13:29:49'),
(204, 312, NULL, NULL, 7, 51, 0, 8, 1, 0, 0, '2023-09-13 13:29:49'),
(205, 312, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 13:29:49'),
(206, 308, NULL, NULL, 7, 51, 0, 8, 2, 1, 0, '2023-09-13 13:33:11'),
(207, 309, NULL, NULL, 7, 15, 0, 1, 1, 0, 0, '2023-09-13 13:50:04'),
(208, 311, '', NULL, 7, 4, 49, 3, 15, 0, 1, '2023-09-13 14:38:26'),
(209, 306, NULL, NULL, 7, 22, 0, 1, 40, 0, 0, '2023-09-13 14:51:29'),
(210, 306, NULL, NULL, 7, 52, 0, 8, 1, 0, 0, '2023-09-13 14:51:29'),
(211, 306, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-13 14:51:29'),
(212, 310, '', NULL, 7, 4, 49, 1, 6, 0, 1, '2023-09-13 14:52:43'),
(214, 316, NULL, NULL, 7, 41, 0, 1, 1, 0, 0, '2023-09-13 19:41:25'),
(226, 317, NULL, NULL, 7, 24, 0, 1, 100, 1, 0, '2023-09-13 23:03:20'),
(227, 318, NULL, NULL, 7, 45, 0, 1, 1, 0, 0, '2023-09-13 23:26:10'),
(228, 318, '', NULL, 7, 4, 52, 2, 5, 0, 0, '2023-09-13 23:29:20'),
(229, 320, '', NULL, 7, 4, 21, 1, 3, 0, 1, '2023-09-14 00:43:48'),
(230, 321, '', NULL, 7, 41, 0, 1, 1, 0, 0, '2023-09-14 00:59:57'),
(231, 321, '', NULL, 7, 4, 0, 1, 10, 0, 0, '2023-09-14 01:01:12'),
(232, 325, '', NULL, 7, 44, 50, 1, 26, 0, 1, '2023-09-14 01:17:05'),
(233, 326, NULL, NULL, 7, 32, 0, 1, 1, 0, 0, '2023-09-14 01:57:16'),
(235, 326, NULL, NULL, 7, 51, 0, 8, 1, 0, 0, '2023-09-14 01:57:16'),
(236, 326, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 01:57:16'),
(237, 327, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-14 02:13:00'),
(238, 328, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-14 02:13:31'),
(239, 329, '', NULL, 7, 41, 50, 1, 22, 0, 1, '2023-09-14 03:42:40'),
(240, 331, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-14 07:31:21'),
(241, 330, NULL, NULL, 7, 15, 50, 1, 33, 0, 1, '2023-09-14 07:34:55'),
(242, 332, NULL, NULL, 7, 18, 9, 1, 45, 0, 1, '2023-09-14 07:43:07'),
(243, 333, NULL, NULL, 7, 29, 50, 1, 53, 0, 1, '2023-09-14 07:43:49'),
(245, 337, NULL, NULL, 7, 26, 50, 1, 24, 0, 1, '2023-09-14 07:47:22'),
(246, 338, NULL, NULL, 7, 37, 50, 1, 5, 0, 1, '2023-09-14 07:48:27'),
(247, 345, NULL, NULL, 7, 11, 21, 1, 41, 0, 1, '2023-09-14 07:57:57'),
(248, 346, NULL, NULL, 7, 28, 21, 1, 5, 0, 1, '2023-09-14 08:07:46'),
(249, 335, NULL, NULL, 7, 28, 50, 1, 75, 0, 1, '2023-09-14 08:08:03'),
(250, 336, NULL, NULL, 7, 17, 50, 1, 30, 0, 1, '2023-09-14 08:17:35'),
(251, 339, NULL, NULL, 7, 22, 21, 1, 32, 0, 1, '2023-09-14 08:35:55'),
(252, 340, NULL, NULL, 7, 20, 21, 1, 24, 0, 1, '2023-09-14 08:49:00'),
(253, 334, NULL, NULL, 7, 26, 21, 1, 66, 0, 1, '2023-09-14 08:53:15'),
(254, 334, NULL, NULL, 7, 51, 0, 8, 1, 0, 0, '2023-09-14 08:53:15'),
(255, 334, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 08:53:15'),
(256, 341, NULL, NULL, 7, 42, 50, 1, 20, 0, 1, '2023-09-14 08:59:05'),
(257, 343, NULL, NULL, 7, 15, 21, 1, 55, 0, 1, '2023-09-14 09:21:01'),
(258, 343, '', NULL, 7, 51, 0, 8, 1, 0, 0, '2023-09-14 09:21:01'),
(259, 343, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 09:21:01'),
(260, 344, NULL, NULL, 7, 46, 50, 1, 22, 0, 1, '2023-09-14 09:28:41'),
(261, 355, NULL, NULL, 7, 22, 21, 1, 39, 0, 1, '2023-09-14 10:11:20'),
(262, 355, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-14 10:11:20'),
(263, 355, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 10:11:20'),
(264, 356, NULL, NULL, 7, 20, 0, 1, 1, 0, 0, '2023-09-14 10:25:39'),
(265, 356, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-14 10:25:39'),
(266, 356, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 10:25:39'),
(267, 347, NULL, NULL, 7, 30, 21, 1, 35, 0, 1, '2023-09-14 11:04:32'),
(268, 349, NULL, NULL, 7, 18, 21, 1, 39, 0, 1, '2023-09-14 11:09:50'),
(269, 342, '', NULL, 7, 48, 51, 1, 14, 0, 1, '2023-09-14 11:19:16'),
(270, 342, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 11:19:16'),
(271, 350, NULL, NULL, 7, 25, 50, 1, 67, 0, 1, '2023-09-14 11:38:52'),
(272, 352, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-14 11:39:19'),
(273, 351, NULL, NULL, 7, 29, 21, 1, 50, 0, 1, '2023-09-14 11:59:06'),
(274, 351, NULL, NULL, 7, 9, 0, 8, 2, 1, 0, '2023-09-14 11:59:06'),
(275, 351, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 11:59:06'),
(276, 354, NULL, NULL, 7, 37, 21, 1, 25, 0, 1, '2023-09-14 12:33:52'),
(277, 357, NULL, NULL, 7, 42, 0, 1, 1, 0, 0, '2023-09-14 12:39:45'),
(278, 357, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-14 12:39:45'),
(279, 357, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 12:39:45'),
(280, 358, NULL, NULL, 7, 30, 50, 1, 53, 0, 1, '2023-09-14 12:52:12'),
(281, 360, NULL, NULL, 7, 19, 0, 1, 1, 0, 0, '2023-09-14 13:18:08'),
(282, 361, NULL, NULL, 7, 20, 21, 1, 38, 0, 1, '2023-09-14 13:29:04'),
(283, 363, NULL, NULL, 7, 29, 50, 1, 34, 0, 1, '2023-09-14 13:40:46'),
(284, 363, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-14 13:40:46'),
(285, 363, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 13:40:46'),
(286, 364, NULL, NULL, 7, 17, 0, 1, 1, 0, 0, '2023-09-14 14:01:34'),
(287, 364, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-14 14:01:34'),
(288, 364, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 14:01:34'),
(289, 365, NULL, NULL, 7, 22, 0, 1, 66, 0, 0, '2023-09-14 14:26:16'),
(290, 365, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-14 14:26:16'),
(291, 365, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-14 14:26:16'),
(292, 368, '', NULL, 7, 19, 0, 1, 1, 0, 0, '2023-09-15 07:23:26'),
(293, 377, NULL, NULL, 7, 42, 50, 1, 43, 0, 1, '2023-09-15 07:25:18'),
(294, 377, '', NULL, 4, 9, 0, 8, 1, 0, 0, '2023-09-15 07:25:18'),
(295, 377, NULL, NULL, 1, 0, 0, 10, 1, 0, 0, '2023-09-15 07:25:18'),
(296, 376, '', NULL, 7, 28, 50, 1, 42, 0, 1, '2023-09-15 07:46:24'),
(297, 378, '', NULL, 7, 13, 21, 1, 16, 0, 1, '2023-09-15 07:51:31'),
(298, 378, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 07:51:31'),
(299, 378, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 07:51:31'),
(300, 382, NULL, NULL, 7, 29, 21, 1, 23, 0, 1, '2023-09-15 07:57:07'),
(301, 382, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 07:57:07'),
(302, 382, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 07:57:07'),
(303, 383, NULL, NULL, 7, 20, 0, 1, 30, 1, 0, '2023-09-15 08:10:34'),
(304, 380, NULL, NULL, 7, 17, 0, 1, 1, 0, 0, '2023-09-15 08:17:24'),
(305, 380, NULL, NULL, 7, 0, 0, 6, 1, 0, 0, '2023-09-15 08:17:24'),
(306, 380, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 08:17:24'),
(307, 384, NULL, NULL, 7, 29, 50, 1, 1, 0, 1, '2023-09-15 08:37:33'),
(308, 385, NULL, NULL, 7, 18, 0, 1, 32, 1, 0, '2023-09-15 08:51:22'),
(309, 385, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 08:51:22'),
(310, 385, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 08:51:22'),
(311, 386, NULL, NULL, 7, 17, 0, 1, 34, 1, 0, '2023-09-15 09:01:49'),
(312, 386, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 09:01:49'),
(313, 386, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 09:01:49'),
(314, 388, NULL, NULL, 7, 18, 50, 1, 11, 0, 1, '2023-09-15 09:25:14'),
(315, 389, NULL, NULL, 7, 22, 21, 1, 1, 0, 1, '2023-09-15 09:32:04'),
(316, 392, NULL, NULL, 7, 30, 50, 1, 16, 0, 1, '2023-09-15 09:32:17'),
(317, 389, '', NULL, 7, 22, 21, 3, 15, 0, 1, '2023-09-15 10:15:15'),
(318, 375, '', NULL, 7, 26, 0, 1, 1, 0, 0, '2023-09-15 10:19:18'),
(319, 387, NULL, NULL, 7, 15, 0, 1, 67, 1, 0, '2023-09-15 10:22:12'),
(320, 387, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 10:22:12'),
(321, 387, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 10:22:12'),
(322, 379, '', NULL, 7, 4, 0, 1, 73, 0, 0, '2023-09-15 10:30:10'),
(323, 374, '', NULL, 7, 4, 0, 1, 1, 0, 0, '2023-09-15 10:34:14'),
(324, 390, NULL, NULL, 7, 28, 21, 1, 28, 0, 1, '2023-09-15 10:54:46'),
(325, 390, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 10:54:46'),
(326, 390, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 10:54:46'),
(327, 391, '', NULL, 7, 13, 21, 1, 17, 0, 1, '2023-09-15 11:47:58'),
(328, 393, NULL, NULL, 7, 23, 0, 1, 60, 1, 0, '2023-09-15 11:51:35'),
(329, 394, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 11:51:43'),
(330, 384, '', NULL, 7, 29, 50, 5, 1, 0, 1, '2023-09-15 12:12:45'),
(331, 384, '', NULL, 7, 29, 50, 2, 55, 0, 1, '2023-09-15 12:13:50'),
(332, 395, NULL, NULL, 7, 20, 0, 1, 1, 0, 0, '2023-09-15 12:35:45'),
(333, 395, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 12:35:45'),
(334, 395, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 12:35:45'),
(335, 396, NULL, NULL, 7, 11, 0, 1, 47, 1, 0, '2023-09-15 13:04:25'),
(336, 396, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-15 13:04:25'),
(337, 396, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-15 13:04:25'),
(338, 409, NULL, NULL, 7, 15, 50, 1, 76, 0, 1, '2023-09-16 07:55:51'),
(339, 401, '', NULL, 7, 13, 50, 1, 30, 0, 1, '2023-09-16 07:57:17'),
(340, 402, NULL, NULL, 7, 18, 50, 1, 39, 0, 1, '2023-09-16 08:03:17'),
(341, 407, NULL, NULL, 7, 29, 50, 1, 25, 0, 1, '2023-09-16 08:16:28'),
(342, 404, NULL, NULL, 7, 14, 49, 1, 72, 0, 1, '2023-09-16 08:22:23'),
(343, 403, NULL, NULL, 7, 19, 0, 1, 43, 1, 0, '2023-09-16 08:23:20'),
(344, 403, NULL, NULL, 7, 9, 0, 8, 1, 0, 0, '2023-09-16 08:23:20'),
(345, 403, NULL, NULL, 7, 0, 0, 10, 1, 0, 0, '2023-09-16 08:23:20'),
(346, 405, NULL, NULL, 1, 20, 49, 1, 33, 0, 1, '2023-09-16 09:08:42'),
(347, 406, NULL, NULL, 3, 36, 0, 1, 1, 1, 0, '2023-09-16 09:14:59'),
(348, 410, NULL, NULL, 1, 18, 0, 1, 1, 0, 0, '2023-09-16 09:39:56'),
(349, 410, NULL, NULL, 4, 9, 0, 8, 1, 0, 0, '2023-09-16 09:39:56'),
(350, 410, NULL, NULL, 1, 0, 0, 10, 1, 0, 0, '2023-09-16 09:39:56'),
(351, 408, NULL, NULL, 3, 36, 0, 1, 45, 1, 0, '2023-09-16 09:52:03'),
(352, 411, NULL, NULL, 1, 23, 49, 1, 29, 1, 0, '2023-09-16 10:16:45'),
(353, 411, NULL, NULL, 4, 9, 0, 8, 1, 0, 0, '2023-09-16 10:16:45'),
(354, 411, NULL, NULL, 1, 0, 0, 10, 1, 0, 0, '2023-09-16 10:16:45'),
(355, 412, NULL, NULL, 3, 46, 0, 1, 55, 1, 0, '2023-09-16 11:05:35'),
(356, 412, NULL, NULL, 4, 9, 0, 8, 1, 0, 0, '2023-09-16 11:05:35'),
(357, 412, NULL, NULL, 1, 0, 0, 10, 1, 0, 0, '2023-09-16 11:05:35'),
(358, 413, '', NULL, 1, 13, 0, 1, 1, 0, 0, '2023-09-16 11:19:07'),
(359, 413, NULL, NULL, 4, 9, 0, 8, 1, 0, 0, '2023-09-16 11:19:07'),
(360, 413, NULL, NULL, 1, 0, 0, 10, 1, 0, 0, '2023-09-16 11:19:07'),
(361, 416, '', NULL, 1, 29, 0, 1, 1, 0, 0, '2023-09-16 13:26:07'),
(362, 416, '', NULL, 4, 9, 0, 8, 1, 0, 0, '2023-09-16 13:26:07'),
(363, 416, NULL, NULL, 1, 0, 0, 10, 1, 0, 0, '2023-09-16 13:26:07'),
(364, 417, '', NULL, 4, 11, 9, 1, 51, 0, 0, '2023-09-16 13:41:50'),
(365, 419, NULL, NULL, 2, 37, 9, 1, 1, 0, 0, '2023-09-16 14:00:54'),
(366, 420, NULL, NULL, 1, 20, 0, 1, 1, 0, 0, '2023-09-16 14:01:06'),
(367, 420, '', NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-17 09:11:12'),
(368, 420, '', NULL, 4, 9, 0, 8, 1, 0, 0, '2023-09-17 09:46:09'),
(369, 420, '', NULL, 4, 9, 0, 8, 1, 0, 0, '2023-09-17 10:08:44'),
(370, 405, '', NULL, 1, 9, 0, 8, 1, 0, 0, '2023-09-17 10:12:39'),
(371, 412, '', NULL, 1, 0, 0, 8, 1, 0, 0, '2023-09-17 10:15:39'),
(372, 435, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:15:51'),
(373, 436, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:16:13'),
(374, 437, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:17:26'),
(375, 439, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:18:15'),
(376, 441, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:19:04'),
(377, 442, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:19:30'),
(378, 443, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:22:51'),
(379, 444, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:23:10'),
(380, 445, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:23:38'),
(381, 445, NULL, NULL, 1, 0, 0, 2, 1, 0, 0, '2023-09-30 13:23:38'),
(382, 445, NULL, NULL, 1, 0, 0, 4, 1, 0, 0, '2023-09-30 13:23:38'),
(383, 446, NULL, NULL, 1, 0, 0, 2, 1, 0, 0, '2023-09-30 13:26:35'),
(384, 446, NULL, NULL, 1, 0, 0, 4, 1, 0, 0, '2023-09-30 13:26:35'),
(385, 446, NULL, NULL, 1, 0, 0, 7, 1, 0, 0, '2023-09-30 13:26:36'),
(386, 447, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:27:33'),
(387, 447, NULL, NULL, 1, 0, 0, 3, 1, 0, 0, '2023-09-30 13:27:33'),
(388, 447, NULL, NULL, 1, 0, 0, 6, 1, 0, 0, '2023-09-30 13:27:33'),
(389, 448, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:29:36'),
(390, 448, NULL, NULL, 1, 0, 0, 3, 1, 0, 0, '2023-09-30 13:29:36'),
(391, 448, NULL, NULL, 1, 0, 0, 5, 1, 0, 0, '2023-09-30 13:29:36'),
(392, 450, NULL, NULL, 1, 0, 0, 1, 1, 0, 0, '2023-09-30 13:37:09'),
(393, 450, NULL, NULL, 1, 0, 0, 4, 1, 0, 0, '2023-09-30 13:37:09'),
(394, 450, NULL, NULL, 1, 0, 0, 6, 1, 0, 0, '2023-09-30 13:37:09'),
(395, 451, NULL, NULL, 1, 0, 0, 2, 1, 0, 0, '2023-09-30 13:46:15'),
(396, 451, NULL, NULL, 1, 0, 0, 7, 1, 0, 0, '2023-09-30 13:46:15'),
(397, 452, NULL, NULL, 1, 0, 0, 3, 1, 0, 0, '2023-09-30 13:48:05'),
(398, 454, NULL, NULL, 1, 0, 0, 2, 1, 0, 0, '2023-09-30 20:58:56'),
(399, 454, NULL, NULL, 1, 0, 0, 3, 1, 0, 0, '2023-09-30 20:58:56'),
(400, 454, NULL, NULL, 1, 0, 0, 4, 1, 0, 0, '2023-09-30 20:58:56');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` int(30) NOT NULL,
  `firstname` varchar(200) NOT NULL,
  `lastname` varchar(200) NOT NULL,
  `viettat` varchar(30) NOT NULL,
  `email` varchar(200) NOT NULL,
  `password` text NOT NULL,
  `type` tinyint(1) NOT NULL DEFAULT 2 COMMENT '1 = admin, 2 = staff',
  `groupe` int(11) NOT NULL,
  `groupqa` int(11) NOT NULL,
  `avatar` text NOT NULL,
  `sttget` int(11) NOT NULL,
  `ustatus` int(11) NOT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `firstname`, `lastname`, `viettat`, `email`, `password`, `type`, `groupe`, `groupqa`, `avatar`, `sttget`, `ustatus`, `date_created`) VALUES
(1, 'Administrator', '', 'admin', 'admin@admin.com', '2db5228517bf8473a1dda3cab7cb4b8c', 1, 0, 0, '', 0, 0, '2020-11-26 10:57:04'),
(2, 'Nguyễn Hoàng Yến', '', 'Yen.nh', 'sale1@photohome.com.vn', '81dc9bdb52d04dc20036dbd8313ed055', 2, 0, 0, '', 0, 0, '2023-08-20 10:55:42'),
(3, 'Nguyễn Hữu Bình', '', 'Binh.nh', 'binh.nhphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 4, 0, 0, '1693061220_12 228 Main Photo 62.JPG', 0, 0, '2023-08-20 10:57:13'),
(4, 'Thiện', '', 'thien.pd', 'thien@gmail.com', '202cb962ac59075b964b07152d234b70', 6, 1, 0, '', 1, 0, '2023-08-20 11:40:37'),
(5, 'Đỗ Thị Ngọc Mai', '', 'Mai.dn', 'Mai.dnPhotohome@gmail.com', '37f075e83964183d460c4eca59d27d0b', 2, 0, 0, '', 0, 0, '2023-08-20 16:40:39'),
(6, 'Trịnh Thanh Bình', '', 'binh.tt', 'binh.ttphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, '2023-08-25 11:19:50'),
(7, 'Trần Tú Thành', '', 'Thanh.tt', 'Thanh.ttphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, '2023-08-25 11:36:12'),
(8, 'Trần Hồng Nhung', '', 'nhung.th', 'nhung.thphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, '2023-09-04 21:41:06'),
(9, 'Phạm Năng Bình', '', 'binh.pn', 'binh@photohome.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-05 15:00:36'),
(10, 'Bùi Đức Hiếu', '', 'hieu.bd', 'hieu.bdphotohome@gmai.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:52:26'),
(11, 'Phạm Phương Nam', '', 'nam.pp', 'nam.ppphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:53:05'),
(12, 'Nguyễn Đức Việt', '', 'viet.nd', 'viet.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:53:39'),
(13, 'Vũ văn Đạt', '', 'dat.vv', 'dat.vvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:54:18'),
(14, 'Bùi Văn Tuấn', '', 'tuan.bv', 'tuan.bvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:54:50'),
(15, 'Vi Đức Trịnh', '', 'trinh.vd', 'trinh.vdphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:55:23'),
(16, 'Phùng Minh Phong', '', 'phong.pm', 'phong.pmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:55:56'),
(17, 'Nguyễn Hồng Sơn', '', 'son.nh', 'son.nhphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:56:33'),
(18, 'Vũ Đức Thắng', '', 'thang.vd', 'thang.vdphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:57:58'),
(19, 'Chu Thị Thúy', '', 'thuy.ct', 'thuy.ctphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:58:36'),
(20, 'Trần Văn Đoàn', '', 'doan.tv', 'doan.tvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-09 23:59:01'),
(21, 'Vũ Hồng Sơn', '', 'son.vh', 'son.vhphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-10 09:40:43'),
(22, 'Nguyễn Tuấn Nam', '', 'nam.nt', 'nam.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:12:02'),
(23, 'Bùi Văn Hưng', '', 'hung.bv', 'hung.bvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:12:26'),
(24, 'Bùi Ngọc Hoàng', '', 'hoang.bn', 'hoang.bnphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:12:55'),
(25, 'Nguyễn Quốc Cường', '', 'cuong.nq', 'cuong.nqphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:13:21'),
(26, 'Phùng Hữu Tình', '', 'tinh.ph', 'tinh.phphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:14:41'),
(27, 'Phan Văn Thiêm', '', 'thiem.pv', 'thiem.pvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:15:05'),
(28, 'Nguyễn Việt Hoàng', '', 'hoang.nv', 'hoang.nvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:15:33'),
(29, 'Nguyễn Duy Tú', '', 'tu.nd', 'tu.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:15:54'),
(30, 'Nguyễn Đức Chính', '', 'chinh.nd', 'chinh.ndphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:16:21'),
(31, 'Dương Văn Hưng', '', 'hung.dv', 'hung.dvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:16:52'),
(32, 'Dương nguyễn kiên', '', 'kien.dn', 'kien.dnphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:17:14'),
(33, 'Bùi Thị Hoa', '', 'hoa.bt', 'hoa.btphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:17:34'),
(34, 'Phạm Thị thùy Trang', '', 'trang.pt', 'trang.ptphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:18:03'),
(35, 'Nguyễn Thị Thu', '', 'thu.nt', 'thu.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:18:26'),
(36, 'Lê Thu Hiên', '', 'hien.lt', 'hien.ltphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:18:53'),
(37, 'Phạm Thúy Hảo', '', 'hao.pt', 'hoa.ptphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:19:15'),
(38, 'Hoàng Thị Thanh Lam', '', 'lam.ht', 'Lam.htphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:19:40'),
(39, 'Đinh Thị Minh Thi', '', 'thi.dt', 'thi.dmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:20:06'),
(40, 'Trần Mạnh Hùng', '', 'hung.tm', 'hung.tmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:20:28'),
(41, 'Trần Văn Chung', '', 'chung.tv', 'chung.tvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:20:51'),
(42, 'Nguyễn Tuấn Đạt', '', 'dat.nt', 'dat.ntphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:21:14'),
(43, 'Đặng Đức Anh', '', 'anh.dd', 'anh.ddphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:21:36'),
(44, 'Lê Minh Thành', '', 'thanh.lm', 'thanh.lmphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:22:09'),
(45, 'Cấn Việt Ánh', '', 'anh.cv', 'anh.cvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:22:28'),
(46, 'Nguyễn Công Thành', '', 'thanh.nc', 'thanh.ncphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:22:55'),
(47, 'Đinh Công Hưng', '', 'hung.dc', 'hung.dcphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:23:17'),
(48, 'Nguyễn Công Lực', '', 'luc.nc', 'luc.ncphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 6, 1, 0, '', 1, 0, '2023-09-11 11:23:38'),
(49, 'Hoàng Anh Dũng', '', 'dung.ha', 'dung.haphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-11 11:51:45'),
(50, 'Đỗ Văn Chủ', '', 'chu.dv', 'chu.dvphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-11 12:01:17'),
(51, 'Đỗ Tiến Duy', '', 'duy.dd', 'duy.ddphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-11 12:01:50'),
(52, 'Trần Xuân Thịnh', '', 'thinh.tx', 'thinh.txphotohome@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 5, 6, 5, '', 1, 0, '2023-09-12 12:07:42'),
(53, 'Phạm Thị Dung', '', 'dung.pt', 'dung.pt@gmail.com', '81dc9bdb52d04dc20036dbd8313ed055', 3, 0, 0, '', 0, 0, '2023-09-13 11:00:12'),
(54, 'Lê Minh Quân', '', 'Quan.lm', 'Quan.lm@photohome.com', 'cdf28f8b7d14ab02d12a2329d71e4079', 1, 0, 0, '', 0, 0, '2023-09-14 14:07:22');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_productivity`
--

CREATE TABLE `user_productivity` (
  `id` int(30) NOT NULL,
  `project_id` int(30) NOT NULL,
  `task_id` int(30) NOT NULL,
  `comment` text NOT NULL,
  `user_id` int(30) NOT NULL,
  `time_rendered` float NOT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `user_productivity`
--

INSERT INTO `user_productivity` (`id`, `project_id`, `task_id`, `comment`, `user_id`, `time_rendered`, `date_created`) VALUES
(1, 2, 3, 'link done abcd', 3, 0, '2023-08-20 16:19:40'),
(2, 20, 9, 'link done', 3, 0, '2023-08-21 15:13:21'),
(3, 12, 10, 'link done', 3, 0, '2023-08-21 15:16:32'),
(4, 118, 91, 'anh mo, noise', 9, 0, '2023-09-05 17:11:31'),
(5, 240, 109, '1 ANH mo', 4, 0, '2023-09-09 16:26:51'),
(6, 239, 110, 'am sai style khach hang', 9, 0, '2023-09-09 20:01:12'),
(7, 260, 157, '                                  ', 18, 0, '2023-09-12 10:54:31'),
(8, 283, 169, '                                  ', 49, 0, '2023-09-13 14:11:57'),
(9, 316, 214, 'okkko', 3, 0, '2023-09-13 19:54:45'),
(10, 341, 256, 'trung 1&nbsp;', 42, 0, '2023-09-14 11:42:50'),
(11, 335, 249, '<p>trung 1</p><p><br></p>', 28, 0, '2023-09-14 11:47:25'),
(12, 376, 296, '<span style=\"color: rgb(0, 0, 0); font-family: Arial; font-size: 17px; white-space-collapse: preserve;\">Photo HDR 42</span>                                  ', 28, 0, '2023-09-15 10:48:05'),
(13, 411, 352, '<p>trung 2 anh</p><p><br></p>', 23, 0, '2023-09-16 12:42:44');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_type`
--

CREATE TABLE `user_type` (
  `id` int(11) NOT NULL,
  `name_ut` varchar(30) NOT NULL,
  `group_ut` varchar(120) NOT NULL,
  `ngay_tao_ut` date NOT NULL,
  `nguoi_tao_ut` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `user_type`
--

INSERT INTO `user_type` (`id`, `name_ut`, `group_ut`, `ngay_tao_ut`, `nguoi_tao_ut`) VALUES
(1, 'CEO', '1', '0000-00-00', ''),
(2, 'CSO', '', '0000-00-00', ''),
(3, 'CSS', '', '0000-00-00', ''),
(4, 'TLA', '', '0000-00-00', ''),
(5, 'QA', '', '0000-00-00', ''),
(6, 'EDITOR', '', '0000-00-00', '');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `ccs`
--
ALTER TABLE `ccs`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `combo`
--
ALTER TABLE `combo`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `cong_ty`
--
ALTER TABLE `cong_ty`
  ADD PRIMARY KEY (`id_cong_ty`);

--
-- Chỉ mục cho bảng `custom`
--
ALTER TABLE `custom`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `group_c`
--
ALTER TABLE `group_c`
  ADD PRIMARY KEY (`groupc_id`);

--
-- Chỉ mục cho bảng `group_e`
--
ALTER TABLE `group_e`
  ADD PRIMARY KEY (`group_id`);

--
-- Chỉ mục cho bảng `invoice`
--
ALTER TABLE `invoice`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `ip_photo`
--
ALTER TABLE `ip_photo`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `level`
--
ALTER TABLE `level`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `project_list`
--
ALTER TABLE `project_list`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `status_invoice`
--
ALTER TABLE `status_invoice`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `status_job`
--
ALTER TABLE `status_job`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `status_task`
--
ALTER TABLE `status_task`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `task_list`
--
ALTER TABLE `task_list`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tl` (`project_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `user_productivity`
--
ALTER TABLE `user_productivity`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `user_type`
--
ALTER TABLE `user_type`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `ccs`
--
ALTER TABLE `ccs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `combo`
--
ALTER TABLE `combo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `cong_ty`
--
ALTER TABLE `cong_ty`
  MODIFY `id_cong_ty` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `custom`
--
ALTER TABLE `custom`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=124;

--
-- AUTO_INCREMENT cho bảng `group_c`
--
ALTER TABLE `group_c`
  MODIFY `groupc_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `group_e`
--
ALTER TABLE `group_e`
  MODIFY `group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `invoice`
--
ALTER TABLE `invoice`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `ip_photo`
--
ALTER TABLE `ip_photo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `level`
--
ALTER TABLE `level`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `logs`
--
ALTER TABLE `logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2220;

--
-- AUTO_INCREMENT cho bảng `project_list`
--
ALTER TABLE `project_list`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=456;

--
-- AUTO_INCREMENT cho bảng `status_invoice`
--
ALTER TABLE `status_invoice`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `status_job`
--
ALTER TABLE `status_job`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `status_task`
--
ALTER TABLE `status_task`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `task_list`
--
ALTER TABLE `task_list`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=401;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT cho bảng `user_productivity`
--
ALTER TABLE `user_productivity`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `user_type`
--
ALTER TABLE `user_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `task_list`
--
ALTER TABLE `task_list`
  ADD CONSTRAINT `fk_tl` FOREIGN KEY (`project_id`) REFERENCES `project_list` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
