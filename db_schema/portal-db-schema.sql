DROP DATABASE IF EXISTS falcon_portal;
CREATE DATABASE falcon_portal
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;
USE falcon_portal;
SET NAMES utf8;

/**
 * 这里的机器是从机器管理系统中同步过来的
 * 系统拿出来单独部署需要为hbs增加功能，心跳上来的机器写入host表
 */
DROP TABLE IF EXISTS host;
CREATE TABLE host
(
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  hostname       VARCHAR(255) NOT NULL DEFAULT '',
  ip             VARCHAR(16)  NOT NULL DEFAULT '',
  agent_version  VARCHAR(16)  NOT NULL DEFAULT '',
  plugin_version VARCHAR(128) NOT NULL DEFAULT '',
  maintain_begin INT UNSIGNED NOT NULL DEFAULT 0,
  maintain_end   INT UNSIGNED NOT NULL DEFAULT 0,
  update_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_host_hostname (hostname)
) ENGINE =InnoDB;

/**
 * 机器分组信息
 * come_from 0: 从机器管理同步过来的；1: 从页面创建的
 */
DROP TABLE IF EXISTS grp;
CREATE TABLE `grp` (
  id          INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  grp_name    VARCHAR(255)     NOT NULL DEFAULT '',
  create_user VARCHAR(64)      NOT NULL DEFAULT '',
  create_at   TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  come_from   TINYINT(4)       NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE KEY idx_host_grp_grp_name (grp_name)
) ENGINE =InnoDB;

--
-- Dumping data for table `grp`
--

LOCK TABLES `grp` WRITE;
/*!40000 ALTER TABLE `grp` DISABLE KEYS */;
INSERT INTO `grp` VALUES (1,'cluster','root','2016-08-04 09:51:27',1);
/*!40000 ALTER TABLE `grp` ENABLE KEYS */;
UNLOCK TABLES;


DROP TABLE IF EXISTS grp_host;
CREATE TABLE grp_host
(
  grp_id  INT UNSIGNED NOT NULL,
  host_id INT UNSIGNED NOT NULL,
  KEY idx_grp_host_grp_id (grp_id),
  KEY idx_grp_host_host_id (host_id)
) ENGINE =InnoDB;

/**
 * 监控策略模板
 * tpl_name全局唯一，命名的时候可以适当带上一些前缀，比如：sa.falcon.base
 */
DROP TABLE IF EXISTS tpl;
CREATE TABLE tpl
(
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tpl_name    VARCHAR(255) NOT NULL DEFAULT '',
  parent_id   INT UNSIGNED NOT NULL DEFAULT 0,
  action_id   INT UNSIGNED NOT NULL DEFAULT 0,
  create_user VARCHAR(64)  NOT NULL DEFAULT '',
  create_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_tpl_name (tpl_name),
  KEY idx_tpl_create_user (create_user)
) ENGINE =InnoDB;


/*创建alarm模板*/
LOCK TABLES `tpl` WRITE;
INSERT INTO `tpl` VALUES (1,'alarm',0,1,'root','2016-08-04 09:51:27');
UNLOCK TABLES;

