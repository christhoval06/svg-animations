-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 16, 2019 at 09:54 PM
-- Server version: 5.7.23
-- PHP Version: 5.6.37

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `tasktracker`
--

DELIMITER $$
--
-- Procedures
--
CREATE PROCEDURE `update_task` (IN `task__id` INT, `status_id` INT, `is_parent` BOOLEAN)  BEGIN
    DECLARE me_parent_id INT;
    DECLARE parent_new_status_id INT;
    DECLARE parent_child_count INT;
    DECLARE status_value INT;
    DECLARE parent_child_progress_sum FLOAT;


    SET me_parent_id := (SELECT T.parent_id
                         FROM tasks AS T
                         WHERE T.task_id = task__id);


    IF is_parent
    THEN
      -- get childs count
      SET parent_child_count := (SELECT COUNT(T.task_id)
                                 FROM tasks AS T
                                 WHERE T.parent_id = task__id);

      -- get total progress
      SET parent_child_progress_sum := (SELECT SUM(T.progress)
                                        FROM tasks AS T
                                        WHERE T.parent_id = task__id);
      SET parent_new_status_id := (SELECT TS.task_status_id
                                   FROM task_status AS TS
                                   WHERE TS.value <= CEIL((parent_child_progress_sum / parent_child_count) / 10) * 10
                                   ORDER BY TS.value DESC
                                   LIMIT 1);

      -- update parent
      UPDATE tasks AS T
      SET progress = (parent_child_progress_sum / parent_child_count), status_id = parent_new_status_id
      WHERE T.task_id = task__id;
    ELSE
      SET status_value := (SELECT TS.value
                           FROM task_status AS TS
                           WHERE TS.task_status_id = status_id
                           LIMIT 1);
      -- update me
      UPDATE tasks AS T
      SET progress = status_value, status_id = status_id
      WHERE T.task_id = task__id;
    END IF;

    -- make recursive
    IF me_parent_id IS NOT NULL
    THEN
      CALL update_task(me_parent_id, 0, TRUE);
    END IF;

  END$$

--
-- Functions
--
CREATE FUNCTION `getAutoGenerateNumber` (`processId` INT, `save` BOOLEAN) RETURNS VARCHAR(50) CHARSET utf8 COLLATE utf8_spanish2_ci BEGIN
    DECLARE numero VARCHAR(50);
    DECLARE yyyy INT;
    DECLARE pre_yyyy INT;
    DECLARE next_secuence INT;

    SET yyyy := YEAR(curdate());
    SET next_secuence := (SELECT MAX(secuencia) + 1
                          FROM auto_generate_number
                          WHERE process_id = processId);
    IF (next_secuence IS NULL)
    THEN
      SET next_secuence := 1;
    END IF;

    SET pre_yyyy := (SELECT MAX(YEAR(fecha))
                     FROM auto_generate_number
                     WHERE process_id = processId);
    IF (pre_yyyy IS NOT NULL)
    THEN
      IF (yyyy > pre_yyyy)
      THEN
        SET next_secuence := 1;
      END IF;
    END IF;


    SET numero := CONCAT(processId, yyyy, next_secuence);

    IF (save)
    THEN
      -- Insert variables in auto_generate_number
      INSERT INTO auto_generate_number (process_id, fecha, secuencia, numero) VALUES (processId, curdate(), next_secuence, numero);
    END IF;

    RETURN numero;
  END$$

CREATE FUNCTION `getDepartmentCode` (`eId` INT) RETURNS VARCHAR(30) CHARSET utf8 COLLATE utf8_bin BEGIN
    RETURN (SELECT CONCAT(eId, LPAD((SELECT CAST(IF(count(department_id) = 0, 1, count(department_id)) AS CHAR(3))
                                     FROM departments
                                     WHERE company_id = eId), 3, '0')));
  END$$

CREATE FUNCTION `getDuration` (`fa` DATETIME) RETURNS VARCHAR(30) CHARSET utf8 COLLATE utf8_bin BEGIN

    DECLARE tiempo INT;
    DECLARE dias INT;
    DECLARE horas INT;
    DECLARE mins INT;

    SET tiempo := TIMESTAMPDIFF(MINUTE, fa, now());
    SET dias := tiempo DIV (24 * 60);
    SET horas := (tiempo % (24 * 60)) DIV 60;
    SET mins := (tiempo % (24 * 60)) % 60;

    RETURN CONCAT(
        IF(dias > 0, CONCAT(dias, IF(dias = 1, ' dia ', ' dias ')),
           IF(horas > 0, CONCAT(horas, IF(horas = 1, ' hora ', ' horas ')),
              IF(horas < 0 AND mins > 0, CONCAT(mins, IF(mins = 1, ' min ', ' mins')), 'unos seg')))
    );

    RETURN 1;
  END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `area_departments`
--

