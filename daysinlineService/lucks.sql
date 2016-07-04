CREATE TABLE IF NOT EXISTS luckInfo(
  luck_id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(64)CHARACTER SET utf8 Default NULL,
  start_date varchar(64)CHARACTER SET utf8 Default NULL,
  end_date varchar(64)CHARACTER SET utf8 Default NULL,
  week varchar(64) CHARACTER SET utf8 Default NULL,
  life varchar(1024) CHARACTER SET utf8 Default NULL,
  work varchar(1024) CHARACTER SET utf8 Default NULL,
  PRIMARY KEY (luck_id)
);