DROP TABLE IF EXISTS strategy;
CREATE TABLE `strategy` (
  `id`          INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `metric`      VARCHAR(128)     NOT NULL DEFAULT '',
  `tags`        VARCHAR(256)     NOT NULL DEFAULT '',
  `max_step`    INT(11)          NOT NULL DEFAULT '1',
  `priority`    TINYINT(4)       NOT NULL DEFAULT '0',
  `func`        VARCHAR(16)      NOT NULL DEFAULT 'all(#1)',
  `op`          VARCHAR(8)       NOT NULL DEFAULT '',
  `right_value` VARCHAR(64)      NOT NULL,
  `note`        VARCHAR(128)     NOT NULL DEFAULT '',
  `run_begin`   VARCHAR(16)      NOT NULL DEFAULT '',
  `run_end`     VARCHAR(16)      NOT NULL DEFAULT '',
  `tpl_id`      INT(10) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_strategy_tpl_id` (`tpl_id`)
) ENGINE =InnoDB;


/*为模板创建策略*/
ProcessCallTime99thpercentile
LOCK TABLES `strategy` WRITE;
INSERT INTO `strategy` VALUES
(1,'HeapMemoryUsagePercent','service=DataNode',3,0,'all(#3)','>=','0.8','','','',1),
(2,'HeapMemoryUsagePercent','service=NameNode',3,0,'all(#3)','>=','0.8','','','',1),
(3,'HeapMemoryUsagePercent','service=HMaster',3,0,'all(#3)','>=','0.8','','','',1),
(4,'HeapMemoryUsagePercent','service=NodeManager',3,0,'all(#3)','>=','0.8','','','',1),
(5,'HeapMemoryUsagePercent','service=ResourceManager',3,0,'all(#3)','>=','0.8','','','',1),
(6,'HeapMemoryUsagePercent','service=HRegionServer',3,0,'all(#3)','>=','0.8','','','',1),
(7,'RpcProcessingTimeAvgTime','service=NameNode',3,0,'all(#3)','>=','5','','','',1),
(8,'RpcProcessingTimeAvgTime','service=DataNode',3,0,'all(#3)','>=','5','','','',1),
(9,'ProcessCallTime_99th_percentile','service=HMaster',3,0,'all(#3)','>=','5','','','',1),
(10,'ProcessCallTime_99th_percentile','service=HRegionServer',3,0,'all(#3)','>=','500','','','',1),
(11,'CapacityPercent','service=NameNode',3,0,'all(#3)','>=','0.8','','','',1),
(12,'FSState','service=NameNode',3,0,'all(#3)','!=','1','','','',1),
(13,'WriteBlockOpAvgTime','service=DataNode',3,0,'all(#3)','>=','5000','','','',1),
(14,'DfsPercent','service=DataNode',3,0,'all(#3)','>=','0.8','','','',1);
UNLOCK TABLES;

DROP TABLE IF EXISTS expression;
CREATE TABLE `expression` (
  `id`          INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `expression`  VARCHAR(1024)    NOT NULL,
  `func`        VARCHAR(16)      NOT NULL DEFAULT 'all(#1)',
  `op`          VARCHAR(8)       NOT NULL DEFAULT '',
  `right_value` VARCHAR(16)      NOT NULL DEFAULT '',
  `max_step`    INT(11)          NOT NULL DEFAULT '1',
  `priority`    TINYINT(4)       NOT NULL DEFAULT '0',
  `note`        VARCHAR(1024)    NOT NULL DEFAULT '',
  `action_id`   INT(10) UNSIGNED NOT NULL DEFAULT '0',
  `create_user` VARCHAR(64)      NOT NULL DEFAULT '',
  `pause`       TINYINT(1)       NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE =InnoDB;



DROP TABLE IF EXISTS grp_tpl;
CREATE TABLE `grp_tpl` (
  `grp_id`    INT(10) UNSIGNED NOT NULL,
  `tpl_id`    INT(10) UNSIGNED NOT NULL,
  `bind_user` VARCHAR(64)      NOT NULL DEFAULT '',
  KEY `idx_grp_tpl_grp_id` (`grp_id`),
  KEY `idx_grp_tpl_tpl_id` (`tpl_id`)
) ENGINE =InnoDB;


/*将模板与组绑定*/
LOCK TABLES `grp_tpl` WRITE;
INSERT INTO `grp_tpl` VALUES(1,1,'root');
UNLOCK TABLES;

CREATE TABLE `plugin_dir` (
  `id`          INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `grp_id`      INT(10) UNSIGNED NOT NULL,
  `dir`         VARCHAR(255)     NOT NULL,
  `create_user` VARCHAR(64)      NOT NULL DEFAULT '',
  `create_at`   TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_plugin_dir_grp_id` (`grp_id`)
) ENGINE =InnoDB;

--
-- Dumping data for table `plugin_dir`
--