CREATE TABLE `area_departments` (
  `area_department_id` int(11) NOT NULL,
  `department_id` int(11) DEFAULT NULL,
  `name` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `detail` text CHARACTER SET utf8 COLLATE utf8_spanish_ci,
  `created` datetime DEFAULT CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `auto_generate_number`
--

CREATE TABLE `auto_generate_number` (
  `id` int(11) NOT NULL,
  `process_id` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `secuencia` int(3) NOT NULL DEFAULT '0',
  `numero` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE `company` (
  `company_id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `short_name` varchar(100) DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `address` varchar(150) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `active` int(1) DEFAULT '1',
  `created` datetime DEFAULT CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`company_id`, `code`, `short_name`, `name`, `address`, `description`, `active`, `created`, `modified`) VALUES
(1, 'TT', 'Tasks', 'Tasks Trackers', NULL, NULL, 1, '2016-09-05 23:08:56', '2016-09-05 23:08:56');

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `department_id` int(11) NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `status` int(1) DEFAULT '1',
  `created` datetime DEFAULT CURRENT_TIMESTAMP,
  `modified` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`department_id`, `company_id`, `parent_id`, `name`, `description`, `status`, `created`, `modified`) VALUES
(1, 1, NULL, 'Testers', NULL, NULL, '2016-09-05 23:12:06', '2016-09-05 23:12:06'),
(6, NULL, NULL, 'Gerencia', 'Test', 1, '2018-04-09 19:57:47', '2018-04-09 19:57:47'),
(7, NULL, 6, 'Finanzas', 'Test', 1, '2018-04-09 19:58:06', '2018-04-09 19:58:06'),
(8, NULL, 6, 'Tecnológia', 'Tecnológia', 1, '2018-04-09 19:58:51', '2018-04-09 19:58:51'),
(9, NULL, 6, 'Operaciones', 'Operaciones', 1, '2018-04-09 20:03:32', '2018-04-09 20:03:32'),
(10, NULL, 8, 'Soporte', 'Soporte', 1, '2018-04-09 20:21:13', '2018-04-09 20:21:13'),
(11, NULL, 8, 'Informática', 'Informática', 1, '2018-04-09 20:21:43', '2018-04-09 20:21:43'),
(12, NULL, 10, 'Hardware', 'Hardware', 1, '2018-04-09 20:26:46', '2018-04-09 20:26:46'),
(13, NULL, 11, 'Front-End Dev', 'Front-End Dev', 1, '2018-04-09 20:27:28', '2018-04-09 20:27:28'),
(14, NULL, 11, 'Back-End Dev', 'Back-End Dev', 1, '2018-04-09 20:27:46', '2018-04-09 20:27:46'),
(15, NULL, 11, 'FullStack-End Dev', 'FullStack-End Dev', 1, '2018-04-09 20:28:10', '2018-04-09 20:28:10'),
(16, NULL, 13, 'Apps Dev', 'Apps Dev', 1, '2018-04-09 20:28:44', '2018-04-09 20:28:44'),
(17, NULL, 13, 'Web Dev', 'Web Dev', 1, '2018-04-09 20:29:03', '2018-04-09 20:29:03'),
(18, NULL, 10, 'Software', 'Software', 1, '2018-04-09 20:29:44', '2018-04-09 20:29:44'),
(19, NULL, 18, 'Linux', 'Linux', 1, '2018-04-09 20:30:07', '2018-04-09 20:30:07'),
(20, NULL, 18, 'Windows', 'Windows', 1, '2018-04-09 20:30:21', '2018-04-09 20:30:21'),
(21, NULL, 12, 'Perifericos', 'Perifericos', 1, '2018-04-09 20:30:45', '2018-04-09 20:30:45'),
(22, NULL, 12, 'Servers', 'Servers', 1, '2018-04-09 20:31:07', '2018-04-09 20:31:07'),
(23, NULL, 7, 'Caja Menuda', 'Caja Menuda', 1, '2018-04-09 20:31:30', '2018-04-09 20:31:30'),
(24, NULL, 7, 'Contabilidad', 'Contabilidad', 1, '2018-04-09 20:31:43', '2018-04-09 20:31:43'),
(25, NULL, 9, 'Recursos Humanos', 'Recursos Humanos', 1, '2018-04-09 20:31:58', '2018-04-09 20:31:58'),
(26, NULL, 9, 'Insumos', 'Insumos', 1, '2018-04-09 20:32:19', '2018-04-09 20:32:19');

-- --------------------------------------------------------

--
-- Table structure for table `departments_policies`
--

CREATE TABLE `departments_policies` (
  `department_policie_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `type` varchar(25) NOT NULL,
  `description` text,
  `status` tinyint(1) DEFAULT '0',
  `create_at` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `documents_type`
--

CREATE TABLE `documents_type` (
  `document_type_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `key` varchar(30) NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  `description` varchar(250) DEFAULT NULL,
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `documents_type`
--

INSERT INTO `documents_type` (`document_type_id`, `name`, `key`, `active`, `description`, `create_at`) VALUES
(1, 'Imagen de Perfil', 'PROFILE', 1, 'Test profile', '2017-06-24 20:40:48'),
(2, 'Hoja de Vida', '', 1, 'Test', '2017-06-24 20:41:51'),
(3, 'Certificación', '', 1, 'Test', '2017-06-24 20:42:53'),
(4, 'Diploma', '', 1, 'Test', '2017-06-24 20:49:53');

-- --------------------------------------------------------

--
-- Table structure for table `educations`
--

CREATE TABLE `educations` (
  `education_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  `school` varchar(250) NOT NULL,
  `title` varchar(250) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `currently` tinyint(1) DEFAULT '0',
  `description` text,
  `active` tinyint(1) DEFAULT '1',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `educations`
--

INSERT INTO `educations` (`education_id`, `profile_id`, `school`, `title`, `start_date`, `end_date`, `currently`, `description`, `active`, `create_at`) VALUES
(1, 1, 'C. Elena Ch. de Pinate', 'Bachiller en Ciencias', '2003-03-03 00:00:00', '2006-12-01 00:00:00', 0, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus tincidunt elementum interdum. Duis non felis tellus. Nunc mi lacus, laoreet eget congue non, ultrices et justo. Aliquam eu vehicula lacus. Etiam pulvinar sem velit, sed porttitor massa ', 1, '2017-12-04 12:12:52'),
(2, 1, 'Universidad Tecnológica de Panamá', 'Lic. Ing. en Sistemas y Computación', '2007-03-09 00:00:00', '2012-06-22 00:00:00', 0, 'Vivamus ut tortor quis felis feugiat elementum a quis orci. Cras in tellus lacus. Donec est purus, tempor vitae eleifend et, egestas in justo. In eget ligula pharetra lorem egestas accumsan et ut justo. Nam convallis dui enim, id lobortis turpis ulla', 1, '2017-12-04 12:20:27'),
(3, 1, 'Universidad Tecnológica de Panamásidad', 'Lic. en Desarrollo de Software', '2013-03-04 00:00:00', '2017-12-04 00:00:00', 1, 'Donec convallis faucibus dui. Vestibulum euismod pretium velit ut venenatis. Cras sed mattis orci. Aenean aliquam, lorem sit amet semper auctor, ligula erat vulputate tellus, quis elementum sem odio ac turpis. Vestibulum efficitur non metus vitae fri', 1, '2017-12-04 12:23:24');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `job_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `description` text,
  `is_chief` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint(2) DEFAULT '1',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`job_id`, `department_id`, `name`, `description`, `is_chief`, `status`, `create_at`) VALUES
(1, 13, 'Chief Technology Officer', 'Test Test', 0, 2, '2018-04-11 18:46:21'),
(2, 16, 'Chief Technology Officer', 'Test Test Test Test Test Test', 1, 2, '2018-06-14 22:11:30'),
(3, 16, 'Swift 4 Developer', 'Test Test\r\nTest Test\r\nTest Test\r\n___________\r\nTest Test', 0, 2, '2018-06-14 22:28:33');

-- --------------------------------------------------------

--
-- Table structure for table `jobs_assignments`
--

CREATE TABLE `jobs_assignments` (
  `jobs_assignments_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `status` tinyint(2) DEFAULT '0',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `modified_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `jobs_assignments`
--

INSERT INTO `jobs_assignments` (`jobs_assignments_id`, `user_id`, `job_id`, `status`, `create_at`, `modified_at`) VALUES
(1, 20, 3, 2, '2018-08-06 21:37:44', '2018-08-06 21:37:44'),
(2, 22, 2, 1, '2018-09-19 21:24:33', '2018-09-19 21:24:33'),
(3, 24, 1, 2, '2018-09-19 21:24:53', '2018-09-19 21:24:53'),
(4, 2, 2, 2, '2018-10-29 21:25:11', '2018-10-29 21:25:11');

-- --------------------------------------------------------

--
-- Table structure for table `jobs_responsibilities`
--

CREATE TABLE `jobs_responsibilities` (
  `responsibility_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `type` varchar(25) NOT NULL,
  `description` text,
  `status` tinyint(2) DEFAULT '0',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `jobs_rights`
--

CREATE TABLE `jobs_rights` (
  `job_right_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `description` text,
  `status` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `jobs_skills`
--

CREATE TABLE `jobs_skills` (
  `job_skill_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `percentage` int(3) NOT NULL,
  `description` text,
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `jobs_skills`
--

INSERT INTO `jobs_skills` (`job_skill_id`, `job_id`, `name`, `percentage`, `description`, `create_at`) VALUES
(1, 2, 'Help Desk', 70, 'Test Test', '2018-08-07 00:00:13');

-- --------------------------------------------------------

--
-- Table structure for table `login_tokens`
--

CREATE TABLE `login_tokens` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` char(32) NOT NULL,
  `duration` varchar(32) NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL,
  `expires` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `profile`
--

CREATE TABLE `profile` (
  `profile_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `address` text,
  `phone` varchar(25) DEFAULT NULL,
  `nationality` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `blood_type_id` tinyint(2) DEFAULT '0',
  `gender_id` tinyint(2) DEFAULT '0',
  `birthday` date DEFAULT NULL,
  `status_id` tinyint(2) NOT NULL DEFAULT '1',
  `active` tinyint(1) DEFAULT '1',
  `notes` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `profile`
--

INSERT INTO `profile` (`profile_id`, `user_id`, `address`, `phone`, `nationality`, `email`, `blood_type_id`, `gender_id`, `birthday`, `status_id`, `active`, `notes`) VALUES
(1, 21, 'Panama, Panama, San Miguelito', '456789', 'Panameña', 'christhoval@icloud.com', 4, 1, '2017-11-01', 2, 1, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut interdum pretium ornare. Aliquam sed porttitor mi. Nullam ultrices magna eu tellus posuere, venenatis ullamcorper dui blandit. Nullam nec mollis urna. Morbi finibus mauris vel enim bibendum tempus. Praesent sollicitudin, arcu in iaculis accumsan, ex sem mollis urna, sed rhoncus eros lacus ac ligula. Praesent vel lectus ac urna aliquet rhoncus. Aenean vulputate, magna non lacinia maximus, odio tortor malesuada nulla, id bibendum nulla quam vel neque. Nunc molestie magna dui. Nulla facilisi. Interdum et malesuada fames ac ante ipsum pri'),
(2, 21, 'Panama, Panama, San Miguelito', '456789', 'Panameña', 'christhoval@icloud.com', 4, 1, '2017-11-01', 2, 1, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut interdum pretium ornare. Aliquam sed porttitor mi. Nullam ultrices magna eu tellus posuere, venenatis ullamcorper dui blandit. Nullam nec mollis urna. Morbi finibus mauris vel enim bibendum tempus. Praesent sollicitudin, arcu in iaculis accumsan, ex sem mollis urna, sed rhoncus eros lacus ac ligula. Praesent vel lectus ac urna aliquet rhoncus. Aenean vulputate, magna non lacinia maximus, odio tortor malesuada nulla, id bibendum nulla quam vel neque. Nunc molestie magna dui. Nulla facilisi. Interdum et malesuada fames ac ante ipsum pri'),
(3, 20, 'Panama, Panama, San Miguelito', '456789', 'Panameña', 'christhoval@icloud.com', 4, 1, '2017-11-01', 2, 1, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut interdum pretium ornare. Aliquam sed porttitor mi. Nullam ultrices magna eu tellus posuere, venenatis ullamcorper dui blandit. Nullam nec mollis urna. Morbi finibus mauris vel enim bibendum tempus. Praesent sollicitudin, arcu in iaculis accumsan, ex sem mollis urna, sed rhoncus eros lacus ac ligula. Praesent vel lectus ac urna aliquet rhoncus. Aenean vulputate, magna non lacinia maximus, odio tortor malesuada nulla, id bibendum nulla quam vel neque. Nunc molestie magna dui. Nulla facilisi. Interdum et malesuada fames ac ante ipsum pri'),
(4, 2, 'El Crisol', '+50761023295', 'Panameña', 'me@christhoval.xyz', 8, 1, '1989-01-06', 1, 1, 'Test');

-- --------------------------------------------------------

--
-- Table structure for table `skill_jobs`
--

CREATE TABLE `skill_jobs` (
  `id` int(11) NOT NULL,
  `job_id` int(11) DEFAULT NULL,
  `area_skill_id` int(11) DEFAULT NULL,
  `name` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `level` varchar(15) CHARACTER SET utf8 COLLATE utf8_spanish_ci DEFAULT NULL,
  `exp` int(10) DEFAULT NULL,
  `detail` text CHARACTER SET utf8 COLLATE utf8_spanish_ci,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `task_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `assign_to` int(11) NOT NULL,
  `name` varchar(150) COLLATE utf8_bin NOT NULL,
  `before_at` datetime NOT NULL,
  `start_at` datetime NOT NULL,
  `task_type_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL,
  `description` text COLLATE utf8_bin,
  `progress` float NOT NULL DEFAULT '0',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` int(11) NOT NULL,
  `update_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`task_id`, `parent_id`, `assign_to`, `name`, `before_at`, `start_at`, `task_type_id`, `status_id`, `description`, `progress`, `create_at`, `update_at`, `create_by`, `update_by`) VALUES
(1, NULL, 20, 'Make app Maps waze', '2018-11-30 12:00:00', '2018-11-01 12:00:00', 3, 1, 'Make app Maps waze\r\nMake app Maps waze\r\nMake app Maps waze\r\nMake app Maps waze\r\nMake app Maps waze\r\n&nbsp;', 0, '2018-10-29 21:34:35', '2018-10-29 21:34:35', 1, 1),
(2, NULL, 2, 'iOS App', '2018-12-01 05:30:00', '2018-11-01 14:39:00', 3, 3, 'ios&nbsp;\r\nios ios', 15, '2018-10-29 21:40:28', '2018-11-24 03:05:42', 1, 1),
(3, 2, 20, 'Make Requirements files', '2018-11-08 12:00:00', '2018-11-03 00:00:00', 2, 2, 'This is a test', 0, '2018-11-03 01:10:53', '2018-11-19 21:43:40', 2, 2),
(4, 2, 20, 'Create Design', '2018-11-22 17:00:00', '2018-11-14 09:00:00', 3, 2, 'Lorem Ipsum', 20, '2018-11-12 20:18:09', '2018-11-19 21:43:48', 2, 2),
(5, 2, 2, 'Test Split 1', '2018-12-02 00:00:00', '2018-11-19 00:00:00', 2, 6, 'Test Split 1', 40, '2018-11-19 21:45:46', '2018-11-24 03:02:55', 2, 2),
(6, 5, 2, 'Test Split 1.1', '2018-12-07 00:00:00', '2018-11-19 00:00:00', 1, 6, 'Test Split 1.1', 40, '2018-11-19 21:46:12', '2018-11-24 03:02:55', 2, 2),
(7, 6, 2, 'Test Split 1.1', '2018-11-24 00:00:00', '2018-11-19 00:00:00', 3, 6, 'Test Split 1.1', 40, '2018-11-19 21:46:32', '2018-11-24 03:02:55', 2, 2),
(8, 2, 20, 'Test Add Child', '2018-11-30 00:00:00', '2018-11-24 00:00:00', 3, 1, 'Test', 0, '2018-11-24 03:05:42', '2018-11-24 03:05:42', 2, 2),
(9, 0, 2, 'Test 02', '2018-12-14 00:00:00', '2018-12-07 00:00:00', 2, 1, 'Test', 0, '2018-12-07 22:07:35', '2018-12-07 22:07:35', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `task_documents`
--

CREATE TABLE `task_documents` (
  `document_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `document_type_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `path` varchar(250) NOT NULL,
  `file` varchar(100) NOT NULL,
  `ext` varchar(10) NOT NULL,
  `description` text,
  `activo` tinyint(1) DEFAULT '1',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `task_documents`
--

INSERT INTO `task_documents` (`document_id`, `name`, `document_type_id`, `task_id`, `path`, `file`, `ext`, `description`, `activo`, `create_at`) VALUES
(1, 'TransferApp-ERD.jpg', 3, 9, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/9/photos', 'TransferApp_ERD', 'jpg', NULL, 1, '2018-12-08 00:06:56'),
(2, 'proyecto de P.P.pdf', 2, 9, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/9/documents', 'proyecto_de_P_P', 'pdf', NULL, 1, '2018-12-08 00:12:26'),
(3, 'Transfers Apps.jpeg', 4, 9, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/9/photos', 'Transfers_Apps', 'jpeg', NULL, 1, '2018-12-08 01:06:05'),
(4, 'Proyecto Final - Programación IV.pdf', 3, 9, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/9/documents', 'Proyecto_Final_Programacion_IV', 'pdf', NULL, 1, '2018-12-08 01:06:05');

-- --------------------------------------------------------

--
-- Table structure for table `task_status`
--

CREATE TABLE `task_status` (
  `task_status_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `value` tinyint(3) DEFAULT '10',
  `background_color` varchar(20) NOT NULL,
  `border_color` varchar(20) NOT NULL,
  `text_color` varchar(20) NOT NULL,
  `active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `task_status`
--

INSERT INTO `task_status` (`task_status_id`, `name`, `value`, `background_color`, `border_color`, `text_color`, `active`) VALUES
(1, 'Created', 0, '#ffa500', '#cf9121', '#ffffff', 1),
(2, 'Started', 10, '#008000', '#0a5c0a', '#ffffff', 1),
(3, 'In Progress', 20, '#21cc5b', '#248215', '#451ce8', 1),
(4, 'Finished', 100, '#8a2be2', '#632999', '#ffffff', 1),
(5, 'Developing', 30, '#e88817', '#ff005c', '#ffffff', 1),
(6, 'Almost half done', 40, '#21deb1', '#17b368', '#ffffff', 1),
(7, 'Half Done', 50, '#59e019', '#136120', '#ffffff', 1);

-- --------------------------------------------------------

--
-- Table structure for table `task_type`
--

CREATE TABLE `task_type` (
  `task_type_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `background_color` varchar(20) NOT NULL,
  `border_color` varchar(20) NOT NULL,
  `text_color` varchar(20) NOT NULL,
  `active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `task_type`
--

INSERT INTO `task_type` (`task_type_id`, `name`, `background_color`, `border_color`, `text_color`, `active`) VALUES
(1, 'Data Clean', '#de1414', '#c72828', '#ffffff', 1),
(2, 'Analitycs', '#b926d1', '#8e1ba1', '#ffffff', 1),
(3, 'Make App', '#628bf5', '#6784cf', '#ffffff', 1);

-- --------------------------------------------------------

--
-- Table structure for table `unity_type`
--

CREATE TABLE `unity_type` (
  `unity_type_id` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  `level` tinyint(2) DEFAULT '1',
  `active` tinyint(1) DEFAULT '1',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` int(11) NOT NULL,
  `update_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `unity_type`
--

INSERT INTO `unity_type` (`unity_type_id`, `description`, `level`, `active`, `create_at`, `update_at`, `create_by`, `update_by`) VALUES
(1, 'Junta Directiva', 1, 1, '2016-01-25 11:33:00', '2016-01-25 11:33:00', 1, 1),
(2, 'Administración', 1, 1, '2016-01-25 11:33:00', '2016-01-25 11:33:00', 1, 1),
(3, 'Dirección', 1, 1, '2016-01-25 11:35:13', '2016-01-25 11:35:13', 1, 1),
(4, 'Oficina', 1, 1, '2016-01-25 11:35:13', '2016-01-25 11:35:13', 1, 1),
(5, 'Juzgado', 1, 1, '2016-01-25 11:35:13', '2016-01-25 11:35:13', 1, 1),
(6, 'Secretaria', 1, 1, '2016-01-25 11:35:13', '2016-01-25 11:35:13', 1, 1),
(7, 'Auditoría', 1, 1, '2016-01-25 11:35:13', '2016-01-25 11:35:13', 1, 1),
(8, 'Notaria', 1, 1, '2016-01-25 11:35:13', '2016-01-25 11:35:13', 1, 1),
(12, 'Departamento', 2, 1, '2016-01-25 11:36:35', '2016-01-25 11:36:35', 1, 1),
(13, 'Subdirección', 2, 1, '2016-01-25 11:36:35', '2016-01-25 11:36:35', 1, 1),
(14, 'Subadministración', 2, 1, '2016-01-25 11:36:35', '2016-01-25 11:36:35', 1, 1),
(15, 'Coordinacion', 2, 1, '2016-01-25 11:36:35', '2016-01-25 11:36:35', 1, 1),
(16, 'Sección', 3, 1, '2016-01-25 11:37:20', '2016-01-25 11:37:20', 1, 1),
(17, 'Unidad', 3, 1, '2016-01-25 11:37:20', '2016-01-25 11:37:20', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `job_id` int(11) DEFAULT NULL,
  `user_group_id` int(11) UNSIGNED DEFAULT NULL,
  `username` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `salt` text,
  `email` varchar(100) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `active` int(1) NOT NULL DEFAULT '0',
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `job_id`, `user_group_id`, `username`, `password`, `salt`, `email`, `first_name`, `last_name`, `active`, `created`, `modified`) VALUES
(1, 0, 1, 'admin', '365caef7fccbdb1ee711f084be9317a7', '1e6d99570a4d37cc29b18c4a6b06e6ed', 'admin@admin.com', 'Admin', '', 1, '2016-09-05 22:45:00', '2016-09-05 22:45:00'),
(2, 1, 2, 'christhoval', '02595d20d3730da162a729eb63f8775a', '5bdef5ea0f4b3197cc2302b63c928da8', 'pruebas@pruebas.pruebas', 'Christhoval', 'Barba', 1, '2016-09-05 23:12:35', '2018-11-03 00:31:11'),
(20, 1, 3, 'sarfraz', 'f62c480f22478a34eb2ec18fd5f851dd', 'ba6c14670263f5b4eece6a3fc8e59f64', 'sarfraz@abejagrama.com', 'Sarfraz', 'Setch', 1, '2017-11-03 16:26:59', '2017-11-04 02:23:15'),
(21, 5, 4, 'guest', '495f87f5c0225b1a3699bf68c227d33b', '792ab779d979eb22086da1f8e66f43bc', 'gest@tasktracker.com', 'Guest', 'Guest', 1, '2017-11-12 15:10:26', '2017-11-12 15:31:28'),
(22, 1, 2, 'user1', '4a05eab827ff10b6cf2f4473aacaa3e7', '8bb33d73c2aec114ff5163a3eb0b38f4', 'user@b.com', 'User', 'Uno', 1, '2018-09-19 19:57:39', '2018-09-19 19:57:39'),
(24, NULL, 2, 'userdos', 'b4d6db633c6198ee3571e5a9d681c185', '73d15f7de15b1759a07e42c0f1d97777', 'dos@user.com', 'User', 'Dos', 1, '2018-09-19 20:07:03', '2018-09-19 20:07:03'),
(25, NULL, 2, 'usertres', '1ff9207e6d707aefa76e459071c292ac', '9827654dda9968861659b9c2860f51af', 'tres@user.com', 'User', 'Tres', 1, '2018-09-19 20:10:01', '2018-09-19 20:10:01');

-- --------------------------------------------------------

--
-- Table structure for table `users_skills`
--

CREATE TABLE `users_skills` (
  `skill_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  `name` varchar(25) COLLATE utf8_spanish_ci NOT NULL,
  `percentage` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT '1',
  `create_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Dumping data for table `users_skills`
--

INSERT INTO `users_skills` (`skill_id`, `profile_id`, `name`, `percentage`, `active`, `create_at`) VALUES
(1, 1, 'rfewrewr', 20, 1, '0000-00-00 00:00:00'),
(2, 1, 'Javascript', 97, 1, '0000-00-00 00:00:00'),
(3, 1, 'PHP', 100, 1, '0000-00-00 00:00:00'),
(4, 1, 'NodeJS', 95, 1, '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `user_documents`
--

CREATE TABLE `user_documents` (
  `document_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `document_type_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  `path` varchar(250) NOT NULL,
  `file` varchar(100) NOT NULL,
  `ext` varchar(10) NOT NULL,
  `description` text,
  `activo` tinyint(1) DEFAULT '1',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user_documents`
--

INSERT INTO `user_documents` (`document_id`, `name`, `document_type_id`, `profile_id`, `path`, `file`, `ext`, `description`, `activo`, `create_at`) VALUES
(3, '_1332001440733.jpg', 1, 1, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/1/photos', '1332001440733', 'jpg', NULL, 1, '2017-11-23 20:26:06'),
(4, 'felipillo crew_1331905028464.jpg', 1, 1, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/1/photos', 'felipillo_crew_1331905028464', 'jpg', NULL, 1, '2017-11-23 20:49:23'),
(5, 'gndlabs bg.png', 1, 1, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/1/photos', 'gndlabs_bg', 'png', NULL, 1, '2017-11-23 22:26:00'),
(6, 'IMG_20130701_191607.jpg', 1, 1, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/1/photos', 'IMG_20130701_191607', 'jpg', NULL, 1, '2017-11-30 22:51:58'),
(7, '20130728_105253.jpg', 1, 1, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/1/photos', '20130728_105253', 'jpg', NULL, 1, '2017-11-30 22:53:04'),
(8, '20130728_105302.jpg', 1, 1, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/1/photos', '20130728_105302', 'jpg', NULL, 1, '2017-11-30 22:53:04'),
(9, 'IMG-20150426-WA0039.jpg', 1, 1, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/1/photos', 'IMG_20150426_WA0039', 'jpg', NULL, 1, '2017-11-30 22:53:48'),
(10, 'felipillo crew_1331905028464.jpg', 1, 3, '/Users/christhoval/Documents/dev/cake2/task-tracker/docs/1/photos', 'felipillo_crew_1331905028464', 'jpg', NULL, 1, '2017-11-23 20:49:23');

-- --------------------------------------------------------

--
-- Table structure for table `user_groups`
--

CREATE TABLE `user_groups` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `alias_name` varchar(100) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `allowRegistration` int(1) NOT NULL DEFAULT '1',
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user_groups`
--

INSERT INTO `user_groups` (`id`, `name`, `alias_name`, `active`, `allowRegistration`, `created`, `modified`) VALUES
(1, 'Admin', 'Admin', 1, 0, '2016-09-05 22:44:03', '2016-09-05 22:44:03'),
(2, 'User', 'User', 1, 1, '2016-09-05 22:44:03', '2016-09-05 22:44:03'),
(3, 'Guest', 'Guest', 1, 0, '2016-09-05 22:44:03', '2016-09-05 22:44:03'),
(4, 'Tester', 'tester', 1, 0, '2016-09-05 23:13:43', '2016-09-05 23:13:43');

-- --------------------------------------------------------

--
-- Table structure for table `user_group_permissions`
--

CREATE TABLE `user_group_permissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_group_id` int(10) UNSIGNED NOT NULL,
  `controller` varchar(50) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `action` varchar(100) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `allowed` tinyint(1) UNSIGNED NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user_group_permissions`
--

INSERT INTO `user_group_permissions` (`id`, `user_group_id`, `controller`, `action`, `allowed`) VALUES
(1, 1, 'Companies', 'index', 1),
(2, 1, 'Companies', 'add', 1),
(3, 1, 'Companies', 'edit', 1),
(4, 1, 'Companies', 'delete', 1),
(5, 2, 'Tasks', 'index', 1),
(6, 2, 'Tasks', 'add', 1),
(7, 2, 'Tasks', 'edit', 1),
(8, 2, 'Tasks', 'view', 1),
(9, 2, 'Tasks', 'dashboard', 1),
(10, 2, 'Profiles', 'add', 1),
(11, 2, 'Profiles', 'edit', 1),
(12, 2, 'Profiles', 'view', 1),
(13, 1, 'Users', 'dashboard', 1),
(14, 2, 'Users', 'dashboard', 1),
(15, 3, 'Users', 'dashboard', 1),
(16, 4, 'Users', 'dashboard', 1),
(17, 2, 'Tasks', 'changeStatus', 1),
(18, 2, 'TaskDocuments', 'index', 1),
(19, 3, 'TaskDocuments', 'index', 1),
(20, 2, 'TaskDocuments', 'dropzoneprocesss', 1),
(21, 3, 'TaskDocuments', 'dropzoneprocesss', 1),
(22, 4, 'TaskDocuments', 'index', 1),
(23, 2, 'TaskDocuments', 'add', 1),
(24, 3, 'TaskDocuments', 'add', 1),
(25, 4, 'TaskDocuments', 'add', 1),
(26, 2, 'TaskDocuments', 'download', 1),
(27, 3, 'TaskDocuments', 'download', 1),
(28, 4, 'TaskDocuments', 'download', 1),
(29, 2, 'TaskDocuments', 'view', 1),
(30, 3, 'TaskDocuments', 'view', 1),
(31, 4, 'TaskDocuments', 'view', 1),
(32, 2, 'TaskDocuments', 'delete', 1),
(33, 3, 'TaskDocuments', 'delete', 1),
(34, 4, 'TaskDocuments', 'delete', 1);

-- --------------------------------------------------------

--
-- Table structure for table `work_experiences`
--

CREATE TABLE `work_experiences` (
  `experience_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  `company` varchar(150) NOT NULL,
  `job_name` varchar(100) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `description` text,
  `active` tinyint(1) DEFAULT '1',
  `create_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `work_experiences`
--

INSERT INTO `work_experiences` (`experience_id`, `profile_id`, `company`, `job_name`, `start_date`, `end_date`, `description`, `active`, `create_at`) VALUES
(1, 1, 'Lorem Ipsum', 'Lorem Ipsum', '2017-06-26 00:00:00', '2017-11-30 00:00:00', 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', 1, '2017-11-30 21:44:01'),
(2, 1, 'EEM Systems', 'Developer Jr.', '2010-10-28 00:00:00', '2014-06-27 00:00:00', 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', 1, '2017-11-30 22:15:17');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `auto_generate_number`
--
ALTER TABLE `auto_generate_number`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`company_id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`department_id`),
  ADD KEY `entidad_id_fk_idx` (`company_id`),
  ADD KEY `parent_id_fk` (`parent_id`);

--
-- Indexes for table `departments_policies`
--
ALTER TABLE `departments_policies`
  ADD PRIMARY KEY (`department_policie_id`);

--
-- Indexes for table `documents_type`
--
ALTER TABLE `documents_type`
  ADD PRIMARY KEY (`document_type_id`);

--
-- Indexes for table `educations`
--
ALTER TABLE `educations`
  ADD PRIMARY KEY (`education_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`job_id`);

--
-- Indexes for table `jobs_assignments`
--
ALTER TABLE `jobs_assignments`
  ADD PRIMARY KEY (`jobs_assignments_id`);

--
-- Indexes for table `jobs_responsibilities`
--
ALTER TABLE `jobs_responsibilities`
  ADD PRIMARY KEY (`responsibility_id`);

--
-- Indexes for table `jobs_rights`
--
ALTER TABLE `jobs_rights`
  ADD PRIMARY KEY (`job_right_id`);

--
-- Indexes for table `jobs_skills`
--
ALTER TABLE `jobs_skills`
  ADD PRIMARY KEY (`job_skill_id`);

--
-- Indexes for table `login_tokens`
--
ALTER TABLE `login_tokens`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `profile`
--
ALTER TABLE `profile`
  ADD PRIMARY KEY (`profile_id`);

--
-- Indexes for table `skill_jobs`
--
ALTER TABLE `skill_jobs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`task_id`);

--
-- Indexes for table `task_documents`
--
ALTER TABLE `task_documents`
  ADD PRIMARY KEY (`document_id`);

--
-- Indexes for table `task_status`
--
ALTER TABLE `task_status`
  ADD PRIMARY KEY (`task_status_id`);

--
-- Indexes for table `task_type`
--
ALTER TABLE `task_type`
  ADD PRIMARY KEY (`task_type_id`);

--
-- Indexes for table `unity_type`
--
ALTER TABLE `unity_type`
  ADD PRIMARY KEY (`unity_type_id`),
  ADD KEY `create_by` (`create_by`),
  ADD KEY `update_by` (`update_by`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user` (`username`),
  ADD KEY `mail` (`email`),
  ADD KEY `users_FKIndex1` (`user_group_id`);

--
-- Indexes for table `users_skills`
--
ALTER TABLE `users_skills`
  ADD PRIMARY KEY (`skill_id`);

--
-- Indexes for table `user_documents`
--
ALTER TABLE `user_documents`
  ADD PRIMARY KEY (`document_id`);

--
-- Indexes for table `user_groups`
--
ALTER TABLE `user_groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_group_permissions`
--
ALTER TABLE `user_group_permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `work_experiences`
--
ALTER TABLE `work_experiences`
  ADD PRIMARY KEY (`experience_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `auto_generate_number`
--
ALTER TABLE `auto_generate_number`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company`
--
ALTER TABLE `company`
  MODIFY `company_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `department_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `departments_policies`
--
ALTER TABLE `departments_policies`
  MODIFY `department_policie_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `documents_type`
--
ALTER TABLE `documents_type`
  MODIFY `document_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `educations`
--
ALTER TABLE `educations`
  MODIFY `education_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `job_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `jobs_assignments`
--
ALTER TABLE `jobs_assignments`
  MODIFY `jobs_assignments_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `jobs_responsibilities`
--
ALTER TABLE `jobs_responsibilities`
  MODIFY `responsibility_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs_rights`
--
ALTER TABLE `jobs_rights`
  MODIFY `job_right_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs_skills`
--
ALTER TABLE `jobs_skills`
  MODIFY `job_skill_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `login_tokens`
--
ALTER TABLE `login_tokens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `profile`
--
ALTER TABLE `profile`
  MODIFY `profile_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `skill_jobs`
--
ALTER TABLE `skill_jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `task_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `task_documents`
--
ALTER TABLE `task_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `task_status`
--
ALTER TABLE `task_status`
  MODIFY `task_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `task_type`
--
ALTER TABLE `task_type`
  MODIFY `task_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `unity_type`
--
ALTER TABLE `unity_type`
  MODIFY `unity_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `users_skills`
--
ALTER TABLE `users_skills`
  MODIFY `skill_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_documents`
--
ALTER TABLE `user_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user_groups`
--
ALTER TABLE `user_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_group_permissions`
--
ALTER TABLE `user_group_permissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `work_experiences`
--
ALTER TABLE `work_experiences`
  MODIFY `experience_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `departments`
--
ALTER TABLE `departments`
  ADD CONSTRAINT `entidad_id_fk` FOREIGN KEY (`company_id`) REFERENCES `company` (`company_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `parent_id_fk` FOREIGN KEY (`parent_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `unity_type`
--
ALTER TABLE `unity_type`
  ADD CONSTRAINT `unity_type_ibfk_1` FOREIGN KEY (`create_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `unity_type_ibfk_2` FOREIGN KEY (`update_by`) REFERENCES `users` (`id`);
