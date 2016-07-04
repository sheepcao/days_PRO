CREATE TABLE IF NOT EXISTS userinfo (
  id int(11) NOT NULL AUTO_INCREMENT,
  unique_id varchar(64) CHARACTER SET utf8 NOT NULL,
  password varchar(64) CHARACTER SET utf8 NOT NULL,
  created_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY (unique_id)
);

