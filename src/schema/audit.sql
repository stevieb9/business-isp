CREATE TABLE audit (
  id mediumint(12) NOT NULL auto_increment,
  process varchar(45) NOT NULL default '',
  date date default NULL,
  type varchar(16) default NULL,
  schedule varchar(20) default NULL,
  operator varchar(20) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;
