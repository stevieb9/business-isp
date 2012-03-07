CREATE TABLE bank (
  id mediumint(12) NOT NULL auto_increment,
  invoice_number mediumint(16) default NULL,
  record text default NULL,
	PRIMARY KEY  (id)
) TYPE=MyISAM;
