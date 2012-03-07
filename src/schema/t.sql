CREATE TABLE balance (
  id mediumint(12) NOT NULL auto_increment,
  username varchar(45) NOT NULL default '',
  balance decimal(8,2) default NULL,
  PRIMARY KEY  (id,username)
) TYPE=MyISAM;
CREATE TABLE clients (
  id smallint(9) NOT NULL auto_increment,
  username varchar(45) default NULL,
  last_update datetime default NULL,
  status varchar(7) default NULL,
  home_phone varchar(14) default NULL,
  work_phone varchar(14) default NULL,
  fax_phone varchar(14) default NULL,
  tax_exempt char(1) default NULL,
  comment varchar(255) default NULL,
  billing_company_name varchar(45) default NULL,
  billing_first_name varchar(20) default NULL,
  billing_last_name varchar(40) default NULL,
  billing_address1 varchar(45) default NULL,
  billing_address2 varchar(45) default NULL,
  billing_town varchar(40) default NULL,
  billing_province varchar(25) default NULL,
  billing_postal_code varchar(20) default NULL,
  billing_email_address varchar(60) default NULL,
  shipping_company_name varchar(45) default NULL,
  shipping_first_name varchar(20) default NULL,
  shipping_last_name varchar(40) default NULL,
  shipping_address1 varchar(45) default NULL,
  shipping_address2 varchar(45) default NULL,
  shipping_town varchar(40) default NULL,
  shipping_province varchar(25) default NULL,
  shipping_postal_code varchar(20) default NULL,
  shipping_email_address varchar(60) default NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY `username` (`username`)
) TYPE=MyISAM;
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
CREATE TABLE inv_num (
  id mediumint(12) NOT NULL auto_increment,
  inv_num mediumint(12) default NULL,
  PRIMARY KEY  (id)
) TYPE=MyISAM;
CREATE TABLE notes (
  id mediumint(12) NOT NULL auto_increment,
  username varchar(45) NOT NULL default '',
  note MEDIUMTEXT default NULL,
  tag varchar(16) default NULL,
  operator varchar(16) default NULL,
  date DATETIME default NULL,
  PRIMARY KEY  (id,username)
) TYPE=MyISAM;
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
CREATE TABLE plans (
  id mediumint(12) NOT NULL auto_increment,
  plan_status varchar(7) default NULL,
  username varchar(45) NOT NULL default '',
  login_name varchar(45) default NULL,
  password varchar(20) default NULL,
  server varchar(60) NOT NULL default '',
  email varchar(60) default NULL,
  dob varchar(12) default NULL,
  last_update date default NULL,
  plan varchar(15) default NULL,
  description varchar(60) default NULL,
  rate decimal(6,2) default NULL,
  hours smallint(6) default NULL,
  over_rate decimal(6,2) default NULL,
  billing_period varchar(9) default NULL,
  expires date default NULL,
  started date default NULL,
  pap_date tinyint(4) default NULL,
  next_billing_date date default NULL,
  pap_method varchar(25) default NULL,
  billing_method varchar(22) default NULL,
  os varchar(8) default NULL,
  dsl_number varchar(13),  
  comment varchar(255) default NULL,
  hours_balance decimal(7,2) not null default 0,
  classification varchar(24) default NULL,
  PRIMARY KEY  (id,username)
) TYPE=MyISAM;
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
CREATE TABLE bank (
  id mediumint(12) NOT NULL auto_increment,
  invoice_number mediumint(16) default NULL,
  record text default NULL,
	PRIMARY KEY  (id)
) TYPE=MyISAM;
