## (C) Copyright IBM Corporation 2015.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

# Each SQL statement in this file should terminate with a semicolon (;)
# Lines starting with the pound character (#) are considered as comments
DROP TABLE HOLDINGEJB;
DROP TABLE ACCOUNTPROFILEEJB;
DROP TABLE QUOTEEJB;
DROP TABLE KEYGENEJB;
DROP TABLE ACCOUNTEJB;
DROP TABLE ORDEREJB;

CREATE TABLE HOLDINGEJB
  (PURCHASEPRICE DECIMAL(14, 2),
   HOLDINGID INTEGER NOT NULL,
   QUANTITY DOUBLE NOT NULL,
   PURCHASEDATE TIMESTAMP,
   ACCOUNT_ACCOUNTID INTEGER,
   QUOTE_SYMBOL VARCHAR(250));

ALTER TABLE HOLDINGEJB
  ADD CONSTRAINT PK_HOLDINGEJB PRIMARY KEY (HOLDINGID);

CREATE TABLE ACCOUNTPROFILEEJB
  (ADDRESS VARCHAR(250),
   PASSWD VARCHAR(250),
   USERID VARCHAR(250) NOT NULL,
   EMAIL VARCHAR(250),
   CREDITCARD VARCHAR(250),
   FULLNAME VARCHAR(250));

ALTER TABLE ACCOUNTPROFILEEJB
  ADD CONSTRAINT PK_ACCOUNTPROFILE2 PRIMARY KEY (USERID);

CREATE TABLE QUOTEEJB
  (LOW DECIMAL(14, 2),
   OPEN1 DECIMAL(14, 2),
   VOLUME DOUBLE NOT NULL,
   PRICE DECIMAL(14, 2),
   HIGH DECIMAL(14, 2),
   COMPANYNAME VARCHAR(250),
   SYMBOL VARCHAR(250) NOT NULL,
   CHANGE1 DOUBLE NOT NULL);

ALTER TABLE QUOTEEJB
  ADD CONSTRAINT PK_QUOTEEJB PRIMARY KEY (SYMBOL);

CREATE TABLE KEYGENEJB
  (KEYVAL INTEGER NOT NULL,
   KEYNAME VARCHAR(250) NOT NULL);

ALTER TABLE KEYGENEJB
  ADD CONSTRAINT PK_KEYGENEJB PRIMARY KEY (KEYNAME);
  
INSERT INTO KEYGENEJB (KEYNAME,KEYVAL) VALUES ('account', 0);
INSERT INTO KEYGENEJB (KEYNAME,KEYVAL) VALUES ('holding', 0);
INSERT INTO KEYGENEJB (KEYNAME,KEYVAL) VALUES ('order', 0);

CREATE TABLE ACCOUNTEJB
  (CREATIONDATE TIMESTAMP,
   OPENBALANCE DECIMAL(14, 2),
   LOGOUTCOUNT INTEGER NOT NULL,
   BALANCE DECIMAL(14, 2),
   ACCOUNTID INTEGER NOT NULL,
   LASTLOGIN TIMESTAMP,
   LOGINCOUNT INTEGER NOT NULL,
   PROFILE_USERID VARCHAR(250));

ALTER TABLE ACCOUNTEJB
  ADD CONSTRAINT PK_ACCOUNTEJB PRIMARY KEY (ACCOUNTID);

CREATE TABLE ORDEREJB
  (ORDERFEE DECIMAL(14, 2),
   COMPLETIONDATE TIMESTAMP,
   ORDERTYPE VARCHAR(250),
   ORDERSTATUS VARCHAR(250),
   PRICE DECIMAL(14, 2),
   QUANTITY DOUBLE NOT NULL,
   OPENDATE TIMESTAMP,
   ORDERID INTEGER NOT NULL,
   ACCOUNT_ACCOUNTID INTEGER,
   QUOTE_SYMBOL VARCHAR(250),
   HOLDING_HOLDINGID INTEGER);

CREATE TABLE OUTBOXEVENT
  (ID VARCHAR(250),
   AGGREGATETYPE VARCHAR(255),
   AGGREGATEID VARCHAR(255),
   TYPE VARCHAR(255),
   PAYLOAD VARCHAR(32672));

ALTER TABLE ORDEREJB
  ADD CONSTRAINT PK_ORDEREJB PRIMARY KEY (ORDERID);

CREATE INDEX ACCOUNT_USERID ON ACCOUNTEJB(PROFILE_USERID);
CREATE INDEX HOLDING_ACCOUNTID ON HOLDINGEJB(ACCOUNT_ACCOUNTID);
CREATE INDEX ORDER_ACCOUNTID ON ORDEREJB(ACCOUNT_ACCOUNTID);
CREATE INDEX ORDER_HOLDINGID ON ORDEREJB(HOLDING_HOLDINGID);
CREATE INDEX CLOSED_ORDERS ON ORDEREJB(ACCOUNT_ACCOUNTID,ORDERSTATUS);

