CREATE TABLE IF NOT EXISTS backupinfo (
  backup_id int(16) NOT NULL AUTO_INCREMENT,
  backup_user varchar(128) CHARACTER SET utf8 NOT NULL,
  backup_device varchar(128) CHARACTER SET utf8,
  backup_day datetime NOT NULL,
  PRIMARY KEY (backup_id),
  UNIQUE KEY (backup_user)

);

