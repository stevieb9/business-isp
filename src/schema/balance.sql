CREATE TABLE balance (
  id mediumint(12) NOT NULL auto_increment,
  username varchar(45) NOT NULL default '',
  balance decimal(8,2) default NULL,
  PRIMARY KEY  (id,username)
) TYPE=MyISAM;
