-- MySQL dump 10.13  Distrib 9.6.0, for macos26.2 (arm64)
--
-- Host: 127.0.0.1    Database: fastapiadmin
-- ------------------------------------------------------
-- Server version	8.4.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `apscheduler_jobs`
--

DROP TABLE IF EXISTS `apscheduler_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `apscheduler_jobs` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `next_run_time` double DEFAULT NULL,
  `job_state` blob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_apscheduler_jobs_next_run_time` (`next_run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `apscheduler_jobs`
--

LOCK TABLES `apscheduler_jobs` WRITE;
/*!40000 ALTER TABLE `apscheduler_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `apscheduler_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `example_demo`
--

DROP TABLE IF EXISTS `example_demo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `example_demo` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `int_val` int DEFAULT NULL COMMENT '整数',
  `bigint_val` bigint DEFAULT NULL COMMENT '大整数',
  `float_val` float DEFAULT NULL COMMENT '浮点数',
  `bool_val` tinyint(1) NOT NULL COMMENT '布尔型',
  `date_val` date DEFAULT NULL COMMENT '日期',
  `time_val` time DEFAULT NULL COMMENT '时间',
  `datetime_val` datetime DEFAULT NULL COMMENT '日期时间',
  `text_val` text COLLATE utf8mb4_unicode_ci COMMENT '长文本',
  `json_val` json DEFAULT NULL COMMENT '元数据(JSON格式)',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_example_demo_uuid` (`uuid`),
  KEY `ix_example_demo_updated_id` (`updated_id`),
  KEY `ix_example_demo_deleted_time` (`deleted_time`),
  KEY `ix_example_demo_is_deleted` (`is_deleted`),
  KEY `ix_example_demo_status_deleted` (`status`,`is_deleted`),
  KEY `ix_example_demo_status` (`status`),
  KEY `ix_example_demo_created_id` (`created_id`),
  KEY `ix_example_demo_created_time` (`created_time`),
  KEY `ix_example_demo_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_example_demo_deleted_id` (`deleted_id`),
  KEY `ix_example_demo_id` (`id`),
  KEY `ix_example_demo_updated_time` (`updated_time`),
  CONSTRAINT `example_demo_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `example_demo_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `example_demo_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `example_demo`
--

LOCK TABLES `example_demo` WRITE;
/*!40000 ALTER TABLE `example_demo` DISABLE KEYS */;
/*!40000 ALTER TABLE `example_demo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table`
--

DROP TABLE IF EXISTS `gen_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `table_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '表名称',
  `table_comment` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '表描述',
  `class_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '实体类名称',
  `package_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生成功能名',
  `sub_table_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '子表关联的外键名',
  `parent_menu_id` int DEFAULT NULL COMMENT '父菜单ID',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_gen_table_uuid` (`uuid`),
  KEY `ix_gen_table_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_gen_table_created_id` (`created_id`),
  KEY `ix_gen_table_deleted_id` (`deleted_id`),
  KEY `ix_gen_table_created_time` (`created_time`),
  KEY `ix_gen_table_id` (`id`),
  KEY `ix_gen_table_updated_time` (`updated_time`),
  KEY `ix_gen_table_updated_id` (`updated_id`),
  KEY `ix_gen_table_status_deleted` (`status`,`is_deleted`),
  KEY `ix_gen_table_deleted_time` (`deleted_time`),
  KEY `ix_gen_table_status` (`status`),
  KEY `ix_gen_table_is_deleted` (`is_deleted`),
  CONSTRAINT `gen_table_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_table_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_table_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table`
--

LOCK TABLES `gen_table` WRITE;
/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table_column`
--

DROP TABLE IF EXISTS `gen_table_column`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_column` (
  `column_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '列名称',
  `column_comment` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '列类型',
  `column_length` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列长度',
  `column_default` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '列默认值',
  `is_pk` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否主键',
  `is_increment` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否自增',
  `is_nullable` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否允许为空',
  `is_unique` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否唯一',
  `python_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Python类型',
  `python_field` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Python字段名',
  `is_insert` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否为新增字段',
  `is_edit` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否编辑字段',
  `is_list` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否列表字段',
  `is_query` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否查询字段',
  `query_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '查询方式',
  `html_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '前端显示类型',
  `dict_type` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '前端对应字典类型',
  `sort` int NOT NULL COMMENT '排序',
  `table_id` int NOT NULL COMMENT '归属表编号',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_gen_table_column_uuid` (`uuid`),
  KEY `ix_gen_table_column_table_id` (`table_id`),
  KEY `ix_gen_table_column_deleted_id` (`deleted_id`),
  KEY `ix_gen_table_column_updated_time` (`updated_time`),
  KEY `ix_gen_table_column_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_gen_table_column_updated_id` (`updated_id`),
  KEY `ix_gen_table_column_is_deleted` (`is_deleted`),
  KEY `ix_gen_table_column_deleted_time` (`deleted_time`),
  KEY `ix_gen_table_column_status` (`status`),
  KEY `ix_gen_table_column_status_deleted` (`status`,`is_deleted`),
  KEY `ix_gen_table_column_created_time` (`created_time`),
  KEY `ix_gen_table_column_created_id` (`created_id`),
  KEY `ix_gen_table_column_id` (`id`),
  CONSTRAINT `gen_table_column_ibfk_1` FOREIGN KEY (`table_id`) REFERENCES `gen_table` (`id`) ON DELETE CASCADE,
  CONSTRAINT `gen_table_column_ibfk_2` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_table_column_ibfk_3` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_table_column_ibfk_4` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table_column`
--

LOCK TABLES `gen_table_column` WRITE;
/*!40000 ALTER TABLE `gen_table_column` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table_column` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_api_token`
--

DROP TABLE IF EXISTS `sys_api_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_api_token` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '令牌名称（业务语义，如：CRM-对账集成）',
  `token_prefix` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '明文 token 前 12 字符（用于展示）',
  `token_plain` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '明文 token（自管理，按需用于外部集成）',
  `owner_user_id` int DEFAULT NULL COMMENT '所属用户ID（创建者/操作者）',
  `scopes` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '可用 scope（逗号或 JSON 数组字符串）',
  `expires_at` datetime DEFAULT NULL COMMENT '过期时间（NULL=永不过期）',
  `status` int NOT NULL COMMENT '状态(0:启用 1:禁用 2:吊销)',
  `rate_limit` int NOT NULL COMMENT '每小时请求上限',
  `used_count` int NOT NULL COMMENT '累计调用次数',
  `last_used_at` datetime DEFAULT NULL COMMENT '最近一次调用时间',
  `last_used_ip` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '最近一次调用 IP',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_api_token_uuid` (`uuid`),
  KEY `ix_sys_api_token_deleted_time` (`deleted_time`),
  KEY `ix_sys_api_token_token_prefix` (`token_prefix`),
  KEY `ix_sys_api_token_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_api_token_is_deleted` (`is_deleted`),
  KEY `ix_sys_api_token_created_id` (`created_id`),
  KEY `ix_sys_api_token_created_time` (`created_time`),
  KEY `ix_sys_api_token_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_api_token_deleted_id` (`deleted_id`),
  KEY `ix_sys_api_token_status` (`status`),
  KEY `ix_sys_api_token_owner_status` (`owner_user_id`,`status`),
  KEY `ix_sys_api_token_id` (`id`),
  KEY `ix_sys_api_token_updated_time` (`updated_time`),
  KEY `ix_sys_api_token_owner_user_id` (`owner_user_id`),
  KEY `ix_sys_api_token_updated_id` (`updated_id`),
  CONSTRAINT `sys_api_token_ibfk_1` FOREIGN KEY (`owner_user_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_api_token_ibfk_2` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_api_token_ibfk_3` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_api_token_ibfk_4` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_api_token`
--

LOCK TABLES `sys_api_token` WRITE;
/*!40000 ALTER TABLE `sys_api_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_api_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门名称',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `order` int NOT NULL COMMENT '显示排序',
  `code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门编码',
  `leader` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部门负责人',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机',
  `email` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `parent_id` int DEFAULT NULL COMMENT '父级部门ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `ix_sys_dept_uuid` (`uuid`),
  KEY `ix_sys_dept_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_dept_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_dept_updated_id` (`updated_id`),
  KEY `ix_sys_dept_parent_sort` (`parent_id`,`order`),
  KEY `ix_sys_dept_deleted_time` (`deleted_time`),
  KEY `ix_sys_dept_parent_id` (`parent_id`),
  KEY `ix_sys_dept_is_deleted` (`is_deleted`),
  KEY `ix_sys_dept_created_id` (`created_id`),
  KEY `ix_sys_dept_created_time` (`created_time`),
  KEY `ix_sys_dept_deleted_id` (`deleted_id`),
  KEY `ix_sys_dept_id` (`id`),
  KEY `ix_sys_dept_updated_time` (`updated_time`),
  KEY `ix_sys_dept_status` (`status`),
  CONSTRAINT `sys_dept_ibfk_1` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_dept_ibfk_2` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_dept_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `sys_dept` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_dept_ibfk_4` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES ('系统部门',0,'系统默认部门',1,'DEFAULT','管理员','15382112620','948080782@qq.com',NULL,1,'80d90fee-5634-44b4-b4ab-85904fec8da2',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_data`
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `dict_sort` int NOT NULL COMMENT '字典排序',
  `dict_label` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典标签',
  `dict_value` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典键值',
  `css_class` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '表格回显样式',
  `is_default` tinyint(1) NOT NULL COMMENT '是否默认(True是 False否)',
  `dict_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典类型',
  `dict_type_id` int NOT NULL COMMENT '字典类型ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_dict_data_uuid` (`uuid`),
  KEY `dict_type_id` (`dict_type_id`),
  KEY `ix_sys_dict_data_status` (`status`),
  KEY `ix_sys_dict_data_created_time` (`created_time`),
  KEY `ix_sys_dict_data_type_status` (`dict_type`,`status`),
  KEY `ix_sys_dict_data_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_dict_data_updated_time` (`updated_time`),
  KEY `ix_sys_dict_data_id` (`id`),
  KEY `ix_sys_dict_data_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_dict_data_dict_type` (`dict_type`),
  KEY `ix_sys_dict_data_is_deleted` (`is_deleted`),
  KEY `ix_sys_dict_data_deleted_time` (`deleted_time`),
  CONSTRAINT `sys_dict_data_ibfk_1` FOREIGN KEY (`dict_type_id`) REFERENCES `sys_dict_type` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (0,'性别男',1,'男','0','blue',NULL,1,'sys_user_sex',1,1,'06c666e8-02a5-462c-8df7-b449ff90a103',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'性别女',2,'女','1','pink',NULL,0,'sys_user_sex',1,2,'d84ec0ce-3d26-4314-9925-72fadfdcfcdb',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'性别未知',3,'未知','2','red',NULL,0,'sys_user_sex',1,3,'7b204c45-c74d-402e-8359-f5c7f2386e80',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'是',1,'是','1','','primary',1,'sys_yes_no',2,4,'22435fe1-85ac-40ce-8873-e91145565478',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'否',2,'否','0','','danger',0,'sys_yes_no',2,5,'a2869a92-e665-483e-bafd-6eb06c8881d3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'启用状态',1,'启用','1','','primary',0,'sys_common_status',3,6,'3c90829b-5309-410e-a1ab-b71d7d129caf',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'停用状态',2,'停用','0','','danger',0,'sys_common_status',3,7,'b58708bd-2079-41b4-aa50-1782d4b5b557',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'通知',1,'通知','1','blue','warning',1,'sys_notice_type',4,8,'dce74588-25bd-466b-9f46-21893d18b23e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'公告',2,'公告','2','orange','success',0,'sys_notice_type',4,9,'f9789ead-75ab-42fb-8722-246e1b701e07',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'其他操作',99,'其他','0','','info',0,'sys_oper_type',5,10,'1dd379ea-8421-4e61-96c3-dc758f902b93',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'新增操作',1,'新增','1','','info',0,'sys_oper_type',5,11,'61e2090f-9ff7-4f7f-a8fd-46ceafa3279c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'修改操作',2,'修改','2','','info',0,'sys_oper_type',5,12,'2d33ae87-672a-43be-b267-9de8a91661af',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'删除操作',3,'删除','3','','danger',0,'sys_oper_type',5,13,'1fa84e5b-6e72-4409-89ff-d90c264d05d2',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'授权操作',4,'分配权限','4','','primary',0,'sys_oper_type',5,14,'785b6dae-6512-433b-a150-a962a3d3fac3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'导出操作',5,'导出','5','','warning',0,'sys_oper_type',5,15,'76d99fcd-764d-4cb4-9fed-06a20a4c2b09',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'导入操作',6,'导入','6','','warning',0,'sys_oper_type',5,16,'49feaca0-611e-4a50-ae29-5f0d8aadd849',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'强退操作',7,'强退','7','','danger',0,'sys_oper_type',5,17,'b3798f90-8e4c-46b7-b534-c2c2a27b37ab',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'生成操作',8,'生成代码','8','','warning',0,'sys_oper_type',5,18,'80f28c08-d611-444d-831e-c439c90d4f51',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'清空操作',9,'清空数据','9','','danger',0,'sys_oper_type',5,19,'570e5318-1696-4082-b87f-ba1b1c7dc35f',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'默认分组，支持多Worker部署',1,'默认(Redis)','default','',NULL,1,'sys_job_store',6,20,'eddca4d4-11c7-46f4-be9a-0d10a8284d51',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'数据库分组，持久化存储',2,'数据库(Sqlalchemy)','sqlalchemy','',NULL,0,'sys_job_store',6,21,'778805a8-0743-4e01-a8c0-045cb0166b5e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'内存分组，仅单进程测试使用',3,'内存(Memory)','memory','',NULL,0,'sys_job_store',6,22,'4e6ca58a-f7bf-4e8d-8e42-2fea2d9e0af3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'线程池',1,'线程池','default','',NULL,0,'sys_job_executor',7,23,'09f6de53-e962-476c-9f25-8f9d7653a598',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'进程池',2,'进程池','processpool','',NULL,0,'sys_job_executor',7,24,'4cfdc7f1-9856-4a17-b65e-c1ba4c09f205',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'演示函数',1,'演示函数','scheduler_test.job','',NULL,1,'sys_job_function',8,25,'2dc41837-dc02-45da-9c5e-4298eb091f10',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'指定日期任务触发器',1,'指定日期(date)','date','',NULL,1,'sys_job_trigger',9,26,'600ad823-b51b-435a-8c1b-952f58f5266c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'间隔触发器任务触发器',2,'间隔触发器(interval)','interval','',NULL,0,'sys_job_trigger',9,27,'0a2ed2a2-e561-402e-b292-ff92a66c7c2f',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'间隔触发器任务触发器',3,'cron表达式','cron','',NULL,0,'sys_job_trigger',9,28,'65ed835e-db88-41ce-af69-387f532bc695',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'默认表格回显样式',1,'默认(default)','default','',NULL,1,'sys_list_class',10,29,'00c985c5-2f6d-4e81-948f-aa9bc4180865',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'主要表格回显样式',2,'主要(primary)','primary','',NULL,0,'sys_list_class',10,30,'4a2d2fdd-87b0-486c-bd56-3fe63def94c9',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'成功表格回显样式',3,'成功(success)','success','',NULL,0,'sys_list_class',10,31,'cffecefe-ed84-4d5e-8be5-9d865762727d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'信息表格回显样式',4,'信息(info)','info','',NULL,0,'sys_list_class',10,32,'eef547b3-b288-4c1c-9526-f3b8e35a478a',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'警告表格回显样式',5,'警告(warning)','warning','',NULL,0,'sys_list_class',10,33,'66703dc3-e105-473e-9b55-8b6c0c235bf7',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),(0,'危险表格回显样式',6,'危险(danger)','danger','',NULL,0,'sys_list_class',10,34,'02100d2d-adf9-4cac-a27b-77632d573d6e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL);
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `dict_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典名称',
  `dict_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典类型',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_dict_type_uuid` (`uuid`),
  KEY `ix_sys_dict_type_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_dict_type_dict_type` (`dict_type`),
  KEY `ix_sys_dict_type_created_time` (`created_time`),
  KEY `ix_sys_dict_type_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_dict_type_status` (`status`),
  KEY `ix_sys_dict_type_id` (`id`),
  KEY `ix_sys_dict_type_updated_time` (`updated_time`),
  KEY `ix_sys_dict_type_deleted_time` (`deleted_time`),
  KEY `ix_sys_dict_type_is_deleted` (`is_deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES ('用户性别','sys_user_sex',0,'用户性别列表',1,'ee3ba8da-6310-43c4-bc6a-1d1ff1035451',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('系统是否','sys_yes_no',0,'系统是否列表',2,'4476a517-aceb-480a-94c7-65cd93694caa',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('系统状态','sys_common_status',0,'系统状态',3,'21d76897-0c10-4642-8a70-d9791cd0ef52',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('通知类型','sys_notice_type',0,'通知类型列表',4,'c7e5cb1f-f7a0-4393-8adc-472a00c38173',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('操作类型','sys_oper_type',0,'操作类型列表',5,'8ad4e4bc-1332-4859-bee8-e65c138479e1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('任务存储器','sys_job_store',0,'任务分组列表',6,'d5bbb8af-a5a7-4830-9973-4499c812679a',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('任务执行器','sys_job_executor',0,'任务执行器列表',7,'8a162494-b8f3-4341-a1aa-635624999499',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('任务函数','sys_job_function',0,'任务函数列表',8,'2237bc67-5552-4832-b849-a45f4c28d0f0',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('任务触发器','sys_job_trigger',0,'任务触发器列表',9,'a03fab50-5b35-437b-a6dd-793dc4725f97',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('表格回显样式','sys_list_class',0,'表格回显样式列表',10,'a77a238e-a845-465d-be70-5992d380fdb7',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL);
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_login_log`
--

DROP TABLE IF EXISTS `sys_login_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_login_log` (
  `status` int NOT NULL COMMENT '登录状态(1成功 2失败)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `login_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '登录位置',
  `login_ip` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '登录IP地址',
  `request_os` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作系统',
  `request_browser` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '浏览器',
  `msg` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '提示消息',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_login_log_uuid` (`uuid`),
  KEY `ix_sys_login_log_status_created` (`status`,`created_time`),
  KEY `ix_sys_login_log_id` (`id`),
  KEY `ix_sys_login_log_updated_time` (`updated_time`),
  KEY `ix_sys_login_log_deleted_time` (`deleted_time`),
  KEY `ix_sys_login_log_username_created` (`username`,`created_time`),
  KEY `ix_sys_login_log_is_deleted` (`is_deleted`),
  KEY `ix_sys_login_log_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_login_log_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_login_log_created_time` (`created_time`),
  KEY `ix_sys_login_log_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_login_log`
--

LOCK TABLES `sys_login_log` WRITE;
/*!40000 ALTER TABLE `sys_login_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_login_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单名称',
  `type` int NOT NULL COMMENT '菜单类型(1:目录 2:菜单 3:按钮 4:链接)',
  `order` int NOT NULL COMMENT '显示排序',
  `permission` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '权限标识(如:module_system:user:query)',
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '菜单图标',
  `route_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '路由名称',
  `route_path` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '路由路径',
  `component_path` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '组件路径',
  `redirect` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '重定向地址',
  `hidden` tinyint(1) NOT NULL COMMENT '是否隐藏(True:隐藏 False:显示)',
  `keep_alive` tinyint(1) NOT NULL COMMENT '是否缓存(True:是 False:否)',
  `always_show` tinyint(1) NOT NULL COMMENT '是否始终显示(True:是 False:否)',
  `title` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '菜单标题',
  `params` json DEFAULT NULL COMMENT '路由参数(JSON对象)',
  `affix` tinyint(1) NOT NULL COMMENT '是否固定标签页(True:是 False:否)',
  `link` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '外链地址(仅type=4)',
  `is_iframe` tinyint(1) NOT NULL COMMENT '是否嵌入iframe(True:是 False:否)',
  `is_hide_tab` tinyint(1) NOT NULL COMMENT '是否隐藏标签页(True:是 False:否)',
  `active_path` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '激活菜单路径(用于高亮父级)',
  `show_badge` tinyint(1) NOT NULL COMMENT '是否显示红点角标(True:是 False:否)',
  `show_text_badge` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '文字角标内容',
  `scope` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'web' COMMENT '菜单可见范围(web:管理端 desktop app:移动端)',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `parent_id` int DEFAULT NULL COMMENT '父菜单ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_menu_uuid` (`uuid`),
  KEY `ix_sys_menu_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_menu_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_menu_created_time` (`created_time`),
  KEY `ix_sys_menu_parent_sort` (`parent_id`,`order`),
  KEY `ix_sys_menu_status` (`status`),
  KEY `ix_sys_menu_id` (`id`),
  KEY `ix_sys_menu_updated_time` (`updated_time`),
  KEY `ix_sys_menu_deleted_time` (`deleted_time`),
  KEY `ix_sys_menu_parent_id` (`parent_id`),
  KEY `ix_sys_menu_is_deleted` (`is_deleted`),
  CONSTRAINT `sys_menu_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `sys_menu` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=100047 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES ('系统管理',1,1,NULL,'ri:settings-2-line','System','/system',NULL,'/system/dept',0,1,0,'系统管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',NULL,1,'7cfeee31-5103-4574-9c1a-059c81c2640d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('监控管理',1,2,NULL,'ri:computer-line','Monitor','/monitor',NULL,'/monitor/online',0,1,0,'监控管理','null',0,NULL,0,0,NULL,1,'NEW','web',0,'初始化数据',NULL,2,'d6cb71a9-70e8-4b39-b0fd-b223cf750abc',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('接口管理',1,3,NULL,'ri:file-text-line','Swagger','/swagger',NULL,'/swagger/docs',0,1,0,'接口管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',NULL,3,'71af5e08-318a-41d3-9583-08c76f7da4f9',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('代码管理',1,4,NULL,'ri:code-s-slash-line','Generator','/generator',NULL,'/generator/gencode',0,1,0,'代码管理','null',0,NULL,0,0,NULL,1,'DEV','web',0,'代码管理',NULL,4,'4f0f2719-7563-4c9b-9cb6-9db3a630ac91',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('AI管理',1,5,NULL,'ri:chat-3-line','AI','/ai',NULL,'/ai/chat',0,1,0,'AI管理','null',0,NULL,0,0,NULL,1,'HOT','web',0,'AI管理',NULL,5,'5bd429a3-52be-4df7-acbb-a30b61c0b41f',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('任务管理',1,6,NULL,'ri:tools-line','Task','/task',NULL,'/task/cronjob/job',0,1,0,'任务管理','null',0,NULL,0,0,NULL,1,'BETA','web',0,'任务管理',NULL,6,'012309c4-cff8-4f3f-8954-bec95dae04db',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('案例管理',1,999,NULL,'ri:menu-line','Example','/example',NULL,'/example/demo-center/demo',0,1,0,'案例管理','null',0,NULL,0,0,NULL,1,'BETA','web',0,'案例管理',NULL,7,'1c4d7caa-37e4-4178-84d8-d052204cc615',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('首页',1,9,'','ri:home-4-line','AppHome','/app/home',NULL,'/app/home',0,1,1,'首页','null',0,NULL,0,0,NULL,0,NULL,'app',0,'APP 移动端-首页',NULL,8,'4733c13a-8f2a-4a9b-a268-424880418d77',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('同事',1,10,'','ri:user-heart-line','AppColleague','/app/colleague',NULL,'/app/colleague',0,1,1,'同事','null',0,NULL,0,0,NULL,0,NULL,'app',0,'APP 移动端-同事',NULL,9,'cf614a46-9745-43fa-a439-f4a984349de5',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('打卡',1,11,'','ri:time-line','AppAttendance','/app/attendance',NULL,'/app/attendance',0,1,1,'打卡','null',0,NULL,0,0,NULL,0,NULL,'app',0,'APP 移动端-打卡',NULL,10,'b2251691-7775-42d0-82bf-158a56d2388d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('消息',1,12,'','ri:message-3-line','AppMessage','/app/message',NULL,'/app/message',0,1,1,'消息','null',0,NULL,0,0,NULL,0,NULL,'app',0,'APP 移动端-消息',NULL,11,'30acabf6-89f0-4346-a3e5-90b71a8f67e0',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('我的',1,13,'','ri:user-line','AppMine','/app/mine',NULL,'/app/mine',0,1,1,'我的','null',0,NULL,0,0,NULL,0,NULL,'app',0,'APP 移动端-我的',NULL,12,'2314288b-cd7a-42e3-a640-5fe41f9acccc',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('菜单管理',2,1,'module_system:menu:query','ri:menu-line','Menu','menu','module_system/menu/index',NULL,0,1,0,'菜单管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,13,'770e57e1-7736-4d31-835c-246a654bd582',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('字典管理',2,2,'module_system:dict_type:query','ri:book-2-line','Dict','dict','module_system/dict/index',NULL,0,1,0,'字典管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,14,'889804d3-13c0-42bb-aac9-97360ed8d9e0',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('参数管理',2,3,'module_system:param:query','ri:settings-3-line','Params','param','module_system/params/index',NULL,0,1,0,'参数管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,15,'40a2671b-f382-4456-97c9-6da27cf143b1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('部门管理',2,4,'module_system:dept:query','ri:node-tree','Dept','dept','module_system/dept/index',NULL,0,1,0,'部门管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,16,'a06a56cd-b2ae-4e90-8e38-87943ecf79e4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('岗位管理',2,5,'module_system:position:query','ri:map-pin-line','Position','position','module_system/position/index',NULL,0,1,0,'岗位管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,17,'68fd08dc-0435-420d-9d27-8be9cf360c77',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('角色管理',2,6,'module_system:role:query','ri:admin-line','Role','role','module_system/role/index',NULL,0,1,0,'角色管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,18,'a2a68a82-9bde-4ca6-ab0d-d11d8aa01f6e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('用户管理',2,7,'module_system:user:query','ri:user-line','User','user','module_system/user/index',NULL,0,1,0,'用户管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,19,'d80de3f4-84a4-4c7f-8e9b-5459fb4d5599',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('日志管理',2,8,'module_system:log:query','ri:focus-3-line','Log','log','module_system/log/index',NULL,0,1,0,'日志管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,20,'5f7fc5c5-d7e2-42ca-b25f-bc5cd7154267',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('公告管理',2,9,'module_system:notice:query','ri:notification-3-line','Notice','notice','module_system/notice/index',NULL,0,1,0,'公告管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,21,'40e461bf-abc5-4c4a-a35d-b6b93595e4a5',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('工单管理',2,10,'module_system:ticket:query','ri:feedback-line','ModuleTicket','ticket','module_system/ticket/index',NULL,0,1,0,'工单管理','null',0,NULL,0,0,NULL,1,'NEW','web',0,'初始化数据',1,22,'81d33a42-cbb3-45da-b278-21694eab05e0',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('版本管理',2,11,'module_system:version:query','ri:git-branch-line','ModuleVersion','version/list','module_system/version/index',NULL,0,1,0,'版本管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,23,'b74e3d86-7822-4e67-98ad-dc97b5f0d8de',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('API令牌管理',2,12,'module_system:token:query','ri:key-2-line','ApiToken','token','module_system/api_token/index',NULL,0,1,0,'API令牌管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',1,24,'709564b9-86a0-4f61-a395-f0ec0be20d68',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('在线用户',2,1,'module_monitor:online:query','ri:customer-service-2-line','MonitorOnline','online','module_monitor/online/index',NULL,0,1,0,'在线用户','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',2,25,'810fef5d-6a21-4c1b-9a95-77162f8b1fb3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('服务器监控',2,2,'module_monitor:server:query','ri:dashboard-3-line','MonitorServer','server','module_monitor/server/index',NULL,0,1,0,'服务器监控','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',2,26,'4ce63ade-2d9d-4f31-900a-175d53c009fe',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('缓存监控',2,3,'module_monitor:cache:query','ri:timer-flash-line','MonitorCache','cache','module_monitor/cache/index',NULL,0,1,0,'缓存监控','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',2,27,'099de7a1-ecb9-4dd1-9e56-f7013e47f645',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('文件管理',2,4,'module_monitor:resource:query','ri:folder-5-line','Resource','resource','module_monitor/resource/index',NULL,0,1,0,'文件管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',2,28,'b408af4a-35fa-4672-873c-be845abd42ab',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('Swagger文档',4,1,'module_swagger:docs:query','ri:plug-line','Docs','docs','module_swagger/docs/index',NULL,0,1,0,'Swagger文档','null',0,'/api/v1/docs',1,0,NULL,0,NULL,'web',0,'初始化数据',3,29,'c7f6af5b-7eed-4686-9eb1-0422ea17e70d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('代码生成',2,1,'module_generator:gencode:query','ri:code-s-slash-line','GenCode','gencode','module_generator/gencode/index',NULL,0,1,0,'代码生成','null',0,NULL,0,0,NULL,0,NULL,'web',0,'代码生成',4,30,'2bcc18b3-81f7-4f57-9c3c-f6fcf4e04001',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('AI智能助手',2,1,'module_ai:chat:query','ri:message-2-line','Chat','chat','module_ai/chat/index',NULL,0,1,0,'AI智能助手','null',0,NULL,0,0,NULL,0,NULL,'web',0,'AI智能助手',5,31,'bbeba7eb-27dd-4614-8f62-5c1c31831d4a',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('会话记忆',2,2,'module_ai:chat:query','ri:chat-3-line','Memory','memory','module_ai/memory/index',NULL,0,1,0,'会话记忆','null',0,NULL,0,0,NULL,0,NULL,'web',0,'会话记忆管理',5,32,'e2a7a275-e617-40e6-a9b9-29a8b9d59b9c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('定时任务',1,1,NULL,'ri:timer-line','Cronjob','cronjob',NULL,'/task/cronjob/job',0,1,1,'定时任务','null',0,NULL,0,0,NULL,0,NULL,'web',0,'APScheduler 调度器与任务节点',6,33,'9a9ee19f-4490-4f30-8629-007700eeae89',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('工作流',1,2,NULL,'ri:tools-line','WorkflowMgr','workflow-mgr',NULL,'/task/workflow/flow',0,1,1,'工作流','null',0,NULL,0,0,NULL,0,NULL,'web',0,'流程编排与节点类型',6,34,'55a1373a-a3d2-4475-9126-2d8c84601dfe',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('示例中心',1,1,NULL,'ri:apps-line','DemoCenter','demo-center',NULL,'/example/demo-center/demo',0,1,0,'示例中心','null',0,NULL,0,0,NULL,0,NULL,'web',0,'示例中心',7,35,'cc0ea910-bc0c-4516-8a7d-0a9676cabc07',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_system:menu:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',13,36,'28f6a422-3858-4664-a413-42e968d2af63',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_system:menu:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',13,37,'1f85c0af-0386-4241-9a1a-64be6bde9306',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_system:menu:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',13,38,'eddcb96b-faa4-4920-9a09-e71e42b3f032',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,4,'module_system:menu:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',13,39,'f780f601-aefd-47e1-abf3-d993edf1b42e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,5,'module_system:menu:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',13,40,'f6ce6ec0-e3fe-4162-a47a-fad1a5da9f63',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,6,'module_system:menu:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',13,41,'43e9e8b6-24bb-4617-a0eb-606013d39dd7',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_system:dict_type:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,42,'ac770418-843a-4324-8c57-ca1370cb097a',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_system:dict_type:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,43,'5c8ecb09-3955-4301-a313-cbfe63a2bbeb',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_system:dict_type:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,44,'9eb3dd02-96bc-438e-bb26-ccb6989db495',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,5,'module_system:dict_type:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,45,'dcc3ebd5-02bd-4662-b1e9-d8633c3d1d7b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,6,'module_system:dict_data:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,46,'b8e303ca-c4b1-47af-acc1-abde2cae52ec',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,7,'module_system:dict_data:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,47,'20455913-ab32-4623-9690-34e4f27b880b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,8,'module_system:dict_data:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,48,'7068faa1-fedd-4d32-8e72-cefed07e2bb1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,9,'module_system:dict_data:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,49,'f1963458-5354-415d-97b3-979507ea9976',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,11,'module_system:dict_data:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,50,'6afffcb5-b26f-4b60-9512-46d91a5ed643',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,12,'module_system:dict_type:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,51,'b4cebc15-c389-4214-966e-4f027b8a5b59',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,13,'module_system:dict_type:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,52,'10e63682-a122-4d80-b9c5-bf61c459e737',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,14,'module_system:dict_data:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',14,53,'db16d1b5-86fe-4508-9f67-2310b5fdca79',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,1,'module_system:param:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',15,54,'a00ffc17-9982-467e-8cc4-1fa8ff2c524b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_system:dept:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',16,55,'752cc47d-bea1-4389-8b9a-b1103d28b53f',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_system:dept:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',16,56,'f6fcc78e-b343-4cbf-85ae-6133f00517e5',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_system:dept:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',16,57,'0e28fe40-575d-4e30-91da-072ad7393b9a',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,4,'module_system:dept:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',16,58,'30ebe09b-fc95-490c-9c64-d059e4746643',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,5,'module_system:dept:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',16,59,'4a519cd8-8f83-4331-934b-2437c7732cfa',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,6,'module_system:dept:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',16,60,'8b01204d-ee62-4955-ad45-f74863fa8853',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_system:position:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',17,61,'4526d035-7809-4edf-b2b7-35cefc503ab1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_system:position:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',17,62,'979a212f-1898-49c0-a19f-c5fcbca8595d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_system:position:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',17,63,'cc5ab412-80ec-4fbc-af27-d3dad4aefea7',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,4,'module_system:position:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',17,64,'e7517896-c441-493b-a46e-1f35fd3d9607',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导出',3,5,'module_system:position:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',17,65,'7ad68055-c712-4274-8028-814244336636',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,6,'module_system:position:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',17,66,'c59548a4-9d36-47ce-8e4f-01b1bf697a06',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,7,'module_system:position:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',17,67,'4c56a214-9990-4699-9e52-e84ce59820f4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_system:role:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',18,68,'3c6b5ed1-cff5-4c2e-9c25-51e081c58477',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_system:role:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',18,69,'cc585045-f477-4ace-b07c-d7b114a6790e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_system:role:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',18,70,'f1611cb8-7663-4017-8f0a-b88ec4c449f4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,4,'module_system:role:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',18,71,'e8dbb7a0-944e-499e-914c-6db00cd63629',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导出',3,5,'module_system:role:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',18,72,'65526224-d55c-4228-b03d-506ee137dc1d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,6,'module_system:role:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',18,73,'66f5cec5-5477-4e46-be9f-1cebdf0e6fe6',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,7,'module_system:role:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',18,74,'6081f2c4-a2bb-4579-8ccf-fb9031dea93d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('分配权限',3,8,'module_system:role:permission',NULL,NULL,NULL,NULL,NULL,0,1,0,'分配权限','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',18,75,'a29551a7-db04-462f-af4c-74e6f221d8c1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_system:user:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,76,'3ccf1a0d-2acb-47a8-b37d-97b09f8232f8',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_system:user:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,77,'cb1bc2fd-9411-49f2-85d8-8e42aed10787',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_system:user:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,78,'c534445e-cc0b-40d7-80ca-bc0ab17a2942',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,4,'module_system:user:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,79,'54a44273-e94b-4b2e-bc0a-67328a4c535d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导出',3,5,'module_system:user:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,80,'95573e4f-75ae-402b-a006-a443c90eacc7',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导入',3,6,'module_system:user:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,81,'122b03f9-3439-40c6-af19-041d6a50d266',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('下载导入模板',3,7,'module_system:user:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'下载导入模板','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,82,'a758b841-c83c-4235-b86c-b9f67ad6a903',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,8,'module_system:user:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,83,'483c3453-1c06-470f-9558-33f3ccb22d37',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,9,'module_system:user:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',19,84,'209b0ee8-6a7f-4b6d-8a59-6d9584aaa883',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,1,'module_system:log:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',20,85,'eedbe1b4-752f-4cf5-aaca-bfc36695d805',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导出',3,2,'module_system:log:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',20,86,'e98f40ec-e959-4f34-ab11-69a508a6bcf4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,3,'module_system:log:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',20,87,'5498c082-ba4a-410a-9d2d-909ffb306ec9',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,4,'module_system:log:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',20,88,'6414bf1e-663d-4789-8984-2d0235a76b50',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('登录日志删除',3,5,'module_system:login_log:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'登录日志删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',20,89,'6672f019-b3d5-464f-ac78-c7bd686a111d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('登录日志查询',3,6,'module_system:login_log:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'登录日志查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',20,90,'2feb3b86-9b48-473f-bb8d-a993cdb19d77',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_system:notice:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',21,91,'76cb3bb1-5308-4ac2-8bf4-2815ae334119',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_system:notice:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',21,92,'11dc1caa-df77-4bc7-b7f7-3bdc9699760b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_system:notice:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',21,93,'20ef5e68-9430-4661-8a9e-f5aa2a848250',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导出',3,4,'module_system:notice:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',21,94,'7e314839-27bd-4a4f-803c-ac8fe2708a51',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,5,'module_system:notice:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',21,95,'13204099-3e69-4c6c-a97e-a0ba1b29b580',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,6,'module_system:notice:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',21,96,'82a6f6fb-d78c-4378-af50-04ae1f893aaa',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,5,'module_system:notice:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',21,97,'1f5fcc55-8622-473b-a076-37758eb74994',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,1,'module_system:ticket:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',22,98,'783bcd4f-e1e4-4bee-a203-f9276ad431b9',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,2,'module_system:ticket:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',22,99,'19ef6111-8257-4600-8002-480676b65e08',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,3,'module_system:ticket:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',22,100,'afcadf06-e261-4021-adec-ef598d683288',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,4,'module_system:ticket:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',22,101,'fe50319f-db40-418b-ab82-018cb187f678',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,5,'module_system:ticket:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',22,102,'d396a129-cb55-4972-8fbf-5850f5bbf543',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导出',3,6,'module_system:ticket:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',22,103,'95d2dca9-856e-456a-b3f9-49958b207ee1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('批量操作',3,7,'module_system:ticket:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量操作','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',22,104,'f08b71dd-4a3d-4279-8a17-274e284663e3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,1,'module_system:version:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',23,105,'21348ac7-8480-43d8-bd71-a32a4b2c9e30',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,2,'module_system:version:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',23,106,'fda98563-6233-4869-a77e-470f6432cbef',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,3,'module_system:version:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',23,107,'88bcb57a-b2e5-4e56-a45a-177756a38150',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,4,'module_system:version:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',23,108,'54f7949e-8e39-4797-8eee-7a8b02bb5119',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,5,'module_system:version:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',23,109,'36f8f794-b32f-4707-9c56-acfb00fa14fa',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,1,'module_system:token:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',24,110,'d3dfe4f1-46e6-4f37-a197-f6473fcc73f2',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,2,'module_system:token:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',24,111,'f81231af-4820-4a8b-a5be-6254fb715095',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,3,'module_system:token:reset',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',24,112,'e4f97b46-89d1-46e6-b571-6c0ddc57a68d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,4,'module_system:token:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',24,113,'84fc7ed4-9a02-4d9b-8357-852e1b2f2cfd',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,5,'module_system:token:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',24,114,'35debfcc-64d7-4cb9-9b7a-38c03f56b310',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,6,'module_system:token:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',24,115,'4516b890-d807-4f58-b7a0-3daf55b6d51b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查看明文',3,7,'module_system:token:reveal',NULL,NULL,NULL,NULL,NULL,0,1,0,'查看明文','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',24,116,'0284b3db-19ee-4263-84ea-08013dab7aa3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('强制下线',3,1,'module_monitor:online:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'强制下线','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',25,117,'d0af4541-4a81-432a-8c1a-37cd8f57580b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('仪表盘统计',3,2,'module_monitor:dashboard:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'仪表盘统计','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',25,118,'df8fceac-5b98-4c79-baa6-6982538464a2',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('清除缓存',3,1,'module_monitor:cache:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'清除缓存','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',27,119,'fea133e6-e608-4ed7-989b-f09cb4a00602',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,2,'module_monitor:cache:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',27,120,'644fcfe6-a0e4-4007-89b2-bcb9e8f02fdc',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('上传',3,1,'module_monitor:resource:upload',NULL,NULL,NULL,NULL,NULL,0,1,0,'上传','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',28,121,'94669d72-5302-4df8-a28b-5ab130359d1e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('下载',3,2,'module_monitor:resource:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'下载','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',28,122,'2e15fdf5-915e-4086-af81-42a5d62f7f2e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_monitor:resource:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',28,123,'9d1801a3-2525-4aa7-ac78-9a6560e7bde1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('移动',3,4,'module_monitor:resource:move',NULL,NULL,NULL,NULL,NULL,0,1,0,'移动','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',28,124,'94a49c87-76a3-46d1-afef-11e18d41ebe0',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('复制',3,5,'module_monitor:resource:copy',NULL,NULL,NULL,NULL,NULL,0,1,0,'复制','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',28,125,'0e17a2a2-819b-4576-9a9a-7ecbae1e6cbf',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('重命名',3,6,'module_monitor:resource:rename',NULL,NULL,NULL,NULL,NULL,0,1,0,'重命名','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',28,126,'e105f5a5-b9b2-4afe-8a39-1bd1cf1c00db',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,7,'module_monitor:resource:mkdir',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',28,127,'58518846-1e27-4b74-90d4-563d18f548ff',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导出',3,9,'module_monitor:resource:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',28,128,'9c8eb0af-af25-40cb-b9e3-68e01271378f',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,1,'module_generator:gencode:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'查询代码生成业务表列表',30,129,'a0ac4904-b9e1-4300-a7da-c81d8908baaa',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,2,'module_generator:gencode:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'创建表结构',30,130,'be225c36-35b9-4245-b176-c7331adaaec4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,3,'module_generator:gencode:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'编辑业务表信息',30,131,'3a0da4b7-2b20-4f63-bebd-267b9f60c9c4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,4,'module_generator:gencode:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'删除业务表信息',30,132,'520848e5-c5a1-485c-97f4-a0962d930dfc',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导入',3,5,'module_generator:gencode:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入','null',0,NULL,0,0,NULL,0,NULL,'web',0,'导入表结构',30,133,'a27244d5-fd91-4639-a9d5-6e075070df40',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('批量生成代码',3,6,'module_generator:gencode:operate',NULL,NULL,NULL,NULL,NULL,0,1,0,'批量生成代码','null',0,NULL,0,0,NULL,0,NULL,'web',0,'批量生成代码',30,134,'428296e9-a1f4-4e37-971b-4ba40b7b88af',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('生成代码到指定路径',3,7,'module_generator:gencode:code',NULL,NULL,NULL,NULL,NULL,0,1,0,'生成代码到指定路径','null',0,NULL,0,0,NULL,0,NULL,'web',0,'生成代码到指定路径',30,135,'05e29230-76cc-43e7-99d7-ab9c552cf2ff',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,8,'module_generator:dblist:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'查询数据库表列表',30,136,'9e8aad98-5e68-4fca-b0a4-798726d4190d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('同步数据库',3,9,'module_generator:db:sync',NULL,NULL,NULL,NULL,NULL,0,1,0,'同步数据库','null',0,NULL,0,0,NULL,0,NULL,'web',0,'同步数据库',30,137,'e668cccb-ba11-4ec5-a930-19bea3f3bf52',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('AI对话',3,1,'module_ai:chat:ws',NULL,NULL,NULL,NULL,NULL,0,1,0,'AI对话','null',0,NULL,0,0,NULL,0,NULL,'web',0,'AI对话',31,138,'b2639d06-4cad-4dc7-ad20-f9e6f1aadbad',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,2,'module_ai:chat:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'查询会话',31,139,'9f2c62ed-e2c9-4401-8cbe-bc1525de8b07',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,3,'module_ai:chat:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'会话详情',31,140,'8e54c761-21bc-4392-9847-a6bcf751f088',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,4,'module_ai:chat:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'创建会话',31,141,'6859e5fb-2fca-4238-9f7c-0df96d011ea4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,5,'module_ai:chat:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'更新会话',31,142,'89ddc7df-bdfc-45ea-971a-e51773622c56',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,6,'module_ai:chat:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'删除会话',31,143,'2e59bec3-2c12-4212-8bd5-1563b2ceba0c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('激活',3,7,'module_ai:chat:activate','',NULL,NULL,NULL,NULL,0,1,0,'激活','null',0,NULL,0,0,NULL,0,NULL,'web',0,'激活会话',31,100007,'03592f9d-dadb-4a66-bb8a-576b59126311',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,1,'module_ai:chat:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'查询会话记忆',32,100008,'a46f546d-f13e-47c8-8cba-cfb0de31e12c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,2,'module_ai:chat:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'会话记忆详情',32,100009,'c9513e48-afd5-42f2-ac44-85b8182136be',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_ai:chat:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'删除会话记忆',32,100010,'cb4d55a1-7b01-4477-97e4-bb58033fb080',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('调度器监控',2,1,'module_task:cronjob:job:query','ri:line-chart-line','Job','job','module_task/cronjob/job/index',NULL,0,1,0,'调度器监控','null',0,NULL,0,0,NULL,0,NULL,'web',0,'调度器监控',33,100011,'dcf6a174-c6a5-4bd9-91fe-591ab207cf1e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('节点管理',2,2,'module_task:cronjob:node:query','ri:mail-send-line','Node','node','module_task/cronjob/node/index',NULL,0,1,0,'节点管理','null',0,NULL,0,0,NULL,0,NULL,'web',0,'节点管理',33,100012,'eebdd0fd-8547-4f8a-ba75-b9bdb7f7e68c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('流程编排',2,1,'module_task:workflow:flow:query','ri:tools-line','Workflow','task/workflow/flow','module_task/workflow/flow/index',NULL,0,1,0,'流程编排','null',0,NULL,0,0,NULL,0,NULL,'web',0,'Vue Flow 画布与发布执行',34,100013,'bcdf35db-7525-4ab6-88c7-d6bb1a373cc2',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('节点类型',2,2,'module_task:workflow:nodes:query','ri:layout-grid-line','WorkflowNodeType','task/workflow/nodes','module_task/workflow/nodes/index',NULL,0,1,0,'节点类型','null',0,NULL,0,0,NULL,0,NULL,'web',0,'画布节点类型与 Prefect 执行逻辑',34,100014,'8e6a9153-2b69-4f40-ac64-4a6563a24b25',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('demo示例',2,1,'module_example:demo:query','ri:menu-line','Demo','demo','module_example/demo/index',NULL,0,1,0,'demo示例','null',0,NULL,0,0,NULL,0,NULL,'web',0,'demo示例',35,100015,'5e70baed-e45f-408e-a7fc-d6047ba375b1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,1,'module_task:cronjob:job:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'查询',100011,100016,'360129a6-0c7b-4e1e-9fda-8eb1ddd75794',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('控制调度器',3,2,'module_task:cronjob:job:scheduler',NULL,NULL,NULL,NULL,NULL,0,1,0,'控制调度器','null',0,NULL,0,0,NULL,0,NULL,'web',0,'控制调度器',100011,100017,'82133f0b-282f-4104-8389-46f0baf19d29',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('执行',3,3,'module_task:cronjob:job:task',NULL,NULL,NULL,NULL,NULL,0,1,0,'执行','null',0,NULL,0,0,NULL,0,NULL,'web',0,'执行',100011,100018,'709c0d50-475e-48d9-86fe-a49abcc5ef2f',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,4,'module_task:cronjob:job:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'删除',100011,100019,'11ec32a1-07c3-46d8-a069-ddaed75463ee',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,5,'module_task:cronjob:job:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'详情',100011,100020,'31f41883-1923-4bad-b8f9-1cd5bfbc0410',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_task:cronjob:node:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'新增',100012,100021,'8fb52000-01fe-4988-ad0f-c03bc53701ca',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('调试节点',3,2,'module_task:cronjob:node:execute',NULL,NULL,NULL,NULL,NULL,0,1,0,'调试节点','null',0,NULL,0,0,NULL,0,NULL,'web',0,'调试节点',100012,100022,'8f54d74c-19d1-4a51-ba54-137fe46a8148',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,3,'module_task:cronjob:node:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'编辑',100012,100023,'4ada0291-d5cc-45ac-92b4-1769d00ec1c6',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除节点',3,4,'module_task:cronjob:node:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除节点','null',0,NULL,0,0,NULL,0,NULL,'web',0,'删除节点',100012,100024,'62d4c746-bfa0-408a-bf48-95766334dcb4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,5,'module_task:cronjob:node:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'详情',100012,100025,'baae2098-9fac-4ca5-92eb-5f0b0c05dba5',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,6,'module_task:cronjob:node:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'查询',100012,100026,'67ca01f9-46b4-48b2-9f70-4206aaf8a1b2',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_task:workflow:flow:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'新增',100013,100027,'73c5b4fc-4e43-4edd-b336-2dca9486b840',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('执行流程',3,2,'module_task:workflow:flow:execute',NULL,NULL,NULL,NULL,NULL,0,1,0,'执行流程','null',0,NULL,0,0,NULL,0,NULL,'web',0,'执行流程',100013,100028,'d475271f-8a33-4d68-a8b0-3a4198c58f87',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,3,'module_task:workflow:flow:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'编辑',100013,100029,'64d069e7-2130-423f-8a80-6cd979fb464e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除流程',3,4,'module_task:workflow:flow:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除流程','null',0,NULL,0,0,NULL,0,NULL,'web',0,'删除流程',100013,100030,'c31dd3cc-789c-45e7-87c2-270236ef260b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,5,'module_task:workflow:flow:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'详情',100013,100031,'4171e6e3-52a0-40ad-a970-28e65b3f5bd1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,6,'module_task:workflow:flow:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'查询',100013,100032,'cdd0263b-2a72-4a2e-8299-f67c35b42f05',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_task:workflow:nodes:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'新增',100014,100033,'d6de9cea-6421-49ff-8956-9398c77d9a84',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_task:workflow:nodes:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'编辑',100014,100034,'3fef4ee7-fe1d-48bc-872a-4e51cd5ebc1c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除节点类型',3,3,'module_task:workflow:nodes:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除节点类型','null',0,NULL,0,0,NULL,0,NULL,'web',0,'删除节点类型',100014,100035,'fed84f73-f324-48af-a595-985d4fecd240',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,4,'module_task:workflow:nodes:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'详情',100014,100036,'42a3b3c6-f4b0-46bd-92e1-f16a2069726e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,5,'module_task:workflow:nodes:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'查询',100014,100037,'fb039a8b-9721-43a2-afee-6c422f226844',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('新增',3,1,'module_example:demo:create',NULL,NULL,NULL,NULL,NULL,0,1,0,'新增','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100038,'9f68babe-3864-4ecb-b6b2-51c3db802b13',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('编辑',3,2,'module_example:demo:update',NULL,NULL,NULL,NULL,NULL,0,1,0,'编辑','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100039,'3a9502c1-f3ee-4ed8-8e92-b0cf86efb35c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('删除',3,3,'module_example:demo:delete',NULL,NULL,NULL,NULL,NULL,0,1,0,'删除','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100040,'8ff8eaa4-b522-4fed-b5cc-34b9c296a724',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('状态变更',3,4,'module_example:demo:patch',NULL,NULL,NULL,NULL,NULL,0,1,0,'状态变更','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100041,'2abcec8c-e4ce-4fe5-9692-97d4797641ba',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导出',3,5,'module_example:demo:export',NULL,NULL,NULL,NULL,NULL,0,1,0,'导出','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100042,'67821208-aa4e-4e0b-a0d5-d57fa0864d16',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('导入',3,6,'module_example:demo:import',NULL,NULL,NULL,NULL,NULL,0,1,0,'导入','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100043,'eb2e8f8c-0281-4fba-98ee-985c9837008d',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('下载导入模板',3,7,'module_example:demo:download',NULL,NULL,NULL,NULL,NULL,0,1,0,'下载导入模板','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100044,'49f5ed4a-1dfd-483c-a34a-38b9b4fe694c',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('详情',3,8,'module_example:demo:detail',NULL,NULL,NULL,NULL,NULL,0,1,0,'详情','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100045,'d54eddfd-adb2-4a1b-a3ca-5ea83e642028',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('查询',3,9,'module_example:demo:query',NULL,NULL,NULL,NULL,NULL,0,1,0,'查询','null',0,NULL,0,0,NULL,0,NULL,'web',0,'初始化数据',100015,100046,'fd779438-22f5-4b5b-a89c-bf2808101204',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL);
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_notice`
--

DROP TABLE IF EXISTS `sys_notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice` (
  `notice_title` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告标题',
  `notice_type` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告类型(1通知 2公告)',
  `notice_content` text COLLATE utf8mb4_unicode_ci COMMENT '公告内容',
  `status` int NOT NULL COMMENT '状态(0:草稿 1:已发布 2:已归档)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_notice_uuid` (`uuid`),
  KEY `ix_sys_notice_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_notice_updated_time` (`updated_time`),
  KEY `ix_sys_notice_updated_id` (`updated_id`),
  KEY `ix_sys_notice_deleted_time` (`deleted_time`),
  KEY `ix_sys_notice_status` (`status`),
  KEY `ix_sys_notice_is_deleted` (`is_deleted`),
  KEY `ix_sys_notice_created_id` (`created_id`),
  KEY `ix_sys_notice_created_time` (`created_time`),
  KEY `ix_sys_notice_deleted_id` (`deleted_id`),
  KEY `ix_sys_notice_id` (`id`),
  KEY `ix_sys_notice_status_deleted` (`status`,`is_deleted`),
  CONSTRAINT `sys_notice_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_notice_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_notice_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_notice`
--

LOCK TABLES `sys_notice` WRITE;
/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_operation_log`
--

DROP TABLE IF EXISTS `sys_operation_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_operation_log` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作人用户名',
  `status` int NOT NULL COMMENT '操作状态(0:成功 1:失败)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `request_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请求路径',
  `request_method` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请求方式',
  `request_payload` longtext COLLATE utf8mb4_unicode_ci COMMENT '请求体',
  `response_code` int NOT NULL COMMENT '响应状态码',
  `response_json` longtext COLLATE utf8mb4_unicode_ci COMMENT '响应体',
  `process_time` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '处理时间',
  `request_ip` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '请求IP',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_operation_log_uuid` (`uuid`),
  KEY `ix_sys_operation_log_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_operation_log_updated_time` (`updated_time`),
  KEY `ix_sys_operation_log_request_ip` (`request_ip`),
  KEY `ix_sys_operation_log_is_deleted` (`is_deleted`),
  KEY `ix_sys_operation_log_deleted_time` (`deleted_time`),
  KEY `ix_sys_operation_log_id` (`id`),
  KEY `ix_sys_operation_log_path_created` (`request_path`,`created_time`),
  KEY `ix_sys_operation_log_created_time` (`created_time`),
  KEY `ix_sys_operation_log_status` (`status`),
  KEY `ix_sys_operation_log_created_deleted` (`created_time`,`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_operation_log`
--

LOCK TABLES `sys_operation_log` WRITE;
/*!40000 ALTER TABLE `sys_operation_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_operation_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_param`
--

DROP TABLE IF EXISTS `sys_param`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_param` (
  `config_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数名称',
  `config_key` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数键名',
  `config_value` text COLLATE utf8mb4_unicode_ci COMMENT '参数键值',
  `config_type` tinyint(1) DEFAULT NULL COMMENT '系统内置(True:是 False:否)',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_param_uuid` (`uuid`),
  KEY `ix_sys_param_deleted_time` (`deleted_time`),
  KEY `ix_sys_param_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_param_status` (`status`),
  KEY `ix_sys_param_is_deleted` (`is_deleted`),
  KEY `ix_sys_param_created_time` (`created_time`),
  KEY `ix_sys_param_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_param_id` (`id`),
  KEY `ix_sys_param_updated_time` (`updated_time`),
  KEY `ix_sys_param_config_type` (`config_type`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_param`
--

LOCK TABLES `sys_param` WRITE;
/*!40000 ALTER TABLE `sys_param` DISABLE KEYS */;
INSERT INTO `sys_param` VALUES ('演示模式启用','demo_enable','off',1,0,'是否启用演示模式（启用后非白名单IP只允许GET请求）',1,'53a76d55-0c86-4785-8619-b0ec7bc175a4',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('演示访问IP白名单','ip_white_list','[\"127.0.0.1\"]',1,0,'演示模式下允许访问的IP列表',2,'13413d69-9753-444b-b933-2b72beb27a20',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('访问IP黑名单','ip_black_list','[]',1,0,'禁止访问的IP列表（任意请求均拒绝）',3,'7a8272bf-8f0c-4585-abb6-00a6f2be0ad3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('Logo URL','logo_url','https://service.fastapiadmin.com/api/v1/static/image/logo.svg',1,0,'平台Logo地址',4,'dbc35b88-d570-4129-bc8c-5cade7f66c38',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('Favicon 地址','favicon','https://service.fastapiadmin.com/api/v1/static/image/favicon.ico',1,0,'浏览器标签栏图标地址',5,'7522ed07-59ab-447b-8415-abbb788b5a51',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('登录背景图','login_bg','https://service.fastapiadmin.com/api/v1/static/image/background.svg',1,0,'登录页面背景图地址',6,'acd65410-5f46-42e7-abc9-3afef8cb9a3b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('版权信息','copyright','Copyright © 2025-2027 service.fastapiadmin.com 版权所有',1,0,'页面底部版权信息',7,'7eb264ce-b75e-45e9-8945-b3ff5f181b3b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('备案号','keep_record','陕ICP备2025069493号-1',1,0,'ICP备案号',8,'0dc82f6a-f224-45e2-b1ab-06bd54ccc9a1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('帮助文档地址','help_doc','https://docs.fastapiadmin.com',1,0,'帮助文档链接地址',9,'1b3f5416-820c-4f4f-b704-448a2cdf48e1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('隐私政策地址','privacy','https://fastapiadmin.com/privacy',1,0,'隐私政策链接地址',10,'2ece9549-51d1-4509-8d87-79fd33fd5504',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('用户协议地址','clause','https://fastapiadmin.com/clause',1,0,'用户协议链接地址',11,'52701095-3808-4b8b-bb72-dceb85ad62e8',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('源码地址','git_code','https://github.com/fastapi-admin/fastapi-admin',1,0,'项目源码仓库地址',12,'4885e318-a4cd-40a6-bce7-40fb31472f69',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('系统版本','version','3.0.0',1,0,'系统版本号',13,'1425e585-167a-4f8c-ab1c-586bf401c191',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('系统名称','sys_name','FastapiAdmin系统',1,0,'平台系统名称，用于登录页等界面展示',14,'e0d1997d-acb1-430c-9cd1-0d201afc48f1',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('登录页标题','login_title','一款兼具设计美学与高效开发的后台系统',1,0,'登录页左侧面板主标题文案',15,'f3dbdb61-e8d8-4d3b-8750-715dd6350f1e',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('登录页副标题','login_subtitle','提供安全、高效、可扩展的管理解决方案，助力企业数字化转型与业务增长。',1,0,'登录页左侧面板副标题文案',16,'6a466c19-7a46-4e62-9b66-62ce35849135',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL),('IP归属地查询','ip_location_enable','on',1,0,'是否启用IP归属地查询（登录时对外发起HTTP请求，关闭后只记录内网/未知）',17,'ec4e5843-94d8-460c-84d7-f165fe5dd380',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL);
/*!40000 ALTER TABLE `sys_param` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_position`
--

DROP TABLE IF EXISTS `sys_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_position` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位名称',
  `code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位编码',
  `order` int NOT NULL COMMENT '显示排序',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `ix_sys_position_uuid` (`uuid`),
  KEY `ix_sys_position_status` (`status`),
  KEY `ix_sys_position_updated_time` (`updated_time`),
  KEY `ix_sys_position_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_position_is_deleted` (`is_deleted`),
  KEY `ix_sys_position_created_id` (`created_id`),
  KEY `ix_sys_position_deleted_id` (`deleted_id`),
  KEY `ix_sys_position_created_time` (`created_time`),
  KEY `ix_sys_position_deleted_time` (`deleted_time`),
  KEY `ix_sys_position_updated_id` (`updated_id`),
  KEY `ix_sys_position_id` (`id`),
  KEY `ix_sys_position_status_deleted` (`status`,`is_deleted`),
  CONSTRAINT `sys_position_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_position_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_position_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_position`
--

LOCK TABLES `sys_position` WRITE;
/*!40000 ALTER TABLE `sys_position` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_position` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色编码',
  `order` int NOT NULL COMMENT '显示排序',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `data_scope` int NOT NULL COMMENT '数据权限范围(1:仅本人 2:本部门 3:本部门及以下 4:全部 5:自定义)',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `ix_sys_role_uuid` (`uuid`),
  KEY `ix_sys_role_updated_id` (`updated_id`),
  KEY `ix_sys_role_deleted_time` (`deleted_time`),
  KEY `ix_sys_role_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_role_status` (`status`),
  KEY `ix_sys_role_created_id` (`created_id`),
  KEY `ix_sys_role_created_time` (`created_time`),
  KEY `ix_sys_role_deleted_id` (`deleted_id`),
  KEY `ix_sys_role_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_role_id` (`id`),
  KEY `ix_sys_role_is_deleted` (`is_deleted`),
  KEY `ix_sys_role_updated_time` (`updated_time`),
  CONSTRAINT `sys_role_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_role_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_role_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES ('超级管理员','SUPER_ADMIN',1,0,'拥有系统最高权限',4,1,'fa7e2fc3-8079-4cb0-8318-5bc0ca14f9fd',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('管理员','ADMIN',2,0,'管理系统内所有资源',3,2,'d7d35f20-0de8-4071-bb81-bb3cefc84704',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('普通用户','USER',3,0,'仅能查看和操作自己的数据',1,3,'6251c341-ab6d-42f3-945c-a27211530d58',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_depts`
--

DROP TABLE IF EXISTS `sys_role_depts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_depts` (
  `role_id` int NOT NULL COMMENT '角色ID',
  `dept_id` int NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`,`dept_id`),
  KEY `dept_id` (`dept_id`),
  CONSTRAINT `sys_role_depts_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_role_depts_ibfk_2` FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_depts`
--

LOCK TABLES `sys_role_depts` WRITE;
/*!40000 ALTER TABLE `sys_role_depts` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_depts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menus`
--

DROP TABLE IF EXISTS `sys_role_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menus` (
  `role_id` int NOT NULL COMMENT '角色ID',
  `menu_id` int NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`),
  KEY `menu_id` (`menu_id`),
  CONSTRAINT `sys_role_menus_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_role_menus_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `sys_menu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menus`
--

LOCK TABLES `sys_role_menus` WRITE;
/*!40000 ALTER TABLE `sys_role_menus` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_ticket`
--

DROP TABLE IF EXISTS `sys_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_ticket` (
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工单标题',
  `status` int NOT NULL COMMENT '状态(0:待处理 1:处理中 2:已完成 3:已关闭)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `ticket_content` text COLLATE utf8mb4_unicode_ci COMMENT '工单内容（富文本）',
  `summary` text COLLATE utf8mb4_unicode_ci COMMENT '工单内容（纯文本摘要）',
  `ticket_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工单类型(suggestion:建议 bug:缺陷 optimize:优化 other:其他)',
  `images` text COLLATE utf8mb4_unicode_ci COMMENT '图片URL列表(JSON数组)',
  `reply` text COLLATE utf8mb4_unicode_ci COMMENT '回复内容',
  `assigned_id` int DEFAULT NULL COMMENT '处理人ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_ticket_uuid` (`uuid`),
  KEY `ix_sys_ticket_id` (`id`),
  KEY `ix_sys_ticket_updated_time` (`updated_time`),
  KEY `ix_sys_ticket_updated_id` (`updated_id`),
  KEY `ix_sys_ticket_deleted_time` (`deleted_time`),
  KEY `ix_sys_ticket_assigned_id` (`assigned_id`),
  KEY `ix_sys_ticket_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_ticket_is_deleted` (`is_deleted`),
  KEY `ix_sys_ticket_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_ticket_status` (`status`),
  KEY `ix_sys_ticket_created_id` (`created_id`),
  KEY `ix_sys_ticket_created_time` (`created_time`),
  KEY `ix_sys_ticket_deleted_id` (`deleted_id`),
  CONSTRAINT `sys_ticket_ibfk_1` FOREIGN KEY (`assigned_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_ticket_ibfk_2` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_ticket_ibfk_3` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_ticket_ibfk_4` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_ticket`
--

LOCK TABLES `sys_ticket` WRITE;
/*!40000 ALTER TABLE `sys_ticket` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_ticket` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_ticket_comment`
--

DROP TABLE IF EXISTS `sys_ticket_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_ticket_comment` (
  `ticket_id` int NOT NULL COMMENT '工单ID',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容（富文本）',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_ticket_comment_uuid` (`uuid`),
  KEY `ix_sys_ticket_comment_id` (`id`),
  KEY `ix_sys_ticket_comment_ticket_id` (`ticket_id`),
  KEY `ix_sys_ticket_comment_updated_time` (`updated_time`),
  KEY `ix_sys_ticket_comment_deleted_id` (`deleted_id`),
  KEY `ix_sys_ticket_comment_created_id` (`created_id`),
  KEY `ix_sys_ticket_comment_created_time` (`created_time`),
  KEY `ix_sys_ticket_comment_is_deleted` (`is_deleted`),
  KEY `ix_sys_ticket_comment_deleted_time` (`deleted_time`),
  KEY `ix_sys_ticket_comment_updated_id` (`updated_id`),
  KEY `ix_sys_ticket_comment_created_deleted` (`created_time`,`is_deleted`),
  CONSTRAINT `sys_ticket_comment_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `sys_ticket` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sys_ticket_comment_ibfk_2` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_ticket_comment_ibfk_3` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_ticket_comment_ibfk_4` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_ticket_comment`
--

LOCK TABLES `sys_ticket_comment` WRITE;
/*!40000 ALTER TABLE `sys_ticket_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_ticket_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名/登录账号',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '昵称',
  `mobile` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `email` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `gender` varchar(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '性别(0:男 1:女 2:未知)',
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL地址',
  `is_superuser` tinyint(1) NOT NULL COMMENT '是否超管',
  `last_login` datetime DEFAULT NULL COMMENT '最后登录时间',
  `gitee_login` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Gitee登录',
  `github_login` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Github登录',
  `wx_login` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微信登录',
  `qq_login` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'QQ登录',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `dept_id` int DEFAULT NULL COMMENT '部门ID',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `ix_sys_user_uuid` (`uuid`),
  KEY `ix_sys_user_deleted_id` (`deleted_id`),
  KEY `ix_sys_user_id` (`id`),
  KEY `ix_sys_user_updated_time` (`updated_time`),
  KEY `ix_sys_user_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_user_deleted_time` (`deleted_time`),
  KEY `ix_sys_user_updated_id` (`updated_id`),
  KEY `ix_sys_user_is_deleted` (`is_deleted`),
  KEY `ix_sys_user_dept_id` (`dept_id`),
  KEY `ix_sys_user_created_id` (`created_id`),
  KEY `ix_sys_user_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_user_status` (`status`),
  KEY `ix_sys_user_created_time` (`created_time`),
  CONSTRAINT `sys_user_ibfk_1` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_user_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_user_ibfk_3` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_user_ibfk_4` FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES ('super','$pbkdf2-sha256$600000$XX20aO1v73xS0JnoewXNtw==$PEaVHV1N5L7PfYQw2lCAQOc4hAEyCiwsGR48/jgVBjU=','超级管理员','13800138000','super@example.com','0','https://service.fastapiadmin.com/api/v1/static/image/avatar.png',1,NULL,NULL,NULL,NULL,NULL,0,'系统超级管理员',1,1,'8ff36664-b8ff-44ec-928b-cfb0e3e455a0',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('admin','$pbkdf2-sha256$600000$XX20aO1v73xS0JnoewXNtw==$PEaVHV1N5L7PfYQw2lCAQOc4hAEyCiwsGR48/jgVBjU=','管理员','13800138001','admin@example.com','0','https://service.fastapiadmin.com/api/v1/static/image/avatar.png',1,NULL,NULL,NULL,NULL,NULL,0,'系统管理员',1,2,'9ef61f54-b76c-4bd6-b015-5d4ce0748e7b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,1,NULL,NULL),('user','$pbkdf2-sha256$600000$XX20aO1v73xS0JnoewXNtw==$PEaVHV1N5L7PfYQw2lCAQOc4hAEyCiwsGR48/jgVBjU=','普通用户','13800138002','user@example.com','0','https://service.fastapiadmin.com/api/v1/static/image/avatar.png',0,NULL,NULL,NULL,NULL,NULL,0,'普通用户',1,3,'fe0478cb-245d-42e9-b29c-405df155d915',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,1,NULL,NULL);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_positions`
--

DROP TABLE IF EXISTS `sys_user_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_positions` (
  `user_id` int NOT NULL COMMENT '用户ID',
  `position_id` int NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`,`position_id`),
  KEY `position_id` (`position_id`),
  CONSTRAINT `sys_user_positions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_user_positions_ibfk_2` FOREIGN KEY (`position_id`) REFERENCES `sys_position` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_positions`
--

LOCK TABLES `sys_user_positions` WRITE;
/*!40000 ALTER TABLE `sys_user_positions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_user_positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_roles`
--

DROP TABLE IF EXISTS `sys_user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_roles` (
  `user_id` int NOT NULL COMMENT '用户ID',
  `role_id` int NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `sys_user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sys_user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_roles`
--

LOCK TABLES `sys_user_roles` WRITE;
/*!40000 ALTER TABLE `sys_user_roles` DISABLE KEYS */;
INSERT INTO `sys_user_roles` VALUES (1,1),(2,2),(3,3);
/*!40000 ALTER TABLE `sys_user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_version`
--

DROP TABLE IF EXISTS `sys_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_version` (
  `version` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '版本号',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '版本标题',
  `date` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '发布日期',
  `content` text COLLATE utf8mb4_unicode_ci COMMENT '版本富文本内容',
  `sort` int NOT NULL COMMENT '排序',
  `status` int NOT NULL COMMENT '状态: 0=草稿,1=已发布,2=已回滚',
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `require_re_login` tinyint(1) NOT NULL COMMENT '是否需要重新登录',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_sys_version_uuid` (`uuid`),
  KEY `ix_sys_version_is_deleted` (`is_deleted`),
  KEY `ix_sys_version_created_id` (`created_id`),
  KEY `ix_sys_version_created_time` (`created_time`),
  KEY `ix_sys_version_id` (`id`),
  KEY `ix_sys_version_deleted_id` (`deleted_id`),
  KEY `ix_sys_version_status_deleted` (`status`,`is_deleted`),
  KEY `ix_sys_version_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_sys_version_updated_time` (`updated_time`),
  KEY `ix_sys_version_updated_id` (`updated_id`),
  KEY `ix_sys_version_deleted_time` (`deleted_time`),
  CONSTRAINT `sys_version_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_version_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `sys_version_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_version`
--

LOCK TABLES `sys_version` WRITE;
/*!40000 ALTER TABLE `sys_version` DISABLE KEYS */;
INSERT INTO `sys_version` VALUES ('v3.0.0','问题修复、表单与路由体验优化','2026-03-15','- 修复：富文本编辑器样式异常问题\n- 修复：菜单区域无法滚动的问题\n- 修复：特殊路由打开后显示空白页面的问题\n- 修复：WebSocket 重连异常问题\n- 修复：特殊动态路由参数处理异常问题\n- 优化：FaForm、FaSearchBar 表单提交前增加数据清洗，避免无效字段提交到后端\n- 修复：FaTable 与 ElForm 组合使用时动态表单校验错误的问题\n- 修复：隐藏子菜单时父级菜单被一并隐藏的问题\n- 修复：静态路由刷新后跳回首页的问题\n- 修复：fa-table 属性继承异常问题\n- 修复：PC 端切换到移动端后再切回 PC 端，菜单无法恢复原桌面布局的问题',1,1,NULL,0,1,'826b1710-5872-4c50-b24f-50394a4e3959',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.6.3','bug修复、新增功能','2025-11-15','- 修复：路由注册时不存在接口的重复请求问题\n- 修复：一键精简脚本打包失败的问题\n- 优化：完善路由配置验证机制，自动检测并提示非一级菜单的路径配置错误\n- 优化：顶部进度条残影\n- 优化：vite 预构建优化\n- 优化：圆角、边框统一\n- 优化：锁屏页面重新设计\n- 优化：退出登录菜单提前消失造成的视觉体验不好问题\n- 新增：FaForm 和 FaSearchBar 组件的 label 支持自定义渲染函数\n- 新增：菜单管理表单关键字段新增 Tooltip 提示\n- 新增：iconify 新增离线图标加载模式\n- 新增：退出登录新增 redirect 属性\n- 新增：退出登录重新进入系统保留用户标签页\n- 新增：双列菜单新增折叠按钮\n- 新增：菜单图标完善\n- 新增：多标签页增加图标\n- 新增：WebSocket 连接',2,1,NULL,0,2,'b059f4c0-f126-4ea8-a4cb-c3af3c63893b',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.6.2','Sass 重构为 Tailwind CSS，Iconfont 替换为 Iconify','2025-11-09','- 样式系统重构：Sass 全面迁移至 Tailwind CSS\n- 图标方案升级：Iconfont 替换为 Iconify\n- 构建优化：完整包体积减少 1.3 MB\n- 路由注册重构：全面重构路由注册系统\n- 架构优化：优化目录结构，职责划分更清晰\n- 注释优化：统一模块注释规范\n- 性能提升：优化核心代码逻辑\n- 设计系统：重构颜色体系\n- 菜单优化：细化菜单样式\n- 组件重构：重构 ArtTextScroll 组件\n- 问题修复：修复 FaForm、FaSearchBar 自定义组件渲染异常\n- 功能增强：FaForm、FaSearchBar 新增 render 属性\n- 功能增强：useTable hooks 新增 visible 属性\n- 响应式优化：优化 FaForm、FaSearchBar 栅格布局\n- 节日功能增强：礼花配置支持跨日期范围设置\n- 依赖更新：升级核心依赖至最新稳定版本',3,1,'重要提示：本次升级涉及样式系统（Sass → Tailwind CSS）与图标库（Iconfont → Iconify）的底层重构，属于破坏性更新。建议新项目直接使用 v3.0，旧版本项目不建议升级。',1,3,'0afc1816-7e24-4fe8-b82f-5b72287bfcb5',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.6.1','bug修复、授权页增加主题色切换功能','2025-10-19','- 修复获取用户信息、获取菜单接口访问无效地址重复调用问题\n- 升级部分依赖兼容 tailwindcss\n- 修复 ElButton circle 模式样式\n- 修复 ElSelect 无法通过键盘选择问题\n- 修复带参数静态路由跳转登录页面问题\n- 优化外部链接菜单点击选中状态\n- 授权页增加主题色切换功能',4,1,NULL,0,4,'e5e63408-6f02-47c0-b5ad-012cf226ebf7',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.6.0','代码优化、bug修复','2025-10-16','- 优化精简版本菜单数据结构\n- 优化本地开发环境网络请求代理配置\n- 优化 ElTree 组件默认样式\n- 新增 VsCode 推荐插件相关配置\n- 优化 ElDropdown 组件点击触发模式下的交互样式\n- 扩展注册、密码重置页面顶部组件支持\n- 优化菜单过滤逻辑\n- 优化页面切换动画\n- 优化暗黑模式文字颜色\n- 修复静态路由自定义首页路径首次访问跳转登录页问题\n- 修复退出登录时短暂跳转至 500 页的问题\n- 修复 v2.5.9 版本首页路由跳转配置失效问题\n- 修复 v2.5.9 自动导包机制导致的构建异常',5,1,NULL,1,5,'79f9ad3a-7561-406a-8849-ff23639e1e64',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.5.9','代码优化','2025-10-12','- views 文件目录、文件名、代码优化\n- useTable 分页请求字段增加全局配置 tableConfig.ts\n- 优化路由配置为模块化结构\n- 获取菜单接口使用 apifox mock 数据',6,1,NULL,0,6,'5ae8174c-dcf2-4bbe-b529-b09e2d2070a3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.5.8','依赖升级、bug修复','2025-09-29','- vue、vite、element-plus 等核心库升级\n- 修复富文本编辑器全屏顶栏层级问题\n- 修复表格列排序组件文字溢出问题\n- 修复统计卡片条件判断\n- 优化 el-tag 样式\n- 优化顶部进度条颜色\n- 优化自定义主题配置\n- 优化 ElementPlus 自定义主题问题\n- 修复根路径 / 与 HOME_PAGE_PATH 同为 / 时出现的无限重定向',7,1,'由于项目依赖升级，node 版本需要升级到 v20.19.0 或以上',0,7,'0a338dac-9c99-4d24-9e3a-3a0b573a751f',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.5.7','新增表单组件','2025-09-14','- 新增 FaForm 组件\n- 修复新版本谷歌浏览器切换主题闪烁问题\n- 优化表单 label 高度没有对齐问题\n- 首屏启动性能优化',8,1,NULL,0,8,'b12f13a3-596d-411a-aab6-6f2a42f21af3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.5.6','优化用户体验、bug修复','2025-08-17','- useTable 类型推导优化\n- useTable removeColumn 支持多数据删除\n- useTable 自动识别响应体支持自定义配置\n- useTable 空数据浏览器警告优化\n- api 接口请求代码优化\n- FaTable 分页组件选中样式优化\n- FaTable 空状态高度默认撑满\n- ArtButtonMore 组件新增图标、颜色配置\n- FaTableHeader 新增搜索按钮\n- FaSearchBar label 为空时不占空间\n- 表格操作栏拖拽禁止固定列拖拽\n- 角色管理页面接口对接\n- 菜单管理页面优化\n- 优化设置中心滚动页面跟随滚动问题\n- 一级路由是外链时component校验逻辑优化\n- 优化地图右下角拖动问题\n- 优化暗黑模式刷新页面白色背景问题\n- 移动端显示左侧菜单logo\n- 网络请求新增 showSuccessMessage\n- 添加全局错误处理基础框架\n- 修复批量删除整页数据没有返回上一页的bug\n- 修复动态路由参数导致的问题\n- 新增权限演示示例\n- 全局组件采用异步加载策略',9,1,NULL,0,9,'7e633fdd-ee54-4399-bf13-bbdfeb8b3ad3',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL),('v2.5.5','bug修复、优化用户体验','2025-07-27','- 重构 FaSearchBar 组件，支持更多组件、表单校验等能力\n- useTable 列配置：支持动态更新能力\n- 修复多个富文本编辑器图标不统一问题\n- 优化颜色选择器圆角\n- el-radio、el-checkbox 统一大小\n- art-stats-card 新增小数位、分隔符配置\n- 路由配置示例优化\n- 高级表格新增自定义获取数据示例\n- useTable 新增 excludeParams\n- 优化路径别名类型问题\n- 本地开发跨域配置优化\n- 修复 useTable 删除最后一整页数据没有返回上一页的问题\n- 修复 echarts 图表数据初始化、更新数据浏览器报错\n- 删除 art-chart-empty 组件\n- 新增 FaSearchBar 组件示例\n- 网络请求支持 http 状态码为 401 时退出登录\n- 优化网络请求退出登录多次提示问题\n- useTable 属性、方法命名优化\n- 登录页UI升级\n- 403、404、500 页面UI升级',10,1,NULL,0,10,'ca73fc4c-a6fd-4986-a333-c9aca9c59d8a',0,'2026-07-19 11:46:04','2026-07-19 11:46:04',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `sys_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_job`
--

DROP TABLE IF EXISTS `task_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_job` (
  `job_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务ID',
  `job_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '任务名称',
  `trigger_type` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '触发方式: cron/interval/date/manual',
  `next_run_time` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '下次执行时间',
  `job_state` text COLLATE utf8mb4_unicode_ci COMMENT '任务状态信息',
  `result` text COLLATE utf8mb4_unicode_ci COMMENT '执行结果',
  `error` text COLLATE utf8mb4_unicode_ci COMMENT '错误信息',
  `status` int NOT NULL COMMENT '执行状态(0:待执行 1:执行中 2:成功 3:失败 4:超时 5:已取消)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_task_job_uuid` (`uuid`),
  KEY `ix_task_job_status` (`status`),
  KEY `ix_task_job_job_id` (`job_id`),
  KEY `ix_task_job_created_time` (`created_time`),
  KEY `ix_task_job_updated_time` (`updated_time`),
  KEY `ix_task_job_id` (`id`),
  KEY `ix_task_job_deleted_time` (`deleted_time`),
  KEY `ix_task_job_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_task_job_is_deleted` (`is_deleted`),
  KEY `ix_task_job_status_deleted` (`status`,`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_job`
--

LOCK TABLES `task_job` WRITE;
/*!40000 ALTER TABLE `task_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_node`
--

DROP TABLE IF EXISTS `task_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_node` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '节点名称',
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '节点编码',
  `jobstore` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '存储器',
  `executor` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '执行器',
  `trigger` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '触发器',
  `trigger_args` text COLLATE utf8mb4_unicode_ci COMMENT '触发器参数',
  `func` text COLLATE utf8mb4_unicode_ci COMMENT '代码块',
  `args` text COLLATE utf8mb4_unicode_ci COMMENT '位置参数',
  `kwargs` text COLLATE utf8mb4_unicode_ci COMMENT '关键字参数',
  `coalesce` tinyint(1) DEFAULT NULL COMMENT '是否合并运行',
  `max_instances` int DEFAULT NULL COMMENT '最大实例数',
  `start_date` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开始时间',
  `end_date` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '结束时间',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `ix_task_node_uuid` (`uuid`),
  KEY `ix_task_node_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_task_node_id` (`id`),
  KEY `ix_task_node_updated_time` (`updated_time`),
  KEY `ix_task_node_status_deleted` (`status`,`is_deleted`),
  KEY `ix_task_node_updated_id` (`updated_id`),
  KEY `ix_task_node_deleted_time` (`deleted_time`),
  KEY `ix_task_node_is_deleted` (`is_deleted`),
  KEY `ix_task_node_status` (`status`),
  KEY `ix_task_node_created_id` (`created_id`),
  KEY `ix_task_node_created_time` (`created_time`),
  KEY `ix_task_node_deleted_id` (`deleted_id`),
  CONSTRAINT `task_node_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `task_node_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `task_node_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_node`
--

LOCK TABLES `task_node` WRITE;
/*!40000 ALTER TABLE `task_node` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_node` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_workflow`
--

DROP TABLE IF EXISTS `task_workflow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_workflow` (
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流程名称',
  `code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流程编码',
  `nodes` json DEFAULT NULL COMMENT 'VueFlow节点',
  `edges` json DEFAULT NULL COMMENT 'VueFlow连接线',
  `status` int NOT NULL COMMENT '状态(0:草稿 1:已发布 2:已归档)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `ix_task_workflow_uuid` (`uuid`),
  KEY `ix_task_workflow_updated_time` (`updated_time`),
  KEY `ix_task_workflow_updated_id` (`updated_id`),
  KEY `ix_task_workflow_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_task_workflow_deleted_time` (`deleted_time`),
  KEY `ix_task_workflow_is_deleted` (`is_deleted`),
  KEY `ix_task_workflow_status` (`status`),
  KEY `ix_task_workflow_created_id` (`created_id`),
  KEY `ix_task_workflow_created_time` (`created_time`),
  KEY `ix_task_workflow_deleted_id` (`deleted_id`),
  KEY `ix_task_workflow_status_deleted` (`status`,`is_deleted`),
  KEY `ix_task_workflow_id` (`id`),
  CONSTRAINT `task_workflow_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `task_workflow_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `task_workflow_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_workflow`
--

LOCK TABLES `task_workflow` WRITE;
/*!40000 ALTER TABLE `task_workflow` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_workflow` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_workflow_node_type`
--

DROP TABLE IF EXISTS `task_workflow_node_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_workflow_node_type` (
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '显示名称',
  `code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '节点编码，对应画布 node.type',
  `category` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类: trigger/action/condition/control',
  `func` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Python 代码块，须定义 handler(*args,**kwargs)',
  `args` text COLLATE utf8mb4_unicode_ci COMMENT '默认位置参数，逗号分隔',
  `kwargs` text COLLATE utf8mb4_unicode_ci COMMENT '默认关键字参数 JSON',
  `sort_order` int NOT NULL COMMENT '排序',
  `is_active` tinyint(1) NOT NULL COMMENT '是否启用',
  `status` int NOT NULL COMMENT '状态(0:启动 1:停用)',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `uuid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID全局唯一标识',
  `is_deleted` tinyint(1) NOT NULL COMMENT '是否已删除(0:未删除 1:已删除)',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  `deleted_time` datetime DEFAULT NULL COMMENT '删除时间',
  `created_id` int DEFAULT NULL COMMENT '创建人ID',
  `updated_id` int DEFAULT NULL COMMENT '更新人ID',
  `deleted_id` int DEFAULT NULL COMMENT '删除人ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `ix_task_workflow_node_type_uuid` (`uuid`),
  KEY `ix_task_workflow_node_type_deleted_id` (`deleted_id`),
  KEY `ix_task_workflow_node_type_status` (`status`),
  KEY `ix_task_workflow_node_type_is_deleted` (`is_deleted`),
  KEY `ix_task_workflow_node_type_deleted_time` (`deleted_time`),
  KEY `ix_task_workflow_node_type_updated_id` (`updated_id`),
  KEY `ix_task_workflow_node_type_created_time` (`created_time`),
  KEY `ix_task_workflow_node_type_id` (`id`),
  KEY `ix_task_workflow_node_type_status_deleted` (`status`,`is_deleted`),
  KEY `ix_task_workflow_node_type_created_id` (`created_id`),
  KEY `ix_task_workflow_node_type_created_deleted` (`created_time`,`is_deleted`),
  KEY `ix_task_workflow_node_type_updated_time` (`updated_time`),
  CONSTRAINT `task_workflow_node_type_ibfk_1` FOREIGN KEY (`created_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `task_workflow_node_type_ibfk_2` FOREIGN KEY (`updated_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `task_workflow_node_type_ibfk_3` FOREIGN KEY (`deleted_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_workflow_node_type`
--

LOCK TABLES `task_workflow_node_type` WRITE;
/*!40000 ALTER TABLE `task_workflow_node_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_workflow_node_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-19 11:46:57
