CREATE database database1;
USE database1;
CREATE TABLE example(
id INT NOT NULL AUTO_INCREMENT, 
PRIMARY KEY(id),
 name VARCHAR(30), 
 age INT);
INSERT INTO example (name,age) VALUES ('flanders',25);
INSERT INTO example (name,age) VALUES ('homero',40);
INSERT INTO example (name,age) VALUES ('bart',18);
INSERT INTO example (name,age) VALUES ('lisa',15);


GRANT ALL PRIVILEGES ON *.* to 'icesi' @ '192.168.131.57' IDENTIFIED by '12345';
GRANT ALL PRIVILEGES ON *.* to 'icesi' @ '192.168.131.58' IDENTIFIED by '12345';

