DROP TABLE gledger;
CREATE TABLE gledger (
  id mediumint(12) NOT NULL auto_increment,
  username varchar(45) NOT NULL default '',
  amount decimal(6,2) default NULL,
  payment decimal(6,2) default NULL,
  quantity smallint(6) default NULL,
  payment_method varchar(40) default NULL,
  comment varchar(255) default NULL,
  invoice_number mediumint(16) default NULL,
  item_name varchar(60) default NULL,
  total_price decimal(6,2) default NULL,
  date datetime default NULL,
  PRIMARY KEY  (id,username)
) TYPE=MyISAM;
