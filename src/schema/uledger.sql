drop table uledger;
CREATE TABLE uledger (
  id mediumint(12) NOT NULL auto_increment,
  username varchar(45) NOT NULL default '',
  amount decimal(6,2) default NULL,
  payment varchar(40) default NULL,
  comment varchar(255) default NULL,
  date datetime default NULL,
  invoice_number INTEGER(12),
  PRIMARY KEY  (id,username)
) TYPE=MyISAM;
