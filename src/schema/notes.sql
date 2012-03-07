CREATE TABLE notes (
  id mediumint(12) NOT NULL auto_increment,
  username varchar(45) NOT NULL default '',
  note MEDIUMTEXT default NULL,
  tag varchar(16) default NULL,
  operator varchar(16) default NULL,
  date DATETIME default NULL,
  PRIMARY KEY  (id,username)
) TYPE=MyISAM;
