CREATE TABLE operators (
  opid smallint(9) NOT NULL auto_increment,
  operator varchar(16) default NULL,
  password varchar(16) default NULL,
  opgroup varchar(16) default NULL,
  name varchar(45) default NULL,
  comment varchar(255) default NULL,
  email_address varchar(60) default NULL,
  rank smallint(3) default NULL,
  PRIMARY KEY  (opid),
  UNIQUE KEY `operator` (`operator`)
) TYPE=MyISAM;