LOCK TABLES `plugin_dir` WRITE;
/*!40000 ALTER TABLE `plugin_dir` DISABLE KEYS */;
INSERT INTO `plugin_dir` VALUES (1,1,'enable','root','2016-08-04 09:57:53');
/*!40000 ALTER TABLE `plugin_dir` ENABLE KEYS */;
UNLOCK TABLES;


DROP TABLE IF EXISTS action;
CREATE TABLE `action` (
  `id`                   INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `uic`                  VARCHAR(255)     NOT NULL DEFAULT '',
  `url`                  VARCHAR(255)     NOT NULL DEFAULT '',
  `callback`             TINYINT(4)       NOT NULL DEFAULT '0',
  `before_callback_sms`  TINYINT(4)       NOT NULL DEFAULT '0',
  `before_callback_mail` TINYINT(4)       NOT NULL DEFAULT '0',
  `after_callback_sms`   TINYINT(4)       NOT NULL DEFAULT '0',
  `after_callback_mail`  TINYINT(4)       NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE =InnoDB;

/*为模板配置警告接受组*/
LOCK TABLES `action` WRITE;
INSERT INTO `action` VALUES (1,'root_team','',0,0,0,0,0);
UNLOCK TABLES;

/**
 * nodata mock config
 */
DROP TABLE IF EXISTS `mockcfg`;
CREATE TABLE `mockcfg` (
  `id`       BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`     VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'name of mockcfg, used for uuid',
  `obj`      VARCHAR(10240) NOT NULL DEFAULT '' COMMENT 'desc of object',
  `obj_type` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'type of object, host or group or other',
  `metric`   VARCHAR(128) NOT NULL DEFAULT '',
  `tags`     VARCHAR(1024) NOT NULL DEFAULT '',
  `dstype`   VARCHAR(32)  NOT NULL DEFAULT 'GAUGE',
  `step`     INT(11) UNSIGNED  NOT NULL DEFAULT 60,
  `mock`     DOUBLE  NOT NULL DEFAULT 0  COMMENT 'mocked value when nodata occurs',
  `creator`  VARCHAR(64)  NOT NULL DEFAULT '',
  `t_create` DATETIME NOT NULL COMMENT 'create time',
  `t_modify` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'last modify time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_name` (`name`)
) ENGINE =InnoDB;

/**
 *  aggregator cluster metric config table
 */
DROP TABLE IF EXISTS `cluster`;
CREATE TABLE `cluster` (
  `id`          INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `grp_id`      INT            NOT NULL,
  `numerator`   VARCHAR(10240) NOT NULL,
  `denominator` VARCHAR(10240) NOT NULL,
  `endpoint`    VARCHAR(255)   NOT NULL,
  `metric`      VARCHAR(255)   NOT NULL,
  `tags`        VARCHAR(255)   NOT NULL,
  `ds_type`     VARCHAR(255)   NOT NULL,
  `step`        INT            NOT NULL,
  `last_update` TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `creator`     VARCHAR(255)   NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE =InnoDB;

--
-- Dumping data for table `cluster`
--

LOCK TABLES `cluster` WRITE;
/*!40000 ALTER TABLE `cluster` DISABLE KEYS */;
INSERT INTO `cluster` VALUES
(1,1,'$(cpu.busy)','$#','cluster','cpu.busy.avg.cluster','','GAUGE',60,'2016-08-04 09:55:15','root'),
(2,1,'$(mem.memused)','$#','cluster','mem.memused.avg.cluster','','GAUGE',60,'2016-08-04 09:55:45','root'),
(3,1,'$(mem.memtotal)','$#','cluster','mem.memtotal.cluster','','GAUGE',60,'2016-08-04 09:56:25','root'),
(4,1,'$(net.if.in.bytes)','$#','cluster','net.if.in.bytes.avg.cluster','','GAUGE',60,'2016-08-04 09:56:55','root'),
(5,1,'$(net.if.out.bytes)','$#','cluster','net.if.out.bytes.avg.cluster','','GAUGE',60,'2016-08-04 09:58:21','root');
/*!40000 ALTER TABLE `cluster` ENABLE KEYS */;
UNLOCK TABLES;
